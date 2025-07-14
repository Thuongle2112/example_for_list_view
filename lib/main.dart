import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'core/di/injector.dart';
import 'presentation/pages/image_column_page.dart';
import 'presentation/pages/image_listview_page.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MobileAds.instance.initialize();
  await dotenv.load(fileName: '.env');
  init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'PicList',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}

class HomeSwitcher extends StatefulWidget {
  const HomeSwitcher({super.key});

  @override
  State<HomeSwitcher> createState() => _HomeSwitcherState();
}

class _HomeSwitcherState extends State<HomeSwitcher> {
  bool showColumn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Column vs ListView'),
        actions: [
          IconButton(
            icon: Icon(showColumn ? Icons.view_list : Icons.view_column),
            onPressed: () {
              setState(() {
                showColumn = !showColumn;
              });
            },
            tooltip: showColumn ? 'Chuyển sang ListView' : 'Chuyển sang Column',
          ),
        ],
      ),
      body: showColumn ? const ImageColumnPage() : const ImageListViewPage(),
    );
  }
}
