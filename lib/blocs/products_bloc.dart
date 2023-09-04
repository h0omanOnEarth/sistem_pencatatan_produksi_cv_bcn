import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/product.dart';

// Events
abstract class ProductEvent {}

class AddProductEvent extends ProductEvent {
  final Product product;
  AddProductEvent(this.product);
}

class UpdateProductEvent extends ProductEvent {
  final String productId;
  final Product updatedProduct;
  UpdateProductEvent(this.productId, this.updatedProduct);
}

class DeleteProductEvent extends ProductEvent {
  final String productId;
  DeleteProductEvent(this.productId);
}

// States
abstract class ProductBlocState {}

class LoadingState extends ProductBlocState {}

class LoadedState extends ProductBlocState {
  final List<Product> products;
  LoadedState(this.products);
}

class ErrorState extends ProductBlocState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class ProductBloc extends Bloc<ProductEvent, ProductBlocState> {
  late FirebaseFirestore _firestore;
  late CollectionReference productsRef;

  ProductBloc() : super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
    productsRef = _firestore.collection('products');
  }

  @override
  Stream<ProductBlocState> mapEventToState(ProductEvent event) async* {
    if (event is AddProductEvent) {
      yield LoadingState();
      try {
        final String nextProductId = await _generateNextProductId();

        await FirebaseFirestore.instance.collection('products').add({
          'id': nextProductId,
          'nama': event.product.nama,
          'deskripsi': event.product.deskripsi,
          'harga': event.product.harga,
          'berat': event.product.berat,
          'dimensi': event.product.dimensi,
          'jenis': event.product.jenis,
          'ketebalan': event.product.ketebalan,
          'satuan': event.product.satuan,
          'status': event.product.status,
          'stok': event.product.stok,
        });

        yield LoadedState(await _getProducts());
      } catch (e) {
        yield ErrorState("Gagal menambahkan produk.");
      }
    } else if (event is UpdateProductEvent) {
      yield LoadingState();
      try {
        await productsRef.doc(event.productId).update({
          'nama': event.updatedProduct.nama,
          'deskripsi': event.updatedProduct.deskripsi,
          'harga': event.updatedProduct.harga,
          'berat': event.updatedProduct.berat,
          'dimensi': event.updatedProduct.dimensi,
          'jenis': event.updatedProduct.jenis,
          'ketebalan': event.updatedProduct.ketebalan,
          'satuan': event.updatedProduct.satuan,
          'status': event.updatedProduct.status,
          'stok': event.updatedProduct.stok,
        });

        yield LoadedState(await _getProducts());
      } catch (e) {
        yield ErrorState("Gagal mengubah produk.");
      }
    } else if (event is DeleteProductEvent) {
      yield LoadingState();
      try {
        await productsRef.doc(event.productId).delete();
        yield LoadedState(await _getProducts());
      } catch (e) {
        yield ErrorState("Gagal menghapus produk.");
      }
    }
  }

Future<String> _generateNextProductId() async {
  final QuerySnapshot snapshot = await productsRef.get();
  final List<String> existingIds = snapshot.docs.map((doc) => doc['id'] as String).toList();
  int productCount = 1;

  while (true) {
    final nextProductId = 'product${productCount.toString().padLeft(3, '0')}';
    if (!existingIds.contains(nextProductId)) {
      return nextProductId;
    }
    productCount++;
  }
}

  Future<List<Product>> _getProducts() async {
    final QuerySnapshot snapshot = await productsRef.get();
    final List<Product> products = [];
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      products.add(Product.fromJson(data));
    }
    return products;
  }
}
