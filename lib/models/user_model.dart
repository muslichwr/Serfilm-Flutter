import 'package:flutter/material.dart';

class UserModel {
  int? id;
  String? name;
  String? username;
  String? email;
  String? phoneNumber;
  String? profilePhoto;
  String? token;

  UserModel({
    this.id,
    this.name,
    this.username,
    this.email,
    this.phoneNumber,
    this.profilePhoto,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('DEBUG - JSON user data: $json');

    // Memeriksa apakah profile_photo_url tersedia dalam response JSON
    String? photoUrl = json['profile_photo_url'];
    if (photoUrl == null) {
      photoUrl = json['profile_photo'];
    }
    print('DEBUG - Photo URL from JSON: $photoUrl');

    return UserModel(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      profilePhoto: photoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'phone_number': phoneNumber,
      'profile_photo': profilePhoto,
    };
  }
}
