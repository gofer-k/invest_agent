import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:invest_agent/model/user_account.dart';
import 'package:invest_agent/utils/database_helper.dart';

const _secureStorage = FlutterSecureStorage();
class MainSettingsPanel extends StatefulWidget {
  const MainSettingsPanel({super.key});

  @override
  State<MainSettingsPanel> createState() => _MainSettingsPanelState();
}

class _MainSettingsPanelState extends State<MainSettingsPanel> {
  final _formKey = GlobalKey<FormState>();
  String _dbPath = 'No cache';
  List<UserAccount> _accounts = [];

  final _nameController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _apiSecretController = TextEditingController();
  ProviderData _selectedProvider = ProviderData.MarketPlace;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _performTrade(UserAccount account) async {
   final apiKey = await _secureStorage.read(key: '${account.name}_apiKey');
    final apiSecret = await _secureStorage.read(key: '${account.name}_apiSecret');

    if (apiKey != null && apiSecret != null) {
      // TODO: Initialize your trading client with the real keys
    }
  }

  Future<void> _loadAccounts() async {
    final db = DatabaseHelper(_dbPath);
    try {
      // Ensure the table exists
      await db.createCache(UserAccountSchema());
      final accounts = await db.fetchAll<UserAccount>(UserAccountSchema());
      setState(() {
        _accounts = accounts;
      });
    } catch (e) {
      debugPrint('Error loading accounts: $e');
    }
  }

  Future<void> _pickDbPath() async {
    String? result = await FilePicker.platform.saveFile(
      dialogTitle: 'Select DuckDB Cache Location',
      fileName: 'No cache path',
    );

    if (result != null) {
      setState(() {
        _dbPath = result;
      });
      _loadAccounts();
    }
  }

  Future<void> _saveAccount() async {
    if (_formKey.currentState!.validate()) {
      final String accountId = _nameController.text;
      try {
        await _secureStorage.write(key: '${accountId}_apiKey', value: _apiKeyController.text);
        await _secureStorage.write(key: '${accountId}_apiSecret', value: _apiSecretController.text);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Secure storage error: Ensure libsecret and a keyring are installed."))
        );
      }

      final account = UserAccount(
        name: _nameController.text,
        apiKey: 'SECURE_STORAGE',
        apiSecret: 'SECURE_STORAGE',
        providerData: _selectedProvider,
      );

      final db = DatabaseHelper(_dbPath);
      await db.saveOne(UserAccountSchema(), account);
      
      _nameController.clear();
      _apiKeyController.clear();
      _apiSecretController.clear();
      
      _loadAccounts();
    }
  }

  Future<void> _deleteAccount(UserAccount account) async {
    final db = DatabaseHelper(_dbPath);
    await db.deleteOne(UserAccountSchema(), account);
    _loadAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('General Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
          ListTile(
            dense: true,
            title: const Text('Cache Location'),
            subtitle: Text(_dbPath, style: const TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.folder_open, size: 20),
            onTap: _pickDbPath,
          ),
          const SizedBox(height: 24),
          const Text('Trading Accounts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
          
          // Account Form
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
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _apiKeyController.dispose();
    _apiSecretController.dispose();
    super.dispose();
  }
}
