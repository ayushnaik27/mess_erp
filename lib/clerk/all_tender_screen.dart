import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/clerk/tender_details_clerk.dart';
import 'package:provider/provider.dart';

import '../providers/tender_provider.dart'; // Import your tender provider

class AllTendersScreen extends StatefulWidget {
  const AllTendersScreen({super.key});

  @override
  _AllTendersScreenState createState() => _AllTendersScreenState();
}

class _AllTendersScreenState extends State<AllTendersScreen> {
  List<Tender> _tenders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTenders();
  }

  Future<void> _fetchTenders() async {
    try {
      final tenders = await Provider.of<TenderProvider>(context, listen: false)
          .fetchAllTenders();
      setState(() {
        _tenders = tenders;
        _isLoading = false;
      });
    } catch (error) {
      showDialog(
          context: context,
          builder: (_) =>
              AlertDialog(content: Text('Error fetching tenders: $error')));
      print('Error fetching tenders: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tenders'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tenders.isEmpty
              ? const Center(child: Text('No tenders available'))
              : ListView.builder(
                  itemCount: _tenders.length,
                  itemBuilder: (context, index) {
                    final tender = _tenders[index];
                    return ListTile(
                      title: Text(tender.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deadline: ${DateFormat('dd-MM-yyyy').format(tender.deadline)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Opening Date: ${DateFormat('dd-MM-yyyy').format(tender.openingDate)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          // Add more relevant information as needed
                        ],
                      ),
                      onTap: tender.openingDate.isBefore(DateTime.now())
                          ? () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return TenderDetailsClerkScreen(
                                    tender: tender, bids: tender.bids);
                              }));
                            }
                          : null,
                      trailing: tender.openingDate.isAfter(DateTime.now())
                          ? const Icon(Icons.lock_clock)
                          : const Icon(Icons.lock_open),
                    );
                  },
                ),
    );
  }
}
