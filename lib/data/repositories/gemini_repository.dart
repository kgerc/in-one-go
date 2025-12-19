import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/i_gemini_repository.dart';
import '../data_sources/remote/gemini_api_service.dart';

class GeminiRepository implements IGeminiRepository {
  final GeminiApiService apiService;

  GeminiRepository({required this.apiService});

  @override
  Future<Either<Failure, ParsedEvent>> parseEventFromText(
    String transcription,
  ) async {
    try {
      final response = await apiService.parseEventFromText(transcription);

      return Right(
        ParsedEvent(
          event: response.toEntity(),
          confidenceScore: response.confidenceScore,
        ),
      );
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ParsingException catch (e) {
      return Left(ParsingFailure(message: e.message));
    } catch (e) {
      return Left(
        UnexpectedFailure(message: 'Failed to parse event from text: $e'),
      );
    }
  }
}
