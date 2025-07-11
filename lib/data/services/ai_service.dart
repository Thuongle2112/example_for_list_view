import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  static const String _baseUrl = 'https://api.replicate.com/v1/predictions';
  static const String _model = 'stability-ai/sdxl:39ed52f2a78e934b3ba6e2a89f5b1c712de7dfea535525255b1aa35c5565e08b';
  
  static String get _apiKey => dotenv.env['REPLICATE_API_KEY'] ?? '';

  static Future<String?> generateImage(String prompt) async {
    try {
      // Tạo prediction
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Token $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'version': _model.split(':')[1],
          'input': {
            'prompt': prompt,
            'width': 1024,
            'height': 1024,
            'num_outputs': 1,
            'scheduler': 'K_EULER',
            'num_inference_steps': 50,
            'guidance_scale': 7.5,
            'seed': DateTime.now().millisecondsSinceEpoch,
          },
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final predictionId = data['id'];
        
        // Poll cho kết quả
        return await _pollForResult(predictionId);
      } else {
        print('Error creating prediction: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error generating image: $e');
      return null;
    }
  }

  static Future<String?> _pollForResult(String predictionId) async {
    const maxAttempts = 30;
    int attempts = 0;
    
    while (attempts < maxAttempts) {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/$predictionId'),
          headers: {
            'Authorization': 'Token $_apiKey',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final status = data['status'];
          
          if (status == 'succeeded') {
            final outputs = data['output'] as List;
            if (outputs.isNotEmpty) {
              return outputs.first as String;
            }
          } else if (status == 'failed') {
            print('Prediction failed: ${data['error']}');
            return null;
          }
        }
        
        await Future.delayed(const Duration(seconds: 2));
        attempts++;
      } catch (e) {
        print('Error polling result: $e');
        return null;
      }
    }
    
    print('Timeout waiting for image generation');
    return null;
  }

  static List<String> getPresetPrompts() {
    return [
      'A beautiful sunset over mountains, digital art',
      'A cute cat sitting on a windowsill, anime style',
      'A futuristic city with flying cars, sci-fi art',
      'A magical forest with glowing mushrooms, fantasy art',
      'A portrait of a robot with expressive eyes, cyberpunk style',
      'A peaceful lake with cherry blossoms, watercolor style',
      'A steampunk airship flying through clouds, detailed art',
      'A cozy coffee shop interior, warm lighting, realistic',
    ];
  }
} 