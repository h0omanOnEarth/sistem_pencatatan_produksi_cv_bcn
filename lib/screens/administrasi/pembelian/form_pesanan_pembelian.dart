import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/pembelian/pesanan_pembelian_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/pembelian/purchase_order.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/bahan_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/supplier_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';


class FormPesananPembelianScreen extends StatefulWidget {
  static const routeName = '/form_pesanan_pembelian_screen';

  final String? purchaseOrderId; // Terima ID PO jika dalam mode edit
  final String? supplierId;
  final String? bahanId;
  const FormPesananPembelianScreen({Key? key, this.purchaseOrderId, this.supplierId, this.bahanId}) : super(key: key);
  
  @override
  State<FormPesananPembelianScreen> createState() =>
      _FormPesananPembelianScreenState();
}

class _FormPesananPembelianScreenState extends State<FormPesananPembelianScreen> {
  DateTime? _selectedTanggalPengiriman;
  DateTime? _selectedTanggalPesanan;
  String? selectedKode; //kode bahan
  String? selectedSupplier; //kode
  String selectedSatuan = "Kg";
  String selectedStatusPembayaran = "Belum Bayar";
  String selectedStatusPengiriman = "Dalam Proses";
  String? dropdownValue;

  // controller
  TextEditingController namaBahanController = TextEditingController();
  TextEditingController jumlahController = TextEditingController();
  TextEditingController hargaSatuanController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  TextEditingController catatanController = TextEditingController();

  @override
  void dispose() {
    jumlahController.removeListener(_updateTotal);
    hargaSatuanController.removeListener(_updateTotal);
    selectedBahanNotifier.removeListener(_selectedKodeListener);
    super.dispose();
  }

  // Fungsi yang akan dipanggil ketika selectedKode berubah
  void _selectedKodeListener() {
    setState(() {
      selectedKode = selectedBahanNotifier.value;
    });
  }

  void _updateTotal() {
    if (jumlahController.text.isNotEmpty && hargaSatuanController.text.isNotEmpty) {
      final jumlah = int.parse(jumlahController.text);
      final hargaSatuan = int.parse(hargaSatuanController.text);
      final total = jumlah * hargaSatuan;
      totalController.text = total.toString();
    }
  }

  @override
  void initState() {
  super.initState();

  // untuk mengganti selected kode dari file dropdown 
  selectedBahanNotifier.addListener(_selectedKodeListener);
    // Inisialisasi selectedPesanan berdasarkan nilai awal selectedKodeNotifier
  selectedKode = selectedBahanNotifier.value;

  jumlahController.addListener(_updateTotal);
  hargaSatuanController.addListener(_updateTotal);
    if (widget.purchaseOrderId != null) {
        FirebaseFirestore.instance
          .collection('purchase_orders')
          .where('id', isEqualTo: widget.purchaseOrderId)
          .get()
          .then((QuerySnapshot querySnapshot) {
            if (querySnapshot.docs.isNotEmpty) {
              final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
              setState(() {
                jumlahController.text = data['jumlah'].toString();
                catatanController.text = data['keterangan'] ?? '';
                hargaSatuanController.text = data['harga_satuan'].toString();
                selectedSatuan = data['satuan'];
                totalController.text = data['total'].toString();
                selectedStatusPembayaran = data['status_pembayaran'];
                selectedStatusPengiriman = data['status_pengiriman'];
                final tanggalKirimFirestore = data['tanggal_kirim'];
                if (tanggalKirimFirestore != null) {
                  if (tanggalKirimFirestore != null) {
                    _selectedTanggalPengiriman = tanggalKirimFirestore.toDate();
                  }
                }
                final tanggalPesanFirestore = data['tanggal_pesan'];
                if (tanggalPesanFirestore != null) {
                  if (tanggalPesanFirestore != null) {
                    _selectedTanggalPesanan = tanggalPesanFirestore.toDate();
                  }
                }
              });
            } else {
              print('Document does not exist on Firestore');
            }
          }).catchError((error) {
            print('Error getting document: $error');
          });
      }
     // Periksa jika widget.supplierId tidak null
    if (widget.supplierId != null) {
      selectedSupplier = widget.supplierId;
    }
    if(widget.bahanId!=null){
      selectedKode = widget.bahanId;
      print(widget.bahanId);
      selectedKode = widget.bahanId;
          FirebaseFirestore.instance
          .collection('materials')
          .where('id', isEqualTo: selectedKode) // Gunakan .where untuk mencocokkan ID
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          final materialData = querySnapshot.docs.first.data() as Map<String, dynamic>;
          final namaBahan = materialData['nama'];
          namaBahanController.text = namaBahan ?? '';
        } else {
          print('Document does not exist on Firestore');
        }
      }).catchError((error) {
        print('Error getting document: $error');
      });
    }
  }

  void _showSuccessMessageAndNavigateBack() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return SuccessDialog(
        message: 'Berhasil menyimpan pesanan pembelian bahan.',
      );
    },
    ).then((_) {
      Navigator.pop(context,null);
    });
  }

    void addOrUpdatePurchaseOrder() {
    final purchaseOrderBloc = BlocProvider.of<PurchaseOrderBloc>(context);
    final PurchaseOrder newPurchaseOrder = PurchaseOrder(id: '', supplierId: selectedSupplier??'', materialId: selectedKode??'', jumlah: int.parse(jumlahController.text), satuan: selectedSatuan, hargaSatuan: int.parse(hargaSatuanController.text), tanggalPesan:  _selectedTanggalPesanan ?? DateTime.now(), tanggalKirim:  _selectedTanggalPengiriman ?? DateTime.now(), statusPembayaran: selectedStatusPembayaran, statusPengiriman: selectedStatusPengiriman, keterangan: catatanController.text, status: 1, total: int.parse(totalController.text)
    );

    if(widget.purchaseOrderId!=null){
      purchaseOrderBloc.add(UpdatePurchaseOrderEvent(widget.purchaseOrderId ?? '',newPurchaseOrder));
    }else{
      purchaseOrderBloc.add(AddPurchaseOrderEvent(newPurchaseOrder));
    }
    
    _showSuccessMessageAndNavigateBack();
  }

  @override
  Widget build(BuildContext context) {
     return BlocProvider(
      create: (context) => PurchaseOrderBloc(),
      child: Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context, null);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child:const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.arrow_back, color: Colors.black),
                        ),
                      ),
                    ),
                   const SizedBox(width: 16.0),
                    const Text(
                      'Pesanan Pembelian',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: BahanDropdown(namaBahanController:namaBahanController)
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child:    TextFieldWidget(
                      label: 'Nama Bahan',
                      placeholder: 'Nama Bahan',
                      controller: namaBahanController,
                      isEnabled: false,
                    ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0,),
                 // Menggunakan SupplierDropdown
                SupplierDropdown(
                  selectedSupplier: selectedSupplier,
                  onChanged: (newValue) {
                    setState(() {
                      selectedSupplier = newValue;
                      print(selectedSupplier);
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(child: 
                    TextFieldWidget(
                      label: 'Jumlah',
                      placeholder: 'Jumlah',
                      controller: jumlahController,
                    ),),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: DropdownWidget(
                      label: 'Satuan',
                      selectedValue: selectedSatuan, // Isi dengan nilai yang sesuai
                      items: const ['Kg','Ons','Pcs','Gram','Sak'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedSatuan = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
                    ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                 Row(
                  children: [
                    Expanded(
                      child:    TextFieldWidget(
                      label: 'Harga Satuan',
                      placeholder: 'Harga Satuan',
                      controller: hargaSatuanController,
                    ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child:    TextFieldWidget(
                        label: 'Total',
                        placeholder: 'Total',
                        controller: totalController,
                        isEnabled: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0,),
                Row(
                  children: [
                    Expanded(
                      child:  DatePickerButton(
                        label: 'Tanggal Pesanan',
                        selectedDate: _selectedTanggalPesanan,
                        onDateSelected: (newDate) {
                          setState(() {
                            _selectedTanggalPesanan = newDate;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: DatePickerButton(
                        label: 'Tanggal Pengirman',
                        selectedDate: _selectedTanggalPengiriman,
                        onDateSelected: (newDate) {
                          setState(() {
                            _selectedTanggalPengiriman = newDate;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0,),
                Row(
                  children: [
                    Expanded(
                      child: DropdownWidget(
                      label: 'Status Pemayaran',
                      selectedValue: selectedStatusPembayaran, // Isi dengan nilai yang sesuai
                      items: const ['Belum Bayar', 'Dalam Proses', 'Selesai'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedStatusPembayaran = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
                    ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: DropdownWidget(
                      label: 'Status Pengiriman',
                      selectedValue: selectedStatusPengiriman, // Isi dengan nilai yang sesuai
                      items: const ['Dalam Proses', 'Selesai'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedStatusPengiriman = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
                    ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0,),
                   TextFieldWidget(
                  label: 'Catatan',
                  placeholder: 'Catatan',
                  controller: catatanController,
              
                ),
                const SizedBox(height: 16.0,),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle save button press
                          addOrUpdatePurchaseOrder();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(59, 51, 51, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'Simpan',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle clear button press
                          _selectedTanggalPengiriman = null;
                          _selectedTanggalPesanan = null;
                          selectedKode = null;
                          selectedSupplier = null;
                          selectedSatuan = "Kg";
                          selectedStatusPembayaran = "Belum Bayar";
                          selectedStatusPengiriman = "Dalam Proses";
                          namaBahanController.clear(); 
                          jumlahController.clear();
                          hargaSatuanController.clear();
                          totalController.clear();
                          catatanController.clear();
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(59, 51, 51, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Padding(
                          padding:  EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'Bersihkan',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    )
    );
  }
}
