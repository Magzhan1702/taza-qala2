import 'dart:async';

import '../models/user_model.dart';
import 'demo_data.dart';

class AuthRepository {
  final _controller = StreamController<UserModel?>.broadcast();
  UserModel? _currentUser = DemoData.currentUser;

  Stream<UserModel?> authStateChanges() async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  UserModel? get currentUser => _currentUser;

  Future<void> signInWithGoogle() async {
    _currentUser = DemoData.currentUser;
    _controller.add(_currentUser);
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _currentUser = DemoData.currentUser.copyWith(email: email);
    DemoData.currentUser = _currentUser!;
    _controller.add(_currentUser);
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _currentUser = DemoData.currentUser.copyWith(
      displayName: name,
      email: email,
    );
    DemoData.currentUser = _currentUser!;
    _controller.add(_currentUser);
  }

  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }
}
