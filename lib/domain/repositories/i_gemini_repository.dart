import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/event_entity.dart';

abstract class IGeminiRepository {
  /// Parse voice transcription into structured event
  Future<Either<Failure, ParsedEvent>> parseEventFromText(String transcription);
}

/// Parsed event from Gemini with confidence score
class ParsedEvent {
  final EventEntity event;
  final double confidenceScore;

  const ParsedEvent({
    required this.event,
    required this.confidenceScore,
  });

  bool get isHighConfidence => confidenceScore >= 0.8;
  bool get isLowConfidence => confidenceScore < 0.7;
}
