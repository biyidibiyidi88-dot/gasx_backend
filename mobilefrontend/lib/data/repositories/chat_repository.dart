import 'package:dio/dio.dart';
import '../models/chat_models.dart';
import '../models/vendor_models.dart';
import 'package:geolocator/geolocator.dart';

class ChatRepository {
  final Dio _dio;
  static const String _apiUrl = "https://openrouter.ai/api/v1/chat/completions";
  static const String _apiKey = "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";

  ChatRepository(this._dio);

  Future<String> sendMessage(List<ChatMessage> history, String model) async {
    try {
      final response = await _dio.post(
        _apiUrl,
        options: Options(headers: {
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'https://GaSX.ai',
          'X-Title': 'GaSX Bipsync AI',
        }),
        data: {
          'model': model,
          'messages': [
            {
              'role': 'system',
              'content': 'You are the Bipsync AI, a high-fidelity intelligence hub for GaSX. You specialize in technical telemetry, safety optimization, and industrial gas logistics. Maintain a professional, data-centric, and sophisticated tone.'
            },
            ...history.map((m) => {'role': m.role, 'content': m.content}),
          ],
          'temperature': 0.1,
          'max_tokens': 1000,
        },
      );

      return response.data['choices'][0]['message']['content'];
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getVendorRecommendation(Position userLocation, List<Vendor> vendors) async {
    final vendorContext = vendors.map((v) => 
      'Vendor: ${v.storeName}\n' +
      'Coordinates: ${v.latitude}, ${v.longitude}\n' +
      'Bottles available: ${(v.gasBottles ?? []).map((b) => "${b.brand} ${b.size} at ${b.price}").join(", ")}'
    ).join('\n\n');

    final systemMessage = 'You are an AI assistant for the GaSX app. The user is looking for a gas vendor.\n' +
      'Prioritize vendors closest to the user and offering the lowest prices.\n' +
      'User current location: Latitude ${userLocation.latitude}, Longitude ${userLocation.longitude}.\n' +
      'Here is the list of available vendors:\n\n$vendorContext';

    final userMessage = 'Based on my current location and the available vendors, who should I buy from and why? Please provide a concise recommendation prioritizing price and proximity.';

    try {
      final response = await _dio.post(
        _apiUrl,
        options: Options(headers: {
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'https://GaSX.ai',
          'X-Title': 'GaSX Bipsync AI',
        }),
        data: {
          'model': 'anthropic/claude-3-haiku',
          'messages': [
            {'role': 'system', 'content': systemMessage},
            {'role': 'user', 'content': userMessage},
          ],
          'temperature': 0.1,
          'max_tokens': 1000,
        },
      );
      return response.data['choices'][0]['message']['content'];
    } catch (e) {
      rethrow;
    }
  }
}
