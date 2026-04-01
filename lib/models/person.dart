import 'dart:convert';

/// 사용자의 이름, 생일, 목표 D-Day 정보를 담는 모델입니다.
class Person {
  final String id;
  final String name;
  final DateTime birthday;
  final bool isLunar; 
  final DateTime refBirthday; // 기준 생일 (매년 기념할 날짜)
  final bool isRefLunar; // 기준 생일의 양/음력 여부
  final DateTime? nextBirthday;
  
  // [개편] 두 가지 목표를 독립적으로 저장
  final DateTime? targetDDayDate;
  final int? targetDDayValue;
  final DateTime? targetAgeDate;
  final int? targetAgeValue;

  Person({
    required this.id,
    required this.name,
    required this.birthday,
    required this.isLunar,
    required this.refBirthday,
    required this.isRefLunar,
    this.nextBirthday,
    this.targetDDayDate,
    this.targetDDayValue,
    this.targetAgeDate,
    this.targetAgeValue,
  });

  // JSON 직렬화
  factory Person.fromJson(Map<String, dynamic> json) => Person(
    id: json['id'],
    name: json['name'],
    birthday: DateTime.parse(json['birthday']),
    isLunar: json['isLunar'] ?? false,
    refBirthday: json['refBirthday'] != null 
        ? DateTime.parse(json['refBirthday']) 
        : DateTime.parse(json['birthday']),
    isRefLunar: json['isRefLunar'] ?? json['isLunar'] ?? false,
    nextBirthday: json['nextBirthday'] != null ? DateTime.parse(json['nextBirthday']) : null,
    targetDDayDate: json['targetDDayDate'] != null ? DateTime.parse(json['targetDDayDate']) : null,
    targetDDayValue: json['targetDDayValue'],
    targetAgeDate: json['targetAgeDate'] != null ? DateTime.parse(json['targetAgeDate']) : null,
    targetAgeValue: json['targetAgeValue'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'birthday': birthday.toIso8601String(),
    'isLunar': isLunar,
    'refBirthday': refBirthday.toIso8601String(),
    'isRefLunar': isRefLunar,
    'nextBirthday': nextBirthday?.toIso8601String(),
    'targetDDayDate': targetDDayDate?.toIso8601String(),
    'targetDDayValue': targetDDayValue,
    'targetAgeDate': targetAgeDate?.toIso8601String(),
    'targetAgeValue': targetAgeValue,
  };

  // 수정을 위한 copyWith
  Person copyWith({
    DateTime? nextBirthday,
    DateTime? targetDDayDate,
    int? targetDDayValue,
    DateTime? targetAgeDate,
    int? targetAgeValue,
  }) => Person(
    id: id,
    name: name,
    birthday: birthday,
    isLunar: isLunar,
    refBirthday: refBirthday,
    isRefLunar: isRefLunar,
    nextBirthday: nextBirthday ?? this.nextBirthday,
    targetDDayDate: targetDDayDate ?? this.targetDDayDate,
    targetDDayValue: targetDDayValue ?? this.targetDDayValue,
    targetAgeDate: targetAgeDate ?? this.targetAgeDate,
    targetAgeValue: targetAgeValue ?? this.targetAgeValue,
  );


  static String encode(List<Person> p) => json.encode(p.map((e) => e.toJson()).toList());
  static List<Person> decode(String s) {
    if (s.isEmpty) return [];
    try {
      final List<dynamic> list = json.decode(s);
      return list.map((e) => Person.fromJson(e)).toList();
    } catch (e) {
      return []; // 파싱 에러 시 빈 리스트 반환하여 블랙스크린 방지
    }
  }
}
// lib/models/person.dart 끝
