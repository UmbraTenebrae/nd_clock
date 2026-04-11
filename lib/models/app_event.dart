import 'dart:convert';
import 'package:flutter/material.dart';

class AppEvent {
  final String id;
  final TimeOfDay time;
  final String label;

  const AppEvent({
    required this.id,
    required this.time,
    required this.label,
  });

  AppEvent copyWith({String? id, TimeOfDay? time, String? label}) {
    return AppEvent(
      id: id ?? this.id,
      time: time ?? this.time,
      label: label ?? this.label,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'hour': time.hour,
        'minute': time.minute,
        'label': label,
      };

  factory AppEvent.fromJson(Map<String, dynamic> json) => AppEvent(
        id: json['id'] as String,
        time: TimeOfDay(
            hour: json['hour'] as int, minute: json['minute'] as int),
        label: json['label'] as String,
      );

  static String encodeList(List<AppEvent> events) =>
      jsonEncode(events.map((e) => e.toJson()).toList());

  static List<AppEvent> decodeList(String json) {
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => AppEvent.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
