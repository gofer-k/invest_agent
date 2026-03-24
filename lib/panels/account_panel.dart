import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/user_account.dart';
import 'package:invest_agent/model/model_manager.dart';
import 'package:invest_agent/widgets/utils/shrinkable.dart';

class AccountPanel extends ConsumerStatefulWidget {
  const AccountPanel({super.key});

  @override
  ConsumerState<AccountPanel> createState() => _AccountPanelState();
}

class _AccountPanelState extends ConsumerState<AccountPanel> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _apiSecretController = TextEditingController();
  ProviderData _selectedProvider = ProviderData.MarketPlace;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(modelManagerProvider.notifier).fetch<UserAccount>(UserAccountSchema());
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _apiKeyController.dispose();
    _apiSecretController.dispose();
    super.dispose();
  }

  Future<void> _saveAccount() async {
    if (_formKey.currentState!.validate()) {
      final notifier = ref.read(modelManagerProvider.notifier);
      
      final account = UserAccount(
        name: _nameController.text,
        apiKey: '',
        apiSecret: '',
        providerData: _selectedProvider,
      );

      await notifier.saveUserAccount(
        account,
        apiKey: _apiKeyController.text,
        apiSecret: _apiSecretController.text,
      );

      _nameController.clear();
      _apiKeyController.clear();
      _apiSecretController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final modelState = ref.watch(modelManagerProvider);
    final accounts = modelState.getItems<UserAccount>();

    return Shrinkable(
      title: "Accounts",
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
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final acc = accounts[index];
              return Card(
                child: ListTile(
                  dense: true,
                  title: Text(acc.name),
                  subtitle: Text(acc.providerData.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                    onPressed: () => ref.read(modelManagerProvider.notifier).delete(UserAccountSchema(), acc),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
