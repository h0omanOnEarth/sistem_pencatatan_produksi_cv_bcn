import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/production_order.dart';

// Events
abstract class ProductionOrderEvent {}

class AddProductionOrderEvent extends ProductionOrderEvent {
  final ProductionOrder productionOrder;
  AddProductionOrderEvent(this.productionOrder);
}

class UpdateProductionOrderEvent extends ProductionOrderEvent {
  final String productionOrderId;
  final ProductionOrder productionOrder;
  UpdateProductionOrderEvent(this.productionOrderId, this.productionOrder);
}

class DeleteProductionOrderEvent extends ProductionOrderEvent {
  final String productionOrderId;
  DeleteProductionOrderEvent(this.productionOrderId);
}

// States
abstract class ProductionOrderBlocState {}

class LoadingState extends ProductionOrderBlocState {}

class LoadedState extends ProductionOrderBlocState {
  final ProductionOrder productionOrder;
  LoadedState(this.productionOrder);
}

class ProductionOrderUpdatedState extends ProductionOrderBlocState {}

class ProductionOrderDeletedState extends ProductionOrderBlocState {}

class ErrorState extends ProductionOrderBlocState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class ProductionOrderBloc
    extends Bloc<ProductionOrderEvent, ProductionOrderBlocState> {
  late FirebaseFirestore _firestore;

  ProductionOrderBloc() : super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Stream<ProductionOrderBlocState> mapEventToState(
      ProductionOrderEvent event) async* {
    if (event is AddProductionOrderEvent) {
      yield LoadingState();
      try {
        final nextProductionOrderId = await _generateNextProductionOrderId();

        final productionOrderRef =
            _firestore.collection('production_orders').doc(nextProductionOrderId);

        final Map<String, dynamic> productionOrderData = {
          'id': nextProductionOrderId,
          'bom_id': event.productionOrder.bomId,
          'jumlah_produksi_est': event.productionOrder.jumlahProduksiEst,
          'jumlah_tenaga_kerja_est':
              event.productionOrder.jumlahTenagaKerjaEst,
          'lama_waktu_est': event.productionOrder.lamaWaktuEst,
          'product_id': event.productionOrder.productId,
          'status': event.productionOrder.status,
          'status_pro': event.productionOrder.statusPro,
          'tanggal_produksi': event.productionOrder.tanggalProduksi,
          'tanggal_rencana': event.productionOrder.tanggalRencana,
          'tanggal_selesai': event.productionOrder.tanggalSelesai,
        };

        await productionOrderRef.set(productionOrderData);

        final detailProductionOrderRef =
            productionOrderRef.collection('detail_production_orders');

        if (event.productionOrder.detailProductionOrderList != null &&
            event.productionOrder.detailProductionOrderList!.isNotEmpty) {
          int detailCount = 1;
          for (var detailProductionOrder
              in event.productionOrder.detailProductionOrderList!) {
            final nextDetailProductionOrderId =
                '$nextProductionOrderId${'D${detailCount.toString().padLeft(3, '0')}'}';

            await detailProductionOrderRef.add({
              'id': nextDetailProductionOrderId,
              'jumlah_bom': detailProductionOrder.jumlahBOM,
              'material_id': detailProductionOrder.materialId,
              'production_order_id': nextProductionOrderId,
              'satuan': detailProductionOrder.satuan,
              'status': 1
            });
            detailCount++;
          }
        }

         // Create 'detail_machines' subcollection
        final detailMachinesRef = productionOrderRef.collection('detail_machines');

        if (event.productionOrder.detailMesinProductionOrderList != null &&
            event.productionOrder.detailMesinProductionOrderList!.isNotEmpty) {
          int machineCount = 1;
          for (var machineDetail in event.productionOrder.detailMesinProductionOrderList!) {
            final nextMachineDetailId =
                '$nextProductionOrderId${'DM${machineCount.toString().padLeft(3, '0')}'}';

            await detailMachinesRef.add({
              'id': nextMachineDetailId,
              'batch': machineDetail.batch,
              'machine_id': machineDetail.machineId,
              'production_order_id': nextProductionOrderId,
              'status': machineDetail.status,
            });
            machineCount++;
          }
        }

        yield LoadedState(event.productionOrder);
      } catch (e) {
        yield ErrorState("Gagal menambahkan Production Order.");
      }
    } else if (event is UpdateProductionOrderEvent) {
      yield LoadingState();
      try {
        final productionOrderToUpdateRef =
            _firestore.collection('production_orders').doc(event.productionOrderId);

        final Map<String, dynamic> productionOrderData = {
          'id': event.productionOrderId,
          'bom_id': event.productionOrder.bomId,
          'jumlah_produksi_est': event.productionOrder.jumlahProduksiEst,
          'jumlah_tenaga_kerja_est':
              event.productionOrder.jumlahTenagaKerjaEst,
          'lama_waktu_est': event.productionOrder.lamaWaktuEst,
          'product_id': event.productionOrder.productId,
          'status': event.productionOrder.status,
          'status_pro': event.productionOrder.statusPro,
          'tanggal_produksi': event.productionOrder.tanggalProduksi,
          'tanggal_rencana': event.productionOrder.tanggalRencana,
          'tanggal_selesai': event.productionOrder.tanggalSelesai,
        };

        await productionOrderToUpdateRef.set(productionOrderData);

        final detailProductionOrderCollectionRef =
            productionOrderToUpdateRef.collection('detail_production_orders');

        final detailProductionOrderDocs =
            await detailProductionOrderCollectionRef.get();
        for (var doc in detailProductionOrderDocs.docs) {
          await doc.reference.delete();
        }

        if (event.productionOrder.detailProductionOrderList != null &&
            event.productionOrder.detailProductionOrderList!.isNotEmpty) {
          int detailCount = 1;
          for (var detailProductionOrder
              in event.productionOrder.detailProductionOrderList!) {
            final nextDetailProductionOrderId =
                'D${detailCount.toString().padLeft(3, '0')}';
            final detailId = event.productionOrderId + nextDetailProductionOrderId;

            await detailProductionOrderCollectionRef.add({
              'id': detailId,
              'jumlah_bom': detailProductionOrder.jumlahBOM,
              'material_id': detailProductionOrder.materialId,
              'production_order_id': event.productionOrderId,
              'satuan': detailProductionOrder.satuan,
              'status': 1,
            });
            detailCount++;
          }
        }

         // Update 'detail_machines' subcollection
        final detailMachinesRef = productionOrderToUpdateRef.collection('detail_machines');

        final detailMachinesDocs = await detailMachinesRef.get();
        for (var doc in detailMachinesDocs.docs) {
          await doc.reference.delete();
        }

        if (event.productionOrder.detailMesinProductionOrderList != null &&
            event.productionOrder.detailMesinProductionOrderList!.isNotEmpty) {
          int machineCount = 1;
          for (var machineDetail in event.productionOrder.detailMesinProductionOrderList!) {
            final nextMachineDetailId ='DM${machineCount.toString().padLeft(3, '0')}';
            final detailMachineId = event.productionOrderId + nextMachineDetailId;

            await detailMachinesRef.add({
              'id': detailMachineId,
              'batch': machineDetail.batch,
              'machine_id': machineDetail.machineId,
              'production_order_id': event.productionOrderId,
              'status': machineDetail.status,
            });
            machineCount++;
          }
        }

        yield ProductionOrderUpdatedState();
      } catch (e) {
        yield ErrorState("Gagal memperbarui Production Order.");
      }
    } else if (event is DeleteProductionOrderEvent) {
      yield LoadingState();
      try {
        final productionOrderToDeleteRef =
            _firestore.collection('production_orders').doc(event.productionOrderId);

        final detailProductionOrderCollectionRef =
            productionOrderToDeleteRef.collection('detail_production_orders');

        final detailProductionOrderDocs =
            await detailProductionOrderCollectionRef.get();
        for (var doc in detailProductionOrderDocs.docs) {
          await doc.reference.delete();
        }

        // Delete 'detail_machines' subcollection
        final detailMachinesCollectionRef =
            productionOrderToDeleteRef.collection('detail_machines');

        final detailMachinesDocs = await detailMachinesCollectionRef.get();
        for (var doc in detailMachinesDocs.docs) {
          await doc.reference.delete();
        }

        // Delete the main production order document
        await productionOrderToDeleteRef.delete();

        yield ProductionOrderDeletedState();
      } catch (e) {
        yield ErrorState("Gagal menghapus Production Order.");
      }
    }
  }

  Future<String> _generateNextProductionOrderId() async {
    final productionOrdersRef =
        _firestore.collection('production_orders');
    final QuerySnapshot snapshot = await productionOrdersRef.get();
    final List<String> existingIds = snapshot.docs.map((doc) => doc['id'] as String).toList();
    int productionCount = 1;

    while (true) {
      final nextProductionOrderId = 'PRO${productionCount.toString().padLeft(5, '0')}';
      if (!existingIds.contains(nextProductionOrderId)) {
        return nextProductionOrderId;
      }
      productionCount++;
    }
  }
}
