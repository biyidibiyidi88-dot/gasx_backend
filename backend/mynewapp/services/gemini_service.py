"""Small server-side client for the Google Gemini generateContent API."""
import logging
from urllib.parse import quote

import requests
from django.conf import settings

logger = logging.getLogger(__name__)


class GeminiAPIError(Exception):
    """Raised when Gemini cannot return a usable forecast response."""


class GeminiService:
    API_URL = "https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"

    @classmethod
    def generate_json(cls, *, system_instruction, prompt, max_output_tokens=180):
        return cls._generate(
            system_instruction=system_instruction,
            prompt=prompt,
            max_output_tokens=max_output_tokens,
            response_mime_type="application/json",
        )

    @classmethod
    def generate_text(cls, *, system_instruction, prompt, max_output_tokens=320):
        """Generate a short plain-text response, for example supplier suggestions."""
        return cls._generate(
            system_instruction=system_instruction,
            prompt=prompt,
            max_output_tokens=max_output_tokens,
        )

    @classmethod
    def _generate(
        cls,
        *,
        system_instruction,
        prompt,
        max_output_tokens,
        response_mime_type=None,
    ):
        api_key = getattr(settings, "GEMINI_API_KEY", "")
        if not api_key:
            raise GeminiAPIError("GEMINI_API_KEY is not configured")

        model = getattr(settings, "GEMINI_MODEL", "gemini-3.5-flash-lite")
        url = cls.API_URL.format(model=quote(model, safe="-_."))
        generation_config = {
            "temperature": 0.1,
            "maxOutputTokens": max_output_tokens,
        }
        if response_mime_type:
            generation_config["responseMimeType"] = response_mime_type
        try:
            response = requests.post(
                url,
                headers={
                    "x-goog-api-key": api_key,
                    "Content-Type": "application/json",
                },
                json={
                    "systemInstruction": {"parts": [{"text": system_instruction}]},
                    "contents": [{"role": "user", "parts": [{"text": prompt}]}],
                    "generationConfig": generation_config,
                },
                timeout=(3, 10),
            )
        except requests.RequestException as exc:
            logger.warning("Gemini request failed: %s", type(exc).__name__)
            raise GeminiAPIError("Gemini could not be reached") from exc

        if not response.ok:
            # Do not log the response body: provider errors can contain request data.
            logger.warning("Gemini returned HTTP %s", response.status_code)
            raise GeminiAPIError("Gemini returned an error")

        try:
            data = response.json()
            parts = data["candidates"][0]["content"]["parts"]
            content = "".join(part.get("text", "") for part in parts)
        except (ValueError, KeyError, IndexError, TypeError) as exc:
            raise GeminiAPIError("Gemini returned an invalid response") from exc
        if not content.strip():
            raise GeminiAPIError("Gemini returned an empty response")
        return content.strip()
