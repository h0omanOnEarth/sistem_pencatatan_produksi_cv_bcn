import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/detail_mesin_production_order.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/detail_production_order.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/production_order.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/emailNotificationService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/notificationService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/utils/notify_awesome.dart';

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

class SuccessState extends ProductionOrderBlocState {}

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
  final HttpsCallable productionOrderValidateCallable;
  final HttpsCallable productionOrderSendMail;
  final notificationService = NotificationService();

  ProductionOrderBloc()
      : productionOrderValidateCallable =
            FirebaseFunctions.instanceFor(region: "asia-southeast2")
                .httpsCallable('productionOrderValidate'),
        productionOrderSendMail =
            FirebaseFunctions.instanceFor(region: "asia-southeast2")
                .httpsCallable('sendEmailNotif'),
        super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Stream<ProductionOrderBlocState> mapEventToState(
      ProductionOrderEvent event) async* {
    if (event is AddProductionOrderEvent) {
      yield LoadingState();

      final bomId = event.productionOrder.bomId;
      final jumlahProduksiEst = event.productionOrder.jumlahProduksiEst;
      final jumlahTenagaKerjaEst = event.productionOrder.jumlahTenagaKerjaEst;
      final lamaWaktuEst = event.productionOrder.lamaWaktuEst;
      final productId = event.productionOrder.productId;
      final status = event.productionOrder.status;
      final statusPro = event.productionOrder.statusPro;
      final tanggalProduksi = event.productionOrder.tanggalProduksi;
      final tanggalRencana = event.productionOrder.tanggalRencana;
      final tanggalSelesai = event.productionOrder.tanggalSelesai;
      final materials = event.productionOrder.detailProductionOrderList;
      final machines = event.productionOrder.detailMesinProductionOrderList;

      if (bomId.isNotEmpty) {
        if (productId.isNotEmpty) {
          try {
            final HttpsCallableResult<dynamic> result =
                await productionOrderValidateCallable.call(<String, dynamic>{
              'materials':
                  materials?.map((material) => material.toJson()).toList(),
              'machines': machines?.map((machine) => machine.toJson()).toList(),
              'jumlahProduksiEst': jumlahProduksiEst,
              'jumlahTenagaKerjaEst': jumlahTenagaKerjaEst,
              'lamaWaktuEst': lamaWaktuEst,
              'bomId': bomId,
              'productId': productId
            });

            if (result.data['success'] == true) {
              final nextProductionOrderId =
                  await _generateNextProductionOrderId();

              final productionOrderRef = _firestore
                  .collection('production_orders')
                  .doc(nextProductionOrderId);

              final Map<String, dynamic> productionOrderData = {
                'id': nextProductionOrderId,
                'bom_id': bomId,
                'jumlah_produksi_est': jumlahProduksiEst,
                'jumlah_tenaga_kerja_est': jumlahTenagaKerjaEst,
                'lama_waktu_est': lamaWaktuEst,
                'product_id': productId,
                'status': status,
                'status_pro': statusPro,
                'tanggal_produksi': tanggalProduksi,
                'tanggal_rencana': tanggalRencana,
                'tanggal_selesai': tanggalSelesai,
                'catatan': event.productionOrder.catatan
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
                    'batch': detailProductionOrder.batch,
                    'satuan': detailProductionOrder.satuan,
                    'status': 1
                  });
                  detailCount++;
                }
              }

              // Create 'detail_machines' subcollection
              final detailMachinesRef =
                  productionOrderRef.collection('detail_machines');

              if (event.productionOrder.detailMesinProductionOrderList !=
                      null &&
                  event.productionOrder.detailMesinProductionOrderList!
                      .isNotEmpty) {
                int machineCount = 1;
                for (var machineDetail
                    in event.productionOrder.detailMesinProductionOrderList!) {
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

              final notificationsRef = _firestore.collection('notifications');
              final nextNotifId =
                  await notificationService.generateNextNotificationId();
              final Map<String, dynamic> notificationData = {
                'pesan':
                    'Perintah Produksi $nextProductionOrderId baru ditambahkan',
                'status': 1,
                'posisi': 'Produksi',
                'created_at': DateTime.now(),
                'id': nextNotifId
              };

              // Gunakan .doc() untuk membuat referensi dokumen baru dengan nextNotifId
              final newNotificationDoc = notificationsRef.doc(nextNotifId);

              // Gunakan .set() untuk menambahkan data ke dokumen tersebut
              await newNotificationDoc.set(notificationData);

              Notify.instantNotify("Perintah Produksi Baru",
                  'Production Order $nextProductionOrderId baru ditambahkan');

              // EmailNotificationService.sendNotification(
              //     'Perintah Produksi Baru',
              //     'Perintah Produksi $nextProductionOrderId baru ditambahkan',
              //     'Produksi');

              // EmailNotificationService.sendNotification(
              //   'Perintah Produksi Baru',
              //   _createEmailMessage(
              //     nextProductionOrderId,
              //     bomId,
              //     jumlahProduksiEst,
              //     jumlahTenagaKerjaEst,
              //     lamaWaktuEst,
              //     productId,
              //     statusPro,
              //     tanggalProduksi,
              //     tanggalRencana,
              //     tanggalSelesai,
              //     materials!,
              //     machines!,
              //   ),
              //   'Produksi',
              // );

              try {
                final HttpsCallable callable =
                    FirebaseFunctions.instanceFor(region: "asia-southeast2")
                        .httpsCallable('sendEmailNotif');
                final HttpsCallableResult<dynamic> result =
                    await callable.call(<String, dynamic>{
                  'dest': 'clarissagracia.cg@gmail.com',
                  'subject': 'Production Order Baru',
                  'html': _createEmailMessage(
                    nextProductionOrderId,
                    bomId,
                    jumlahProduksiEst,
                    jumlahTenagaKerjaEst,
                    lamaWaktuEst,
                    productId,
                    statusPro,
                    tanggalProduksi,
                    tanggalRencana,
                    tanggalSelesai,
                    materials!,
                    machines!,
                  ),
                });

                if (result.data['success'] == true) {
                  print("Email Sent");
                } else {
                  print(result.data['message']);
                }
              } catch (e) {
                print(e.toString());
              }

              yield SuccessState();
            } else {
              yield ErrorState(result.data['message']);
            }
          } catch (e) {
            yield ErrorState(e.toString());
          }
        } else {
          yield ErrorState("kode produk tidak boleh kosong");
        }
      } else {
        yield ErrorState("nomor bom tidak boleh kosong");
      }
    } else if (event is UpdateProductionOrderEvent) {
      yield LoadingState();
      final materials = event.productionOrder.detailProductionOrderList;
      final machines = event.productionOrder.detailMesinProductionOrderList;
      final bomId = event.productionOrder.bomId;
      final productId = event.productionOrder.productId;
      final jumlahProduksiEst = event.productionOrder.jumlahProduksiEst;
      final jumlahTenagaKerjaEst = event.productionOrder.jumlahTenagaKerjaEst;
      final lamaWaktuEst = event.productionOrder.lamaWaktuEst;

      if (bomId.isNotEmpty) {
        if (productId.isNotEmpty) {
          try {
            final HttpsCallableResult<dynamic> result =
                await productionOrderValidateCallable.call(<String, dynamic>{
              'materials':
                  materials?.map((material) => material.toJson()).toList(),
              'machines': machines?.map((machine) => machine.toJson()).toList(),
              'jumlahProduksiEst': jumlahProduksiEst,
              'jumlahTenagaKerjaEst': jumlahTenagaKerjaEst,
              'lamaWaktuEst': lamaWaktuEst,
              'bomId': bomId,
              'productId': productId
            });

            if (result.data['success'] == true) {
              final productionOrderToUpdateRef = _firestore
                  .collection('production_orders')
                  .doc(event.productionOrderId);
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
                'catatan': event.productionOrder.catatan
              };

              await productionOrderToUpdateRef.set(productionOrderData);

              final detailProductionOrderCollectionRef =
                  productionOrderToUpdateRef
                      .collection('detail_production_orders');

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
                  final detailId =
                      event.productionOrderId + nextDetailProductionOrderId;

                  await detailProductionOrderCollectionRef.add({
                    'id': detailId,
                    'jumlah_bom': detailProductionOrder.jumlahBOM,
                    'material_id': detailProductionOrder.materialId,
                    'production_order_id': event.productionOrderId,
                    'batch': detailProductionOrder.batch,
                    'satuan': detailProductionOrder.satuan,
                    'status': 1,
                  });
                  detailCount++;
                }
              }

              // Update 'detail_machines' subcollection
              final detailMachinesRef =
                  productionOrderToUpdateRef.collection('detail_machines');

              final detailMachinesDocs = await detailMachinesRef.get();
              for (var doc in detailMachinesDocs.docs) {
                await doc.reference.delete();
              }

              if (event.productionOrder.detailMesinProductionOrderList !=
                      null &&
                  event.productionOrder.detailMesinProductionOrderList!
                      .isNotEmpty) {
                int machineCount = 1;
                for (var machineDetail
                    in event.productionOrder.detailMesinProductionOrderList!) {
                  final nextMachineDetailId =
                      'DM${machineCount.toString().padLeft(3, '0')}';
                  final detailMachineId =
                      event.productionOrderId + nextMachineDetailId;

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

              yield SuccessState();
            } else {
              yield ErrorState(result.data['message']);
            }
          } catch (e) {
            yield ErrorState(e.toString());
          }
        } else {
          yield ErrorState("kode produk tidak boleh kosong");
        }
      } else {
        yield ErrorState("nomor bom tidak boleh kosong");
      }
    } else if (event is DeleteProductionOrderEvent) {
      yield LoadingState();
      try {
        final productionOrderToDeleteRef = _firestore
            .collection('production_orders')
            .doc(event.productionOrderId);

        final detailProductionOrderCollectionRef =
            productionOrderToDeleteRef.collection('detail_production_orders');

        final detailProductionOrderDocs =
            await detailProductionOrderCollectionRef.get();

        // Mengubah status menjadi 0 pada dokumen detail_production_orders
        for (var doc in detailProductionOrderDocs.docs) {
          await doc.reference.update({'status': 0});
        }

        // Mengambil dan mengubah status pada 'detail_machines' subcollection
        final detailMachinesCollectionRef =
            productionOrderToDeleteRef.collection('detail_machines');

        final detailMachinesDocs = await detailMachinesCollectionRef.get();

        // Mengubah status menjadi 0 pada dokumen detail_machines
        for (var doc in detailMachinesDocs.docs) {
          await doc.reference.update({'status': 0});
        }

        // Mengubah status menjadi 0 pada dokumen produksi utama
        await productionOrderToDeleteRef.update({'status': 0});

        yield SuccessState();
      } catch (e) {
        yield ErrorState("Gagal menghapus Production Order.");
      }
    }
  }

  Future<String> _generateNextProductionOrderId() async {
    final productionOrdersRef = _firestore.collection('production_orders');
    final QuerySnapshot snapshot = await productionOrdersRef.get();
    final List<String> existingIds =
        snapshot.docs.map((doc) => doc['id'] as String).toList();
    int productionCount = 1;

    while (true) {
      final nextProductionOrderId =
          'PRO${productionCount.toString().padLeft(5, '0')}';
      if (!existingIds.contains(nextProductionOrderId)) {
        return nextProductionOrderId;
      }
      productionCount++;
    }
  }

  String _createEmailMessage(
    String nextProductionOrderId,
    String bomId,
    int jumlahProduksiEst,
    int jumlahTenagaKerjaEst,
    int lamaWaktuEst,
    String productId,
    String statusPro,
    DateTime tanggalProduksi,
    DateTime tanggalRencana,
    DateTime tanggalSelesai,
    List<DetailProductionOrder> materials,
    List<MachineDetail> machines,
  ) {
    final StringBuffer message = StringBuffer();

    message
        .writeln('Perintah Produksi $nextProductionOrderId baru ditambahkan');
    message.writeln('Detail Produksi:');
    message.writeln('BOM ID: $bomId');
    message.writeln('Jumlah Produksi Estimasi: $jumlahProduksiEst');
    message.writeln('Jumlah Tenaga Kerja Estimasi: $jumlahTenagaKerjaEst');
    message.writeln('Lama Waktu Estimasi: $lamaWaktuEst');
    message.writeln('Product ID: $productId');
    message.writeln('Status Produksi: $statusPro');
    message.writeln('Tanggal Produksi: $tanggalProduksi');
    message.writeln('Tanggal Rencana: $tanggalRencana');
    message.writeln('Tanggal Selesai: $tanggalSelesai');

    message.writeln('Materials:');
    for (final material in materials) {
      message.writeln('- Material ID: ${material.materialId}');
      message.writeln('  Jumlah BOM: ${material.jumlahBOM}');
      message.writeln('  Batch: ${material.batch}');
      message.writeln('  Satuan: ${material.satuan}');
    }

    message.writeln('Machines:');
    for (final machine in machines) {
      message.writeln('- Machine ID: ${machine.machineId}');
      message.writeln('  Batch: ${machine.batch}');
      message.writeln('  Status: ${machine.status}');
    }

    return message.toString();
  }
}
