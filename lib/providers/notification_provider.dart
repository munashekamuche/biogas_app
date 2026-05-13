import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  // Listen to notifications for a user
  void listenToNotifications(String userId) {
    _notificationService.getUserNotifications(userId).listen((notifications) {
      _notifications = notifications;
      _updateUnreadCount();
      notifyListeners();
    });

    _notificationService.getUnreadCount(userId).listen((count) {
      _unreadCount = count;
      notifyListeners();
    });
  }

  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.read).length;
  }

  Future<void> markAsRead(String notificationId) async {
    await _notificationService.markAsRead(notificationId);
    // Update local state
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(read: true);
      _updateUnreadCount();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead(String userId) async {
    await _notificationService.markAllAsRead(userId);
    // Update local state
    _notifications = _notifications.map((n) => n.copyWith(read: true)).toList();
    _unreadCount = 0;
    notifyListeners();
  }

  Future<void> deleteNotification(String notificationId) async {
    await _notificationService.deleteNotification(notificationId);
    _notifications.removeWhere((n) => n.id == notificationId);
    _updateUnreadCount();
    notifyListeners();
  }
}

