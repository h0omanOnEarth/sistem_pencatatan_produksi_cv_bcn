import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/penjualan/detail_pesanan_pelanggan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/penjualan/pesanan_pelanggan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/emailNotificationService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/notificationService.dart';

// Events
abstract class CustomerOrderEvent {}

class AddCustomerOrderEvent extends CustomerOrderEvent {
  final CustomerOrder customerOrder;
  AddCustomerOrderEvent(this.customerOrder);
}

class UpdateCustomerOrderEvent extends CustomerOrderEvent {
  final String customerOrderId;
  final CustomerOrder customerOrder;
  UpdateCustomerOrderEvent(this.customerOrderId, this.customerOrder);
}

class DeleteCustomerOrderEvent extends CustomerOrderEvent {
  final String customerOrderId;
  DeleteCustomerOrderEvent(this.customerOrderId);
}

// States
abstract class CustomerOrderBlocState {}

class LoadingState extends CustomerOrderBlocState {}

class SuccessState extends CustomerOrderBlocState {}

class LoadedState extends CustomerOrderBlocState {
  final CustomerOrder customerOrder;
  LoadedState(this.customerOrder);
}

class CustomerOrderUpdatedState extends CustomerOrderBlocState {}

class CustomerOrderDeletedState extends CustomerOrderBlocState {}

class ErrorState extends CustomerOrderBlocState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class CustomerOrderBloc
    extends Bloc<CustomerOrderEvent, CustomerOrderBlocState> {
  late FirebaseFirestore _firestore;
  final HttpsCallable customerOrderCallable;
  final notificationService = NotificationService();

  CustomerOrderBloc()
      : customerOrderCallable =
            FirebaseFunctions.instanceFor(region: "asia-southeast2")
                .httpsCallable('customerOrderValidation'),
        super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Stream<CustomerOrderBlocState> mapEventToState(
      CustomerOrderEvent event) async* {
    if (event is AddCustomerOrderEvent) {
      yield LoadingState();

      final customerId = event.customerOrder.customerId;
      final alamatPengiriman = event.customerOrder.alamatPengiriman;
      final catatan = event.customerOrder.catatan;
      final satuan = event.customerOrder.satuan;
      final status = event.customerOrder.status;
      final statusPesanan = event.customerOrder.statusPesanan;
      final tanggalKirim = event.customerOrder.tanggalKirim;
      final tanggalPesan = event.customerOrder.tanggalPesan;
      final totalHarga = event.customerOrder.totalHarga;
      final totalProduk = event.customerOrder.totalProduk;
      final products = event.customerOrder.detailCustomerOrderList;

      if (customerId.isNotEmpty) {
        if (alamatPengiriman.isNotEmpty) {
          try {
            final HttpsCallableResult<dynamic> result =
                await customerOrderCallable.call(<String, dynamic>{
              'products': products?.map((product) => product.toJson()).toList(),
              'totalProduk': totalProduk,
              'totalHarga': totalHarga
            });

            if (result.data['success'] == true) {
              // Generate a new customer order ID (or use an existing one if you have it)
              final nextCustomerOrderId = await _generateNextCustomerId();

              // Buat referensi dokumen customer order menggunakan ID yang sesuai
              final customerOrderRef = _firestore
                  .collection('customer_orders')
                  .doc(nextCustomerOrderId);

              // Set data customer order
              final Map<String, dynamic> customerOrderData = {
                'id': nextCustomerOrderId,
                'customer_id': customerId,
                'alamat_pengiriman': alamatPengiriman,
                'catatan': catatan,
                'satuan': satuan,
                'status': status,
                'status_pesanan': statusPesanan,
                'tanggal_kirim': tanggalKirim,
                'tanggal_pesan': tanggalPesan,
                'total_harga': totalHarga,
                'total_produk': totalProduk,
              };

              // Tambahkan data customer order ke Firestore
              await customerOrderRef.set(customerOrderData);

              // Buat referensi ke subcollection 'detail_customer_orders' dalam dokumen customer order
              final detailCustomerOrderRef =
                  customerOrderRef.collection('detail_customer_orders');

              if (event.customerOrder.detailCustomerOrderList != null &&
                  event.customerOrder.detailCustomerOrderList!.isNotEmpty) {
                int detailCount = 1;
                for (var detailCustomerOrder
                    in event.customerOrder.detailCustomerOrderList!) {
                  final nextDetailCustomerId =
                      '$nextCustomerOrderId${'D${detailCount.toString().padLeft(3, '0')}'}';

                  // Tambahkan dokumen detail customer order dalam koleksi 'detail_customer_orders'
                  await detailCustomerOrderRef.add({
                    'id': nextDetailCustomerId,
                    'customer_order_id': nextCustomerOrderId,
                    'product_id': detailCustomerOrder.productId,
                    'jumlah': detailCustomerOrder.jumlah,
                    'harga_satuan': detailCustomerOrder.hargaSatuan,
                    'satuan': detailCustomerOrder.satuan,
                    'status': detailCustomerOrder.status,
                    'subtotal': detailCustomerOrder.subtotal
                  });
                  detailCount++;
                }
              }

              await notificationService.addNotification(
                  'Terdapat pesanan pelanggan baru $nextCustomerOrderId',
                  'Administrasi');

              EmailNotificationService.sendNotification(
                'Pesanan Pelanggan Baru',
                _createEmailMessage(
                    nextCustomerOrderId,
                    customerId,
                    alamatPengiriman,
                    catatan,
                    totalHarga,
                    totalProduk,
                    tanggalPesan,
                    tanggalKirim,
                    products!),
                'Administrasi',
              );

              yield SuccessState();
            } else {
              yield ErrorState(result.data['message']);
            }
          } catch (e) {
            yield ErrorState(e.toString());
          }
        } else {
          yield ErrorState("alamat pengiriman tidak boleh kosong");
        }
      } else {
        yield ErrorState("kode pelanggan tidak boleh kosong");
      }
    } else if (event is UpdateCustomerOrderEvent) {
      yield LoadingState();

      final customerId = event.customerOrder.customerId;
      final alamatPengiriman = event.customerOrder.alamatPengiriman;
      final catatan = event.customerOrder.catatan;
      final satuan = event.customerOrder.satuan;
      final status = event.customerOrder.status;
      final statusPesanan = event.customerOrder.statusPesanan;
      final tanggalKirim = event.customerOrder.tanggalKirim;
      final tanggalPesan = event.customerOrder.tanggalPesan;
      final totalHarga = event.customerOrder.totalHarga;
      final totalProduk = event.customerOrder.totalProduk;
      final products = event.customerOrder.detailCustomerOrderList;

      if (customerId.isNotEmpty) {
        if (alamatPengiriman.isNotEmpty) {
          try {
            final HttpsCallableResult<dynamic> result =
                await customerOrderCallable.call(<String, dynamic>{
              'products': products?.map((product) => product.toJson()).toList(),
              'totalProduk': totalProduk,
              'totalHarga': totalHarga
            });

            if (result.data['success'] == true) {
              // Mendapatkan referensi dokumen customer order yang akan diperbarui
              final customerOrderToUpdateRef = _firestore
                  .collection('customer_orders')
                  .doc(event.customerOrderId);

              // Set data customer order yang baru
              final Map<String, dynamic> customerOrderData = {
                'id': event.customerOrderId,
                'customer_id': customerId,
                'alamat_pengiriman': alamatPengiriman,
                'catatan': catatan,
                'satuan': satuan,
                'status': status,
                'status_pesanan': statusPesanan,
                'tanggal_kirim': tanggalKirim,
                'tanggal_pesan': tanggalPesan,
                'total_harga': totalHarga,
                'total_produk': totalProduk,
              };

              // Update data customer order dalam dokumen yang ada
              await customerOrderToUpdateRef.set(customerOrderData);

              // Menghapus semua dokumen dalam sub koleksi 'detail_customer_orders' terlebih dahulu
              final detailCustomerOrderCollectionRef =
                  customerOrderToUpdateRef.collection('detail_customer_orders');
              final detailCustomerOrderDocs =
                  await detailCustomerOrderCollectionRef.get();
              for (var doc in detailCustomerOrderDocs.docs) {
                await doc.reference.delete();
              }

              // Menambahkan dokumen detail customer order yang baru dalam sub koleksi 'detail_customer_orders'
              if (event.customerOrder.detailCustomerOrderList != null &&
                  event.customerOrder.detailCustomerOrderList!.isNotEmpty) {
                int detailCount = 1;
                for (var detailCustomerOrder
                    in event.customerOrder.detailCustomerOrderList!) {
                  final nextDetailCustomerId =
                      'D${detailCount.toString().padLeft(3, '0')}';
                  final detailId = event.customerOrderId + nextDetailCustomerId;
                  // Tambahkan dokumen detail customer order dalam koleksi 'detail_customer_orders'
                  await detailCustomerOrderCollectionRef.add({
                    'id': detailId,
                    'customer_order_id': event.customerOrderId,
                    'product_id': detailCustomerOrder.productId,
                    'jumlah': detailCustomerOrder.jumlah,
                    'harga_satuan': detailCustomerOrder.hargaSatuan,
                    'satuan': detailCustomerOrder.satuan,
                    'status': detailCustomerOrder.status,
                    'subtotal': detailCustomerOrder.subtotal
                  });
                  detailCount++;
                }
              }
              yield SuccessState();
            } else {
              yield ErrorState(result.data['message']);
            }
          } catch (e) {
            yield ErrorState(e.toString());
          }
        } else {
          yield ErrorState("alamat pengiriman tidak boleh kosong");
        }
      } else {
        yield ErrorState("kode pelanggan tidak boleh kosong");
      }
    } else if (event is DeleteCustomerOrderEvent) {
      yield LoadingState();
      try {
        final customerOrderId = event.customerOrderId;

        // Update status menjadi 0 pada dokumen customer order
        final customerOrderRef =
            _firestore.collection('customer_orders').doc(customerOrderId);
        await customerOrderRef.update({'status': 0});

        // Mendapatkan koleksi detail_customer_orders
        final detailCustomerOrderCollectionRef =
            customerOrderRef.collection('detail_customer_orders');

        // Mendapatkan semua dokumen dalam subkoleksi
        final detailCustomerOrderDocs =
            await detailCustomerOrderCollectionRef.get();

        // Perbarui status menjadi 0 pada setiap dokumen dalam subkoleksi
        for (final doc in detailCustomerOrderDocs.docs) {
          await doc.reference.update({'status': 0});
        }

        // Mengembalikan status CustomerOrderDeletedState()
        yield CustomerOrderDeletedState();
      } catch (e) {
        yield ErrorState("Gagal menghapus Customer Order: $e");
      }
    }
  }

  Future<String> _generateNextCustomerId() async {
    final customerOrdersRef = _firestore.collection('customer_orders');
    final QuerySnapshot snapshot = await customerOrdersRef.get();
    final List<String> existingIds =
        snapshot.docs.map((doc) => doc['id'] as String).toList();
    int customerCount = 1;

    while (true) {
      final nextCustomerId = 'CO${customerCount.toString().padLeft(3, '0')}';
      if (!existingIds.contains(nextCustomerId)) {
        return nextCustomerId;
      }
      customerCount++;
    }
  }

  String _createEmailMessage(
    String nextCustomerOrderId,
    String customerId,
    String alamatPengiriman,
    String catatan,
    int totalHarga,
    int totalProduk,
    DateTime tanggalPesan,
    DateTime tanggalKirim,
    List<DetailCustomerOrder> products,
  ) {
    final StringBuffer message = StringBuffer();

    message
        .write('Pesanan pelanggan $nextCustomerOrderId baru ditambahkan<br>');
    message.write('<br>Detail Pesanan Pelanggan:<br>');
    message.write('CUSTOMER ID: $customerId<br>');
    message.write('Alamat Pengiriman: $alamatPengiriman<br>');
    message.write('Catatan: $catatan<br>');
    message.write('Total Produk: $totalProduk<br>');
    message.write('Total Harga: Rp $totalHarga<br>');
    message.write('Tanggal Pesan: $tanggalPesan<br>');
    message.write('Tanggal Kirim: $tanggalKirim<br>');

    message.write('<br>Products:<br>');
    for (final product in products) {
      message.write('- Product ID: ${product.productId}<br>');
      message.write('  Jumlah : ${product.jumlah}<br>');
      message.write('  Satuan: ${product.satuan}<br>');
      message.write('  Harga Satuan: ${product.hargaSatuan}<br>');
      message.write('<br>');
    }

    return message.toString();
  }
}
