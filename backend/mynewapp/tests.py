from datetime import date
from decimal import Decimal

from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import override_settings
from rest_framework.authtoken.models import Token
from rest_framework.test import APITestCase

from .models import CustomUser, GasBottle, GasSensor, House, VendorProfile


@override_settings(MEDIA_ROOT="/tmp/gasmonitor-test-media")
class GasReadingContractTests(APITestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="gas-reading-test@example.com",
            password="test-password-123",
            first_name="Gas",
            last_name="Owner",
            preferred_bottle_size="MEDIUM_12_5KG",
            preferred_bottle_brand="TOTAL_ENERGIES",
            tare_weight=Decimal("10.00"),
        )
        self.house = House.objects.create(
            user=self.user,
            address_line_1="1 Test Road",
            city="Test City",
            state_province="Test Region",
            country="Test Country",
            postal_code="00000",
        )
        self.sensor = GasSensor.objects.create(
            house=self.house,
            sensor_name="Test gas sensor",
            sensor_type="PROPANE",
            serial_number="TEST-GAS-001",
            installation_date=date.today(),
            last_calibration_date=date.today(),
            battery_level_percentage=100,
        )
        token = Token.objects.create(user=self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f"Token {token.key}")

    def test_gross_weight_is_calculated_by_selected_bottle_type(self):
        cases = (
            ("SMALL_6KG", "6.00"),
            ("MEDIUM_12_5KG", "10.00"),
            ("BIG_50KG", "10.00"),
        )

        for bottle_size, expected_remaining in cases:
            with self.subTest(bottle_size=bottle_size):
                profile = self.client.patch(
                    "/api/users/profile/",
                    {
                        "preferred_bottle_size": bottle_size,
                        "tare_weight": "10.00",
                    },
                    format="json",
                )
                self.assertEqual(profile.status_code, 200)

                response = self.client.post(
                    "/api/gas-readings/create/",
                    {"sensor": self.sensor.id, "raw_weight": 20.0},
                    format="json",
                )
                self.assertEqual(response.status_code, 201, response.data)
                self.assertEqual(response.data["raw_weight"], 20.0)
                self.assertEqual(response.data["remaining_gas"], float(expected_remaining))

        self.sensor.refresh_from_db()
        self.assertEqual(self.sensor.raw_weight, Decimal("20.00"))

    def test_reading_cannot_be_written_to_another_users_sensor(self):
        other_user = CustomUser.objects.create_user(
            email="other-owner@example.com",
            password="test-password-123",
            first_name="Other",
            last_name="Owner",
        )
        other_house = House.objects.create(
            user=other_user,
            address_line_1="2 Test Road",
            city="Test City",
            state_province="Test Region",
            country="Test Country",
            postal_code="00000",
        )
        other_sensor = GasSensor.objects.create(
            house=other_house,
            sensor_name="Other gas sensor",
            sensor_type="PROPANE",
            serial_number="TEST-GAS-002",
            installation_date=date.today(),
            last_calibration_date=date.today(),
            battery_level_percentage=100,
        )

        response = self.client.post(
            "/api/gas-readings/create/",
            {"sensor": other_sensor.id, "raw_weight": 20.0},
            format="json",
        )

        self.assertEqual(response.status_code, 400)
        self.assertNotIn("id", response.data)

    def test_mobile_valve_route_and_device_poll_are_authenticated(self):
        response = self.client.post(
            f"/api/sensors/{self.sensor.id}/control-valve/",
            {"command": "CLOSE"},
            format="json",
        )
        self.assertEqual(response.status_code, 200, response.data)

        poll = self.client.get(
            f"/api/sensors/{self.sensor.id}/device-command/?current_valve=OPEN"
        )
        self.assertEqual(poll.status_code, 200, poll.data)
        self.assertEqual(poll.data["valve_command"], "CLOSE")
        self.assertEqual(poll.data["current_valve_state"], "OPEN")

    def test_registration_defaults_to_customer_and_cannot_grant_admin_flags(self):
        response = self.client.post(
            "/api/auth/register/",
            {
                "email": "new-customer@example.com",
                "password": "StrongPass!12345",
                "first_name": "New",
                "last_name": "Customer",
                "is_admin": True,
                "is_delivery_person": True,
            },
            format="json",
        )
        self.assertEqual(response.status_code, 201, response.data)
        self.assertEqual(response.data["user"]["role"], "client")
        account = CustomUser.objects.get(email="new-customer@example.com")
        self.assertFalse(account.is_admin)
        self.assertFalse(account.is_delivery_person)

    def test_delivery_signup_creates_pending_application_with_documents(self):
        response = self.client.post(
            "/api/auth/register/",
            {
                "email": "new-driver@example.com",
                "password": "StrongPass!12345",
                "first_name": "New",
                "last_name": "Driver",
                "account_type": "delivery_person",
                "identity_card": SimpleUploadedFile("id.jpg", b"identity", "image/jpeg"),
                "supporting_document": SimpleUploadedFile("proof.pdf", b"proof", "application/pdf"),
            },
            format="multipart",
        )
        self.assertEqual(response.status_code, 201, response.data)
        driver = CustomUser.objects.get(email="new-driver@example.com")
        self.assertTrue(driver.is_delivery_person)
        self.assertEqual(driver.delivery_profile.application_status, "PENDING")
        self.assertEqual(response.data["user"]["application_status"], "pending")

    def test_customer_can_order_for_pickup_and_cancel_reserves_stock(self):
        vendor = CustomUser.objects.create_user(
            email="supplier@example.com",
            password="test-password-123",
            first_name="Gas",
            last_name="Store",
        )
        profile = VendorProfile.objects.create(
            user=vendor,
            store_name="Approved Store",
            address="1 Market Road",
            is_approved=True,
            application_status="APPROVED",
        )
        bottle = GasBottle.objects.create(
            vendor=profile,
            brand="SCTM",
            size="SMALL_6KG",
            price=Decimal("6500.00"),
            stock_quantity=1,
        )
        response = self.client.post(
            "/api/deliveries/",
            {"gas_bottle": bottle.id, "fulfillment_method": "PICKUP"},
            format="json",
        )
        self.assertEqual(response.status_code, 201, response.data)
        self.assertEqual(response.data["fulfillment_method"], "PICKUP")
        self.assertEqual(response.data["vendor_name"], "Approved Store")
        bottle.refresh_from_db()
        self.assertEqual(bottle.stock_quantity, 0)

        cancelled = self.client.patch(
            f"/api/deliveries/{response.data['id']}/",
            {"status": "CANCELLED"},
            format="json",
        )
        self.assertEqual(cancelled.status_code, 200, cancelled.data)
        bottle.refresh_from_db()
        self.assertEqual(bottle.stock_quantity, 1)
