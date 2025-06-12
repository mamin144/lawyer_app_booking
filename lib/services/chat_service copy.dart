import 'package:signalr_netcore/signalr_client.dart';
import 'dart:convert';
import 'dart:developer' as developer;

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final String messageType;
  final DateTime timestamp;
  final String timestampFormatted;
  final bool isRead;
  final DateTime? readAt;
  final String consultationId;
  final String? caseDelegationId;
  final String senderName;
  final String reciverName;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.messageType,
    required this.timestamp,
    required this.timestampFormatted,
    required this.isRead,
    this.readAt,
    required this.consultationId,
    this.caseDelegationId,
    required this.senderName,
    required this.reciverName,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      content: json['content'] as String,
      messageType: json['messageType'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      timestampFormatted: json['timestampFormatted'] as String,
      isRead: json['isRead'] as bool,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      consultationId: json['consultationId'] as String,
      caseDelegationId: json['caseDelegationId'] as String?,
      senderName: json['senderName'] as String,
      reciverName: json['reciverName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'messageType': messageType,
      'timestamp': timestamp.toIso8601String(),
      'timestampFormatted': timestampFormatted,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'consultationId': consultationId,
      'caseDelegationId': caseDelegationId,
      'senderName': senderName,
      'reciverName': reciverName,
    };
  }
}

class ChatService {
  late HubConnection hubConnection;
  final String baseUrl;
  final String userId;
  final String token;
  final void Function(ChatMessage) onMessageReceived;
  final void Function(String) onError;
  final void Function(String) onMessageRead;

  ChatService({
    required this.baseUrl,
    required this.userId,
    required this.token,
    required this.onMessageReceived,
    required this.onError,
    required this.onMessageRead,
  });

  Future<void> connect() async {
    final hubUrl = '$baseUrl/hubs/chathub?access_token=$token';
    developer.log('Connecting to SignalR hub at: $hubUrl');

    hubConnection = HubConnectionBuilder().withUrl(hubUrl).build();

    hubConnection.on('ReceiveMessage', (args) {
      if (args != null && args.isNotEmpty) {
        final messageJson = args[0] as String;
        developer.log('📨 Received message: $messageJson');
        final message = ChatMessage.fromJson(json.decode(messageJson));
        onMessageReceived(message);
      }
    });

    hubConnection.on('Error', (args) {
      if (args != null && args.isNotEmpty) {
        final error = args[0] as String;
        developer.log('❌ Error from SignalR: $error', error: error);
        onError(error);
      }
    });

    hubConnection.on('MessageRead', (args) {
      if (args != null && args.isNotEmpty) {
        final messageId = args[0] as String;
        developer.log('✓ Message read: $messageId');
        onMessageRead(messageId);
      }
    });

    try {
      await hubConnection.start();
      developer.log('✅ Connected to SignalR hub successfully');
    } catch (e) {
      developer.log('❌ Failed to connect to SignalR hub', error: e);
      rethrow;
    }
  }

  Future<void> disconnect() async {
    try {
      await hubConnection.stop();
      developer.log('Disconnected from SignalR hub');
    } catch (e) {
      developer.log('Error disconnecting from SignalR hub', error: e);
    }
  }

  Future<void> sendMessage({
    required String consultationId,
    required String delegationId,
    required String content,
    required String type,
    dynamic file, // can be null
  }) async {
    try {
      developer.log(
          '📤 Sending message: {consultationId: $consultationId, delegationId: $delegationId, content: $content, type: $type, file: $file}');
      await hubConnection.invoke('SendMessage', args: [
        consultationId,
        delegationId,
        content,
        type,
        file // always pass this, can be null
      ]);
      developer.log('✓ Message sent successfully');
    } catch (e) {
      developer.log('❌ Error sending message', error: e);
      onError(e.toString());
    }
  }

  Future<void> markMessageAsRead(String messageId) async {
    try {
      developer.log('Marking message as read: $messageId');
      await hubConnection.invoke('MarkMessageAsRead', args: [messageId]);
      developer.log('✓ Message marked as read');
    } catch (e) {
      developer.log('❌ Error marking message as read', error: e);
      onError(e.toString());
    }
  }
}
