import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/utils/format_date.dart';

class PurchaseRequestDropDown extends StatefulWidget {
  final String? selectedPurchaseRequest;
  final Function(String?) onChanged;
  final TextEditingController? jumlahPermintaanController;
  final TextEditingController? satuanPermintaanController;
  final bool isEnabled;
  final String? feature;

  const PurchaseRequestDropDown(
      {Key? key,
      this.selectedPurchaseRequest,
      required this.onChanged,
      this.jumlahPermintaanController,
      this.satuanPermintaanController,
      this.isEnabled = true,
      this.feature})
      : super(key: key);

  @override
  State<PurchaseRequestDropDown> createState() =>
      _PurchaseRequestDropDownState();
}

class _PurchaseRequestDropDownState extends State<PurchaseRequestDropDown> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('purchase_requests')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

        // Filter dan urutkan data secara lokal
        documents = documents.where((document) {
          if (widget.isEnabled) {
            if (widget.feature == null) {
              return document['status'] == 1 &&
                  document['status_prq'] == "Dalam Proses";
            } else {
              return document['status'] == 1 &&
                  document['status_prq'] == "Selesai";
            }
          } else {
            // Jika isEnabled false, tampilkan semua data
            return true;
          }
        }).toList();

        documents.sort((a, b) {
          DateTime dateA = a['tanggal_permintaan'].toDate();
          DateTime dateB = b['tanggal_permintaan'].toDate();
          return dateB.compareTo(dateA);
        });

        List<DropdownMenuItem<String>> purchaseRequestItems = [];

        for (QueryDocumentSnapshot document in documents) {
          String purchaseRequestId = document['id'];
          String jumlahPermintaan = document['jumlah'].toString();
          String satuanPermintaan = document['satuan'].toString();

          purchaseRequestItems.add(
            DropdownMenuItem<String>(
              value: purchaseRequestId,
              child: Text(
                purchaseRequestId,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          );

          if (widget.jumlahPermintaanController != null &&
              widget.selectedPurchaseRequest == purchaseRequestId) {
            Future.delayed(Duration.zero, () {
              widget.jumlahPermintaanController?.text = jumlahPermintaan;
              widget.satuanPermintaanController?.text = satuanPermintaan;
            });
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Permintaan Pembelian',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8.0),
            InkWell(
              onTap: widget.isEnabled ? _showPurchaseRequestDialog : null,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.selectedPurchaseRequest ??
                            'Select Purchase Request',
                        style: const TextStyle(color: Colors.black),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPurchaseRequestDialog() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('purchase_requests').get();

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Purchase Request'),
          content: SizedBox(
            width: double.maxFinite,
            child: Builder(
              builder: (BuildContext context) {
                List<QueryDocumentSnapshot> documents = snapshot.docs.toList();

                documents = documents.where((document) {
                  if (widget.isEnabled) {
                    if (widget.feature == null) {
                      return document['status'] == 1 &&
                          document['status_prq'] == "Dalam Proses";
                    } else {
                      return document['status'] == 1 &&
                          document['status_prq'] == "Selesai";
                    }
                  } else {
                    return true;
                  }
                }).toList();

                documents.sort((a, b) {
                  DateTime dateA = a['tanggal_permintaan'].toDate();
                  DateTime dateB = b['tanggal_permintaan'].toDate();
                  return dateB.compareTo(dateA);
                });

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    return _buildPurchaseRequestItem(documents[index]);
                  },
                );
              },
            ),
          ),
        );
      },
    ).then((selectedPurchaseRequest) {
      if (selectedPurchaseRequest != null) {
        // widget.onChanged(selectedPurchaseRequest);
      }
    });
  }

  Widget _buildPurchaseRequestItem(QueryDocumentSnapshot document) {
    String purchaseRequestId = document['id'];
    String tanggalPermintaan = DateFormatter.formatDate(
      document['tanggal_permintaan'].toDate(),
    );
    String materialId = document['material_id'];
    String jumlah = document['jumlah'].toString();
    String satuan = document['satuan'].toString();
    String statusPrq = document['status_prq'];

    return FutureBuilder<bool>(
      future: checkIdInMaterialReceives(purchaseRequestId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        } else {
          bool idNotInMaterialReceives = snapshot.data ?? false;

          if (idNotInMaterialReceives) {
            return InkWell(
              onTap: () {
                Navigator.pop(context, purchaseRequestId);

                // Call the onChanged callback with the selected value
                widget.onChanged(purchaseRequestId);

                // Update other fields based on selectedPurchaseRequest if needed
                if (widget.jumlahPermintaanController != null) {
                  widget.jumlahPermintaanController!.text = jumlah;
                  widget.satuanPermintaanController!.text = satuan;
                }
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID: $purchaseRequestId',
                        style: const TextStyle(color: Colors.black),
                      ),
                      Text(
                        'Tanggal Permintaan: $tanggalPermintaan',
                        style: const TextStyle(color: Colors.black),
                      ),
                      Text(
                        'Material ID: $materialId',
                        style: const TextStyle(color: Colors.black),
                      ),
                      Text(
                        'Jumlah: $jumlah',
                        style: const TextStyle(color: Colors.black),
                      ),
                      Text(
                        'Satuan: $satuan',
                        style: const TextStyle(color: Colors.black),
                      ),
                      Text(
                        'Status PRQ: $statusPrq',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            // If purchase request is already in 'material_receives', return an empty container
            return Container();
          }
        }
      },
    );
  }

  Future<bool> checkIdInMaterialReceives(String id) async {
    // Query 'material_receives' collection to check if the id exists
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('material_receives')
        .where('purchase_request_id', isEqualTo: id)
        .get();

    return snapshot
        .docs.isEmpty; // If the list is empty, id is not in 'material_receives'
  }
}
