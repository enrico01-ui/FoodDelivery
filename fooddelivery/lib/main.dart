import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fooddelivery/page/openPage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fooddelivery/entity/menu.dart';
import 'package:fooddelivery/entity/restaurant.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    // Force Hybrid Composition mode.
    mapsImplementation.useAndroidViewSurface = false;
  }
  Hive.registerAdapter(RestaurantAdapter());
  Hive.registerAdapter(MenuAdapter());
  await Hive.openBox<Menu>('cart');
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OpenPage(),
    );
  }
}
