// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ghost_food/domain/entities/product_entity.dart';
// import 'package:ghost_food/presentation/controllers/cook_home_controller.dart';
// import 'package:ghost_food/presentation/widgets/product_form_dialog.dart';


// class ProductCard extends StatelessWidget {
//   final ProductEntity product;

//   const ProductCard({
//     super.key,
//     required this.product,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<CookHomeController>();

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: const Color(0xFF1A1A1A),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           _buildImageSection(),
//           _buildInfoSection(controller, context),
//         ],
//       ),
//     );
//   }

//   Widget _buildImageSection() {
//     return Stack(
//       children: [
//         ClipRRect(
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//           child: Container(
//             height: 180,
//             width: double.infinity,
//             color: const Color(0xFF2A2A2A),
//             child: product.imageUrl != null && product.imageUrl!.isNotEmpty
//                 ? Image.network(
//                     product.imageUrl!,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) =>
//                         _buildPlaceholderImage(),
//                   )
//                 : _buildPlaceholderImage(),
//           ),
//         ),
//         Positioned(
//           top: 12,
//           right: 12,
//           child: _buildAvailabilityBadge(),
//         ),
//         Positioned(
//           top: 12,
//           left: 12,
//           child: _buildCategoryBadge(),
//         ),
//       ],
//     );
//   }

//   Widget _buildInfoSection(CookHomeController controller, BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   product.name,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
//                   ),
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Text(
//                   '\$${product.price.toStringAsFixed(0)}',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             product.description ?? 'Sin descripción.',
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.7),
//               fontSize: 14,
//             ),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildActionButton(
//                   icon: Icons.edit,
//                   label: 'Editar',
//                   color: const Color(0xFF00FFAA),
//                   onTap: () => showDialog(
//                     context: context,
//                     barrierDismissible: false,
//                     builder: (context) => ProductFormDialog(product: product),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _buildActionButton(
//                   icon: Icons.delete_outline,
//                   label: 'Eliminar',
//                   color: const Color(0xFFFF6B6B),
//                   onTap: () =>
//                       _showDeleteConfirmation(context, controller, product),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPlaceholderImage() {
//     return Container(
//       color: const Color(0xFF2A2A2A),
//       child: Center(
//         child: Icon(
//           Icons.restaurant,
//           size: 60,
//           color: Colors.white.withOpacity(0.3),
//         ),
//       ),
//     );
//   }

//   Widget _buildAvailabilityBadge() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: product.available
//             ? const Color(0xFF4CAF50)
//             : const Color(0xFFFF6B6B),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         product.available ? 'Disponible' : 'Agotado',
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 12,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryBadge() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.6),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: const Color(0xFF00FFAA), width: 1),
//       ),
//       child: Text(
//         product.category ?? 'Sin categoría',
//         style: const TextStyle(
//           color: Color(0xFF00FFAA),
//           fontSize: 12,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButton({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: color, width: 1.5),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: color, size: 18),
//             const SizedBox(width: 6),
//             Text(
//               label,
//               style: TextStyle(color: color, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showDeleteConfirmation(BuildContext context, CookHomeController controller, ProductEntity product) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF1A1A1A),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Row(
//           children: [
//             Icon(Icons.warning_amber_rounded, color: Color(0xFFFF6B6B)),
//             SizedBox(width: 8),
//             Text('¿Eliminar producto?', style: TextStyle(color: Color(0xFFFF6B6B))),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('¿Estás seguro de que quieres eliminar "${product.name}"?', style: TextStyle(color: Colors.white.withOpacity(0.7))),
//             const SizedBox(height: 12),
//             Text('Esta acción no se puede deshacer.', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontStyle: FontStyle.italic)),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
//           ),
//           ElevatedButton.icon(
//             onPressed: () async => await controller.deleteProduct(product.id, product.name),
//             style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B)),
//             icon: const Icon(Icons.delete, color: Colors.white),
//             label: const Text('Eliminar', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
// }