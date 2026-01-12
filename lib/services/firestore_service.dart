import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new task
  Future<void> createTask(Task task) async {
    try {
      final taskData = task.toMap();

      await _firestore.collection('tasks').doc(task.id).set(taskData);
    } catch (e) {
      print('Error creating task: $e');
      rethrow;
    }
  }

  // Get all tasks for current user
  Stream<List<Task>> getTasks(String userId) {
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
      print('Stream error: $error');
      return Stream.value(<Task>[]);
    }).map((snapshot) {
      final tasks = <Task>[];
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          final task = Task.fromMap(doc.id, data);
          tasks.add(task);
        } catch (e) {
          print('   Error parsing doc ${doc.id}: $e');
          print('   Data: ${doc.data()}');
        }
      }
      return tasks;
    });
  }

  // Update task
  Future<void> updateTask(Task task) async {
    try {
      await _firestore.collection('tasks').doc(task.id).update(task.toMap());
    } catch (e) {
      print('Error updating task: $e');
      throw e;
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      print('Error deleting task: $e');
      throw e;
    }
  }

  // Mark task as complete/incomplete
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    try {
      await _firestore
          .collection('tasks')
          .doc(taskId)
          .update({'isCompleted': !isCompleted});
    } catch (e) {
      print('Error toggling task: $e');
      throw e;
    }
  }

  // Test method to check Firestore connection
  Future<void> testConnection() async {
    try {
      await _firestore.collection('test').limit(1).get();
    } catch (e) {
      print('Firestore connection failed: $e');
      throw e;
    }
  }
}
