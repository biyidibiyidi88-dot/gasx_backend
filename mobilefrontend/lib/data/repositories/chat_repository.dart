import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../models/chat_models.dart';

class ChatRepository {
  final Dio _dio;

  ChatRepository(this._dio);

  Future<String> sendMessage(List<ChatMessage> history) async {
    final response = await _dio.post(
      'ai/chat/',
      data: {
        'messages': history
            .skip(history.length > 20 ? history.length - 20 : 0)
            .map(
              (message) => {'role': message.role, 'content': message.content},
            )
            .toList(),
      },
    );
    return response.data['reply'] as String;
  }

  Future<String> getVendorRecommendation(
    Position userLocation,
    List<int> vendorIds,
  ) async {
    final response = await _dio.post(
      'ai/chat/',
      data: {
        'mode': 'vendor_recommendation',
        'messages': [
          {
            'role': 'user',
            'content':
                'Which supplier should I choose and why? Keep the recommendation short.',
          },
        ],
        'vendor_context': {
          'latitude': userLocation.latitude,
          'longitude': userLocation.longitude,
          'vendor_ids': vendorIds,
        },
      },
    );
    return response.data['reply'] as String;
  }
}
