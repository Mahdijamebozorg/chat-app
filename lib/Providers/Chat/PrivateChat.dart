import 'dart:io';

import 'package:http/http.dart' as http;

import './Chat.dart';
import 'package:chatapp/Providers/Message.dart';
import 'package:chatapp/Providers/User.dart';

class PrivateChat extends Chat {
  //chat
  final List<User> _users;
  List<Message> _messages;
  List<Message> _unsentMessages;
  final DateTime _createdDate;
  final ChatType _type;
  final String _id;

  PrivateChat(
    this._id,
    this._users,
    this._messages,
    this._unsentMessages,
    this._type,
    this._createdDate,
  ) : super(_id, _users, _messages, _unsentMessages, _type, _createdDate);

  @override
  Future sendMessage(Message newMessage, User currentUser) async {
    print("PrivateChat: sendMessage called");
    if (!canSendMessage(currentUser)) {
      throw Exception("User can't send message");
    }

    //in future temp messages will be saved on device
    //await save message...
    _unsentMessages.add(Message(
      newMessage.id,
      newMessage.text,
      newMessage.senderId,
      null,
      newMessage.isEdited,
      {},
    ));
    notifyListeners();

    final http.Response response;
    try {
      response = await http.post(
        Uri.parse("https://test.com"),
        headers: {},
        body: {},
      );
    } on SocketException catch (message) {
      print("socketException in sendMessage: $message");
    }

    _unsentMessages.removeWhere((message) => message.id == newMessage.id);

    _messages.add(newMessage);
    notifyListeners();
  }

  //test
  // @override
  Future uploadMessages() async {
    print("Chat: uploadMessage called");

    //upload all unsentMessages
    for (var message in _unsentMessages) {
      final http.Response response;
      try {
        response = await http.post(
          Uri.parse("https://test.com"),
          headers: {},
          body: {},
        );
        _unsentMessages.remove(message);
        notifyListeners();
      } on SocketException catch (message) {
        print("socketException in uploadMessage: $message");
      }
    }
  }

  @override
  Future removeMessage(
      Message message, User currentUser, bool totalRemove) async {
    final http.Response response;
    try {
      response = await http.post(
        Uri.parse("https://test.com"),
        headers: {},
        body: {},
      );
    } on SocketException catch (message) {
      print("socketException in removeMessage: $message");
    }
    if (totalRemove) {
      _messages.remove(message);
    } else {
      _users.remove(currentUser);
    }
    notifyListeners();
  }

  @override
  String chatTitle(User currentUser) {
    return _users.firstWhere((user) => currentUser.id != user.id).name;
  }

  @override
  String chatSubtitle(User currentUser) {
    return _users
        .firstWhere((user) => user.id == currentUser.id)
        .lastSeen
        .toString();
  }

  @override
  bool canSendMessage(User user) {
    //... check chat
    return true;
  }

  @override
  List<String> profiles(User currentUser) {
    return _users.firstWhere((user) => user.id == currentUser.id).profileUrls;
  }
}