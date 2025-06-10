import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class AttendanceModel {
  int? id;
  int userId;
  String date;
  String? timeIn;
  String? timeOut;
  String? type;
  String? reason;
  String status;
  AttendanceModel({
    this.id,
    required this.userId,
    required this.date,
    this.timeIn,
    this.timeOut,
    this.type,
    this.reason,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'date': date,
      'timeIn': timeIn,
      'timeOut': timeOut,
      'type': type,
      'reason': reason,
      'status': status,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'] != null ? map['id'] as int : null,
      userId: map['userId'] as int,
      date: map['date'] as String,
      timeIn: map['timeIn'] != null ? map['timeIn'] as String : null,
      timeOut: map['timeOut'] != null ? map['timeOut'] as String : null,
      type: map['type'] != null ? map['type'] as String : null,
      reason: map['reason'] != null ? map['reason'] as String : null,
      status: map['status'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory AttendanceModel.fromJson(String source) =>
      AttendanceModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
