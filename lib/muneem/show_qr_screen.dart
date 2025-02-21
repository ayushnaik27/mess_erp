import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShowQRScreen extends StatefulWidget {
  @override
  _ShowQRScreenState createState() => _ShowQRScreenState();
}

class _ShowQRScreenState extends State<ShowQRScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  bool isMealLive = false;
  bool loading = false;

  @override
  void initState() {
    // Implement the logic to check if the meal is live
    FirebaseFirestore.instance
        .collection('meal')
        .doc('meal')
        .snapshots()
        .listen((event) {
      if (event.data() == null) return;
      if (event.data()!['status'] == 'started') {
        setState(() {
          isMealLive = true;
        });
      } else {
        setState(() {
          isMealLive = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Show QR Code'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QrImageView(
                    data: 'ABCD', // Just a key
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                  const SizedBox(height: 20),
                  !isMealLive
                      ? ElevatedButton(
                          onPressed: () async {
                            // Implement refresh functionality if needed
                            await FirebaseFirestore.instance
                                .collection('meal')
                                .doc('meal')
                                .set({
                              'status': 'started',
                              'time': DateTime.now(),
                            }, SetOptions(merge: true));
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor),
                          child: Text(
                            'Start Meal',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor),
                          child: Text(
                            'Start Meal',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                  isMealLive
                      ? ElevatedButton(
                          onPressed: () async {
                            // Implement refresh functionality if needed
                            await FirebaseFirestore.instance
                                .collection('meal')
                                .doc('meal')
                                .set({
                              'status': 'ended',
                              'time': DateTime.now(),
                            }, SetOptions(merge: true));
                            CollectionReference collectionReference =
                                FirebaseFirestore.instance
                                    .collection('livePlates');
                            QuerySnapshot querySnapshot =
                                await collectionReference.get();

                            if (querySnapshot.docs.isEmpty) return;

                            for (QueryDocumentSnapshot queryDocumentSnapshot
                                in querySnapshot.docs) {
                              await collectionReference
                                  .doc(queryDocumentSnapshot.id)
                                  .delete();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor),
                          child: Text(
                            'End Meal',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor),
                          child: Text(
                            'End Meal',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                        )
                ],
              ),
            ),
    );
  }
}
