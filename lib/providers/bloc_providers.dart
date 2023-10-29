import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/authentication_bloc.dart.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/master/bom_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/master/customers_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/master/employees_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/master/materials_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/master/mesin_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/notification_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/pembelian/penerimaan_bahan_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/pembelian/pesanan_pembelian_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/pembelian/purchase_request_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/pembelian/purchase_return.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/penjualan/customer_order_return_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/penjualan/delivery_order_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/penjualan/faktur_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/penjualan/pesanan_pelanggan_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/master/products_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/penjualan/surat_jalan_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/dloh_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/item_receive_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/material_request_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/material_return_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/material_transfer_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/material_transforms_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/material_usage_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/production_confirmation_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/production_order_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/master/suppliers_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/production_result_bloc.dart';

class AppBlocProviders {
  static final List<BlocProvider> providers = [
    // Daftarkan AuthenticationBloc di sini
    BlocProvider<LoginBloc>(
      create: (BuildContext context) => LoginBloc(),
    ),
    BlocProvider<SupplierBloc>(
      create: (BuildContext context) => SupplierBloc(),
    ),
    BlocProvider<EmployeeBloc>(
      create: (BuildContext context) => EmployeeBloc(),
    ),
    BlocProvider<MesinBloc>(
      create: (BuildContext context) => MesinBloc(),
    ),
    BlocProvider<MaterialBloc>(
      create: (BuildContext context) => MaterialBloc(),
    ),
    BlocProvider<ProductBloc>(
      create: (BuildContext context) => ProductBloc(),
    ),
    BlocProvider<CustomerBloc>(
      create: (BuildContext context) => CustomerBloc(),
    ),
    BlocProvider<PurchaseOrderBloc>(
      create: (BuildContext context) => PurchaseOrderBloc(),
    ),
    BlocProvider<PurchaseReturnBloc>(
      create: (BuildContext context) => PurchaseReturnBloc(),
    ),
    BlocProvider<CustomerOrderBloc>(
      create: (BuildContext context) => CustomerOrderBloc(),
    ),
    BlocProvider<DeliveryOrderBloc>(
      create: (BuildContext context) => DeliveryOrderBloc(),
    ),
    BlocProvider<BillOfMaterialBloc>(
      create: (BuildContext context) => BillOfMaterialBloc(),
    ),
    BlocProvider<ProductionOrderBloc>(
      create: (BuildContext context) => ProductionOrderBloc(),
    ),
    BlocProvider<MaterialRequestBloc>(
      create: (BuildContext context) => MaterialRequestBloc(),
    ),
    BlocProvider<MaterialUsageBloc>(
      create: (BuildContext context) => MaterialUsageBloc(),
    ),
    BlocProvider<MaterialReturnBloc>(
      create: (BuildContext context) => MaterialReturnBloc(),
    ),
    BlocProvider<DLOHBloc>(
      create: (BuildContext context) => DLOHBloc(),
    ),
    BlocProvider<ProductionResultBloc>(
      create: (BuildContext context) => ProductionResultBloc(),
    ),
    BlocProvider<ProductionConfirmationBloc>(
      create: (BuildContext context) => ProductionConfirmationBloc(),
    ),
    BlocProvider<PurchaseRequestBloc>(
      create: (BuildContext context) => PurchaseRequestBloc(),
    ),
    BlocProvider<MaterialReceiveBloc>(
      create: (BuildContext context) => MaterialReceiveBloc(),
    ),
    BlocProvider<ShipmentBloc>(
      create: (BuildContext context) => ShipmentBloc(),
    ),
    BlocProvider<CustomerOrderReturnBloc>(
      create: (BuildContext context) => CustomerOrderReturnBloc(),
    ),
    BlocProvider<MaterialTransferBloc>(
      create: (BuildContext context) => MaterialTransferBloc(),
    ),
    BlocProvider<ItemReceiveBloc>(
      create: (BuildContext context) => ItemReceiveBloc(),
    ),
    BlocProvider<MaterialTransformsBloc>(
      create: (BuildContext context) => MaterialTransformsBloc(),
    ),
    BlocProvider<InvoiceBloc>(
      create: (BuildContext context) => InvoiceBloc(),
    ),
    BlocProvider<NotificationBloc>(
      create: (BuildContext context) => NotificationBloc(),
    ),
  ];
}
