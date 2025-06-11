import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserModel {
  int? id;
  String username;
  String email;
  String password;
  String role;
  final String? mobileNo;
  final String? dob; // Date of Birth
  final String? bloodGroup;
  final String? designation;
  final String? joinedDate;
  final String? profileImageUrl;
  UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.role,
    this.mobileNo,
    this.dob,
    this.bloodGroup,
    this.designation,
    this.joinedDate,
    this.profileImageUrl,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'role': role,
      'mobileNo': mobileNo,
      'dob': dob,
      'bloodGroup': bloodGroup,
      'designation': designation,
      'joinedDate': joinedDate,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] != null ? map['id'] as int : null,
      username: map['username'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      role: map['role'] as String,
      mobileNo: map['mobileNo'] != null ? map['mobileNo'] as String : null,
      dob: map['dob'] != null ? map['dob'] as String : null,
      bloodGroup: map['bloodGroup'] != null
          ? map['bloodGroup'] as String
          : null,
      designation: map['designation'] != null
          ? map['designation'] as String
          : null,
      joinedDate: map['joinedDate'] != null
          ? map['joinedDate'] as String
          : null,
      profileImageUrl: map['profileImageUrl'] != null
          ? map['profileImageUrl'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
