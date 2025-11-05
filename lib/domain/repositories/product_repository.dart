
import 'dart:typed_data'; // Necesario para Uint8List
import 'package:ghost_food/domain/entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProductsByCook(String cookId);
  Future<ProductEntity> createProduct(ProductEntity product);
  Future<ProductEntity> updateProduct(ProductEntity product);
  Future<void> deleteProduct(String productId);
  Future<List<ProductEntity>> getAllAvailableProducts();
  // ¡Aquí estaba el método que faltaba!
  Future<String> uploadProductImage({
    required Uint8List imageBytes,
    required String fileName,
    required String cookId,
  });
}
