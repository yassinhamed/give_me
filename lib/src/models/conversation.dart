import '../repository/user_repository.dart';
import 'user.dart';

class Conversation {
  String id;

  // conversation name for example chat with market name
  String name;

  // Chats messages
  String lastMessage;

  int lastMessageTime;

  // Ids of users that read the chat message
  List<String> readByUsers;

  // Ids of users in this conversation
  List<String> visibleToUsers;

  // users in the conversation
  List<User> users;
  bool isActive;
  Conversation(this.users, {this.id = null, this.name = '',this.visibleToUsers}) {
    readByUsers = [];
  }

  Conversation.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'] != null ? jsonMap['id'].toString() : null;
      isActive = jsonMap['isActive']??true;
      users = jsonMap['users'] != null
          ? List.from(jsonMap['users']).map((element) {
        element['media'] = [
          {'thumb': element['thumb']}
        ];
        return User.fromJSON(element);
      }).toList()
          : [];
      name = name = jsonMap['name'] != null
          ? jsonMap['name'].toString() != currentUser.value.name
          ? jsonMap['name'].toString()
          : users
          .firstWhere((user) => user.id != currentUser.value.id,
          orElse: () =>
              User.fromJSON({'name': currentUser.value.name}))
          .name
          : '';
      readByUsers = jsonMap['read_by_users'] != null ? List.from(jsonMap['read_by_users']) : [];
      visibleToUsers = jsonMap['visible_to_users'] != null ? List.from(jsonMap['visible_to_users']) : [];
      lastMessage = jsonMap['message'] != null ? jsonMap['message'].toString() : '';
      lastMessageTime = jsonMap['time'] != null ? jsonMap['time'] : 0;
    } catch (e) {
      id = '';
      name = '';
      readByUsers = [];
      users = [];
      lastMessage = '';
      lastMessageTime = 0;
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map['isActive']= isActive??true;
    map["name"] = name;
    map["users"] = users.map((element) => element.toRestrictMap()).toSet().toList();
    map["visible_to_users"] = visibleToUsers.toSet().toList();
    map["read_by_users"] = readByUsers.toSet().toList();
    map["message"] = lastMessage;
    map["time"] = lastMessageTime;
    return map;
  }

  Map toUpdatedMap() {
    var map = new Map<String, dynamic>();
    map["message"] = lastMessage;
    map['isActive']= isActive??true;
    map["time"] = lastMessageTime;
    map["read_by_users"] = readByUsers;
    return map;
  }
}
