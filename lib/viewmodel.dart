import 'package:app/model.dart';
import 'package:app/service.dart';
import 'package:flutter/material.dart';

enum ViewState { Idle, Busy }

class UserViewModel extends ChangeNotifier {
  ViewState _state = ViewState.Idle;
  late UserService _userService;
  List<User> _users = [];
  int _page = 1;

  UserViewModel() {
    _userService = UserService();
    getUsers();
  }

  ViewState get state => _state;
  List<User> get users => _users;

  void setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  Future<void> getUsers({int page = 1}) async {
    setState(ViewState.Busy);
    try {
      _users = await _userService.getUsers(page: page);
      setState(ViewState.Idle);
    } catch (e) {
      setState(ViewState.Idle);
      throw e;
    }
  }

  Future<void> loadMoreUsers() async {
    setState(ViewState.Busy);
    try {
      await _userService.loadMoreUsers();
      _users = _userService.users;
      setState(ViewState.Idle);
    } catch (e) {
      setState(ViewState.Idle);
      throw e;
    }
  }

  Future<void> onRefresh() async {
    setState(ViewState.Busy);
    try {
      _page = 1;
      _users.clear();
      await getUsers(page: _page);
      setState(ViewState.Idle);
    } catch (e) {
      setState(ViewState.Idle);
      throw e;
    }
  }
}
