import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/master/product.dart';

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

class SuccessState extends ProductBlocState {}

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

      final nama = event.product.nama;
      final deskripsi =  event.product.deskripsi;
      final harga =  event.product.harga;
      final berat =  event.product.berat;
      final dimensi =  event.product.dimensi;
      final jenis = event.product.jenis;
      final ketebalan = event.product.ketebalan;
      final satuan =  event.product.satuan;
      final status = event.product.status;
      final stok  =  event.product.stok;

      if(nama.isNotEmpty){
        try {
          final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('productValidation');
          final HttpsCallableResult<dynamic> result =
          await callable.call(<String, dynamic>{
            'nama':nama,
            'berat': berat,
            'harga': harga,
            'dimensi': dimensi,
            'ketebalan': ketebalan,
            'stok': stok
          });

           if (result.data['success'] == true) {
              final String nextProductId = await _generateNextProductId();
              await FirebaseFirestore.instance.collection('products').add({
                'id': nextProductId,
                'nama': nama,
                'deskripsi': deskripsi,
                'harga': harga,
                'berat': berat,
                'dimensi': dimensi,
                'jenis': jenis,
                'ketebalan': ketebalan,
                'satuan': satuan,
                'status': status,
                'stok': stok,
              });

              yield SuccessState();
           }else{
            yield ErrorState(result.data['message']);
           }

        } catch (e) {
          yield ErrorState(e.toString());
        }
      }else{
        yield ErrorState("Nama wajib diisi");
      }

    } else if (event is UpdateProductEvent) {
      yield LoadingState();
      
      final nama = event.updatedProduct.nama;
      final deskripsi =  event.updatedProduct.deskripsi;
      final harga =  event.updatedProduct.harga;
      final berat =  event.updatedProduct.berat;
      final dimensi =  event.updatedProduct.dimensi;
      final jenis = event.updatedProduct.jenis;
      final ketebalan = event.updatedProduct.ketebalan;
      final satuan =  event.updatedProduct.satuan;
      final status = event.updatedProduct.status;
      final stok  =  event.updatedProduct.stok;

      final productSnapshot = await productsRef.where('id', isEqualTo: event.productId).get();
      if (productSnapshot.docs.isNotEmpty) {
          try {
            final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('productValidation');
            final HttpsCallableResult<dynamic> result =
            await callable.call(<String, dynamic>{
              'nama':nama,
              'berat': berat,
              'harga': harga,
              'dimensi': dimensi,
              'ketebalan': ketebalan,
              'stok': stok
            });

            if (result.data['success'] == true) {
              final materialDoc = productSnapshot.docs.first;
              await materialDoc.reference.update({
                'nama': nama,
                'deskripsi': deskripsi,
                'harga': harga,
                'berat': berat,
                'dimensi': dimensi,
                'jenis': jenis,
                'ketebalan': ketebalan,
                'satuan': satuan,
                'status': status,
                'stok': stok,
              });
             
              yield SuccessState();
            }else{
              yield ErrorState(result.data['message']);
            }
          
        } catch (e) {
          yield ErrorState(e.toString());
        }
      }else {
          // Handle jika data pelanggan dengan ID tersebut tidak ditemukan
          yield ErrorState('Data produk dengan ID ${event.productId} tidak ditemukan.');
      }

    } else if (event is DeleteProductEvent) {
      yield LoadingState();
      try {
        // Cari dokumen dengan 'id' yang sesuai dengan event.mesinId
          QuerySnapshot querySnapshot = await productsRef.where('id', isEqualTo: event.productId).get();
          
          // Hapus semua dokumen yang sesuai dengan pencarian (biasanya hanya satu dokumen)
          for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
            await documentSnapshot.reference.delete();
          }
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
