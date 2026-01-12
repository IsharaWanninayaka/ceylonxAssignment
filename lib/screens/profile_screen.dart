import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/responsive.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/task_model.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Stream<List<Task>> _tasksStream;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.getCurrentUser();
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);

    if (currentUser != null) {
      _tasksStream = firestoreService.getTasks(currentUser.uid);
    } else {
      _tasksStream = Stream.value([]);
    }
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    final cardWidth = context.wp(28).clamp(100.0, 160.0) as double;
    return Container(
      width: cardWidth,
      padding: EdgeInsets.symmetric(
          horizontal: context.wp(3), vertical: context.hp(1.8)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.wp(3.5)),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(context.wp(2.6)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: context.tp(5), color: color),
          ),
          SizedBox(height: context.hp(1.6)),
          Text(
            value,
            style: TextStyle(
              fontSize: context.tp(5),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: context.hp(0.6)),
          Text(
            title,
            style: TextStyle(
              fontSize: context.tp(3.5),
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, String title, String value, IconData icon) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: context.hp(0.7)),
      padding: EdgeInsets.symmetric(
          horizontal: context.wp(3), vertical: context.hp(1.6)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.wp(3)),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.wp(2)),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(context.wp(2.5)),
            ),
            child: Icon(icon, size: context.tp(4.5), color: Colors.blue),
          ),
          SizedBox(width: context.wp(3.5)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: context.tp(3.5),
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: context.hp(0.6)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: context.tp(4),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.getCurrentUser();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue, size: context.tp(5)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Profile',
          style: TextStyle(
            color: Colors.blue.shade700,
            fontSize: context.tp(5.5),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.wp(5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Header
            Container(
              padding: EdgeInsets.all(context.wp(4)),
              margin: EdgeInsets.only(bottom: context.hp(2.6)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade50, Colors.lightBlue.shade50],
                ),
                borderRadius: BorderRadius.circular(context.wp(5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: context.wp(28).clamp(80.0, 140.0) as double,
                        height: context.wp(28).clamp(80.0, 140.0) as double,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Colors.blue, Colors.lightBlue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade300.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person,
                          size: context.tp(12),
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(context.wp(2.2)),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Icon(Icons.check,
                            size: context.tp(3.5), color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: context.hp(2.2)),
                  Text(
                    currentUser?.email?.split('@').first ?? 'User',
                    style: TextStyle(
                      fontSize: context.tp(6),
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  SizedBox(height: context.hp(1)),
                  Text(
                    currentUser?.email ?? 'No email',
                    style: TextStyle(
                      fontSize: context.tp(4),
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.hp(0.6)),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: context.wp(3.5), vertical: context.hp(0.9)),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Active User',
                      style: TextStyle(
                        fontSize: context.tp(3.5),
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Task Statistics
            StreamBuilder<List<Task>>(
              stream: _tasksStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: context.hp(3.5)),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                final tasks = snapshot.data ?? [];
                final completedTasks =
                    tasks.where((task) => task.isCompleted).length;
                final pendingTasks = tasks.length - completedTasks;
                final overdueTasks =
                    tasks.where((task) => task.isOverdue).length;
                final todayTasks =
                    tasks.where((task) => task.isDueToday).length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: context.hp(1.2)),
                      child: Text(
                        'Task Statistics',
                        style: TextStyle(
                          fontSize: context.tp(4.5),
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SizedBox(width: context.wp(1.5)),
                          _buildStatCard(
                              context,
                              'Total',
                              tasks.length.toString(),
                              Icons.list_alt,
                              Colors.blue),
                          SizedBox(width: context.wp(3)),
                          _buildStatCard(
                              context,
                              'Completed',
                              completedTasks.toString(),
                              Icons.check_circle,
                              Colors.green),
                          SizedBox(width: context.wp(3)),
                          _buildStatCard(
                              context,
                              'Pending',
                              pendingTasks.toString(),
                              Icons.pending,
                              Colors.orange),
                          SizedBox(width: context.wp(3)),
                          _buildStatCard(
                              context,
                              'Overdue',
                              overdueTasks.toString(),
                              Icons.warning,
                              Colors.red),
                          SizedBox(width: context.wp(3)),
                          _buildStatCard(
                              context,
                              'Today',
                              todayTasks.toString(),
                              Icons.today,
                              Colors.purple),
                          SizedBox(width: context.wp(1.5)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: context.hp(3.8)),

            // User Information
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: context.hp(1.2)),
                  child: Text(
                    'Account Information',
                    style: TextStyle(
                      fontSize: context.tp(4.5),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                _buildInfoCard(
                  context,
                  'Email Address',
                  currentUser?.email ?? 'N/A',
                  Icons.email,
                ),
                _buildInfoCard(
                  context,
                  'User ID',
                  currentUser?.uid != null
                      ? '${currentUser!.uid.substring(0, 12)}...'
                      : 'N/A',
                  Icons.fingerprint,
                ),
                _buildInfoCard(
                  context,
                  'Account Created',
                  DateFormat('MMM dd, yyyy').format(
                    currentUser?.metadata.creationTime ?? DateTime.now(),
                  ),
                  Icons.calendar_today,
                ),
                _buildInfoCard(
                  context,
                  'Last Sign In',
                  DateFormat('MMM dd, yyyy • hh:mm a').format(
                    currentUser?.metadata.lastSignInTime ?? DateTime.now(),
                  ),
                  Icons.access_time,
                ),
                _buildInfoCard(
                  context,
                  'Account Status',
                  'Verified',
                  Icons.verified,
                ),
              ],
            ),

            SizedBox(height: context.hp(4.8)),

            // Logout Button
            Container(
              padding: EdgeInsets.symmetric(horizontal: context.wp(5)),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      bool confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Row(
                                children: [
                                  Icon(Icons.logout,
                                      color: Colors.red, size: context.tp(5)),
                                  SizedBox(width: context.wp(2.5)),
                                  Text('Confirm Logout',
                                      style:
                                          TextStyle(fontSize: context.tp(4.5))),
                                ],
                              ),
                              content: Text('Are you sure you want to logout?',
                                  style: TextStyle(fontSize: context.tp(4))),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text('Cancel',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: context.tp(4))),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: Text('Logout',
                                      style:
                                          TextStyle(fontSize: context.tp(4))),
                                ),
                              ],
                            ),
                          ) ??
                          false;

                      if (confirm) {
                        await authService.signOut();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      }
                    },
                    icon: Icon(Icons.logout, size: context.tp(5)),
                    label: Text(
                      'Logout',
                      style: TextStyle(
                          fontSize: context.tp(4), fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, context.hp(6.5)),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.wp(3.5)),
                      ),
                      shadowColor: Colors.red.withOpacity(0.3),
                    ),
                  ),
                  SizedBox(height: context.hp(2.2)),
                  Text(
                    'TaskFlow v1.0.0',
                    style: TextStyle(
                      fontSize: context.tp(3),
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
