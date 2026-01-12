import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../utils/responsive.dart'; // Add this import

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  TaskTile({
    required this.task,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getDueDateColor() {
    if (task.isCompleted) return Colors.grey;
    if (task.dueDate == null) return Colors.grey;

    final now = DateTime.now();
    final dueDate = task.dueDate!;

    // Remove time part for comparison
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (dueDay.isBefore(today)) {
      return Colors.red;
    } else if (dueDay == today) {
      return Colors.orange;
    } else if (dueDay == today.add(const Duration(days: 1))) {
      return Colors.orange.shade600;
    } else {
      return Colors.green;
    }
  }

  String _getDueDateText() {
    if (task.dueDate == null) return 'No due date';

    final now = DateTime.now();
    final dueDate = task.dueDate!;

    // Remove time part for comparison
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (dueDay.isBefore(today)) {
      final daysPast = today.difference(dueDay).inDays;
      return 'Overdue by $daysPast ${daysPast == 1 ? 'day' : 'days'}';
    } else if (dueDay == today) {
      return 'Due today';
    } else if (dueDay == today.add(const Duration(days: 1))) {
      return 'Due tomorrow';
    } else {
      final daysLeft = dueDay.difference(today).inDays;
      return 'Due in $daysLeft days';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dueDateColor = _getDueDateColor();
    final dueDateText = _getDueDateText();
    final isSmallScreen = context.wp(100) < 360;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.wp(100) < 600 ? context.wp(2) : context.wp(3),
        vertical: context.hp(0.8),
      ),
      decoration: BoxDecoration(
        color: task.isCompleted ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(context.wp(3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: context.wp(1),
            offset: Offset(0, context.wp(0.5)),
          ),
        ],
        border: Border.all(
          color: task.isCompleted ? Colors.grey.shade300 : Colors.blue.shade50,
          width: 1,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < context.wp(75);

          return Row(
            children: [
              // Complete Checkbox
              Padding(
                padding: EdgeInsets.only(
                  left: isSmallScreen ? context.wp(2) : context.wp(3),
                  right: isSmallScreen ? context.wp(2) : context.wp(3),
                ),
                child: GestureDetector(
                  onTap: onToggleComplete,
                  child: Container(
                    width: isSmallScreen ? context.wp(7) : context.wp(8),
                    height: isSmallScreen ? context.wp(7) : context.wp(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted
                          ? Colors.green.shade100
                          : Colors.blue.shade100,
                    ),
                    child: Icon(
                      task.isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: task.isCompleted ? Colors.green : Colors.blue,
                      size: isSmallScreen ? context.wp(4.5) : context.wp(5.5),
                    ),
                  ),
                ),
              ),

              // Task Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: context.hp(1),
                    bottom: context.hp(1),
                    right: isSmallScreen ? context.wp(1) : context.wp(2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: isSmallScreen
                                    ? context.tp(3.5)
                                    : context.tp(4),
                                fontWeight: FontWeight.w600,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: task.isCompleted
                                    ? Colors.grey
                                    : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isCompact) _buildPopupMenu(context),
                        ],
                      ),

                      // Description
                      if (task.description.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(
                            top: context.hp(0.5),
                            bottom: context.hp(0.8),
                          ),
                          child: Text(
                            task.description,
                            style: TextStyle(
                              fontSize: isSmallScreen
                                  ? context.tp(3)
                                  : context.tp(3.5),
                              color: task.isCompleted
                                  ? Colors.grey
                                  : Colors.black54,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      // Due Date Row
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: isSmallScreen
                                ? context.tp(2.8)
                                : context.tp(3.2),
                            color: dueDateColor,
                          ),
                          SizedBox(
                              width: isSmallScreen
                                  ? context.wp(1)
                                  : context.wp(1.5)),
                          Flexible(
                            child: Text(
                              dueDateText,
                              style: TextStyle(
                                fontSize: isSmallScreen
                                    ? context.tp(2.6)
                                    : context.tp(2.8),
                                color: dueDateColor,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (task.dueDate != null && !isSmallScreen)
                            Padding(
                              padding: EdgeInsets.only(left: context.wp(2)),
                              child: Text(
                                DateFormat('(MMM dd)').format(task.dueDate!),
                                style: TextStyle(
                                  fontSize: context.tp(2.6),
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Popup menu for compact layout
              if (isCompact) _buildPopupMenu(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Colors.grey,
        size: context.wp(100) < 360 ? context.wp(4.5) : context.wp(6),
      ),
      onSelected: (value) {
        if (value == 'edit') onEdit();
        if (value == 'delete') onDelete();
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue, size: context.tp(4.5)),
              SizedBox(width: context.wp(2)),
              Text('Edit', style: TextStyle(fontSize: context.tp(3.5))),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red, size: context.tp(4.5)),
              SizedBox(width: context.wp(2)),
              Text('Delete', style: TextStyle(fontSize: context.tp(3.5))),
            ],
          ),
        ),
      ],
    );
  }
}
