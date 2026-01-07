import 'package:foundation_models_framework/foundation_models_framework.dart';

final foundationModels = FoundationModelsFramework.instance;

class FoundationModelFrameworkUtils{

  static Future<String> getTranslatedLanguages(String rawText) async {
    final customSession = foundationModels.createSession(
      instructions: 'You are expert in translating text from one language to another. The language is HTML, keep the format the same. Only translate the text.',
      guardrailLevel: GuardrailLevel.permissive,
    );
    try {
      final availability = await foundationModels.checkAvailability();
      if (availability.isAvailable) {
        print('Foundation Models is available on iOS ${availability.osVersion}');
        // Proceed with AI operations
      } else {
        print('Foundation Models not available: ${availability.errorMessage}');
      }
      final response = await customSession.respond(prompt: rawText);

      if (response.errorMessage == null) {
        return response.content;
        print('Response: ${response.content}');

        // Access transcript history
        if (response.transcriptEntries != null) {
          for (final entry in response.transcriptEntries!) {
            print('${entry?.role}: ${entry?.content}');
          }
        }
      } else {
        return "";
        print('Error: ${response.errorMessage}');
      }
    } catch (e) {
      print('Failed to get response: $e');
      return "";
    }
  }
}