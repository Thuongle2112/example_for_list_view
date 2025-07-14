import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/image_listview_page.dart';
import '../../presentation/pages/qr/qr_scan_page.dart';
import '../../presentation/pages/ai/ai_chat_page.dart';
import '../di/injector.dart';
import '../../presentation/bloc/image_bloc.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<ImageBloc>()..add(FetchImagesEvent()),
        child: const ImageListViewPage(),
      ),
    ),
    GoRoute(
      path: '/qr-scan',
      builder: (context, state) => const QrScanPage(),
    ),
    GoRoute(
      path: '/ai-chat',
      builder: (context, state) => const AiChatPage(),
    ),
  ],
); 