import 'package:invest_agent/model/trading_request.dart';

import 'cache_schema.dart';

class UserAccount extends Cache {
  final int? id;
  final String name;
  final String apiKey;
  final String apiSecret;
  final ResourceUri providerData;

  UserAccount({
    this.id,
    required this.name,
    required this.apiKey,
    required this.apiSecret,
    required this.providerData,
  }) : super.from([]);

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'apiKey': apiKey,
      'apiSecret': apiSecret,
      'providerData': providerData.name,
    };
  }

  factory UserAccount.fromList(List<Object?> item) {
    return UserAccount(
      id: item[0] as int?,
      name: item[1] as String,
      apiKey: item[2] as String,
      apiSecret: item[3] as String,
      providerData: ResourceUri.fromString(item[4] as String) ?? ResourceUri.marketStack,
    );
  }

  @override
  String toString() => 'UserAccount(id: $id, name: $name, provider: $providerData)';
}

class UserAccountSchema extends CacheSchema {
  @override
  String get createKey => 'CREATE SEQUENCE IF NOT EXISTS user_id_seq;';

  @override
  String get create => '''
    CREATE TABLE IF NOT EXISTS user_accounts (
      id INTEGER PRIMARY KEY DEFAULT nextval('user_id_seq'),
      name TEXT,
      apiKey TEXT,
      apiSecret TEXT,
      providerData TEXT
    );
  ''';

  @override
  String get readAll => 'SELECT * FROM user_accounts;';

  @override
  String get deleteAll => 'DELETE FROM user_accounts;';

  @override
  String deleteOne(Cache cache) {
    final user = cache as UserAccount;
    return 'DELETE FROM user_accounts WHERE id = ${user.id};';
  }

  @override
  String saveOne(Cache cache) {
    final user = cache as UserAccount;
    return "INSERT INTO user_accounts (name, apiKey, apiSecret, providerData) VALUES ('${user.name}', '${user.apiKey}', '${user.apiSecret}', '${user.providerData.name}');";
  }

  @override
  String readOne(Cache cache) {
    final user = cache as UserAccount;
    return 'SELECT * FROM user_accounts WHERE id = ${user.id};';
  }

  @override
  String updateOne(Cache cache) {
    final user = cache as UserAccount;
    return "UPDATE user_accounts SET name = '${user.name}', apiKey = '${user.apiKey}', apiSecret = '${user.apiSecret}', providerData = '${user.providerData.name}' WHERE id = ${user.id};";
  }
}
