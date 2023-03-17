import 'dart:convert';

import 'package:app/model.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserService extends ChangeNotifier {
  final String _baseUrl = 'https://reqres.in/api/users?page=';
  late int _page;
  late List<User> _users;
  List<User> get users => _users;

  Future<List<User>> getUsers({int page = 1}) async {
    _page = page;
    final response = await http.get(Uri.parse(_baseUrl + _page.toString()));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final usersData = data['data'];
      final users = usersData.map<User>((user) => User.fromJson(user)).toList();
      _users = users;
      return users;
    } else {
      throw Exception('Failed to load users');
    }
  }

  Widget getUserAvatar(String avatarUrl) {
    return CachedNetworkImage(
      imageUrl: avatarUrl,
      placeholder: (context, url) => CircleAvatar(
        child: Icon(Icons.person),
      ),
      errorWidget: (context, url, error) => CircleAvatar(
        child: Icon(Icons.error),
      ),
    );
  }

  Future<List<User>> loadMoreUsers() async {
    final response =
        await http.get(Uri.parse(_baseUrl + (_page + 1).toString()));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final usersData = data['data'];
      final users = usersData.map<User>((user) => User.fromJson(user)).toList();
      _users.addAll(users);
      _page++;
      return users;
    } else {
      throw Exception('Failed to load more users');
    }
  }
}
