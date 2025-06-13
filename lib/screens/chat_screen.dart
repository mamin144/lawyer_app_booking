// import 'package:flutter/material.dart';
// import '../services/chat_service.dart';
// import '../routes.dart';
// import 'package:signalr_netcore/signalr_client.dart';

// class ChatScreen extends StatefulWidget {
//   final String receiverId;
//   final String receiverName;
//   final String consultationId;

//   const ChatScreen({
//     Key? key,
//     required this.receiverId,
//     required this.receiverName,
//     required this.consultationId,
//   }) : super(key: key);

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final ChatService _chatService = ChatService();
//   final TextEditingController _messageController = TextEditingController();
//   final List<ChatMessage> _messages = [];
//   String _currentUserId = '';
//   HubConnectionState _connectionStatus = HubConnectionState.Disconnected;

//   @override
//   void initState() {
//     super.initState();
//     _initializeChat();
//   }

//   Future<void> _initializeChat() async {
//     try {
//       final profileService = ProfileService();
//       await ProfileService.initialize();

//       _currentUserId = await profileService.getCurrentUserIdFromToken();
//       if (_currentUserId.isEmpty) {
//         print('Failed to get user ID. Redirecting to login.');
//         if (mounted) {
//           setState(() {
//             _connectionStatus = HubConnectionState.Disconnected;
//           });
//         }
//         return;
//       }

//       _chatService.onConnectionStatusChanged = (state) {
//         if (mounted) {
//           setState(() {
//             _connectionStatus = state;
//           });
//         }
//       };

//       _chatService.onMessagesReceived = (messages) {
//         if (mounted) {
//           setState(() {
//             _messages.clear();
//             _messages.addAll(messages.reversed);
//           });
//         }
//       };

//       _chatService.onMessageReceived = (message) {
//         if (mounted) {
//           setState(() {
//             _messages.add(message);
//           });
//         }
//       };

//       _chatService.onConnectionError = (error) {
//         print('Chat connection error: $error');
//         if (mounted) {
//           setState(() {
//             _connectionStatus = HubConnectionState.Disconnected;
//           });
//         }
//       };

//       await _chatService.initializeConnection();

//       // Removed _chatService.getMessages(_currentUserId) as server handles sending unread messages
//     } catch (e) {
//       print('Error during chat initialization setup: $e');
//       if (mounted) {
//         setState(() {
//           _connectionStatus = HubConnectionState.Disconnected;
//         });
//       }
//     }
//   }

//   void _sendMessage() {
//     if (_connectionStatus != HubConnectionState.Connected ||
//         _messageController.text.trim().isEmpty ||
//         _currentUserId.isEmpty)
//       return;

//     _chatService.sendMessage(
//       widget.consultationId,
//       null,
//       _messageController.text,
//       'text',
//     );
//     _messageController.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(widget.receiverName),
//             Text(
//               'Status: ${_connectionStatus.toString().split('.').last}',
//               style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                 color:
//                     _connectionStatus == HubConnectionState.Connected
//                         ? Colors.green
//                         : Colors.red,
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               reverse: true,
//               padding: const EdgeInsets.all(16),
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 final message = _messages[_messages.length - 1 - index];
//                 final isMe = message.senderId == _currentUserId;

//                 return Align(
//                   alignment:
//                       isMe ? Alignment.centerRight : Alignment.centerLeft,
//                   child: Container(
//                     margin: const EdgeInsets.only(bottom: 8),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 10,
//                     ),
//                     decoration: BoxDecoration(
//                       color:
//                           isMe
//                               ? Theme.of(context).primaryColor
//                               : Colors.grey[300],
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       message.content,
//                       style: TextStyle(
//                         color: isMe ? Colors.white : Colors.black,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.2),
//                   spreadRadius: 1,
//                   blurRadius: 3,
//                   offset: const Offset(0, -1),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     enabled: _connectionStatus == HubConnectionState.Connected,
//                     decoration: InputDecoration(
//                       hintText:
//                           _connectionStatus == HubConnectionState.Connected
//                               ? 'Type a message...'
//                               : 'Connecting...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(25),
//                         borderSide: BorderSide.none,
//                       ),
//                       filled: true,
//                       fillColor: Colors.grey[200],
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 10,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 CircleAvatar(
//                   backgroundColor:
//                       _connectionStatus == HubConnectionState.Connected
//                           ? Theme.of(context).primaryColor
//                           : Colors.grey,
//                   child: IconButton(
//                     icon: const Icon(Icons.send, color: Colors.white),
//                     onPressed:
//                         _connectionStatus == HubConnectionState.Connected
//                             ? _sendMessage
//                             : null,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _chatService.dispose();
//     super.dispose();
//   }
// }
