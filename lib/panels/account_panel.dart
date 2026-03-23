import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:invest_agent/utils/database_helper.dart';

import '../model/user_account.dart';
import '../widgets/utils/shrinkable.dart';

const _secureStorage = FlutterSecureStorage();

class AccountPanel extends StatefulWidget {
  final DatabaseHelper? dbHelper;

  const AccountPanel(this.dbHelper, {super.key});

  @override
  State<StatefulWidget> createState() => _AccountPanelState();
}

class _AccountPanelState  extends State<AccountPanel> {
  List<UserAccount> _accounts = [];
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _apiSecretController = TextEditingController();
  ProviderData _selectedProvider = ProviderData.MarketPlace;

  // Future<void> _performTrade(UserAccount account) async {
  //   final apiKey = await _secureStorage.read(key: '${account.name}_apiKey');
  //   final apiSecret = await _secureStorage.read(key: '${account.name}_apiSecret');
  //
  //   if (apiKey != null && apiSecret != null) {
  //     // TODO: Initialize your trading client with the real keys
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _loadAccountData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _apiKeyController.dispose();
    _apiSecretController.dispose();
    super.dispose();
  }

  Future<void> _loadAccountData() async {
    try {
      // Ensure the table exists
      final accounts = await widget.dbHelper?.fetchAll<UserAccount>(UserAccountSchema());
      setState(() {
        _accounts = accounts!;
      });
    } catch (e) {
      debugPrint('Error loading accounts: $e');
    }
  }

  Future<void> _saveAccount() async {
    if (_formKey.currentState!.validate()) {
      final String accountId = _nameController.text;
      try {
        await _secureStorage.write(key: '${accountId}_apiKey', value: _apiKeyController.text);
        await _secureStorage.write(key: '${accountId}_apiSecret', value: _apiSecretController.text);
      } catch (e) {
        log('Error saving account: $e', time: DateTime.now());
        // ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text("Secure storage error: Ensure libsecret and a keyring are installed."))
        // );
      }

      final account = UserAccount(
        name: _nameController.text,
        apiKey: 'SECURE_STORAGE',
        apiSecret: 'SECURE_STORAGE',
        providerData: _selectedProvider,
      );

      await widget.dbHelper?.saveOne(UserAccountSchema(), account);

      _nameController.clear();
      _apiKeyController.clear();
      _apiSecretController.clear();

      _loadAccountData();
    }
  }

  Future<void> _deleteAccount(UserAccount account) async {
    await widget.dbHelper?.deleteOne(UserAccountSchema(), account);
    _loadAccountData();
  }

  @override
  Widget build(BuildContext context) {
    return Shrinkable(title: "Accounts",
        body: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Account Name', isDense: true),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  DropdownButtonFormField<ProviderData>(
                    initialValue: _selectedProvider,
                    items: ProviderData.values.map((m) => DropdownMenuItem(value: m, child: Text(m.name))).toList(),
                    onChanged: (v) => setState(() => _selectedProvider = v!),
                    decoration: const InputDecoration(labelText: 'Marketplace', isDense: true),
                  ),
                  TextFormField(
                    obscureText: true,
                    controller: _apiKeyController,
                    decoration: const InputDecoration(labelText: 'API Key', isDense: true),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _apiSecretController,
                    decoration: const InputDecoration(labelText: 'API Secret', isDense: true),
                    obscureText: true,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _saveAccount,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Account'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text('Saved Accounts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Accounts List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _accounts.length,
              itemBuilder: (context, index) {
                final acc = _accounts[index];
                return Card(
                  child: ListTile(
                    dense: true,
                    title: Text(acc.name),
                    subtitle: Text('${acc.providerData} - Key: ${acc.apiKey.length > 4 ? acc.apiKey.substring(0, 4) : acc.apiKey}...'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                      onPressed: () => _deleteAccount(acc),
                    ),
                  ),
                );
              },
            ),
          ],
        )
    );
  }
}