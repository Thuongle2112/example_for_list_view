import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../bloc/image_bloc.dart';
import '../../../domain/entities/image_entity.dart';
import '../detail/image_detail_page.dart';
import '../qr/qr_generate_page.dart';
import '../ai/ai_chat_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:local_auth/local_auth.dart';
import 'widgets/image_card.dart';
import 'widgets/shimmer_card.dart';

class ImageListViewPage extends StatefulWidget {
  const ImageListViewPage({super.key});

  @override
  State<ImageListViewPage> createState() => _ImageListViewPageState();
}

class _ImageListViewPageState extends State<ImageListViewPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController = RefreshController();

  late AnimationController _favoriteController;
  late final Connectivity _connectivity;
  late final Stream<ConnectivityResult> _connectivityStream;
  final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );
  bool _hasConnection = true;
  bool _firstCheckDone = false;
  String testDevice = 'TP1A.220905.001';
  int maxFailedLoadAttempts = 3;
  RewardedInterstitialAd? _rewardedInterstitialAd;
  int _numRewardedInterstitialLoadAttempts = 0;
  // final int _lastAdShownIndex = 0;
  final Map<int, GlobalKey> _itemKeys = {};
  // final int _maxVisibleIndex = -1;
  final Set<int> _adShownIndexes = {};
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _favoriteController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: ['TP1A.220905.001']),
    );
    _createRewardedInterstitialAd();
    _connectivity = Connectivity();
    _connectivityStream = _connectivity.onConnectivityChanged;
    _connectivityStream.listen(_onConnectivityChanged);
    _checkInitialConnection();
    logDeviceId();
  }

  Future<void> logDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      print('Android device ID: ${androidInfo.id}');
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      print('IOS device ID: ${iosInfo.identifierForVendor}');
    }
  }

  void _createRewardedInterstitialAd() {
    RewardedInterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5354046379'
          : 'ca-app-pub-3940256099942544/6978759866',
      request: request,
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (RewardedInterstitialAd ad) {
          print('$ad loaded.');
          _rewardedInterstitialAd = ad;
          _numRewardedInterstitialLoadAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('RewardedInterstitialAd failed to load: $error');
          _rewardedInterstitialAd = null;
          _numRewardedInterstitialLoadAttempts += 1;
          if (_numRewardedInterstitialLoadAttempts < maxFailedLoadAttempts) {
            _createRewardedInterstitialAd();
          }
        },
      ),
    );
  }

  void _showRewardedInterstitialAd() {
    if (_rewardedInterstitialAd == null) {
      print('Warning: attempt to show rewarded interstitial before loaded.');
      return;
    }
    _rewardedInterstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(
          onAdShowedFullScreenContent: (RewardedInterstitialAd ad) =>
              print('$ad onAdShowedFullScreenContent.'),
          onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
            print('$ad onAdDismissedFullScreenContent.');
            ad.dispose();
            _createRewardedInterstitialAd();
          },
          onAdFailedToShowFullScreenContent:
              (RewardedInterstitialAd ad, AdError error) {
                print('$ad onAdFailedToShowFullScreenContent: $error');
                ad.dispose();
                _createRewardedInterstitialAd();
              },
        );

    _rewardedInterstitialAd!.setImmersiveMode(true);
    _rewardedInterstitialAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
      },
    );
    _rewardedInterstitialAd = null;
  }

  Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    _onConnectivityChanged(result);
    setState(() {
      _firstCheckDone = true;
    });
  }

  void _onConnectivityChanged(ConnectivityResult result) {
    final connected = result != ConnectivityResult.none;
    if (connected && !_hasConnection) {
      // Nếu vừa có mạng trở lại, tự động load lại data
      context.read<ImageBloc>().add(FetchImagesEvent());
    }
    setState(() {
      _hasConnection = connected;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ImageBloc>().add(LoadMoreImages());
    }

    final RenderBox? listViewBox = context.findRenderObject() as RenderBox?;
    if (listViewBox == null) return;
    final listViewOffset = listViewBox.localToGlobal(Offset.zero).dy;
    final listViewHeight = listViewBox.size.height;

    _itemKeys.forEach((index, key) {
      final ctx = key.currentContext;
      if (ctx != null) {
        final RenderBox box = ctx.findRenderObject() as RenderBox;
        final offset = box.localToGlobal(Offset.zero).dy - listViewOffset;
        if (offset < listViewHeight && offset + box.size.height > 0) {
          // Nếu index này là mốc 30, 60, 90... và chưa từng hiện quảng cáo
          if ((index + 1) % 30 == 0 && !_adShownIndexes.contains(index)) {
            _showRewardedInterstitialAd();
            _adShownIndexes.add(index);
          }
        }
      }
    });
  }

  void _onRefresh() async {
    context.read<ImageBloc>().add(FetchImagesEvent());
    _refreshController.refreshCompleted();
  }

  void _handleQrResult(dynamic qrResult) {
    if (qrResult is Map<String, dynamic>) {
      // Handle JSON data from QR
      // final albumId = qrResult['albumId'];
      final title = qrResult['title'];
      final images = qrResult['images'] as List<dynamic>?;

      if (images != null && images.isNotEmpty) {
        // Convert to ImageEntity list
        final imageEntities = images
            .map((img) {
              if (img is String) {
                return ImageEntity(
                  id: img.hashCode.toString(),
                  author: 'QR Album',
                  downloadUrl: img,
                );
              }
              return null;
            })
            .whereType<ImageEntity>()
            .toList();

        if (imageEntities.isNotEmpty) {
          // Load images from QR - for now just show a message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Đã mở album: $title (${imageEntities.length} ảnh)',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } else if (qrResult is String) {
      // Handle plain text from QR
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('QR content: $qrResult'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  Future<bool> _authenticate() async {
    final bool canAuthenticate =
        await _localAuth.canCheckBiometrics ||
        await _localAuth.isDeviceSupported();
    if (!canAuthenticate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thiết bị không hỗ trợ sinh trắc học!')),
      );
      return false;
    }
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Vui lòng xác thực để tiếp tục',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (!didAuthenticate) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Xác thực thất bại!')));
      }
      return didAuthenticate;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi xác thực: $e')));
      return false;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    _favoriteController.dispose();
    super.dispose();
    _rewardedInterstitialAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Lottie.asset(
          'assets/animations/Image.json',
          width: 48,
          height: 48,
          fit: BoxFit.contain,
          repeat: true,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.fingerprint),
            tooltip: 'Xác thực vân tay/Face ID',
            onPressed: _authenticate,
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'AI Image Generator',
            onPressed: () async {
              final bool didAuthenticate = await _authenticate();
              if (didAuthenticate) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AiChatPage()),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code),
            tooltip: 'Tạo QR cho album',
            onPressed: () async {
              // Lấy danh sách ảnh hiện tại từ Bloc
              final state = context.read<ImageBloc>().state;
              if (state is ImageLoaded && state.images.isNotEmpty) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QrGeneratePage(
                      images: state.images,
                      albumName: 'My Photo Album',
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No images to create QR for')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Quét QR mở album',
            onPressed: () async {
              final qrResult = context.push('/qr-scan');
              _handleQrResult(qrResult);
            },
          ),
        ],
      ),
      body: !_hasConnection && _firstCheckDone
          ? _buildNoInternet()
          : BlocBuilder<ImageBloc, ImageState>(
              builder: (context, state) {
                if (state is ImageLoading) {
                  return ListView.builder(
                    itemCount: 6,
                    itemBuilder: (context, index) => ShimmerCard(),
                  );
                } else if (state is ImageLoaded) {
                  if (state.images.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text('No images found'),
                          SizedBox(height: 8),
                          Text('Pull down to refresh'),
                        ],
                      ),
                    );
                  }

                  return SmartRefresher(
                    controller: _refreshController,
                    onRefresh: _onRefresh,
                    enablePullDown: true,
                    header: const WaterDropHeader(),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: state.hasMore
                          ? state.images.length + 1
                          : state.images.length,
                      itemBuilder: (context, index) {
                        if (!_itemKeys.containsKey(index)) {
                          _itemKeys[index] = GlobalKey();
                        }
                        if (index >= state.images.length) {
                          return Padding(
                            padding: EdgeInsets.all(16.0),
                            // child: Center(child: ShimmerCard()),
                            child: Center(
                              child: Lottie.asset(
                                'assets/animations/lottie_lego.json',
                                width: MediaQuery.of(context).size.width * 0.2,
                                height: MediaQuery.of(context).size.width * 0.2,
                                repeat: true,
                                animate: true,
                              ),
                            ),
                          );
                        }
                        final img = state.images[index];
                        return ImageCard(
                          img: img,
                          favoriteController: _favoriteController,
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        ImageDetailPage(image: img),
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                              ),
                            );
                          },
                          repaintKey: _itemKeys[index],
                        );
                      },
                    ),
                  );
                } else if (state is ImageError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text('Error: ${state.message}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ImageBloc>().add(FetchImagesEvent());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
    );
  }

  Widget _buildNoInternet() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Không có kết nối Internet',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
          const SizedBox(height: 8),
          const Text('Vui lòng kiểm tra lại kết nối mạng.'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _checkInitialConnection,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
