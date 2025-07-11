import 'package:hive/hive.dart';
import 'ai_chat_page.dart';

part 'chat_message_hive.g.dart';

@HiveType(typeId: 1)
class ChatMessageHive extends HiveObject {
  @HiveField(0)
  String text;

  @HiveField(1)
  bool isUser;

  @HiveField(2)
  int timestamp;

  @HiveField(3)
  String? imageUrl;

  @HiveField(4)
  bool isLoading;

  ChatMessageHive({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imageUrl,
    this.isLoading = false,
  });

  factory ChatMessageHive.fromChatMessage(ChatMessage msg) => ChatMessageHive(
    text: msg.text,
    isUser: msg.isUser,
    timestamp: msg.timestamp.millisecondsSinceEpoch,
    imageUrl: msg.imageUrl,
    isLoading: msg.isLoading,
  );

  ChatMessage toChatMessage() => ChatMessage(
    text: text,
    isUser: isUser,
    timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
    imageUrl: imageUrl,
    isLoading: isLoading,
  );
}
