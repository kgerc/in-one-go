import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/event_entity.dart';

class GeminiApiService {
  final Dio _dio;
  final String apiKey;

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String _model = 'gemini-pro';

  GeminiApiService({
    required this.apiKey,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
  }

  /// Parse voice transcription into structured event
  Future<GeminiEventParseResponse> parseEventFromText(
    String transcription,
  ) async {
    try {
      final prompt = _buildPrompt(transcription);
      final requestBody = {
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.2,
          "topK": 1,
          "topP": 1,
          "maxOutputTokens": 2048,
        },
      };

      final response = await _dio.post(
        '/models/$_model:generateContent',
        queryParameters: {'key': apiKey},
        data: requestBody,
      );

      if (response.statusCode == 200) {
        return _parseResponse(response.data);
      } else {
        throw ServerException(
          message: 'Gemini API error: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(message: 'Connection timeout');
      } else if (e.type == DioExceptionType.badResponse) {
        throw ServerException(
          message: 'Server error: ${e.response?.statusCode}',
        );
      } else {
        throw NetworkException(message: 'Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  String _buildPrompt(String transcription) {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss EEEE');
    final currentDateTime = formatter.format(now);

    return '''
You are an intelligent calendar event parser for Polish language voice input.

IMPORTANT RULES:
1. Return ONLY valid JSON - no markdown, no code blocks, no additional text
2. Parse dates relative to current date/time
3. Use ISO 8601 format for all dates (yyyy-MM-ddTHH:mm:ss)
4. If time is not specified, default to 09:00 for start time
5. Default event duration: 1 hour for meetings/appointments, 30 minutes for reminders/tasks
6. Set confidenceScore based on clarity of input (0.0 to 1.0)

Current date and time: $currentDateTime

User voice command (Polish): "$transcription"

Return this exact JSON structure (no code blocks, no markdown):
{
  "title": "extracted title",
  "description": "additional details or null",
  "startDateTime": "2025-01-15T09:00:00",
  "endDateTime": "2025-01-15T10:00:00",
  "location": "location or null",
  "attendees": ["person1@example.com", "person2@example.com"],
  "eventType": "meeting",
  "priority": "medium",
  "isAllDay": false,
  "confidenceScore": 0.95
}

Field details:
- title: Short, clear title (required)
- description: Additional details if provided (optional)
- startDateTime: ISO 8601 datetime (required)
- endDateTime: ISO 8601 datetime, null if not specified (optional)
- location: Physical or virtual location (optional)
- attendees: Array of email addresses or names (can be empty)
- eventType: must be one of: "meeting", "appointment", "reminder", "task"
- priority: must be one of: "low", "medium", "high", "urgent"
- isAllDay: true if all-day event, false otherwise
- confidenceScore: 0.0-1.0 (>0.8 = high confidence, <0.7 = low confidence)

Examples of Polish date parsing:
- "jutro" = tomorrow at 09:00
- "pojutrze" = day after tomorrow
- "w piątek" = next Friday
- "w przyszły wtorek" = next Tuesday
- "za tydzień" = one week from now
- "15:00" / "o 15" / "o trzeciej" = 3 PM
- "w południe" = 12:00

Return ONLY the JSON object, nothing else.
''';
  }

  GeminiEventParseResponse _parseResponse(Map<String, dynamic> responseData) {
    try {
      final candidates = responseData['candidates'] as List;
      if (candidates.isEmpty) {
        throw const ParsingException(message: 'No response from Gemini');
      }

      final content = candidates[0]['content'];
      final parts = content['parts'] as List;
      if (parts.isEmpty) {
        throw const ParsingException(message: 'Empty response from Gemini');
      }

      String jsonText = parts[0]['text'] as String;

      // Clean up the response - remove markdown code blocks if present
      jsonText = jsonText.trim();
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.substring(7);
      } else if (jsonText.startsWith('```')) {
        jsonText = jsonText.substring(3);
      }
      if (jsonText.endsWith('```')) {
        jsonText = jsonText.substring(0, jsonText.length - 3);
      }
      jsonText = jsonText.trim();

      final Map<String, dynamic> parsedJson = jsonDecode(jsonText);

      return GeminiEventParseResponse.fromJson(parsedJson);
    } catch (e) {
      throw ParsingException(
        message: 'Failed to parse Gemini response: $e',
      );
    }
  }
}

class GeminiEventParseResponse {
  final String title;
  final String? description;
  final DateTime startDateTime;
  final DateTime? endDateTime;
  final String? location;
  final List<String> attendees;
  final EventType eventType;
  final EventPriority priority;
  final bool isAllDay;
  final double confidenceScore;

  GeminiEventParseResponse({
    required this.title,
    this.description,
    required this.startDateTime,
    this.endDateTime,
    this.location,
    this.attendees = const [],
    this.eventType = EventType.meeting,
    this.priority = EventPriority.medium,
    this.isAllDay = false,
    required this.confidenceScore,
  });

  factory GeminiEventParseResponse.fromJson(Map<String, dynamic> json) {
    return GeminiEventParseResponse(
      title: json['title'] as String,
      description: json['description'] as String?,
      startDateTime: DateTime.parse(json['startDateTime'] as String),
      endDateTime: json['endDateTime'] != null
          ? DateTime.parse(json['endDateTime'] as String)
          : null,
      location: json['location'] as String?,
      attendees: (json['attendees'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      eventType: EventType.fromString(json['eventType'] as String),
      priority: EventPriority.fromString(json['priority'] as String),
      isAllDay: json['isAllDay'] as bool? ?? false,
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'startDateTime': startDateTime.toIso8601String(),
      'endDateTime': endDateTime?.toIso8601String(),
      'location': location,
      'attendees': attendees,
      'eventType': eventType.name,
      'priority': priority.name,
      'isAllDay': isAllDay,
      'confidenceScore': confidenceScore,
    };
  }

  // Convert to EventEntity
  EventEntity toEntity() {
    final now = DateTime.now();
    return EventEntity(
      title: title,
      description: description,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      location: location,
      attendees: attendees,
      eventType: eventType,
      priority: priority,
      isAllDay: isAllDay,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
    );
  }

  // Helper: Check if parsing is confident
  bool get isHighConfidence => confidenceScore >= 0.8;

  bool get isLowConfidence => confidenceScore < 0.7;
}
