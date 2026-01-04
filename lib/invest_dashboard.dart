import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:invest_agent/utils/load_json_data.dart';

import 'model/invest_data.dart';

class InvestDashboard extends StatefulWidget {
  const InvestDashboard({Key? key}) : super(key: key);

  @override
  State<InvestDashboard> createState() => _InvestDashboardState();
}

class _InvestDashboardState extends State<InvestDashboard> {
  Future<List<FinancialEntry>>? _financialDataFuture;

  Future<void> _pickAndLoadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gz'],
      );

      if (result == null || result.files.single.path == null) return;

      final filePath = result.files.single.path!;
      final future = loadFinancialDataFromGzip(filePath);

      setState(() {
        _financialDataFuture = future;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Investment Dashboard')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _pickAndLoadFile,
            child: const Text('Select GZIP File'),
          ),
          Expanded(
            child: _financialDataFuture == null
                ? const Center(child: Text('Please select a .gz file to load data.'))
                : FutureBuilder<List<FinancialEntry>>(
              future: _financialDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data available.'));
                }

                final entries = snapshot.data!;
                return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return ListTile(
                      title: Text(entry.date.toIso8601String()),
                      subtitle: Text('Close: ${entry.data.close?.toStringAsFixed(2) ?? 'N/A'}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}