import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MessagingScreen(),
      theme: ThemeData(
        fontFamily: 'Cairo', // Assuming an Arabic-friendly font
      ),
    );
  }
}

class User {
  final int id;
  final String name;
  final String? avatarUrl;

  User({required this.id, required this.name, this.avatarUrl});
}

class Conversation {
  final int id;
  final String name;
  final String lastMessage;
  final String time;
  final bool unread;

  Conversation({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unread = false,
  });
}

class MessagingScreen extends StatelessWidget {
  final List<User> onlineUsers = [
    User(id: 1, name: 'User 1'),
    User(id: 2, name: 'User 2'),
    User(id: 3, name: 'User 3'),
    User(id: 4, name: 'User 4'),
    User(id: 5, name: 'User 5'),
  ];

  final List<Conversation> conversations = [
    Conversation(
      id: 1,
      name: 'سارة سمير',
      lastMessage: 'رسالة أخيرة...',
      time: '2:30 PM',
    ),
    Conversation(
      id: 2,
      name: 'عبدالرحمن طارق',
      lastMessage: 'مرحبا',
      time: '1:45 PM',
      unread: true,
    ),
    Conversation(
      id: 3,
      name: 'شيرين ناصر',
      lastMessage: 'كيف حالك؟',
      time: '12:15 PM',
    ),
    Conversation(
      id: 4,
      name: 'محمد إبراهيم',
      lastMessage: 'موافق',
      time: '11:30 AM',
    ),
    Conversation(
      id: 5,
      name: 'فهد الوهيبي',
      lastMessage: 'شكرا لك',
      time: '10:00 AM',
      unread: true,
    ),
  ];

  MessagingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Online Users Section
            Container(
              color: Colors.grey[100],
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      onlineUsers.map((user) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.grey[300],
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Text(
                                'User ${user.id}',
                                style: TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),

            // Conversations List
            Expanded(
              child: ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          conversation.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          conversation.time,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          conversation.lastMessage,
                          style: TextStyle(color: Colors.grey),
                        ),
                        if (conversation.unread)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Contacts'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
