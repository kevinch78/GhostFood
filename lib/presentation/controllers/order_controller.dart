import 'package:get/get.dart';
import 'package:ghost_food/presentation/controllers/cart_controller.dart';
import 'package:ghost_food/domain/repositories/order_repository.dart';

class OrderController extends GetxController {
  final OrderRepository _orderRepository = Get.find();

  Future<bool> createOrdersFromCart(List<CartItem> cartItems) async {
    if (cartItems.isEmpty) return false;

    try {
      // Creamos un pedido por cada item en el carrito.
      // Usamos Future.wait para que se ejecuten en paralelo y esperamos a que todos terminen.
      await Future.wait(cartItems.map((item) {
        // Aquí asumimos que cada item del carrito se convierte en un pedido individual.
        return _orderRepository.createOrderFromCartItem(item);
      }));
      return true; // Éxito
    } catch (e) {
      return false; // Falla
    }
  }
}