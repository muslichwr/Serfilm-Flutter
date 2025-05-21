import 'package:flutter/foundation.dart';

class CastMember {
  final int id;
  final String name;
  final String character;
  final String? profilePath;

  CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    // Log data untuk debugging
    debugPrint('Parsing cast data: $json');

    // Ambil ID (bisa ada dalam berbagai format)
    int id = 0;
    if (json['id'] != null) {
      id =
          json['id'] is int
              ? json['id']
              : int.tryParse(json['id'].toString()) ?? 0;
    } else if (json['cast_id'] != null) {
      id =
          json['cast_id'] is int
              ? json['cast_id']
              : int.tryParse(json['cast_id'].toString()) ?? 0;
    }

    // Ambil nama (bisa berupa 'name' atau 'original_name')
    String name = 'Nama tidak tersedia';
    if (json['name'] != null && json['name'].toString().isNotEmpty) {
      name = json['name'].toString();
    } else if (json['original_name'] != null &&
        json['original_name'].toString().isNotEmpty) {
      name = json['original_name'].toString();
    }

    // Ambil karakter yang diperankan (bisa berupa 'character' atau 'role')
    String character = 'Peran tidak tersedia';
    if (json['character'] != null && json['character'].toString().isNotEmpty) {
      character = json['character'].toString();
    } else if (json['role'] != null && json['role'].toString().isNotEmpty) {
      character = json['role'].toString();
    }

    // Ambil path foto profil (bisa dalam berbagai format kunci)
    String? profilePath;
    if (json['profile_path'] != null &&
        json['profile_path'].toString().isNotEmpty) {
      profilePath = json['profile_path'].toString();
    } else if (json['profile'] != null &&
        json['profile'].toString().isNotEmpty) {
      profilePath = json['profile'].toString();
    } else if (json['photo'] != null && json['photo'].toString().isNotEmpty) {
      profilePath = json['photo'].toString();
    } else if (json['profile_url'] != null &&
        json['profile_url'].toString().isNotEmpty) {
      profilePath = json['profile_url'].toString();
    }

    debugPrint('Extracted profilePath: $profilePath');

    return CastMember(
      id: id,
      name: name,
      character: character,
      profilePath: profilePath,
    );
  }

  // Url lengkap untuk foto profil
  String get profileUrl {
    if (profilePath == null || profilePath!.isEmpty) {
      return '';
    }

    // Periksa apakah sudah berupa URL lengkap
    if (profilePath!.startsWith('http')) {
      return profilePath!;
    }

    // Gunakan base URL TMDB jika hanya path
    return 'https://image.tmdb.org/t/p/w200$profilePath';
  }

  @override
  String toString() {
    return 'CastMember(id: $id, name: $name, character: $character)';
  }
}
