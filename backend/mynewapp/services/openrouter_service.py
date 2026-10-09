import logging

import requests
from django.conf import settings
from django.core.exceptions import ImproperlyConfigured
from requests.exceptions import RequestException

logger = logging.getLogger(__name__)


class OpenRouterError(Exception):
    """Raised when OpenRouter cannot return a usable response."""


class OpenRouterService:
    API_URL = "https://openrouter.ai/api/v1/chat/completions"

    @classmethod
    def models(cls):
        configured = [settings.OPENROUTER_MODEL, *settings.OPENROUTER_FALLBACK_MODELS]
        return list(dict.fromkeys(model for model in configured if model))

    @classmethod
    def create_completion(
        cls,
        messages,
        *,
        model=None,
        temperature=0.1,
        max_tokens=1000,
        response_format=None,
        timeout=25,
    ):
        api_key = settings.OPENROUTER_API_KEY
        if not api_key:
            raise ImproperlyConfigured("OPENROUTER_API_KEY is not configured")

        payload = {
            "model": model or settings.OPENROUTER_MODEL,
            "messages": messages,
            "temperature": temperature,
            "max_tokens": max_tokens,
        }
        if response_format:
            payload["response_format"] = response_format

        try:
            response = requests.post(
                cls.API_URL,
                headers={
                    "Authorization": f"Bearer {api_key}",
                    "Content-Type": "application/json",
                    "HTTP-Referer": settings.OPENROUTER_SITE_URL,
                    "X-Title": settings.OPENROUTER_APP_NAME,
                },
                json=payload,
                timeout=timeout,
            )
            if not response.ok:
                logger.warning("OpenRouter returned HTTP %s", response.status_code)
                raise OpenRouterError("The AI service returned an error")
            data = response.json()
        except RequestException as exc:
            logger.warning("OpenRouter request failed: %s", type(exc).__name__)
            raise OpenRouterError("The AI service could not be reached") from exc
        except ValueError as exc:
            raise OpenRouterError("The AI service returned an invalid response") from exc

        if not isinstance(data, dict) or not data.get("choices"):
            raise OpenRouterError("The AI service returned no answer")
        return data

    @classmethod
    def complete_with_fallback(cls, messages, **kwargs):
        last_error = None
        for model in cls.models():
            try:
                data = cls.create_completion(messages, model=model, **kwargs)
                content = data["choices"][0]["message"]["content"]
                if not isinstance(content, str) or not content.strip():
                    raise OpenRouterError("The AI service returned an empty answer")
                return content.strip(), model
            except (
                OpenRouterError,
                RequestException,
                KeyError,
                IndexError,
                TypeError,
            ) as exc:
                last_error = exc
                logger.warning("OpenRouter model %s failed", model)
        if last_error:
            raise OpenRouterError("All configured AI models failed") from last_error
        raise ImproperlyConfigured("No OpenRouter models are configured")
