import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/notification.dart';

// Events
abstract class NotificationEvent {}

class AddNotificationEvent extends NotificationEvent {
  final NotificationModel notification;
  AddNotificationEvent(this.notification);
}

class UpdateNotificationEvent extends NotificationEvent {
  final String notificationId;
  final NotificationModel updatedNotification;
  UpdateNotificationEvent(this.notificationId, this.updatedNotification);
}

class DeleteNotificationEvent extends NotificationEvent {
  final String notificationId;
  DeleteNotificationEvent(this.notificationId);
}

// States
abstract class NotificationBlocState {}

class LoadingState extends NotificationBlocState {}

class LoadedState extends NotificationBlocState {
  final List<NotificationModel> notifications;
  LoadedState(this.notifications);
}

class ErrorState extends NotificationBlocState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class NotificationBloc extends Bloc<NotificationEvent, NotificationBlocState> {
  late FirebaseFirestore _firestore;
  late CollectionReference notificationsRef;

  NotificationBloc() : super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
    notificationsRef = _firestore.collection('notifications');
  }

  @override
  Stream<NotificationBlocState> mapEventToState(NotificationEvent event) async* {
    if (event is AddNotificationEvent) {
      yield LoadingState();
      try {
        final newId = await _generateNextNotificationId();
        await FirebaseFirestore.instance.collection('notifications').add({
          'id' : newId,
          'pesan': event.notification.pesan,
          'created_at': event.notification.createdAt,
          'posisi': event.notification.posisi,
          'status': event.notification.status
        });

        yield LoadedState(await _getNotifications());
      } catch (e) {
        yield ErrorState("Gagal menambahkan notifikasi.");
      }
    } else if (event is UpdateNotificationEvent) {
      yield LoadingState();
      try {
        final notificationSnapshot = await notificationsRef.doc(event.notificationId).get();
        if (notificationSnapshot.exists) {
          await notificationSnapshot.reference.update({
            // Definisikan properti notifikasi sesuai kebutuhan Anda
            'id': event.updatedNotification.id,
            'pesan': event.updatedNotification.pesan,
            'created_at': event.updatedNotification.createdAt,
            'posisi': event.updatedNotification.posisi,
            'status': event.updatedNotification.status
          });
          final notifications = await _getNotifications();
          yield LoadedState(notifications);
        } else {
          yield ErrorState('Notifikasi dengan ID ${event.notificationId} tidak ditemukan.');
        }
      } catch (e) {
        yield ErrorState("Gagal mengubah notifikasi.");
      }
    } else if (event is DeleteNotificationEvent) {
      yield LoadingState();
      try {
        await notificationsRef.doc(event.notificationId).delete();
        yield LoadedState(await _getNotifications());
      } catch (e) {
        yield ErrorState("Gagal menghapus notifikasi.");
      }
    }
  }

  Future<List<NotificationModel>> _getNotifications() async {
    final QuerySnapshot snapshot = await notificationsRef.get();
    final List<NotificationModel> notifications = [];
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      notifications.add(NotificationModel.fromJson(data));
    }
    return notifications;
  }

  Future<String> _generateNextNotificationId() async {
  final QuerySnapshot snapshot = await notificationsRef.get();
  final List<String> existingIds = snapshot.docs.map((doc) => doc.id as String).toList();
  int notificationCount = 1;

  while (true) {
    final nextNotificationId = 'NOTIF${notificationCount.toString().padLeft(5, '0')}';
    if (!existingIds.contains(nextNotificationId)) {
      return nextNotificationId;
    }
    notificationCount++;
  }
}

}
