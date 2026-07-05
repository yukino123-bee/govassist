import 'package:flutter/material.dart';
import '../../data/service_data.dart';
import '../../core/user_session.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final userId = UserSession().currentUser?['id']?.toString();
    if (userId == null) return;

    final result = await ServiceData.fetchNotifications(userId);
    if (mounted) {
      setState(() {
        _notifications = result['notifications'] ?? [];
        _isLoading = false;
      });
    }
  }

  void _markAsRead(String notifId) async {
    final userId = UserSession().currentUser?['id']?.toString();
    if (userId == null) return;

    final success = await ServiceData.markNotificationRead(userId, notificationId: notifId);
    if (success) {
      _loadNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(child: Text('No notifications yet.'))
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notif = _notifications[index];
                    final isRead = notif['is_read'] == 1 || notif['is_read'] == true;
                    return ListTile(
                      tileColor: isRead ? null : Colors.blue.withValues(alpha: 0.05),
                      leading: Icon(
                        isRead ? Icons.notifications_none : Icons.notifications_active,
                        color: isRead ? Colors.grey : Theme.of(context).primaryColor,
                      ),
                      title: Text(notif['title'], style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
                      subtitle: Text(notif['message']),
                      trailing: Text(
                        notif['created_at'].split(' ')[0],
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      onTap: () {
                        if (!isRead) {
                          _markAsRead(notif['id'].toString());
                        }
                      },
                    );
                  },
                ),
    );
  }
}
