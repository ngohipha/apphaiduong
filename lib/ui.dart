import 'package:app/model.dart';
import 'package:app/service.dart';
import 'package:app/viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserListWidget extends StatefulWidget {
  @override
  _UserListWidgetState createState() => _UserListWidgetState();
}

class _UserListWidgetState extends State<UserListWidget> {
  bool _isGrid = false;
  bool _isList = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        Provider.of<UserViewModel>(context, listen: false).loadMoreUsers();
      }
    });
  }

  Widget _buildUserListItem(User user) {
    return ListTile(
      leading: Provider.of<UserService>(context).getUserAvatar(user.avatar),
      title: Text('${user.firstName} ${user.lastName}'),
      subtitle: Text(user.email),
    );
  }

  Widget _buildUserGridItem(User user) {
    return Card(
      child: Column(
        children: [
          Expanded(
            child: Provider.of<UserService>(context).getUserAvatar(user.avatar),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${user.firstName} ${user.lastName}'),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    final viewModel = Provider.of<UserViewModel>(context);
    if (viewModel.state == ViewState.Busy && viewModel.users.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    if (viewModel.users.isEmpty) {
      return Center(
        child: Text('No users found'),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<UserViewModel>(context, listen: false).onRefresh();
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: viewModel.users.length + 1,
        itemBuilder: (context, index) {
          if (index == viewModel.users.length) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          final user = viewModel.users[index];
          return _buildUserListItem(user);
        },
      ),
    );
  }

  Widget _buildGrid() {
    final viewModel = Provider.of<UserViewModel>(context);
    if (viewModel.state == ViewState.Busy && viewModel.users.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    if (viewModel.users.isEmpty) {
      return Center(
        child: Text('No users found'),
      );
    }
    return RefreshIndicator(
      onRefresh: () => viewModel.onRefresh(),
      child: GridView.builder(
        controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2 / 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: viewModel.users.length + 1,
        itemBuilder: (context, index) {
          if (index == viewModel.users.length) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          final user = viewModel.users[index];
          return _buildUserGridItem(user);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
        actions: [
          IconButton(
            icon: Icon(_isGrid ? Icons.list : Icons.grid_on),
            onPressed: () {
              setState(() {
                _isGrid = !_isGrid;
              });
            },
          ),
        ],
      ),
      body: _isGrid ? _buildGrid() : _buildList(),
    );
  }
}
