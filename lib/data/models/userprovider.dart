// lib/providers/user_provider.dart
import 'dart:async';

import 'package:car_rent/data/models/user.dart';
import 'package:flutter/material.dart';

import '../../domain/repositories/userepo.dart';
 // Changed from domain to data layer

class UserProvider with ChangeNotifier {
  final UserRepository _userRepository;
  UserModel? _user;
  StreamSubscription? _userSubscription;

  UserProvider(this._userRepository);

  UserModel? get user => _user;

  Future<void> loadCurrentUser() async {
    // Cancel any existing subscription
    await _userSubscription?.cancel();

    _userSubscription = _userRepository.currentUser.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> updateUser(UserModel updatedUser) async {
    try {
      await _userRepository.updateUser(updatedUser);
      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}