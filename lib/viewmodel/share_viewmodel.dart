import 'dart:async';
import '../models/user_model.dart';
import 'package:flutter/material.dart';
import '../repositories/user_repository.dart';

/// ViewModel managing user list and shared selection state
class ShareViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  List<User> users = [];
  Set<String> sharedUserIds = {};
  StreamSubscription<List<User>>? _userSub;

  ShareViewModel({required UserRepository userRepository})
      : _userRepository = userRepository {
    _listenToUsers();
  }

  void _listenToUsers() {
    _userSub = _userRepository.getUsersStream().listen(
      (userList) {
        users = userList;
        notifyListeners();
      },
      onError: (error) {
        // Handle error if needed
      },
    );
  }

  /// Toggles sharing state for a given user ID
  void toggleShared(String uid, bool isShared) {
    if (isShared) {
      sharedUserIds.add(uid);
    } else {
      sharedUserIds.remove(uid);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }
}