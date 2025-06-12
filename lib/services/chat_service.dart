// import 'package:signalr_netcore/signalr_client.dart';
// import 'package:signalr_netcore/msgpack_hub_protocol.dart'; // Import MessagePack protocol
// import 'dart:async';
// import 'package:shared_preferences/shared_preferences.dart';

// class ChatService {
//   late HubConnection hubConnection;
//   // Use the correct server URL from the MapHub call
//   final String baseUrl = 'http://mohamek-legel.runasp.net/hubs/chathub';
//   bool _isConnected = false;
//   int _retryCount = 0;
//   static const int maxRetries = 3;

//   // Stream controllers for real-time updates
//   final _messageController = StreamController<ChatMessage>.broadcast();
//   Stream<ChatMessage> get messageStream => _messageController.stream;

//   // Callbacks
//   Function(List<ChatMessage>)? onMessagesReceived;
//   Function(ChatMessage)? onMessageReceived;
//   Function(String)? onConnectionError;
//   Function(HubConnectionState)? onConnectionStatusChanged;

//   Future<void> init() async {
//     await initializeConnection();
//   }

//   Future<String?> _getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('auth_token');
//     print(
//       'Retrieved token: ${token?.substring(0, 20)}...',
//     ); // Print first 20 chars of token
//     return token;
//   }

//   Future<void> initializeConnection() async {
//     if (hubConnection.state == HubConnectionState.Connected) return;
//     if (_retryCount >= maxRetries) {
//       onConnectionError?.call('Maximum retry attempts reached');
//       onConnectionStatusChanged?.call(HubConnectionState.Disconnected);
//       return;
//     }

//     final token = await _getToken();
//     if (token == null) {
//       onConnectionError?.call('No authentication token found');
//       onConnectionStatusChanged?.call(HubConnectionState.Disconnected);
//       return;
//     }

//     try {
//       print('Attempting connection to: $baseUrl');
//       onConnectionStatusChanged?.call(HubConnectionState.Connecting);

//       // Create the connection with specific options and MessagePack protocol
//       hubConnection =
//           HubConnectionBuilder()
//               .withUrl(
//                 baseUrl,
//                 options: HttpConnectionOptions(
//                   skipNegotiation: false, // Enable negotiation
//                   transport:
//                       HttpTransportType
//                           .WebSockets, // Try WebSockets first with MessagePack
//                   logMessageContent: true,
//                   accessTokenFactory:
//                       () => Future.value(
//                         'Bearer $token',
//                       ), // Use token with Bearer prefix
//                 ),
//               )
//               .withAutomaticReconnect()
//               .withHubProtocol(
//                 MessagePackHubProtocol(),
//               ) // Use MessagePack protocol
//               .build();

//       // Set up message handler
//       hubConnection.on('ReceiveMessage', (args) {
//         if (args != null && args.isNotEmpty) {
//           // The server sends the message object directly as the first argument
//           // When using MessagePack, args might be a List<dynamic> containing the serialized message
//           // We need to handle deserialization if necessary, but for now, assume it's a Map or similar
//           final messageData = Map<String, dynamic>.from(args[0] as Map);
//           final message = ChatMessage.fromJson(messageData);
//           _messageController.add(message);
//           onMessageReceived?.call(message);
//         }
//       });

//       // Add MarkMessageAsRead handler from C# backend
//       hubConnection.on('MessageRead', (args) {
//         if (args != null && args.isNotEmpty) {
//           final messageId = args[0] as String;
//           // You might want to update the UI to reflect the message as read
//           print('Message $messageId marked as read by server');
//         }
//       });

//       // Set up connection state change listeners
//       // hubConnection.onclose((Object? error) {
//       //   print('SignalR Connection closed: $error');
//       //   _isConnected = false;
//       //   onConnectionStatusChanged?.call(HubConnectionState.Disconnected);
//       //   if (error != null) {
//       //     onConnectionError?.call(error.toString());
//       //   }
//       // });

//       // hubConnection.onreconnecting((Object? error) {
//       //   print('SignalR Connection reconnecting: $error');
//       //   _isConnected = false;
//       //   onConnectionStatusChanged?.call(HubConnectionState.Reconnecting);
//       // });

//       // hubConnection.onreconnected((String? connectionId) {
//       //   print('SignalR Connection reconnected. New ID: $connectionId');
//       //   _isConnected = true;
//       //   onConnectionStatusChanged?.call(HubConnectionState.Connected);
//       //   _retryCount = 0;
//       // });

//       await hubConnection.start();
//       _isConnected = true;
//       _retryCount = 0;
//       print('SignalR Connected successfully');
//       print('Connection state: ${hubConnection.state}');
//       print('Connection ID: ${hubConnection.connectionId}');
//       onConnectionStatusChanged?.call(HubConnectionState.Connected);

//       return;
//     } catch (e) {
//       print('Connection attempt failed: $e');
//       _isConnected = false;
//       _retryCount++;
//       onConnectionStatusChanged?.call(HubConnectionState.Disconnected);

//       if (_retryCount < maxRetries) {
//         print('Retrying connection in 2 seconds...');
//         await Future.delayed(const Duration(seconds: 2));
//         await initializeConnection();
//       } else {
//         print('All connection attempts failed');
//         onConnectionError?.call('Connection failed: $e');
//       }
//     }
//   }

//   Future<void> sendMessage(
//     String consultationId,
//     String? delegationId,
//     String content,
//     String type,
//   ) async {
//     if (!_isConnected) {
//       await initializeConnection();
//       if (!_isConnected) return;
//     }

//     try {
//       print(
//         'Attempting to send message with consultationId: $consultationId, delegationId: $delegationId, content: $content, type: $type',
//       );
//       // Call the server-side method to send a message
//       await hubConnection.invoke(
//         'SendMessage',
//         args: [
//           consultationId.trim(),
//           delegationId == null ? '' : delegationId.trim(),
//           content.trim(),
//           type.trim(),
//         ],
//       );
//       print('Message sent successfully');
//     } catch (e) {
//       print('Error sending message: $e');
//       onConnectionError?.call('Error sending message: $e');
//       _isConnected = false;
//       await initializeConnection();
//     }
//   }

//   Future<void> markMessageAsRead(String messageId) async {
//     if (!_isConnected) {
//       await initializeConnection();
//       if (!_isConnected) return;
//     }
//     try {
//       print('Attempting to mark message $messageId as read');
//       await hubConnection.invoke('MarkMessageAsRead', args: [messageId]);
//       print('Message $messageId marked as read successfully');
//     } catch (e) {
//       print('Error marking message as read: $e');
//       onConnectionError?.call('Error marking message as read: $e');
//     }
//   }

//   void dispose() {
//     _isConnected = false;
//     _messageController.close();
//     hubConnection.stop();
//   }
// }

// class ChatMessage {
//   final String content;
//   final String senderId;
//   final String receiverId;
//   final DateTime timestamp;
//   final String id;
//   final bool isRead;

//   ChatMessage({
//     required this.content,
//     required this.senderId,
//     required this.receiverId,
//     required this.timestamp,
//     required this.id,
//     required this.isRead,
//   });

//   factory ChatMessage.fromJson(Map<String, dynamic> json) {
//     return ChatMessage(
//       content: json['content'],
//       senderId: json['senderId'],
//       receiverId: json['receiverId'],
//       timestamp: DateTime.parse(json['timestamp']),
//       id: json['id'], // Assuming there is an 'id' field
//       isRead: json['isRead'], // Assuming there is an 'isRead' field
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'content': content,
//       'senderId': senderId,
//       'receiverId': receiverId,
//       'timestamp': timestamp.toIso8601String(),
//       'id': id,
//       'isRead': isRead,
//     };
//   }
// }
