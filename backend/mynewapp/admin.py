from django.contrib import admin
from .models import SubscriptionPayment


@admin.register(SubscriptionPayment)
class SubscriptionPaymentAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "user",
        "plan",
        "amount",
        "payment_operator",
        "payment_status",
        "created_at",
    )
    list_filter = ("plan", "payment_operator", "payment_status", "created_at")
    search_fields = ("user__email", "transaction_id", "payer_phone")
    readonly_fields = (
        "user",
        "plan",
        "amount",
        "payment_operator",
        "payer_phone",
        "payment_status",
        "transaction_id",
        "created_at",
        "updated_at",
    )
