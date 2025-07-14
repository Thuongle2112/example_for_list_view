import 'package:example_for_list_view/core/di/injector.dart';
import 'package:example_for_list_view/presentation/bloc/news_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import 'news_card.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsSearchPage extends StatefulWidget {
  const NewsSearchPage({Key? key}) : super(key: key);

  @override
  State<NewsSearchPage> createState() => _NewsSearchPageState();
}

class _NewsSearchPageState extends State<NewsSearchPage> {
  final TextEditingController _controller = TextEditingController();
  String? _lastQuery;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NewsBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Tìm kiếm tin tức')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Nhập từ khóa...',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.all(8),
                      ),
                      onSubmitted: (_) => _onSearch(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _onSearch(context),
                    child: const Icon(Icons.search),
                  ),
                ],
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

  void _onSearch(BuildContext context) {
    final query = _controller.text.trim();
    if (query.isNotEmpty && query != _lastQuery) {
      _lastQuery = query;
      context.read<NewsBloc>().add(SearchNews(query));
    }
  }
}
