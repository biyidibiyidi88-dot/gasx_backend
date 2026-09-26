"""DigiPay gateway setup kept on the backend; never expose the key to clients."""

from django.conf import settings


def get_digipay_client():
    api_key = getattr(settings, "DIGIPAY_API_KEY", "")
    if not api_key:
        raise RuntimeError("DigiPay is not configured.")
    environment = getattr(settings, "DIGIPAY_ENVIRONMENT", "sandbox")
    if environment != "production" or getattr(settings, "ALLOW_MOCK_PAYMENTS", False):
        raise RuntimeError(
            "Real DigiPay payments require production mode with mock payments disabled."
        )
    from digipay import DigiPay

    return DigiPay(
        api_key=api_key,
        environment=environment,
    )


def normalize_status(value):
    return str(value or "").strip().lower()
