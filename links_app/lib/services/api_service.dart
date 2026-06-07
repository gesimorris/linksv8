import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://linksv8.onrender.com',
    connectTimeout: Duration(seconds: 5),
    receiveTimeout: Duration(seconds: 3),
  ));

  // CORS
ApiService() {
  _dio.options.baseUrl = 'https://linksv8.onrender.com';
}
  // USER METHODS

  Future<Response> login(String email, String password) async {
    return await _dio.post('/users/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> register(String firstName, String lastName, String email, String password) async {
    return await _dio.post('/users/register', data: {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
    });
  }

  // EVENT METHODS

  Future<Response> getEvents() async {
    return await _dio.get('/events');
  }

  Future<Response> getEventById(int id) async {
    return await _dio.get('/events/$id');
  }

  // GROUP METHODS

  Future<Response> getGroupsByEventId(int eventId) async {
    return await _dio.get('/groups/event/$eventId');
  }

  Future<Response> getGroupsByUserId(int userId) async {
    return await _dio.get('/groups/$userId');
  }

  Future<Response> createGroup(int eventId, int creatorId, int maxMembers) async {
    return await _dio.post('/groups', data: {
      'eventId': eventId,
      'creatorId': creatorId,
      'maxMembers': maxMembers,
      'groupStatus': 'open',
    });
  }

  Future<Response> joinGroup(int groupId, int userId) async {
    return await _dio.post('/groups/$groupId/join',
        queryParameters: {'userId': userId});
  }

  Future<Response> leaveGroup(int groupId, int userId) async {
    return await _dio.delete('/groups/$groupId/leave',
        queryParameters: {'userId': userId});
  }

  Future<Response> deleteGroup(int groupId, int userId) async {
    return await _dio.delete('/groups/$groupId',
        queryParameters: {'userId': userId});
  }

  // MESSAGE METHODS

  Future<Response> getMessages(int groupId, int userId) async {
    return await _dio.get('/messages/$groupId',
        queryParameters: {'userId': userId});
  }

  Future<Response> sendMessage(int groupId, int userId, String messageText) async {
    return await _dio.post('/messages', data: {
      'groupId': groupId,
      'userId': userId,
      'messageText': messageText,
      'messageDate': DateTime.now().toIso8601String(),
    });
  }

  Future<Response> editMessage(int id, int userId, String messageText) async {
    return await _dio.put('/messages/$id',
        data: {'messageText': messageText},
        queryParameters: {'userId': userId});
  }

  Future<Response> deleteMessage(int id, int userId) async {
    return await _dio.delete('/messages/$id',
        queryParameters: {'userId': userId});
  }

  // FRIEND METHODS

  Future<Response> sendFriendRequest(int senderId, int receiverId) async {
    return await _dio.post('/friends',
        queryParameters: {'senderId': senderId, 'receiverId': receiverId});
  }

  Future<Response> acceptFriendRequest(int id) async {
    return await _dio.put('/friends/$id');
  }

  Future<Response> declineFriendRequest(int id) async {
    return await _dio.delete('/friends/$id');
  }

  Future<Response> getFriends(int userId) async {
    return await _dio.get('/friends/$userId');
  }

  Future<Response> getPendingRequests(int userId) async {
    return await _dio.get('/friends/pending/$userId');
  }
}