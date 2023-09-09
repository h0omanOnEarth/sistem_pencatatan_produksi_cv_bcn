import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/penjualan/pesanan_pelanggan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Events
abstract class CustomerOrderEvent {}

class AddCustomerOrderEvent extends CustomerOrderEvent {
  final CustomerOrder customerOrder;
  AddCustomerOrderEvent(this.customerOrder);
}

// States
abstract class CustomerOrderBlocState {}

class LoadingState extends CustomerOrderBlocState {}

class LoadedState extends CustomerOrderBlocState {
  final CustomerOrder customerOrder;
  LoadedState(this.customerOrder);
}

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
              'customer_id' : nextCustomerOrderId,
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
