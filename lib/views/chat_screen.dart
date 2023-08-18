import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatMessage {
  String sender;
  String message;
  bool isMe;
  String email;
  Timestamp timestamp;

  ChatMessage({
    required this.sender,
    required this.message,
    required this.isMe,
    required this.email,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      sender: json['sender'],
      message: json['message'],
      isMe: json['isMe'],
      email: json['email'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "sender": this.sender,
      "message": this.message,
      "isMe": this.isMe,
      "email": this.email,
      "timestamp": this.timestamp,
    };
  }
}

class ChatScreen extends StatefulWidget {
  String bookingID;
  String attenderEmail;
  String attenderName;

  ChatScreen({
    required this.bookingID,
    required this.attenderEmail,
    required this.attenderName,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();

  void _handleSubmitted(String text) {
    _textController.clear();
    ChatMessage message = ChatMessage(
      sender: widget.attenderName,
      email: widget.attenderEmail,
      message: text,
      isMe: true,
      timestamp: Timestamp.fromDate(
        DateTime.now(),
      ),
    );
    FirebaseFirestore.instance
        .collection("bookings")
        .doc(widget.bookingID)
        .collection("chats")
        .doc()
        .set(
          message.toJson(),
        );
    // var docRef = collection.doc(widget.bookingID).update({"chats": FieldValue.arrayUnion(message.toJson())})
  }

  Widget _buildChatList() {
    return Flexible(
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("bookings")
              .doc(widget.bookingID)
              .collection("chats")
              .orderBy("timestamp", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            List<ChatMessage> _messages = [];

            if (snapshot.hasData) {
              snapshot.data!.docs.forEach((element) {
                print(element.data());
                ChatMessage newMess = ChatMessage.fromJson(
                  element.data(),
                );
                newMess.isMe = newMess.email == widget.attenderEmail;
                _messages.add(newMess);
              });
            }

            return !snapshot.hasData
                ? Container()
                : ListView.builder(
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      final ChatMessage message = _messages[index];
                      return _buildChatMessage(message);
                    },
                  );
          }),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    final AlignmentGeometry alignment =
        message.isMe ? Alignment.centerRight : Alignment.centerLeft;

    final BorderRadiusGeometry borderRadius = message.isMe
        ? BorderRadius.only(
            topLeft: Radius.circular(16.0),
            bottomLeft: Radius.circular(16.0),
            bottomRight: Radius.circular(16.0),
          )
        : BorderRadius.only(
            topRight: Radius.circular(16.0),
            bottomLeft: Radius.circular(16.0),
            bottomRight: Radius.circular(16.0),
          );

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      alignment: alignment,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.sender,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey[600],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 4.0),
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: message.isMe ? Colors.teal[300] : Colors.grey[200],
              borderRadius: borderRadius,
            ),
            child: Text(
              message.message,
              style: TextStyle(
                fontSize: 16.0,
                color: message.isMe ? Colors.white : Colors.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      margin: EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 5,
              ),
              child: TextField(
                controller: _textController,
                textInputAction: TextInputAction.send,
                onSubmitted: _handleSubmitted,
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () => _handleSubmitted(_textController.text),
            color: Colors.teal,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Row(
          children: [
            Text(
              "Chat #${widget.bookingID}",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildChatList(),
          Divider(
            height: 1.0,
            color: Colors.grey[300],
          ),
          _buildMessageInput(),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
