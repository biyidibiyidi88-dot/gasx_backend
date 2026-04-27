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
    DEFAULT_BOTTLE_CAPACITY = 12.50

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

            # consumption_kg is already daily consumption rate, not total consumption
            daily_consumptions = [float(day['consumption_kg']) for day in history_data]
            
            # Calculate average daily consumption (not total)
            avg_daily = sum(daily_consumptions) / len(daily_consumptions) if daily_consumptions else 0
            
            # Estimate remaining gas based on current consumption patterns
            # We'll get the actual remaining from the latest reading in the calling function
            weekend_days = [d for d in history_data if d['is_weekend']]
            weekday_days = [d for d in history_data if not d['is_weekend']]
            
            weekend_avg = sum(d['consumption_kg'] for d in weekend_days)/len(weekend_days) if weekend_days else avg_daily
            weekday_avg = sum(d['consumption_kg'] for d in weekday_days)/len(weekday_days) if weekday_days else avg_daily
            
            # Calculate recent trend (last 3 days)
            recent_avg = sum(daily_consumptions[-3:])/3 if len(daily_consumptions) >= 3 else avg_daily
            
            return {
                'avg_daily': max(0.1, avg_daily),  # Ensure minimum consumption to avoid division by zero
                'weekend_avg': max(0.1, weekend_avg),
                'weekday_avg': max(0.1, weekday_avg),
                'recent_avg': max(0.1, recent_avg),
                'total_days': len(daily_consumptions)
            }
        except Exception as e:
            cls._debug_log(f"Metrics calculation error: {str(e)}", level='error')
            raise

    @classmethod
    def _validate_prediction(cls, prediction, metrics, bottle_capacity):
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

            # Basic validation - projected days should be reasonable
            if not (0 <= projected_days <= 365):  # Max 1 year
                raise ValueError(
                    f"Projected days {projected_days} invalid. Should be between 0-365 days"
                )
            
            # Remaining gas should be within tank capacity
            if not (0 <= remaining_kg <= bottle_capacity):
                raise ValueError(
                    f"Reported remaining {remaining_kg}kg invalid. Should be between 0-{bottle_capacity}kg"
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
    def predict_days_remaining(cls, history_data, current_remaining_kg=None, bottle_capacity=None):
        """Predict remaining gas days with robust error handling"""
        if bottle_capacity is None:
            bottle_capacity = cls.DEFAULT_BOTTLE_CAPACITY
        bottle_capacity = float(bottle_capacity)
        """Predict remaining gas days with robust error handling"""
        try:
            if not cls.API_KEY:
                raise ImproperlyConfigured("API_KEY is not set")

            metrics = cls._calculate_metrics(history_data)
            cls._debug_log(f"Metrics: {metrics}", level='info')
            
            # If current remaining gas not provided, estimate from latest data
            if current_remaining_kg is None:
                # Assume we start with some reasonable amount based on consumption patterns
                current_remaining_kg = max(1.0, bottle_capacity * 0.3)  # Default to 30% capacity
            
            current_remaining_kg = float(current_remaining_kg)
            cls._debug_log(f"Current remaining gas: {current_remaining_kg}kg", level='info')

            headers = {
                "Authorization": f"Bearer {cls.API_KEY}",
                "Content-Type": "application/json",
                "HTTP-Referer": "http://localhost:8000"
            }

            prompt = f"""Act as a precise gas consumption analyzer. Follow strictly:

            Constraints:
            - Bottle capacity: {bottle_capacity}kg
            - Current remaining: {current_remaining_kg:.2f}kg
            - Max possible days: {current_remaining_kg/metrics['avg_daily']:.1f}

            Consumption Averages:
            - Daily: {metrics['avg_daily']:.2f}kg
            - Weekdays: {metrics['weekday_avg']:.2f}kg
            - Weekends: {metrics['weekend_avg']:.2f}kg
            - Recent 3 days: {metrics['recent_avg']:.2f}kg

            Response (JSON, NO LISTS for numbers):
            {{
                "remaining_kg": {current_remaining_kg:.2f},
                "projected_days": [number ≤ {current_remaining_kg/metrics['avg_daily']:.1f}],
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
                    
                    if cls._validate_prediction(prediction, metrics, bottle_capacity):
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
            
            # Check if tank is empty or nearly empty
            if current_remaining_kg <= 0.5:  # Less than 0.5kg remaining
                return {
                    "remaining_kg": float(current_remaining_kg),
                    "projected_days": 0.0,
                    "confidence": 1.0,
                    "trend": "empty",
                    "calculation": "Tank is empty or nearly empty",
                    "recommendation": "Immediate refill required - tank is empty!"
                }
            
            # Use current_remaining_kg from function parameter instead of missing metrics['remaining']
            manual_projection = current_remaining_kg / metrics['recent_avg'] if metrics['recent_avg'] > 0 else 0
            return {
                "remaining_kg": float(current_remaining_kg),
                "projected_days": float(round(manual_projection, 2)),
                "confidence": 0.8,
                "trend": "stable",
                "calculation": f"{current_remaining_kg:.2f}kg / {metrics['recent_avg']:.2f}kg/day",
                "recommendation": "Based on recent average consumption"
            }

        except Exception as e:
            cls._debug_log(f"Critical failure: {str(e)}", level='error')
            metrics = cls._calculate_metrics(history_data) if 'history_data' in locals() else {'avg_daily': 1}
            # Use current_remaining_kg parameter or default to 0 if not available
            remaining_kg = current_remaining_kg if 'current_remaining_kg' in locals() else 0
            return {
                "error": "Prediction failed",
                "details": str(e),
                "emergency_calculation": {
                    "remaining_kg": float(remaining_kg),
                    "projected_days": float(round(remaining_kg / metrics['avg_daily'], 2)) if metrics['avg_daily'] > 0 else 0,
                    "calculation": "Emergency fallback"
                }
            }