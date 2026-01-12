import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/shared_pref_service.dart';
import '../models/task_model.dart';
import 'add_edit_taskscreen.dart';
import 'profile_screen.dart';
import 'weather_screen.dart';
import '../widgets/task_tile_widget.dart';
import '../utils/responsive.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SharedPrefsService _sharedPrefs = SharedPrefsService();
  String? _lastOpenTime;

  @override
  void initState() {
    super.initState();
    _loadLastOpenTime();
    _saveCurrentOpenTime();
  }

  Future<void> _loadLastOpenTime() async {
    final time = await _sharedPrefs.getLastOpenTime();
    if (time != null) {
      final formattedTime =
          DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.parse(time));
      setState(() {
        _lastOpenTime = formattedTime;
      });
    }
  }

  Future<void> _saveCurrentOpenTime() async {
    await _sharedPrefs.saveLastOpenTime();
  }

  Widget _buildTaskStats(BuildContext context, List<Task> tasks) {
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    final pendingTasks = tasks.length - completedTasks;
    final overdueTasks = tasks.where((task) {
      if (task.isCompleted) return false;
      final now = DateTime.now();
      final dueDate = task.dueDate;

      return dueDate.isBefore(DateTime(now.year, now.month, now.day));
    }).length;

    return Container(
      padding: EdgeInsets.all(context.wp(3)),
      margin: EdgeInsets.symmetric(
        horizontal: context.wp(4),
        vertical: context.hp(1),
      ),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(context.wp(3)),
        border: Border.all(color: Colors.blue.shade100, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
              context, 'Total', tasks.length.toString(), Colors.blue),
          _buildStatItem(
              context, 'Completed', completedTasks.toString(), Colors.green),
          _buildStatItem(
              context, 'Pending', pendingTasks.toString(), Colors.orange),
          _buildStatItem(
              context, 'Overdue', overdueTasks.toString(), Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: context.tp(5),
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: context.hp(0.5)),
        Text(
          label,
          style: TextStyle(
            fontSize: context.tp(3),
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final firestoreService = Provider.of<FirestoreService>(context);
    final currentUser = authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TaskFlow',
          style: TextStyle(
            color: Colors.blue,
            fontSize: context.tp(6),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.blue, size: context.tp(5.5)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade700, Colors.blue.shade400],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: context.wp(7.5),
                    child: Icon(Icons.person,
                        color: Colors.blue, size: context.tp(9)),
                  ),
                  SizedBox(height: context.hp(2)),
                  // Email with ellipsis for overflow
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      currentUser?.email ?? 'User',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.tp(4.5),
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(height: context.hp(0.6)),
                  Text(
                    'Task Manager',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: context.tp(3.5),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading:
                  Icon(Icons.home, color: Colors.blue, size: context.tp(5)),
              title: Text('Home', style: TextStyle(fontSize: context.tp(4))),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.cloud, color: Colors.blue, size: context.tp(5)),
              title: Text('Weather', style: TextStyle(fontSize: context.tp(4))),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WeatherScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading:
                  Icon(Icons.info, color: Colors.grey, size: context.tp(5)),
              title: Text('About', style: TextStyle(fontSize: context.tp(4))),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('TaskFlow',
                        style: TextStyle(fontSize: context.tp(4.5))),
                    content: Text(
                      'A simple task management app with weather integration.',
                      style: TextStyle(fontSize: context.tp(3.8)),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK',
                            style: TextStyle(fontSize: context.tp(4))),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.logout, color: Colors.red, size: context.tp(5)),
              title: Text('Logout', style: TextStyle(fontSize: context.tp(4))),
              onTap: () async {
                await authService.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Task>>(
        stream: firestoreService.getTasks(currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: context.hp(2)),
                  Text(
                    'Loading your tasks...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: context.tp(4),
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: context.tp(15), color: Colors.red),
                  SizedBox(height: context.hp(2)),
                  Text(
                    'Error loading tasks',
                    style: TextStyle(
                      fontSize: context.tp(4.5),
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: context.hp(1)),
                  Text(
                    'Please check your connection',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: context.tp(4),
                    ),
                  ),
                  SizedBox(height: context.hp(2)),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.wp(8),
                        vertical: context.hp(1.5),
                      ),
                    ),
                    child: Text('Retry',
                        style: TextStyle(fontSize: context.tp(4))),
                  ),
                ],
              ),
            );
          }

          final tasks = snapshot.data ?? [];

          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_alt_rounded,
                      size: context.tp(25), color: Colors.grey.shade300),
                  SizedBox(height: context.hp(3)),
                  Text(
                    'No tasks yet',
                    style: TextStyle(
                      fontSize: context.tp(6),
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: context.hp(1.5)),
                  Text(
                    'Start by adding your first task',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: context.tp(4),
                    ),
                  ),
                  SizedBox(height: context.hp(4)),
                  ElevatedButton.icon(
                    onPressed: () {
                      _navigateToAddEditTask(context);
                    },
                    icon: Icon(Icons.add, size: context.tp(4.5)),
                    label: Text('Create First Task',
                        style: TextStyle(fontSize: context.tp(4))),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.wp(8),
                        vertical: context.hp(1.8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Sort tasks: incomplete first, then by due date
          tasks.sort((a, b) {
            if (a.isCompleted && !b.isCompleted) return 1;
            if (!a.isCompleted && b.isCompleted) return -1;

            //sort by due date
            return a.dueDate.compareTo(b.dueDate);
          });

          return Column(
            children: [
              if (_lastOpenTime != null)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.wp(4),
                    vertical: context.hp(1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time,
                          size: context.tp(3.5), color: Colors.grey),
                      SizedBox(width: context.wp(2)),
                      Expanded(
                        child: Text(
                          'Last opened: $_lastOpenTime',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: context.tp(3.2),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              _buildTaskStats(context, tasks),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.wp(4),
                  vertical: context.hp(1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.filter_list,
                        color: Colors.blue, size: context.tp(5)),
                    SizedBox(width: context.wp(2)),
                    Expanded(
                      child: Text(
                        'Your Tasks (${tasks.length})',
                        style: TextStyle(
                          fontSize: context.tp(4.5),
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: context.wp(2)),
                    Text(
                      'Sorted by Due Date',
                      style: TextStyle(
                        fontSize: context.tp(3.2),
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.wp(2),
                    vertical: context.hp(1),
                  ),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskTile(
                      task: task,
                      onToggleComplete: () async {
                        await firestoreService.toggleTaskCompletion(
                          task.id,
                          task.isCompleted,
                        );
                      },
                      onEdit: () {
                        _navigateToAddEditTask(context, task: task);
                      },
                      onDelete: () async {
                        bool confirm = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Delete Task',
                                    style:
                                        TextStyle(fontSize: context.tp(4.5))),
                                content: Text(
                                    'Are you sure you want to delete "${task.title}"?',
                                    style: TextStyle(fontSize: context.tp(4))),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text('Cancel',
                                        style:
                                            TextStyle(fontSize: context.tp(4))),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text('Delete',
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontSize: context.tp(4))),
                                  ),
                                ],
                              ),
                            ) ??
                            false;

                        if (confirm) {
                          await firestoreService.deleteTask(task.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Task deleted successfully',
                                  style: TextStyle(fontSize: context.tp(4))),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _navigateToAddEditTask(context);
        },
        icon: Icon(Icons.add, color: Colors.white, size: context.tp(5)),
        label: Text(
          "Add Task",
          style: TextStyle(
            color: Colors.white,
            fontSize: context.tp(4),
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.wp(12.5)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _navigateToAddEditTask(BuildContext context, {Task? task}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTaskScreen(task: task),
      ),
    );

    print('Add/Edit returned result: $result');
    if (result == true) {
      // Show success message based on action
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            task == null
                ? 'Task added successfully!'
                : 'Task updated successfully!',
            style: TextStyle(fontSize: context.tp(4)),
          ),
          backgroundColor: task == null ? Colors.green : Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );

      setState(() {});
    }
  }
}
