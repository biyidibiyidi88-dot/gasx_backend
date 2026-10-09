"""Authenticated PDF invoices for paid gas orders."""

from decimal import Decimal
from html import escape
from io import BytesIO
from pathlib import Path
from zoneinfo import ZoneInfo

from django.http import HttpResponse
from django.shortcuts import get_object_or_404
import reportlab
from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT, TA_RIGHT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Delivery


INK = colors.HexColor("#132238")
TEAL = colors.HexColor("#0F766E")
MUTED = colors.HexColor("#334155")
PALE = colors.HexColor("#F1F7F6")
LINE = colors.HexColor("#D9E4E2")

_FONT_DIR = Path(reportlab.__file__).parent / "fonts"
pdfmetrics.registerFont(TTFont("GasX-Vera", str(_FONT_DIR / "Vera.ttf")))
pdfmetrics.registerFont(TTFont("GasX-Vera-Bold", str(_FONT_DIR / "VeraBd.ttf")))


def _paragraph(text, style):
    return Paragraph(escape(str(text or "Not provided")), style)


def _amount(value):
    return f"{Decimal(value or 0):,.0f} FCFA"


def _make_invoice(order):
    buffer = BytesIO()
    doc = SimpleDocTemplate(
        buffer,
        pagesize=A4,
        rightMargin=18 * mm,
        leftMargin=18 * mm,
        topMargin=15 * mm,
        bottomMargin=18 * mm,
        title=f"GasX invoice for order {order.pk}",
        author="GasX",
    )
    styles = getSampleStyleSheet()
    brand_style = ParagraphStyle(
        "GasXBrand", parent=styles["Title"], fontName="GasX-Vera-Bold",
        fontSize=23, leading=27, textColor=TEAL, alignment=TA_LEFT, spaceAfter=2,
    )
    title_style = ParagraphStyle(
        "InvoiceTitle", parent=styles["Title"], fontName="GasX-Vera-Bold",
        fontSize=19, leading=23, textColor=INK, alignment=TA_RIGHT, spaceAfter=2,
    )
    small_right = ParagraphStyle(
        "InvoiceRight", parent=styles["Normal"], fontName="GasX-Vera",
        fontSize=9, leading=13,
        textColor=MUTED, alignment=TA_RIGHT,
    )
    body = ParagraphStyle(
        "InvoiceBody", parent=styles["Normal"], fontName="GasX-Vera",
        fontSize=9, leading=13, textColor=INK,
    )
    body_small = ParagraphStyle(
        "InvoiceSmall", parent=body, fontSize=9, leading=13, textColor=MUTED,
    )
    section_style = ParagraphStyle(
        "InvoiceSection", parent=styles["Heading3"], fontName="GasX-Vera-Bold",
        fontSize=10, leading=13, textColor=TEAL, spaceBefore=5, spaceAfter=7,
    )
    label_style = ParagraphStyle(
        "InvoiceLabel", parent=body_small, fontName="GasX-Vera-Bold",
        textColor=MUTED,
    )
    bold_style = ParagraphStyle(
        "InvoiceBold", parent=body, fontName="GasX-Vera-Bold",
    )

    paid_at = order.payment_confirmed_at or order.created_at
    local_paid_at = paid_at.astimezone(ZoneInfo("Africa/Douala"))
    invoice_no = f"GX-INV-{local_paid_at:%Y}-{order.pk:06d}"
    customer = order.client
    supplier = order.vendor
    bottle = order.gas_bottle
    customer_phone = order.payer_phone or customer.phone_number
    supplier_user = supplier.user
    fulfillment = order.get_fulfillment_method_display()
    location_label = "Delivery address" if order.fulfillment_method == "DELIVERY" else "Pickup location"
    location = order.delivery_address or supplier.address or "Not provided"
    if order.fulfillment_method == "DELIVERY" and order.latitude is not None and order.longitude is not None:
        location += f" (GPS: {order.latitude:.6f}, {order.longitude:.6f})"

    story = []
    header = Table(
        [[
            Paragraph("GasX", brand_style),
            [
                Paragraph("INVOICE", title_style),
                Paragraph(f"Invoice {invoice_no}", small_right),
                Paragraph(f"Issued {local_paid_at:%d %b %Y, %H:%M %Z}", small_right),
            ],
        ]],
        colWidths=[90 * mm, 82 * mm],
    )
    header.setStyle(TableStyle([
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("ALIGN", (1, 0), (1, 0), "RIGHT"),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
        ("LINEBELOW", (0, 0), (-1, -1), 1.2, TEAL),
    ]))
    story.extend([header, Spacer(1, 7 * mm)])

    party_cards = Table(
        [[
            [
                Paragraph("CUSTOMER", label_style),
                Spacer(1, 2 * mm),
                _paragraph(customer.get_full_name(), bold_style),
                _paragraph(customer.email, body_small),
                _paragraph(customer_phone, body_small),
            ],
            [
                Paragraph("SUPPLIER", label_style),
                Spacer(1, 2 * mm),
                _paragraph(supplier.store_name, bold_style),
                _paragraph(supplier.address, body_small),
                _paragraph(supplier_user.get_full_name(), body_small),
                _paragraph(supplier_user.phone_number or supplier_user.email, body_small),
            ],
        ]],
        colWidths=[86 * mm, 86 * mm],
    )
    party_cards.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), PALE),
        ("BOX", (0, 0), (-1, -1), 0.7, LINE),
        ("INNERGRID", (0, 0), (-1, -1), 0.7, LINE),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 10),
        ("RIGHTPADDING", (0, 0), (-1, -1), 10),
        ("TOPPADDING", (0, 0), (-1, -1), 10),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 10),
    ]))
    story.extend([party_cards, Spacer(1, 7 * mm)])

    story.append(Paragraph("ORDER DETAILS", section_style))
    item_table = Table(
        [[
            Paragraph("Bottle", label_style),
            Paragraph("Qty", label_style),
            Paragraph("Unit price", label_style),
            Paragraph("Delivery", label_style),
            Paragraph("Line total", label_style),
        ], [
            _paragraph(f"{bottle.get_brand_display()} - {bottle.get_size_display()}", body),
            _paragraph("1", body),
            _paragraph(_amount(order.unit_price), body),
            _paragraph(_amount(order.delivery_fee), body),
            _paragraph(_amount(order.payment_amount), bold_style),
        ]],
        colWidths=[67 * mm, 12 * mm, 31 * mm, 31 * mm, 31 * mm],
    )
    item_table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), PALE),
        ("BOX", (0, 0), (-1, -1), 0.7, LINE),
        ("INNERGRID", (0, 0), (-1, -1), 0.5, LINE),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("ALIGN", (1, 0), (-1, -1), "RIGHT"),
        ("LEFTPADDING", (0, 0), (-1, -1), 7),
        ("RIGHTPADDING", (0, 0), (-1, -1), 7),
        ("TOPPADDING", (0, 0), (-1, -1), 8),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
    ]))
    story.extend([item_table, Spacer(1, 3 * mm)])
    story.append(_paragraph(f"{location_label}: {location}", body_small))
    story.append(_paragraph(f"Fulfilment: {fulfillment}", body_small))
    story.extend([Spacer(1, 5 * mm), Paragraph("PAYMENT", section_style)])

    operator = order.get_payment_operator_display() or "Mobile Money"
    payment_rows = [
        [Paragraph("Payment status", label_style), _paragraph("PAID", bold_style)],
        [Paragraph("Payment method", label_style), _paragraph(operator, body)],
        [Paragraph("Paid from phone", label_style), _paragraph(customer_phone, body)],
        [Paragraph("DigiPay transaction reference", label_style), _paragraph(order.payment_transaction_id, body)],
        [Paragraph("Payment date", label_style), _paragraph(local_paid_at.strftime("%d %b %Y, %H:%M %Z"), body)],
    ]
    payment_table = Table(payment_rows, colWidths=[57 * mm, 115 * mm])
    payment_table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), colors.white),
        ("BOX", (0, 0), (-1, -1), 0.7, LINE),
        ("INNERGRID", (0, 0), (-1, -1), 0.4, LINE),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 8),
        ("RIGHTPADDING", (0, 0), (-1, -1), 8),
        ("TOPPADDING", (0, 0), (-1, -1), 6),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
        ("TEXTCOLOR", (1, 0), (1, 0), TEAL),
    ]))
    story.extend([payment_table, Spacer(1, 5 * mm)])

    total_table = Table(
        [
            [Paragraph("Bottle price", body), _paragraph(_amount(order.unit_price), body)],
            [Paragraph("Delivery fee", body), _paragraph(_amount(order.delivery_fee), body)],
            [Paragraph("TOTAL PAID", bold_style), _paragraph(_amount(order.payment_amount), bold_style)],
        ],
        colWidths=[45 * mm, 37 * mm],
        hAlign="RIGHT",
    )
    total_table.setStyle(TableStyle([
        ("ALIGN", (1, 0), (1, -1), "RIGHT"),
        ("LINEABOVE", (0, 2), (-1, 2), 1, TEAL),
        ("TEXTCOLOR", (0, 2), (-1, 2), TEAL),
        ("TOPPADDING", (0, 0), (-1, -1), 4),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
    ]))
    story.extend([total_table, Spacer(1, 7 * mm)])
    story.append(_paragraph("Thank you for your purchase. Keep this invoice for your records.", body_small))

    def draw_footer(canvas, _doc):
        canvas.saveState()
        canvas.setStrokeColor(LINE)
        canvas.setLineWidth(0.6)
        canvas.line(18 * mm, 13 * mm, A4[0] - 18 * mm, 13 * mm)
        canvas.setFont("GasX-Vera", 8)
        canvas.setFillColor(MUTED)
        canvas.drawString(18 * mm, 8.5 * mm, f"GasX invoice {invoice_no} | Order #{order.pk}")
        canvas.drawRightString(A4[0] - 18 * mm, 8.5 * mm, f"Page {_doc.page}")
        canvas.restoreState()

    doc.build(story, onFirstPage=draw_footer, onLaterPages=draw_footer)
    return buffer.getvalue()


class GasOrderInvoiceView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, order_id):
        order = get_object_or_404(
            Delivery.objects.select_related(
                "client", "vendor__user", "gas_bottle"
            ),
            pk=order_id,
            client=request.user,
        )
        if order.payment_status != "PAID":
            return Response(
                {"detail": "An invoice is available after payment is confirmed."},
                status=status.HTTP_409_CONFLICT,
            )

        response = HttpResponse(_make_invoice(order), content_type="application/pdf")
        response["Content-Disposition"] = (
            f'attachment; filename="GasX-Invoice-{order.pk}.pdf"'
        )
        response["Cache-Control"] = "private, no-store"
        return response
