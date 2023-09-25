import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/penjualan/invoice.dart';

// Events
abstract class InvoiceEvent {}

class AddInvoiceEvent extends InvoiceEvent {
  final Invoice invoice;
  AddInvoiceEvent(this.invoice);
}

class UpdateInvoiceEvent extends InvoiceEvent {
  final String invoiceId;
  final Invoice updatedInvoice;
  UpdateInvoiceEvent(this.invoiceId, this.updatedInvoice);
}

class DeleteInvoiceEvent extends InvoiceEvent {
  final String invoiceId;
  DeleteInvoiceEvent(this.invoiceId);
}

// States
abstract class InvoiceBlocState {}

class LoadingState extends InvoiceBlocState {}

class LoadedState extends InvoiceBlocState {
  final Invoice invoice;
  LoadedState(this.invoice);
}

class InvoiceUpdatedState extends InvoiceBlocState {}

class InvoiceDeletedState extends InvoiceBlocState {}

class ErrorState extends InvoiceBlocState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceBlocState> {
  late FirebaseFirestore _firestore;

  InvoiceBloc() : super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Stream<InvoiceBlocState> mapEventToState(InvoiceEvent event) async* {
    if (event is AddInvoiceEvent) {
      yield LoadingState();
      try {
        // Generate a new invoice ID (or use an existing one if you have it)
        final nextInvoiceId = await _generateNextInvoiceId();

        // Create a reference to the invoice document using the appropriate ID
        final invoiceRef = _firestore.collection('invoices').doc(nextInvoiceId);

        // Set invoice data
        final Map<String, dynamic> invoiceData = {
          'id': nextInvoiceId,
          'metode_pembayaran': event.invoice.metodePembayaran,
          'nomor_rekening': event.invoice.nomorRekening,
          'shipment_id': event.invoice.shipmentId,
          'tanggal_pembuatan': event.invoice.tanggalPembuatan,
          'total': event.invoice.total,
          'total_produk': event.invoice.totalProduk,
          'status': event.invoice.status,
          'status_fk': event.invoice.statusFk,
          'catatan': event.invoice.catatan,
          'status_pembayaran': event.invoice.statusPembayaran,
        };

        // Add invoice data to Firestore
        await invoiceRef.set(invoiceData);

        // Create a reference to the 'detail_invoices' subcollection within the invoice document
        final detailInvoiceRef = invoiceRef.collection('detail_invoices');

        if (event.invoice.detailInvoices.isNotEmpty) {
          int detailCount = 1;
          for (var detailInvoice in event.invoice.detailInvoices) {
            final nextDetailInvoiceId =
                '$nextInvoiceId${'D${detailCount.toString().padLeft(3, '0')}'}';

            // Add detail invoice document to the 'detail_invoices' subcollection
            await detailInvoiceRef.add({
              'id': nextDetailInvoiceId,
              'invoice_id': nextInvoiceId,
              'product_id': detailInvoice.productId,
              'harga': detailInvoice.harga,
              'jumlah_pengiriman': detailInvoice.jumlahPengiriman,
              'jumlah_pengiriman_dus': detailInvoice.jumlahPengirimanDus,
              'subtotal': detailInvoice.subtotal,
              'status': detailInvoice.status,
            });
            detailCount++;
          }
        }

        yield LoadedState(event.invoice);
      } catch (e) {
        yield ErrorState("Failed to add Invoice.");
      }
    } else if (event is UpdateInvoiceEvent) {
      yield LoadingState();
      try {
        // Get a reference to the invoice document to be updated
        final invoiceToUpdateRef =
            _firestore.collection('invoices').doc(event.invoiceId);

        // Set the new invoice data
        final Map<String, dynamic> invoiceData = {
          'id': event.invoiceId,
          'metode_pembayaran': event.updatedInvoice.metodePembayaran,
          'nomor_rekening': event.updatedInvoice.nomorRekening,
          'tanggal_pembuatan': event.updatedInvoice.tanggalPembuatan,
          'shipment_id': event.updatedInvoice.shipmentId,
          'status': event.updatedInvoice.status,
          'total': event.updatedInvoice.total,
          'total_produk': event.updatedInvoice.totalProduk,
          'catatan': event.updatedInvoice.catatan,
          'status_fk': event.updatedInvoice.statusFk,
          'status_pembayaran': event.updatedInvoice.statusPembayaran,
        };

        // Update the invoice data within the existing document
        await invoiceToUpdateRef.set(invoiceData);

        // Delete all documents in the 'detail_invoices' subcollection first
        final detailInvoiceCollectionRef =
            invoiceToUpdateRef.collection('detail_invoices');
        final detailInvoiceDocs =
            await detailInvoiceCollectionRef.get();
        for (var doc in detailInvoiceDocs.docs) {
          await doc.reference.delete();
        }

        // Add the new detail invoice documents to the 'detail_invoices' subcollection
        if (event.updatedInvoice.detailInvoices.isNotEmpty) {
          int detailCount = 1;
          for (var detailInvoice in event.updatedInvoice.detailInvoices) {
            final nextDetailInvoiceId =
                '$event.invoiceId${'D${detailCount.toString().padLeft(3, '0')}'}';

            await detailInvoiceCollectionRef.add({
              'id': nextDetailInvoiceId,
              'invoice_id': event.invoiceId,
              'product_id': detailInvoice.productId,
              'harga': detailInvoice.harga,
              'jumlah_pengiriman': detailInvoice.jumlahPengiriman,
              'jumlah_pengiriman_dus': detailInvoice.jumlahPengirimanDus,
              'subtotal': detailInvoice.subtotal,
              'status': detailInvoice.status,
            });
            detailCount++;
          }
        }

        yield InvoiceUpdatedState();
      } catch (e) {
        yield ErrorState("Failed to update Invoice.");
      }
    } else if (event is DeleteInvoiceEvent) {
      yield LoadingState();
      try {
        // Get a reference to the invoice document to be deleted
        final invoiceToDeleteRef =
            _firestore.collection('invoices').doc(event.invoiceId);

        // Get a reference to the 'detail_invoices' subcollection within the invoice document
        final detailInvoiceCollectionRef =
            invoiceToDeleteRef.collection('detail_invoices');

        // Delete all documents in the 'detail_invoices' subcollection first
        final detailInvoiceDocs =
            await detailInvoiceCollectionRef.get();
        for (var doc in detailInvoiceDocs.docs) {
          await doc.reference.delete();
        }

        // After deleting all documents in the subcollection, delete the invoice document itself
        await invoiceToDeleteRef.delete();

        yield InvoiceDeletedState();
      } catch (e) {
        yield ErrorState("Failed to delete Invoice.");
      }
    }
  }

  Future<String> _generateNextInvoiceId() async {
    final invoicesRef = _firestore.collection('invoices');
    final QuerySnapshot snapshot = await invoicesRef.get();
    final List<String> existingIds =
        snapshot.docs.map((doc) => doc['id'] as String).toList();
    int invoiceCount = 1;

    while (true) {
      final nextInvoiceId = 'FK${invoiceCount.toString().padLeft(6, '0')}';
      if (!existingIds.contains(nextInvoiceId)) {
        return nextInvoiceId;
      }
      invoiceCount++;
    }
  }
}
