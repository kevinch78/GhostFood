import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ghost_food/domain/entities/recipe_entity.dart';

/// Representa un item dentro del carrito de compras.
/// Este objeto es independiente de ProductEntity para "congelar" el precio y nombre al momento de la compra.
class CartItem {
  final String recipeId;
  final String name;
  final String? imageUrl;
  final double price;
  final RxInt quantity;

  CartItem({
    required this.recipeId,
    required this.name,
    this.imageUrl,
    required this.price,
    int initialQuantity = 1,
  })
      : quantity = initialQuantity.obs;

  double get subtotal => price * quantity.value;

  // Helper para crear un CartItem desde un RecipeEntity
  factory CartItem.fromRecipe(RecipeEntity recipe) {
    return CartItem(
      recipeId: recipe.id,
      name: recipe.name,
      imageUrl: recipe.imageUrl,
      price: recipe.basePrice,
    );
  }

  // --- MÉTODOS PARA PERSISTENCIA ---

  /// Convierte el CartItem a un Map para poder guardarlo.
  Map<String, dynamic> toJson() {
    return {
      'recipeId': recipeId,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity.value,
    };
  }

  /// Crea un CartItem desde un Map leído del almacenamiento.
  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Hacemos el constructor más robusto. Si falta algún dato esencial,
    // lanzamos una excepción para que no se cargue el item corrupto.
    if (json['recipeId'] == null || json['name'] == null || json['price'] == null) {
      throw const FormatException("CartItem guardado es inválido, faltan datos.");
    }

    return CartItem(
      recipeId: json['recipeId'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'],
      price: (json['price'] as num).toDouble(),
      initialQuantity: json['quantity'] ?? 1,
    );
  }
}

class CartController extends GetxController {
  final _storage = GetStorage(); // Instancia de GetStorage
  // --- STATE ---
  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final isProcessing = false.obs;

  // --- GETTERS COMPUTADOS ---

  /// Número total de unidades en el carrito (sumando cantidades).
  int get itemCount =>
      cartItems.fold(0, (sum, item) => sum + item.quantity.value);

  /// Subtotal de todos los productos.
  double get subtotal =>
      cartItems.fold(0.0, (sum, item) => sum + item.subtotal);

  /// Costo de envío (simulado).
  double get deliveryFee => subtotal > 0 ? 50.0 : 0.0; // Simulado

  /// Costo total del pedido.
  double get total => subtotal + deliveryFee;

  @override
  void onInit() {
    super.onInit();
    _loadCartFromStorage();
    // Cada vez que el carrito cambie, lo guardamos.
    ever(cartItems, (_) => _saveCartToStorage());
  }

  // --- ACTIONS ---

  /// Añade un producto al carrito. Si ya existe, incrementa su cantidad.
  void addItem(RecipeEntity recipe) {
    final existingItemIndex =
        cartItems.indexWhere((item) => item.recipeId == recipe.id);

    if (existingItemIndex != -1) {
      // Si el producto ya está en el carrito, solo incrementa la cantidad.
      cartItems[existingItemIndex].quantity.value++;
    } else {
      // Si es un producto nuevo, lo añade a la lista.
      cartItems.add(CartItem.fromRecipe(recipe));
    }

    Get.snackbar(
      '¡Agregado!',
      '${recipe.name} añadido al carrito',
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Actualiza la cantidad de un item. Si es 0 o menos, lo elimina.
  void updateQuantity(String recipeId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(recipeId);
      return;
    }
    
    final index = cartItems.indexWhere((i) => i.recipeId == recipeId);
    if (index != -1) {
      cartItems[index].quantity.value = newQuantity;
    }
  }

  /// Elimina un producto del carrito.
  void removeItem(String recipeId) {
    cartItems.removeWhere((i) => i.recipeId == recipeId);
  }

  /// Vacía completamente el carrito de compras.
  void clear() {
    cartItems.clear();
  }

  // --- MÉTODOS DE PERSISTENCIA ---

  /// Guarda la lista actual del carrito en el almacenamiento local.
  void _saveCartToStorage() {
    final List<Map<String, dynamic>> cartData =
        cartItems.map((item) => item.toJson()).toList();
    _storage.write('cart', cartData);
  }

  /// Carga el carrito desde el almacenamiento local al iniciar el controlador.
  void _loadCartFromStorage() {
    final List<dynamic>? cartData = _storage.read<List<dynamic>>('cart');
    if (cartData != null) {
      final validItems = <CartItem>[];
      for (final itemData in cartData) {
        try {
          validItems.add(CartItem.fromJson(itemData as Map<String, dynamic>));
        } catch (e) {
          // Si un item del carrito guardado es inválido, simplemente lo ignoramos.
          print('Error al cargar un item del carrito, será ignorado: $e');
        }
      }
      cartItems.value = validItems;
    }
  }
}