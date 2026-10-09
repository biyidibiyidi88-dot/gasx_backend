import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../constants/api_constants.dart';

class WebSocketClient {
  final _storage = const FlutterSecureStorage();
  WebSocketChannel? _channel;

  // Single broadcast StreamController that persists for the lifetime of the client.
  // Listeners attached before connection still receive future events.
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  bool _isConnecting = false;
  bool _shouldReconnect = true;
  Timer? _reconnectTimer;
  int _reconnectDelay = 2;

  Stream<Map<String, dynamic>> get stream => _controller.stream;
  bool get isConnected => _channel != null && !_isConnecting;

  Future<void> connect() async {
    if (_isConnecting || _channel != null) return;
    _isConnecting = true;
    _shouldReconnect = true;

    String? token;
    try {
      token = await _storage.read(key: 'authToken');
    } catch (e) {
      debugPrint('WebSocket: Exception reading token from storage: $e');
    }

    if (token == null || token.isEmpty) {
      _isConnecting = false;
      debugPrint(
        'WebSocket: Connection aborted, no auth token found or storage exception',
      );
      return;
    }

    for (final baseUrl in ApiConstants.apiBaseUrls) {
      if (!_shouldReconnect) break;

      WebSocketChannel? candidate;
      try {
        final url = ApiConstants.websocketUrlFor(baseUrl, token);
        candidate = WebSocketChannel.connect(Uri.parse(url));
        await candidate.ready.timeout(const Duration(seconds: 8));

        if (!_shouldReconnect) {
          await candidate.sink.close();
          break;
        }

        _channel = candidate;
        _isConnecting = false;
        _reconnectDelay = 2;
        debugPrint(
          'WebSocket: Connected to ${baseUrl == ApiConstants.onlineBaseUrl ? 'online' : 'local'} backend',
        );

        candidate.stream.listen(
          (message) {
            try {
              final data =
                  jsonDecode(message as String) as Map<String, dynamic>;
              debugPrint('WebSocket: Received event type=${data['type']}');
              _controller.add(data);
            } catch (e) {
              debugPrint('WebSocket: Error parsing message: $e');
            }
          },
          onDone: () {
            debugPrint('WebSocket: Connection closed');
            _cleanupAndReconnect();
          },
          onError: (error) {
            debugPrint('WebSocket: Connection error: $error');
            _cleanupAndReconnect();
          },
          cancelOnError: false,
        );
        return;
      } catch (e) {
        try {
          await candidate?.sink.close();
        } catch (_) {}
        debugPrint(
          'WebSocket: ${baseUrl == ApiConstants.onlineBaseUrl ? 'online' : 'local'} backend unavailable: $e',
        );
      }
    }

    _isConnecting = false;
    _cleanupAndReconnect();
  }

  void disconnect() {
    _shouldReconnect = false;
    _isConnecting = false;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    debugPrint('WebSocket: Manual disconnect');
  }

  void _cleanupAndReconnect() {
    _channel = null;
    _isConnecting = false;

    if (!_shouldReconnect) return;

    _reconnectTimer?.cancel();
    debugPrint('WebSocket: Reconnecting in $_reconnectDelay seconds...');
    _reconnectTimer = Timer(Duration(seconds: _reconnectDelay), () {
      _reconnectDelay = (_reconnectDelay * 2).clamp(2, 60);
      connect();
    });
  }

  void dispose() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _controller.close();
  }
}
