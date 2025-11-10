import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/domain/entities/recipe_entity.dart';
import 'package:ghost_food/presentation/controllers/active_orders_controller.dart';
import 'package:ghost_food/presentation/controllers/agreement_controller.dart';
import 'package:ghost_food/presentation/controllers/cook_home_controller.dart';
import 'package:ghost_food/presentation/controllers/market_place_controller.dart';
import 'package:ghost_food/presentation/widgets/ai_recipes_tab.dart';
import 'package:ghost_food/presentation/widgets/custom_app_bar.dart';
import 'package:ghost_food/presentation/widgets/pending_orders_tab.dart';
import 'package:ghost_food/presentation/widgets/recipe_marketplace_tab.dart';
import 'package:ghost_food/presentation/widgets/active_orders_tab.dart';

class CookHomePage extends StatefulWidget {
  const CookHomePage({super.key});

  @override
  State<CookHomePage> createState() => _CookHomePageState();
}

class _CookHomePageState extends State<CookHomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cookHomeController = Get.put(CookHomeController());
    final marketplaceController = Get.find<MarketPlaceController>();
    final agreementController = Get.find<AgreementController>();
    final orderController = Get.find<ActiveOrderController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: const CustomAppBar(title: 'Cocina GhostFood'),
      body: Column(
        children: [
          _buildTabBar(marketplaceController, orderController),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                RecipeMarketplaceTab(
                  cookHomeController: cookHomeController,
                  marketplaceController: marketplaceController,
                  agreementController: agreementController,
                ),
                AiRecipesTab(
                  cookHomeController: cookHomeController,
                  marketplaceController: marketplaceController,
                ),
                PendingOrdersTab(
                  cookHomeController: cookHomeController,
                  orderController: orderController,
                ),
                ActiveOrdersTab(
                  cookHomeController: cookHomeController,
                  orderController: orderController,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(
    MarketPlaceController marketplaceController,
    ActiveOrderController orderController,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF00FFB8),
          borderRadius: BorderRadius.circular(25),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        tabs: [
          const Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.storefront, size: 18),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Recetas',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Obx(() {
              final aiCount = marketplaceController.allRecipes
                  .where((r) => r.type == RecipeType.aiGenerated)
                  .length;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, size: 18),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'IA ($aiCount)',
                      overflow: TextOverflow.ellipsis, maxLines: 1,
                    ),
                  ),
                ],
              );
            }),
          ),
          Tab(
            child: Obx(() {
              final pendingCount = orderController.pendingOrders.length;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Badge(
                    label: Text('$pendingCount'),
                    isLabelVisible: pendingCount > 0,
                    child:
                        const Icon(Icons.notifications_active_outlined, size: 18),
                  ),
                  const SizedBox(width: 4),
                  const Flexible(
                    child: Text(
                      'Pedidos',
                      overflow: TextOverflow.ellipsis, maxLines: 1,
                    ),
                  ),
                ],
              );
            }),
          ),
          const Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.outdoor_grill_outlined, size: 18),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Activos',
                    overflow: TextOverflow.ellipsis, maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
