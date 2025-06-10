import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class AttendanceModel {
  int? id;
  int? userId;
  String date;
  String timeIn;
  String? timeOut;
  String status;
  AttendanceModel({
    this.id,
    this.userId,
    required this.date,
    required this.timeIn,
    this.timeOut,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'date': date,
      'timeIn': timeIn,
      'timeOut': timeOut,
      'status': status,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'] != null ? map['id'] as int : null,
      userId: map['userId'] != null ? map['userId'] as int : null,
      date: map['date'] as String,
      timeIn: map['timeIn'] as String,
      timeOut: map['timeOut'] != null ? map['timeOut'] as String : null,
      status: map['status'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory AttendanceModel.fromJson(String source) =>
      AttendanceModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
