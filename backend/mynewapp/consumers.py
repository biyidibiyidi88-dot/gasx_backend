import json
import logging
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from .models import GasSensor, Notification
from .serializers import GasSensorSerializer, NotificationSerializer

logger = logging.getLogger(__name__)

@database_sync_to_async
def get_serialized_sensors(user):
    try:
        sensors = GasSensor.objects.filter(house__user=user)
        return GasSensorSerializer(sensors, many=True).data
    except Exception as e:
        logger.error(f"Error serializing gas sensors: {e}")
        return []

@database_sync_to_async
def get_serialized_notifications(user):
    try:
        notifications = (
            Notification.objects.filter(alert__user=user)
            .select_related("alert", "alert__sensor", "alert__sensor__house")
            .order_by("-sent_at")
        )
        return NotificationSerializer(notifications, many=True).data
    except Exception as e:
        logger.error(f"Error serializing notifications: {e}")
        return []

class GasMonitorConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.user = self.scope.get("user")
        
        if not self.user or self.user.is_anonymous:
            logger.warning("Rejecting unauthenticated WebSocket connection")
            await self.close()
            return
        
        self.group_name = f"user_{self.user.id}"
        
        # Join user group
        await self.channel_layer.group_add(
            self.group_name,
            self.channel_name
        )
        
        await self.accept()
        logger.info(f"WebSocket connected: User {self.user.email} joined group {self.group_name}")
        
        # Send initial data immediately on connection
        await self.send_sensors_data()
        await self.send_notifications_data()

    async def disconnect(self, close_code):
        if hasattr(self, 'group_name'):
            # Leave user group
            await self.channel_layer.group_discard(
                self.group_name,
                self.channel_name
            )
            logger.info(f"WebSocket disconnected: User {self.user.email} left group {self.group_name}")

    async def receive(self, text_data):
        # We don't expect client messages for now, but handle gracefully
        try:
            data = json.loads(text_data)
            action = data.get("action")
            if action == "ping":
                await self.send(text_data=json.dumps({"type": "pong"}))
        except Exception as e:
            logger.error(f"WebSocket receive error: {e}")

    # Helper methods to send data
    async def send_sensors_data(self):
        sensors = await get_serialized_sensors(self.user)
        await self.send(text_data=json.dumps({
            "type": "gas_sensors",
            "data": sensors
        }))

    async def send_notifications_data(self):
        notifications = await get_serialized_notifications(self.user)
        await self.send(text_data=json.dumps({
            "type": "notifications",
            "data": notifications
        }))

    # Handlers for group broadcasts
    async def send_gas_reading(self, event):
        """Called when gas readings are updated."""
        await self.send_sensors_data()

    async def send_alert(self, event):
        """Called when a new alert is triggered or updated."""
        await self.send_notifications_data()
