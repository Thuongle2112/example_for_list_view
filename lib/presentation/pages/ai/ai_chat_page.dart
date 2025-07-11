import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import '../../../data/services/ai_service.dart';
import 'ai_image_viewer_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'chat_message_hive.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isGenerating = false;
  String? _generatedImageUrl;
  List<ChatMessage> _messages = [];
  List<String> _presetPrompts = [];

  late Box<ChatMessageHive> _chatBox;

  @override
  void initState() {
    super.initState();
    _initHive();
    _presetPrompts = AiService.getPresetPrompts();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ChatMessageHiveAdapter());
    }
    _chatBox = await Hive.openBox<ChatMessageHive>('ai_chat_history');
    _loadHistory();
  }

  void _loadHistory() {
    final history = _chatBox.values.map((e) => e.toChatMessage()).toList();
    setState(() {
      _messages = history.isNotEmpty ? history : [];
      if (_messages.isEmpty) _addWelcomeMessage();
    });
  }

  Future<void> _saveHistory() async {
    await _chatBox.clear();
    await _chatBox.addAll(_messages.map((e) => ChatMessageHive.fromChatMessage(e)));
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      text: 'Xin chào! Tôi là AI Assistant. Hãy mô tả ảnh bạn muốn tạo và tôi sẽ giúp bạn tạo ra nó! 🎨',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    _chatBox.close();
    super.dispose();
  }

  Future<void> _generateImage() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _messages.add(ChatMessage(
        text: prompt,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _messages.add(ChatMessage(
        text: 'Đang tạo ảnh...',
        isUser: false,
        timestamp: DateTime.now(),
        isLoading: true,
      ));
    });
    await _saveHistory();

    _promptController.clear();
    _scrollToBottom();

    try {
      final imageUrl = await AiService.generateImage(prompt);
      
      setState(() {
        _messages.removeLast(); // Remove loading message
        if (imageUrl != null) {
          _messages.add(ChatMessage(
            text: 'Đây là ảnh tôi đã tạo cho bạn!',
            isUser: false,
            timestamp: DateTime.now(),
            imageUrl: imageUrl,
          ));
          _generatedImageUrl = imageUrl;
        } else {
          _messages.add(ChatMessage(
            text: 'Xin lỗi, tôi không thể tạo ảnh lúc này. Vui lòng thử lại sau.',
            isUser: false,
            timestamp: DateTime.now(),
          ));
        }
      });
      await _saveHistory();
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add(ChatMessage(
          text: 'Có lỗi xảy ra: $e',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      await _saveHistory();
    } finally {
      setState(() {
        _isGenerating = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _usePresetPrompt(String prompt) {
    _promptController.text = prompt;
  }

  void _clearHistory() async {
    await _chatBox.clear();
    setState(() {
      _messages.clear();
      _addWelcomeMessage();
    });
    await _saveHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Image Generator'),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Xóa lịch sử chat',
            onPressed: _clearHistory,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hướng dẫn sử dụng'),
                  content: const Text(
                    '• Mô tả chi tiết ảnh bạn muốn tạo\n'
                    '• Sử dụng các prompt có sẵn để tham khảo\n'
                    '• Thêm style như "anime", "realistic", "digital art"\n'
                    '• Quá trình tạo ảnh có thể mất 1-2 phút',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Preset prompts
          if (_presetPrompts.isNotEmpty)
            Container(
              height: 120,
              padding: const EdgeInsets.all(8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _presetPrompts.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(
                        _presetPrompts[index].split(',')[0],
                        style: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () => _usePresetPrompt(_presetPrompts[index]),
                      backgroundColor: Colors.purple[100],
                    ),
                  );
                },
              ),
            ),
          
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageWidget(message);
              },
            ),
          ),
          
          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    decoration: InputDecoration(
                      hintText: 'Mô tả ảnh bạn muốn tạo...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _generateImage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.purple[600],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                    onPressed: _isGenerating ? null : _generateImage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageWidget(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isUser) const Spacer(),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: message.isUser ? Colors.purple[600] : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.isLoading)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Lottie.asset(
                          'assets/animations/lottie_lego.json',
                          repeat: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Đang tạo ảnh...'),
                    ],
                  )
                else
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                    ),
                  ),
                if (message.imageUrl != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              AiImageViewerPage(
                            imageUrl: message.imageUrl!,
                            prompt: message.text,
                          ),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                    child: Hero(
                      tag: 'ai_image_${message.imageUrl}',
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: message.imageUrl!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: double.infinity,
                              height: 200,
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: double.infinity,
                              height: 200,
                              color: Colors.grey[300],
                              child: const Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!message.isUser) const Spacer(),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? imageUrl;
  final bool isLoading;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imageUrl,
    this.isLoading = false,
  });
} 