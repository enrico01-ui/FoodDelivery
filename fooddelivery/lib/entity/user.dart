import 'dart:convert';
import 'package:crypto/crypto.dart';


class User {
  // String? token;
  // final String userName;
  // final String email;
  // final String noTlp;
  // late final String hashpassword;
  // late final String salt;
  // User(this.email, this.noTlp, {required this.userName, required String password, this.token}) {
  //   salt = saltGen();
  //   hashpassword = _Hashing(password, salt);
  // }

  // static _Hashing(String password, String salt) {
  //   password = password + salt;
  //   var encoded = utf8.encode(password);
  //   var digest = sha256.convert(encoded);
  //   return digest.toString();
  // }

  // static saltGen(){
  //   var random = Random.secure();
  //   //Random.secure() constructor utilizes a source of randomness that is considered secure for cryptographic purposes. This means that the random numbers generated are less predictable and more suitable for use in security-sensitive applications.
  //   var values = List<int>.generate(16, (i) => random.nextInt(256));
  //   //generate fungsi yang menghasilkan list dengan panjang tertentu, dan setiap elemen diisi dengan nilai yang dihasilkan oleh fungsi yang diberikan.
  //   //pertama i disini 16 adalah panjang list, kedua random.nextInt(256) adalah nilai yang dihasilkan oleh fungsi yang diberikan
  //   //jadi akan ada 16 nilai random yg dihasilkan oleh random.nextInt(256)
  //   return base64.encode(values);
  //   //encode fungsi yang mengubah list of bytes menjadi string base64
  // }

  String? token;
  final String name;
  final String email;
  final String hashedPassword;
  User({required this.name, required this.email, required String password, this.token}): hashedPassword = _hashPassword(password);

  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hashed = sha256.convert(bytes);
    return hashed.toString();
  }

  // Convert User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'token': token,
    };
  }

  // Create User object from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      password: '', // Password is not included in the response
      token: json['token'],
    );
  }

  // Verify if a plain-text password matches the hashed password
  bool verifyPassword(String plainPassword) {
    return _hashPassword(plainPassword) == hashedPassword;
  }
}