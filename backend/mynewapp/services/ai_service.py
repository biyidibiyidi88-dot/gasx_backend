import requests
import json
import re
import time
from django.core.exceptions import ImproperlyConfigured
import logging
from requests.exceptions import RequestException
from datetime import datetime, timedelta
from django.utils import timezone

# Configure logging
logger = logging.getLogger(__name__)

class AIPredictionService:
    API_URL = "https://openrouter.ai/api/v1/chat/completions"
    API_KEY = "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"
    BOTTLE_CAPACITY = 20  # kg

    # Available models with fallback order
    MODEL_PRIORITY = [
        "anthropic/claude-3-haiku",
        "mistralai/mistral-7b-instruct:free"
    ]

    @classmethod
    def _debug_log(cls, message, level='debug'):
        """Centralized debug logging with level support"""
        try:
            log_methods = {
                'debug': logger.debug,
                'info': logger.info,
                'warning': logger.warning,
                'error': logger.error
            }
            log_methods.get(level, logger.debug)(f"{time.strftime('%H:%M:%S')} - {message}")
        except Exception as e:
            print(f"[FALLBACK DEBUG] {time.strftime('%H:%M:%S')} - {message} (Logging error: {str(e)})")

    @classmethod
    def _calculate_metrics(cls, history_data):
        """Calculate gas consumption metrics"""
        try:
            if not history_data:
                raise ValueError("Empty history data provided")

            consumptions = [float(day['consumption_kg']) for day in history_data]
            total_used = sum(consumptions)
            
            if total_used > cls.BOTTLE_CAPACITY:
                raise ValueError(f"Total used {total_used}kg exceeds bottle capacity {cls.BOTTLE_CAPACITY}kg")

            remaining = cls.BOTTLE_CAPACITY - total_used
            avg_daily = total_used / len(consumptions)
            
            weekend_days = [d for d in history_data if d['is_weekend']]
            weekday_days = [d for d in history_data if not d['is_weekend']]
            
            weekend_avg = sum(d['consumption_kg'] for d in weekend_days)/len(weekend_days) if weekend_days else avg_daily
            weekday_avg = sum(d['consumption_kg'] for d in weekday_days)/len(weekday_days) if weekday_days else avg_daily
            
            return {
                'total_used': total_used,
                'remaining': remaining,
                'avg_daily': avg_daily,
                'weekend_avg': weekend_avg,
                'weekday_avg': weekday_avg,
                'recent_avg': sum(consumptions[-3:])/3 if len(consumptions) >= 3 else avg_daily
            }
        except Exception as e:
            cls._debug_log(f"Metrics calculation error: {str(e)}", level='error')
            raise

    @classmethod
    def _validate_prediction(cls, prediction, metrics):
        """Validate prediction accuracy with enhanced list handling"""
        try:
            # Handle cases where remaining_kg or projected_days are lists
            remaining_kg = prediction.get('remaining_kg')
            projected_days = prediction.get('projected_days')

            if isinstance(remaining_kg, list):
                cls._debug_log(f"Received list for remaining_kg: {remaining_kg}", level='warning')
                remaining_kg = float(remaining_kg[0]) if remaining_kg and isinstance(remaining_kg[0], (int, float, str)) else None
            else:
                remaining_kg = float(remaining_kg)

            if isinstance(projected_days, list):
                cls._debug_log(f"Received list for projected_days: {projected_days}", level='warning')
                projected_days = float(projected_days[0]) if projected_days and isinstance(projected_days[0], (int, float, str)) else None
            else:
                projected_days = float(projected_days)

            if remaining_kg is None or projected_days is None:
                raise ValueError("Could not extract valid numbers from prediction")

            max_possible_days = metrics['remaining'] / metrics['avg_daily'] if metrics['avg_daily'] > 0 else 0
            
            if not (0 <= projected_days <= max_possible_days * 1.5):
                raise ValueError(
                    f"Projected days {projected_days} invalid. "
                    f"Max possible: {max_possible_days:.2f} (remaining {metrics['remaining']:.2f}kg)"
                )
            
            if abs(remaining_kg - metrics['remaining']) > 0.1:
                raise ValueError(
                    f"Reported remaining {remaining_kg}kg doesn't match calculated {metrics['remaining']:.2f}kg"
                )
            
            if not (0.5 <= prediction.get('confidence', 0) <= 0.95):
                raise ValueError(f"Invalid confidence score: {prediction.get('confidence')}")

            # Update prediction with validated float values
            prediction['remaining_kg'] = remaining_kg
            prediction['projected_days'] = projected_days
            return True
        except (ValueError, KeyError, TypeError) as e:
            cls._debug_log(f"Prediction validation failed: {str(e)}", level='warning')
            return False

    @classmethod
    def predict_days_remaining(cls, history_data):
        """Predict remaining gas days with robust error handling"""
        try:
            if not cls.API_KEY:
                raise ImproperlyConfigured("API_KEY is not set")

            metrics = cls._calculate_metrics(history_data)
            cls._debug_log(f"Metrics: {metrics}", level='info')

            headers = {
                "Authorization": f"Bearer {cls.API_KEY}",
                "Content-Type": "application/json",
                "HTTP-Referer": "http://localhost:8000"
            }

            prompt = f"""Act as a precise gas consumption analyzer. Follow strictly:

            Constraints:
            - Bottle capacity: {cls.BOTTLE_CAPACITY}kg
            - Total consumed: {metrics['total_used']:.2f}kg
            - Remaining: {metrics['remaining']:.2f}kg
            - Max days: {metrics['remaining']/metrics['avg_daily']:.2f}

            Averages:
            - Daily: {metrics['avg_daily']:.2f}kg
            - Weekdays: {metrics['weekday_avg']:.2f}kg
            - Weekends: {metrics['weekend_avg']:.2f}kg
            - Recent 3 days: {metrics['recent_avg']:.2f}kg

            Response (JSON, NO LISTS for numbers):
            {{
                "remaining_kg": {metrics['remaining']:.2f},
                "projected_days": [number ≤ {metrics['remaining']/metrics['avg_daily']:.2f}],
                "confidence": [number between 0.5-0.95],
                "trend": ["increasing"/"decreasing"/"stable"],
                "calculation": "[formula]",
                "recommendation": "[advice]"
            }}"""

            for model in cls.MODEL_PRIORITY:
                try:
                    cls._debug_log(f"Trying model: {model}", level='info')
                    
                    payload = {
                        "model": model,
                        "messages": [{"role": "user", "content": prompt}],
                        "temperature": 0.1,
                        "response_format": {"type": "json_object"},
                        "max_tokens": 400
                    }

                    start_time = time.time()
                    response = requests.post(
                        cls.API_URL,
                        headers=headers,
                        json=payload,
                        timeout=20
                    )
                    response_time = time.time() - start_time

                    cls._debug_log(f"API response ({response.status_code}) in {response_time:.2f}s", level='info')
                    
                    if response.status_code != 200:
                        cls._debug_log(f"API error for {model}: {response.text[:200]}", level='error')
                        continue

                    result = response.json()
                    content = result['choices'][0]['message']['content']
                    cls._debug_log(f"Raw API response for {model}: {content[:500]}...", level='debug')
                    
                    json_match = re.search(r'\{.*\}', content, re.DOTALL)
                    if not json_match:
                        cls._debug_log("No JSON in response", level='error')
                        continue
                    
                    prediction = json.loads(json_match.group())
                    
                    if cls._validate_prediction(prediction, metrics):
                        cls._debug_log(f"Valid prediction from {model}", level='info')
                        return prediction
                    
                    cls._debug_log(f"Invalid prediction from {model}", level='warning')
                    continue

                except RequestException as e:
                    cls._debug_log(f"Request failed for {model}: {str(e)}", level='error')
                    continue
                except json.JSONDecodeError as e:
                    cls._debug_log(f"JSON parse error for {model}: {str(e)}", level='error')
                    continue
                except Exception as e:
                    cls._debug_log(f"Unexpected error for {model}: {str(e)}", level='error')
                    continue

                time.sleep(1)

            cls._debug_log("All AI models failed, using fallback calculation", level='warning')
            manual_projection = metrics['remaining'] / metrics['recent_avg'] if metrics['recent_avg'] > 0 else 0
            return {
                "remaining_kg": float(metrics['remaining']),
                "projected_days": float(round(manual_projection, 2)),
                "confidence": 0.8,
                "trend": "stable",
                "calculation": f"{metrics['remaining']:.2f}kg / {metrics['recent_avg']:.2f}kg/day",
                "recommendation": "Based on recent average consumption"
            }

        except Exception as e:
            cls._debug_log(f"Critical failure: {str(e)}", level='error')
            metrics = cls._calculate_metrics(history_data) if 'history_data' in locals() else {'remaining': 0, 'avg_daily': 1}
            return {
                "error": "Prediction failed",
                "details": str(e),
                "emergency_calculation": {
                    "remaining_kg": float(metrics['remaining']),
                    "projected_days": float(round(metrics['remaining'] / metrics['avg_daily'], 2)) if metrics['avg_daily'] > 0 else 0,
                    "calculation": "Emergency fallback"
                }
            }