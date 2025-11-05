import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/core/config/supabase_config.dart';
import 'package:ghost_food/auth/initial_bindings.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ghost_food/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); // Inicializamos GetStorage

  try {
    // Initialize Supabase
    await SupabaseConfig.initialize();
    runApp(const MyApp());
  } catch (e) {
    // If Supabase initialization fails, you might want to show an error screen
    print('Error initializing Supabase: $e');
    // For now, we can show a simple error app
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Failed to initialize app: $e'),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ghost Food',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // AuthGate will decide which page to show
      initialBinding: InitialBindings(),
      home: const GhostFoodSplash(), // This will navigate to AuthGate
      debugShowCheckedModeBanner: false,
    );
  }
}
