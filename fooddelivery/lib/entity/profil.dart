import 'package:fooddelivery/entity/user.dart';

class Profil {
  final String email;
  final String no_telp;
  final String bio;
  final String image;
  final String? address;
  final User user;

  Profil({
    required this.email,
    required this.no_telp,
    required this.bio,
    required this.image,
    this.address,
    required this.user,
  });
  


  factory Profil.fromJson(Map<String, dynamic> json) {
    return Profil(
      email: json['email'],
      no_telp: json['no_telp'],
      bio: json['bio'],
      image: json['image'],
      address: json['address'] ?? "not set",
      user: User.fromJson(json['user']),
    );
  }

  String toRawJson() {
    return '{"email": "$email", "no_telp": "$no_telp","bio": "$bio", "image": "$image", "address": "$address"}';
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'no_telp': no_telp,
      'bio': bio,
      'image': image,
      'address': address,
    };
  }

}