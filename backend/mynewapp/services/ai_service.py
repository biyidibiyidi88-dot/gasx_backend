"""Forecast gas time left from measured use, with an optional AI rate estimate."""
import hashlib
import json
import logging
import math
import re
from datetime import timedelta

from django.conf import settings
from django.core.cache import cache
from django.utils import timezone

from .gemini_service import GeminiService

logger = logging.getLogger(__name__)


class AIPredictionService:
    DEFAULT_BOTTLE_CAPACITY = 12.5
    MIN_HISTORY_DAYS = 1 / 24  # An hour supports an early, low-confidence estimate.

    @classmethod
    def build_history(cls, hourly_readings, bottle_capacity):
        """Use hourly averages so rapid uploads do not hide older consumption."""
        history = {}
        previous_time = None
        anchor = None
        refill_jump = max(0.25, float(bottle_capacity) * 0.05)
        for row in hourly_readings:
            at = row['first_at'] + (row['last_at'] - row['first_at']) / 2
            remaining = float(row['remaining_kg'])
            if not math.isfinite(remaining) or not 0 <= remaining <= bottle_capacity:
                previous_time = anchor = None
                continue
            if previous_time is None:
                previous_time, anchor = at, remaining
                continue
            elapsed = (at - previous_time).total_seconds() / 86400
            previous_time = at
            if elapsed <= 0:
                continue
            drop = anchor - remaining
            # Skip refills, long offline gaps, and sudden scale/calibration jumps.
            if elapsed > 2 or drop < -refill_jump or drop / elapsed > bottle_capacity * 2:
                anchor = remaining
                continue
            # Keep the previous low point through small fluctuations. Counting
            # every downward twitch would invent consumption on a steady scale.
            consumed = drop if drop >= 0.02 - 1e-9 else 0.0
            if consumed:
                anchor = remaining
            day = at.date().isoformat()
            item = history.setdefault(day, {
                'date': day, 'consumed_kg': 0.0, 'elapsed_days': 0.0,
                'is_weekend': at.weekday() >= 5,
            })
            item['consumed_kg'] += consumed
            item['elapsed_days'] += elapsed
        return [dict(item, consumption_kg=item['consumed_kg'] / item['elapsed_days'])
                for item in history.values()]

    @staticmethod
    def _calculate_metrics(history_data):
        valid = []
        for day in history_data:
            rate = float(day['consumption_kg'])
            duration = float(day.get('elapsed_days', 1))
            if math.isfinite(rate) and math.isfinite(duration) and rate >= 0 and duration > 0:
                valid.append((day, rate, duration))

        def average(rows):
            duration = sum(row[2] for row in rows)
            return sum(rate * elapsed for _, rate, elapsed in rows) / duration if duration else 0.0

        return {
            'avg_daily': average(valid),
            'recent_avg': average(valid[-3:]),
            'weekday_avg': average([row for row in valid if not row[0]['is_weekend']]),
            'weekend_avg': average([row for row in valid if row[0]['is_weekend']]),
            'observed_days': sum(row[2] for row in valid),
        }

    @classmethod
    def _ai_rate(cls, metrics, baseline, cache_scope):
        """Cache the rate, not days left: fresh weight still updates the forecast."""
        if not getattr(settings, 'GEMINI_API_KEY', ''):
            return baseline, 'usage'
        model = getattr(settings, 'GEMINI_MODEL', 'gemini-3.5-flash-lite')
        if not model:
            return baseline, 'usage'
        signature = json.dumps([cache_scope, model, metrics], sort_keys=True)
        key = 'gas-forecast-rate-v2:' + hashlib.sha256(signature.encode()).hexdigest()
        saved = cache.get(key)
        if saved is not None:
            return saved
        result = (baseline, 'usage')
        timeout = 60  # Retry unavailable AI later, without holding up every refresh.
        try:
            content = GeminiService.generate_json(
                system_instruction=(
                    'Estimate the daily LPG consumption rate from measured usage. '
                    'Account for recent changes and weekday/weekend use. '
                    'Do not invent extra measurements. Return a JSON object with '
                    'daily_consumption_kg as a single positive number. '
                    'Keep the rate between half and twice the supplied baseline.'
                ),
                prompt=json.dumps(dict(metrics, baseline_kg_per_day=baseline)),
                max_output_tokens=180,
            )
            match = re.search(r'\{.*\}', content, re.DOTALL)
            payload = json.loads(match.group() if match else content)
            value = payload['daily_consumption_kg']
            if isinstance(value, bool):
                raise ValueError('Boolean consumption rate')
            rate = float(value)
            if not math.isfinite(rate) or not baseline * 0.5 <= rate <= baseline * 2:
                raise ValueError('Forecast rate outside measured range')
            result = (rate, 'ai')
            timeout = 600
        except Exception as exc:
            logger.warning('Gas forecast using measured consumption: %s', type(exc).__name__)
        cache.set(key, result, timeout=timeout)
        return result

    @classmethod
    def predict_days_remaining(cls, history_data, current_remaining_kg=None,
                               bottle_capacity=None, *, cache_scope='', ai_enabled=True,
                               observed_at=None):
        capacity = float(bottle_capacity or cls.DEFAULT_BOTTLE_CAPACITY)
        remaining = None if current_remaining_kg is None else float(current_remaining_kg)
        result = {
            'projected_days': 0.0, 'projected_hours': 0.0,
            'expected_depletion_date': None, 'confidence': 0.0,
            'trend': 'collecting', 'prediction_source': 'collecting',
            'remaining_kg': remaining, 'daily_consumption_kg': 0.0,
            'recommendation': 'Keep the sensor on while you use gas. At least one hour of measured use is needed for an early estimate.',
            'calculation': 'Waiting for enough measured gas use.',
        }
        if remaining is None or not math.isfinite(remaining):
            return result
        remaining = min(capacity, max(0.0, remaining))
        result['remaining_kg'] = remaining
        if remaining == 0:
            return dict(result, trend='empty', prediction_source='reading', confidence=1.0,
                        expected_depletion_date=(observed_at or timezone.now()).isoformat(),
                        recommendation='No gas remains in this bottle. Arrange a refill.',
                        calculation='The latest reading shows 0 kg of gas.')
        metrics = cls._calculate_metrics(history_data)
        if metrics['observed_days'] < cls.MIN_HISTORY_DAYS:
            return result
        if metrics['avg_daily'] <= 0:
            return dict(result, recommendation='No steady gas use has been measured yet. The estimate will appear after you use some gas.')

        rate = metrics['avg_daily']
        if metrics['observed_days'] >= 3:
            rate = 0.7 * metrics['recent_avg'] + 0.3 * rate
        source = 'usage'
        if ai_enabled:
            rate, source = cls._ai_rate(metrics, rate, cache_scope)
        days = remaining / rate
        recent_ratio = metrics['recent_avg'] / metrics['avg_daily']
        trend = 'increasing' if recent_ratio > 1.15 else 'decreasing' if recent_ratio < 0.85 else 'stable'
        recommendation = ('AI estimate based on your measured gas use.' if source == 'ai'
                          else 'Estimate based on your measured gas use.')
        if metrics['observed_days'] < 1:
            recommendation += ' This is an early estimate; a full day of readings will improve it.'
        elif days < 2:
            recommendation += ' Plan a refill soon.'
        else:
            recommendation += ' The time will change if you use more or less gas.'
        return dict(
            result, projected_days=round(days, 4), projected_hours=round(days * 24, 2),
            expected_depletion_date=((observed_at or timezone.now()) + timedelta(days=days)).isoformat(),
            confidence=round(min(0.85, 0.3 + metrics['observed_days'] / 14 * 0.55), 2),
            trend=trend, prediction_source=source, daily_consumption_kg=round(rate, 4),
            recommendation=recommendation,
            calculation=f'{remaining:.2f} kg / {rate:.4f} kg per day = {days:.2f} days',
        )
