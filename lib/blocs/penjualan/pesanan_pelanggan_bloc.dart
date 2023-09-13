import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/penjualan/pesanan_pelanggan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
class CustomerOrderBloc extends Bloc<CustomerOrderEvent, CustomerOrderBlocState> {
  late FirebaseFirestore _firestore;

  CustomerOrderBloc() : super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Stream<CustomerOrderBlocState> mapEventToState(CustomerOrderEvent event) async* {
    if (event is AddCustomerOrderEvent) {
      yield LoadingState();
      try {
        // Generate a new customer order ID (or use an existing one if you have it)
        final nextCustomerOrderId = await _generateNextCustomerId();

        // Buat referensi dokumen customer order menggunakan ID yang sesuai
        final customerOrderRef = _firestore.collection('customer_orders').doc(nextCustomerOrderId);

        // Set data customer order
        final Map<String, dynamic> customerOrderData = {
          'id': nextCustomerOrderId,
          'customer_id': event.customerOrder.customerId,
          'alamat_pengiriman': event.customerOrder.alamatPengiriman,
          'catatan': event.customerOrder.catatan,
          'satuan': event.customerOrder.satuan,
          'status': event.customerOrder.status,
          'status_pesanan': event.customerOrder.statusPesanan,
          'tanggal_kirim': event.customerOrder.tanggalKirim,
          'tanggal_pesan': event.customerOrder.tanggalPesan,
          'total_harga': event.customerOrder.totalHarga,
          'total_produk': event.customerOrder.totalProduk,
        };

        // Tambahkan data customer order ke Firestore
        await customerOrderRef.set(customerOrderData);

        // Buat referensi ke subcollection 'detail_customer_orders' dalam dokumen customer order
        final detailCustomerOrderRef = customerOrderRef.collection('detail_customer_orders');

        if (event.customerOrder.detailCustomerOrderList != null &&
            event.customerOrder.detailCustomerOrderList!.isNotEmpty) {
          int detailCount = 1;
          for (var detailCustomerOrder in event.customerOrder.detailCustomerOrderList!) {
            final nextDetailCustomerId ='$nextCustomerOrderId${'D${detailCount.toString().padLeft(3, '0')}'}';

            // Tambahkan dokumen detail customer order dalam koleksi 'detail_customer_orders'
            await detailCustomerOrderRef.add({
              'id' : nextDetailCustomerId,
              'customer_order_id' : nextCustomerOrderId,
              'product_id' : detailCustomerOrder.productId,
              'jumlah': detailCustomerOrder.jumlah,
              'harga_satuan': detailCustomerOrder.hargaSatuan,
              'satuan' : detailCustomerOrder.satuan,
              'status' : detailCustomerOrder.status,
              'subtotal' : detailCustomerOrder.subtotal
            });
            detailCount++;
          }
        }
        
        yield LoadedState(event.customerOrder);
      } catch (e) {
        yield ErrorState("Gagal menambahkan Customer Order.");
      }
    }else if (event is UpdateCustomerOrderEvent) {
      yield LoadingState();
      try {
        // Mendapatkan referensi dokumen customer order yang akan diperbarui
        final customerOrderToUpdateRef = _firestore.collection('customer_orders').doc(event.customerOrderId);

        // Set data customer order yang baru
        final Map<String, dynamic> customerOrderData = {
          'id': event.customerOrderId,
          'customer_id': event.customerOrder.customerId,
          'alamat_pengiriman': event.customerOrder.alamatPengiriman,
          'catatan': event.customerOrder.catatan,
          'satuan': event.customerOrder.satuan,
          'status': event.customerOrder.status,
          'status_pesanan': event.customerOrder.statusPesanan,
          'tanggal_kirim': event.customerOrder.tanggalKirim,
          'tanggal_pesan': event.customerOrder.tanggalPesan,
          'total_harga': event.customerOrder.totalHarga,
          'total_produk': event.customerOrder.totalProduk,
        };

        // Update data customer order dalam dokumen yang ada
        await customerOrderToUpdateRef.set(customerOrderData);

        // Menghapus semua dokumen dalam sub koleksi 'detail_customer_orders' terlebih dahulu
        final detailCustomerOrderCollectionRef = customerOrderToUpdateRef.collection('detail_customer_orders');
        final detailCustomerOrderDocs = await detailCustomerOrderCollectionRef.get();
        for (var doc in detailCustomerOrderDocs.docs) {
          await doc.reference.delete();
        }

        // Menambahkan dokumen detail customer order yang baru dalam sub koleksi 'detail_customer_orders'
        if (event.customerOrder.detailCustomerOrderList != null &&
            event.customerOrder.detailCustomerOrderList!.isNotEmpty) {
          int detailCount = 1;
          for (var detailCustomerOrder in event.customerOrder.detailCustomerOrderList!) {
            final nextDetailCustomerId = 'D${detailCount.toString().padLeft(3, '0')}';
            final detailId = event.customerOrderId+nextDetailCustomerId;
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
        yield CustomerOrderUpdatedState();
      } catch (e) {
        yield ErrorState("Gagal memperbarui Customer Order.");
      }
    } else if (event is DeleteCustomerOrderEvent) {
      yield LoadingState();
      try {
        // Mendapatkan referensi dokumen customer order yang akan dihapus
        final customerOrderToDeleteRef = _firestore.collection('customer_orders').doc(event.customerOrderId);

        // Mendapatkan referensi koleksi 'detail_customer_orders' di dalam dokumen customer order
        final detailCustomerOrderCollectionRef = customerOrderToDeleteRef.collection('detail_customer_orders');

        // Hapus semua dokumen di dalam sub koleksi 'detail_customer_orders'
        final detailCustomerOrderDocs = await detailCustomerOrderCollectionRef.get();
        for (var doc in detailCustomerOrderDocs.docs) {
          await doc.reference.delete();
        }

        // Setelah menghapus semua dokumen dalam sub koleksi, hapus dokumen customer order itu sendiri
        await customerOrderToDeleteRef.delete();

        yield CustomerOrderDeletedState();
      } catch (e) {
        yield ErrorState("Gagal menghapus Customer Order.");
      }
    }
  }

  Future<String> _generateNextCustomerId() async {
    final customerOrdersRef = _firestore.collection('customer_orders');
    final QuerySnapshot snapshot = await customerOrdersRef.get();
    final List<String> existingIds = snapshot.docs.map((doc) => doc['id'] as String).toList();
    int customerCount = 1;

    while (true) {
      final nextCustomerId = 'CO${customerCount.toString().padLeft(3, '0')}';
      if (!existingIds.contains(nextCustomerId)) {
        return nextCustomerId;
      }
      customerCount++;
    }
  }
}
