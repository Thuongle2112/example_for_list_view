import 'package:example_for_list_view/core/di/injector.dart';
import 'package:example_for_list_view/presentation/bloc/news_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'news_card.dart';

class NewsFilterPage extends StatefulWidget {
  const NewsFilterPage({Key? key}) : super(key: key);

  @override
  State<NewsFilterPage> createState() => _NewsFilterPageState();
}

class _NewsFilterPageState extends State<NewsFilterPage> {
  String? _selectedCategory;
  final categories = [
    'business',
    'entertainment',
    'general',
    'health',
    'science',
    'sports',
    'technology',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NewsBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Lọc tin tức')),
        body: Column(
          children: [
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return ChoiceChip(
                    label: Text(cat),
                    selected: _selectedCategory == cat,
                    onSelected: (_) => _onCategorySelected(context, cat),
                  );
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<NewsBloc, NewsState>(
                builder: (context, state) {
                  if (state is NewsLoading) {
                    return Center(
                      child: Lottie.asset(
                        'assets/animations/lottie_lego.json',
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                        repeat: true,
                      ),
                    );
                  } else if (state is NewsLoaded) {
                    if (state.articles.isEmpty) {
                      return const Center(child: Text('Không có kết quả.'));
                    }
                    return ListView.builder(
                      itemCount: state.articles.length,
                      itemBuilder: (context, index) {
                        final article = state.articles[index];
                        return NewsCard(
                          article: article,
                          onTap: () async {
                            final url = Uri.parse(article.url);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                        );
                      },
                    );
                  } else if (state is NewsError) {
                    return Center(child: Text('Lỗi: ${state.message}'));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCategorySelected(BuildContext context, String? category) {
    setState(() => _selectedCategory = category);
    if (category != null && category.isNotEmpty) {
      context.read<NewsBloc>().add(FetchNews(category: category));
    }
  }
}
