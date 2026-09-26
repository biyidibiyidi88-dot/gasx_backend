import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/websocket_client.dart';
import 'auth_provider.dart';

final websocketClientProvider = Provider<WebSocketClient>((ref) {
  final client = WebSocketClient();

  // Watch auth state to connect/disconnect accordingly
  ref.listen(authStateProvider, (prev, next) {
    if (next.user != null) {
      client.connect();
    } else {
      client.disconnect();
    }
  });

  // Trigger initial connection check if user is already logged in
  final auth = ref.read(authStateProvider);
  if (auth.user != null) {
    client.connect();
  }

  ref.onDispose(() {
    client.disconnect();
  });

  return client;
});

// websocketStreamProvider is unused and removed since providers listen directly to websocketClientProvider.stream
