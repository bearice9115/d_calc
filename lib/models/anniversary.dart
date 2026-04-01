import 'dart:convert';

class Anniversary {
  final String id;
  final String title;
  final DateTime date;
  
  // 목표 설정 필드 추가
  final DateTime? targetDate;
  final int? targetValue;

  Anniversary({
    required this.id,
    required this.title,
    required this.date,
    this.targetDate,
    this.targetValue,
  });

  factory Anniversary.fromJson(Map<String, dynamic> json) => Anniversary(
    id: json['id'],
    title: json['title'],
    date: DateTime.parse(json['date']),
    targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate']) : null,
    targetValue: json['targetValue'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'date': date.toIso8601String(),
    'targetDate': targetDate?.toIso8601String(),
    'targetValue': targetValue,
  };

  Anniversary copyWith({DateTime? targetDate, int? targetValue}) => Anniversary(
    id: id,
    title: title,
    date: date,
    targetDate: targetDate ?? this.targetDate,
    targetValue: targetValue ?? this.targetValue,
  );

  static String encode(List<Anniversary> list) => json.encode(list.map((e) => e.toJson()).toList());
  static List<Anniversary> decode(String s) {
    if (s.isEmpty) return [];
    try {
      final List<dynamic> list = json.decode(s);
      return list.map((e) => Anniversary.fromJson(e)).toList();
    } catch (_) { return []; }
  }
}
