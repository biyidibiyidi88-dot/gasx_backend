from django.urls import path
from . import consumers

websocket_urlpatterns = [
    path('ws/gas-monitor/', consumers.GasMonitorConsumer.as_asgi()),
]
