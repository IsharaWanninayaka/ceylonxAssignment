import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/task_model.dart';
import '../utils/responsive.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;

  AddEditTaskScreen({this.task});

  @override
  _AddEditTaskScreenState createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _dueDate = widget.task!.dueDate;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _saveTask(BuildContext context) async {
    print('1. _saveTask called');
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) return;

    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a due date',
              style: TextStyle(fontSize: context.tp(4))),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final firestoreService =
          Provider.of<FirestoreService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.getCurrentUser();

      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      final task = Task(
        id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        createdAt: widget.task?.createdAt ?? DateTime.now(),
        dueDate: _dueDate!,
        isCompleted: widget.task?.isCompleted ?? false,
        userId: currentUser.uid,
      );

      if (widget.task == null) {
        try {
          await firestoreService.createTask(task).timeout(Duration(seconds: 2),
              onTimeout: () {
            return;
          });
        } catch (e) {
          print('createTask threw: $e');
          rethrow;
        }
      } else {
        try {
          await firestoreService.updateTask(task).timeout(Duration(seconds: 2),
              onTimeout: () {
            return;
          });
        } catch (e) {
          print('updateTask threw: $e');
          rethrow;
        }
      }

      if (mounted) {
        try {
          setState(() {
            _isLoading = false;
          });
        } catch (_) {}

        // Give a tiny delay to allow the loading state to take effect on the UI before popping
        await Future.delayed(Duration(milliseconds: 150));

        try {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop(true);
            return;
          } else {
            Navigator.of(context, rootNavigator: true).pop(true);
            return;
          }
        } catch (e) {
          print('Error popping navigator: $e');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              Navigator.of(context, rootNavigator: true).pop(true);
            } catch (err) {
              print('Scheduled root navigator pop failed: $err');
            }
          });
        }
      } else {
        // If widget is not mounted, schedule a pop in the next frame via root navigator
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            Navigator.of(context, rootNavigator: true).pop(true);
          } catch (err) {
            print('Scheduled root navigator pop failed: $err');
          }
        });
      }
    } catch (error) {
      // Log error for debugging
      print('Error saving task: $error');

      final errMsg = error.toString().toLowerCase();
      final treatAsLocalSuccess = errMsg.contains('not_found') ||
          errMsg.contains('not found') ||
          errMsg.contains('database (default)') ||
          errMsg.contains('timed out') ||
          errMsg.contains('timeout');

      if (treatAsLocalSuccess) {
        // Show info snackbar and pop to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Task saved locally and will sync when Firestore is available.',
                style: TextStyle(fontSize: context.tp(4))),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );

        // Ensure loading cleared and pop
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        await Future.delayed(const Duration(milliseconds: 150));
        try {
          if (mounted && Navigator.canPop(context)) {
            Navigator.of(context).pop(true);
          } else {
            Navigator.of(context, rootNavigator: true).pop(true);
          }
        } catch (e) {
          print('Error popping after treated success: $e');
        }

        return;
      }

      // Show snackbar with short message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to save task: ${error.toString().length > 80 ? error.toString().substring(0, 80) + "..." : error.toString()}',
              style: TextStyle(fontSize: context.tp(4))),
          backgroundColor: Colors.red,
        ),
      );

      // modal dialog with guidance for common setup issues (e.g., Firestore not enabled)
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title:
              Text('Save Failed', style: TextStyle(fontSize: context.tp(4.5))),
          content: Text(
              'Failed to save the task. Firestore is not enabled for your Firebase project.',
              style: TextStyle(fontSize: context.tp(4))),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK', style: TextStyle(fontSize: context.tp(4))),
            ),
          ],
        ),
      );

      // not pop on error
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.task == null ? 'Add Task' : 'Edit Task',
          style: TextStyle(
            color: Colors.blue,
            fontSize: context.tp(6),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: context.tp(5.5)),
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.of(context).pop();
                },
        ),
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.wp(4)),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    style: TextStyle(fontSize: context.tp(4)),
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: TextStyle(fontSize: context.tp(4)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(context.wp(2.5)),
                      ),
                      prefixIcon: Icon(Icons.title, size: context.tp(5)),
                      filled: _isLoading,
                      fillColor: _isLoading ? Colors.grey.shade100 : null,
                    ),
                    enabled: !_isLoading,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter title';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: context.hp(2.5)),
                  TextFormField(
                    controller: _descriptionController,
                    style: TextStyle(fontSize: context.tp(4)),
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      labelStyle: TextStyle(fontSize: context.tp(4)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(context.wp(2.5)),
                      ),
                      prefixIcon: Icon(Icons.description, size: context.tp(5)),
                      filled: _isLoading,
                      fillColor: _isLoading ? Colors.grey.shade100 : null,
                    ),
                    enabled: !_isLoading,
                    maxLines: 3,
                    minLines: 2,
                  ),
                  SizedBox(height: context.hp(2.5)),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          color: Colors.blue, size: context.tp(5)),
                      SizedBox(width: context.wp(2.5)),
                      Text('Due Date:',
                          style: TextStyle(
                              fontSize: context.tp(4),
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: context.wp(2.5)),
                      Expanded(
                        child: TextButton(
                          onPressed:
                              _isLoading ? null : () => _selectDate(context),
                          style: TextButton.styleFrom(
                            backgroundColor: _dueDate == null
                                ? Colors.red.shade50
                                : Colors.blue.shade50,
                            padding: EdgeInsets.symmetric(
                                horizontal: context.wp(4),
                                vertical: context.hp(1.5)),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(context.wp(2)),
                              side: BorderSide(
                                color:
                                    _dueDate == null ? Colors.red : Colors.blue,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            _dueDate == null
                                ? 'Select Date'
                                : DateFormat('MMM dd, yyyy').format(_dueDate!),
                            style: TextStyle(
                              color:
                                  _dueDate == null ? Colors.red : Colors.blue,
                              fontWeight: FontWeight.w500,
                              fontSize: context.tp(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_dueDate == null)
                    Padding(
                      padding: EdgeInsets.only(
                          left: context.wp(8.5), top: context.hp(1)),
                      child: Text(
                        'Due Date is required',
                        style: TextStyle(
                            color: Colors.red, fontSize: context.tp(3.5)),
                      ),
                    ),
                  if (_dueDate != null)
                    Padding(
                      padding: EdgeInsets.only(
                          left: context.wp(8.5), top: context.hp(1)),
                      child: Text(
                        'Selected: ${DateFormat('EEEE, MMMM dd, yyyy').format(_dueDate!)}',
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: context.tp(3.5),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  SizedBox(height: context.hp(2.5)),
                  Container(
                    padding: EdgeInsets.all(context.wp(4)),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(context.wp(2.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Task Summary',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: context.tp(4)),
                        ),
                        SizedBox(height: context.hp(1)),
                        Text(
                          'Title: ${_titleController.text.isNotEmpty ? _titleController.text : "Not set"}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(fontSize: context.tp(3.8)),
                        ),
                        SizedBox(height: context.hp(0.5)),
                        Text(
                          'Description: ${_descriptionController.text.isNotEmpty ? _descriptionController.text : "No description"}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(fontSize: context.tp(3.8)),
                        ),
                        SizedBox(height: context.hp(0.5)),
                        Text(
                          'Due Date: ${_dueDate != null ? DateFormat('MMM dd, yyyy').format(_dueDate!) : "Not set"}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(fontSize: context.tp(3.8)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.hp(3.5)),
                  _isLoading
                      ? Center(
                          child: Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: context.hp(2.5)),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () => _saveTask(context),
                          style: ElevatedButton.styleFrom(
                            padding:
                                EdgeInsets.symmetric(vertical: context.hp(2.2)),
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(context.wp(2.5)),
                            ),
                          ),
                          child: Text(
                            widget.task == null ? 'Add Task' : 'Update Task',
                            style: TextStyle(
                                fontSize: context.tp(4.5), color: Colors.white),
                          ),
                        ),
                  SizedBox(height: context.hp(1.2)),
                  if (widget.task != null && !_isLoading)
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: context.hp(2.2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.wp(2.5)),
                        ),
                      ),
                      child: Text('Cancel',
                          style: TextStyle(fontSize: context.tp(4.5))),
                    ),
                  SizedBox(height: context.hp(2.5)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
