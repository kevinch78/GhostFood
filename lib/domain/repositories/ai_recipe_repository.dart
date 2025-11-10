abstract class AiRecipeRepository {
  Future<AiChatResponse> sendMessage({
    required String userMessage,
    required List<ChatMessage> conversationHistory,
  });
}

class ChatMessage {
  final String role; // 'user' o 'assistant'
  final String content;

  const ChatMessage({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };
}

class AiChatResponse {
  final bool success;
  final String message;
  final RecipeData? recipe; // null si no es una receta completa

  const AiChatResponse({
    required this.success,
    required this.message,
    this.recipe,
  });
}

class RecipeData {
  final String nombre;
  final String descripcion;
  final String categoria;
  final int precioSugerido; 
  final List<String> ingredientes;
  final List<String> pasos;

  const RecipeData({
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.precioSugerido,
    required this.ingredientes,
    required this.pasos,
  });

  factory RecipeData.fromJson(Map<String, dynamic> json) {
    return RecipeData(
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      categoria: json['categoria'],
      precioSugerido: json['precioSugerido'] ?? 15000, // ← AGREGADO con fallback
      ingredientes: List<String>.from(json['ingredientes']),
      pasos: List<String>.from(json['pasos']),
    );
  }
}