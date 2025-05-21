import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:serfilm/models/user_model.dart';

class AuthService {
  String baseUrl = 'http://192.168.1.21:8000/api';

  Future<UserModel> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      var url = Uri.parse('$baseUrl/register');
      var headers = {'Content-Type': 'application/json'};
      var body = jsonEncode({
        'name': name,
        'username': username,
        'email': email,
        'password': password,
      });

      var response = await http.post(url, headers: headers, body: body);
      var data = jsonDecode(response.body);

      print('DEBUG - Register response: $data');

      if (response.statusCode == 200) {
        UserModel user = UserModel.fromJson(data['data']['user']);
        user.token = 'Bearer ' + data['data']['access_token'];
        print(
          'DEBUG - User setelah register: ${user.name}, profile: ${user.profilePhoto}',
        );
        return user;
      } else {
        throw Exception(data['message'] ?? 'Gagal Register');
      }
    } catch (e) {
      print('ERROR Register: $e');
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      var url = Uri.parse('$baseUrl/login');
      var headers = {'Content-Type': 'application/json'};
      var body = jsonEncode({'email': email, 'password': password});

      var response = await http.post(url, headers: headers, body: body);
      var data = jsonDecode(response.body);

      print('DEBUG - Login response: $data');

      if (response.statusCode == 200) {
        UserModel user = UserModel.fromJson(data['data']['user']);
        user.token = 'Bearer ' + data['data']['access_token'];
        print(
          'DEBUG - User setelah login: ${user.name}, profile: ${user.profilePhoto}',
        );
        return user;
      } else {
        throw Exception(data['message'] ?? 'Email atau password salah');
      }
    } catch (e) {
      print('ERROR Login: $e');
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<bool> logout(String token) async {
    try {
      var url = Uri.parse('$baseUrl/logout');
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': token,
      };

      var response = await http.post(url, headers: headers);

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Terjadi kesalahan saat logout: ${e.toString()}');
    }
  }

  Future<UserModel> updateProfile({
    required int userId,
    required String name,
    required String username,
    required String email,
    String? phone,
    String? profilePhoto,
    required String token,
  }) async {
    try {
      var url = Uri.parse('$baseUrl/user/$userId');
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': token,
      };
      var body = jsonEncode({
        'name': name,
        'username': username,
        'email': email,
        'phone_number': phone,
        'profile_photo': profilePhoto,
      });

      var response = await http.put(url, headers: headers, body: body);
      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        UserModel user = UserModel.fromJson(data['data']['user']);
        user.token = token;
        return user;
      } else {
        throw Exception(data['message'] ?? 'Gagal update profile');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<UserModel> updateProfilePhoto({
    required int userId,
    required File photoFile,
    required String token,
  }) async {
    try {
      var url = Uri.parse('$baseUrl/user/$userId/photo');

      // Membuat multipart request untuk upload file
      var request = http.MultipartRequest('POST', url);

      // Menambahkan header dan foto
      request.headers['Authorization'] = token;
      request.files.add(
        await http.MultipartFile.fromPath('photo', photoFile.path),
      );

      // Mengirim request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        UserModel user = UserModel.fromJson(data['data']['user']);
        user.token = token;
        return user;
      } else {
        throw Exception(data['message'] ?? 'Gagal mengupload foto profil');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat upload foto: ${e.toString()}');
    }
  }

  Future<bool> changePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
    required String token,
  }) async {
    try {
      var url = Uri.parse('$baseUrl/user/$userId/change-password');
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': token,
      };
      var body = jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
      });

      var response = await http.post(url, headers: headers, body: body);
      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(data['message'] ?? 'Gagal mengubah password');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }
}
