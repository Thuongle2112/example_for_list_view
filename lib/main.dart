import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/di/injector.dart';
import 'presentation/bloc/image_bloc.dart';
import 'presentation/pages/image_column_page.dart';
import 'presentation/pages/image_listview_page.dart';
import 'package:example_for_list_view/presentation/pages/qr/qr_scan_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gallery',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: BlocProvider(
        create: (_) => sl<ImageBloc>()..add(FetchImagesEvent()),
        child: const HomeSwitcher(),
      ),
      routes: {'/qr-scan': (context) => const QrScanPage()},
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
