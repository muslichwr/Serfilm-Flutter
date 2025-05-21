import 'package:serfilm/models/user_model.dart';
import 'package:serfilm/services/auth_service.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  AuthService authService = AuthService();
  UserModel? _user;

  UserModel? get user => _user;

  set user(UserModel? newUser) {
    _user = newUser;
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      UserModel user = await authService.register(
        name: name,
        username: username,
        email: email,
        password: password,
      );

      _user = user;
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      UserModel user = await authService.login(
        email: email,
        password: password,
      );

      _user = user;
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updateProfile({
    required int userId,
    required String name,
    required String username,
    required String email,
    String? phone,
    String? profilePhoto,
    required String token,
  }) async {
    try {
      UserModel user = await authService.updateProfile(
        userId: userId,
        email: email,
        name: name,
        username: username,
        phone: phone,
        profilePhoto: profilePhoto,
        token: token,
      );
      _user = user;
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> changePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
    required String token,
  }) async {
    try {
      bool result = await authService.changePassword(
        userId: userId,
        oldPassword: oldPassword,
        newPassword: newPassword,
        token: token,
      );
      return result;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Mendapatkan URL foto profil atau placeholder jika tidak ada
  String getProfilePhotoUrl() {
    print('DEBUG - User profilePhoto: ${_user?.profilePhoto}');
    print('DEBUG - User name: ${_user?.name}');
    print('DEBUG - User username: ${_user?.username}');

    // Kembalikan URL foto profil jika tersedia
    if (_user != null &&
        _user!.profilePhoto != null &&
        _user!.profilePhoto!.isNotEmpty) {
      print('DEBUG - Menggunakan foto profil dari API: ${_user!.profilePhoto}');
      return _user!.profilePhoto!;
    }

    // Menggunakan UI Avatars sebagai placeholder dengan nama user
    String name = _user?.name ?? 'User';
    String username = _user?.username ?? '';
    String initials = '';

    if (name.isNotEmpty) {
      initials += name[0];
    }

    if (username.isNotEmpty) {
      initials += '+${username[0]}';
    }

    if (initials.isEmpty) {
      initials = 'U';
    }

    String placeholderUrl =
        "https://ui-avatars.com/api/?name=$initials&color=7F9CF5&background=EBF4FF";
    print('DEBUG - Menggunakan placeholder avatar: $placeholderUrl');
    return placeholderUrl;
  }
}
