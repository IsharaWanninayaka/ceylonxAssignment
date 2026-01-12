import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime dueDate;
  final bool isCompleted;
  final String userId;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.dueDate,
    required this.isCompleted,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
      'userId': userId,
    };
  }

  factory Task.fromMap(String id, Map<String, dynamic> map) {
    DateTime parseDate(dynamic dateValue) {
      try {
        if (dateValue is Timestamp) {
          return dateValue.toDate();
        } else if (dateValue is String) {
          return DateTime.parse(dateValue);
        } else if (dateValue is DateTime) {
          return dateValue;
        } else if (dateValue is int) {
          return DateTime.fromMillisecondsSinceEpoch(dateValue);
        } else {
          print(
              'Unknown date format: $dateValue (type: ${dateValue.runtimeType})');
          return DateTime.now();
        }
      } catch (e) {
        print('Error parsing date: $e, value: $dateValue');
        return DateTime.now();
      }
    }

    return Task(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: parseDate(map['createdAt']),
      dueDate: parseDate(map['dueDate']),
      isCompleted: map['isCompleted'] ?? false,
      userId: map['userId'] ?? '',
    );
  }

  String formatCreatedAt() {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(createdAt);
  }

  String formatDueDate() {
    return DateFormat('MMM dd, yyyy').format(dueDate);
  }

  bool get isOverdue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return !isCompleted && due.isBefore(today);
  }

  bool get isDueToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.isAtSameMomentAs(today);
  }
}
