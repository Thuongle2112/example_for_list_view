import 'package:example_for_list_view/presentation/bloc/image_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/injector.dart';
import '../bloc/news_bloc.dart';
import 'home/image_listview_page.dart';
import 'news/news_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          BlocProvider(
            create: (_) => sl<ImageBloc>()..add(FetchImagesEvent()),
            child: const ImageListViewPage(),
          ),
          BlocProvider(create: (_) => sl<NewsBloc>(), child: const NewsPage()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          _pageController.jumpToPage(i);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.image), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'News'),
        ],
      ),
    );
  }
}
