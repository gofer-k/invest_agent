import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sealed_currencies/sealed_currencies.dart';

import '../model/asset_config.dart';

void showAsset(
    BuildContext context, AssetConfig? assetConfig,
    Function(AssetConfig? assetConfig) onSave) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AssetDialog(assetConfig: assetConfig, onSave: onSave);
    },
  );
}

enum FiatCurrencyEnum {
  usd(FiatCurrency.usd()),
  eur(FiatCurrency.eur()),
  pln(FiatCurrency.pln()),
  gbp(FiatCurrency.gbp());

  const FiatCurrencyEnum(this.data);
  final FiatCurrency data;

  static FiatCurrencyEnum? fromCurrency(FiatCurrency? otherCurrency) {
    // Uses Dart 3.0+ firstOrNull for cleaner logic
    return values.where((e) => e.data == otherCurrency).firstOrNull;
  }
}

class AssetDialog extends ConsumerStatefulWidget{
  final Function(AssetConfig? assetConfig) onSave;
  final AssetConfig? assetConfig;
  const AssetDialog({
    super.key, required this.onSave, required this.assetConfig});

  @override
  ConsumerState<AssetDialog> createState() => _AssetDialogState();
}

class _AssetDialogState extends ConsumerState<AssetDialog> {
  late FiatCurrencyEnum selectedCurrency =
      FiatCurrencyEnum.fromCurrency(widget.assetConfig?.currency) ?? FiatCurrencyEnum.usd;
  late StockExchange selectedStockExchange = widget.assetConfig?.stockExchange ?? StockExchange.lSe;

  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.assetConfig?.symbol ?? '');
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleStr = widget.assetConfig == null ? "Add portfolio" : "Update portfolio";
    return AlertDialog(
      title: Text(titleStr),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Asset name
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: "Asset Symbol",
              hintText: "e.g. ISAC",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.text,
            textAlign: TextAlign.end,
          ),
          const SizedBox(height: 16),
          // Currency list
          DropdownButtonFormField<FiatCurrencyEnum>(
            decoration: const InputDecoration(labelText: "Currency"),
            initialValue: selectedCurrency,
            items: FiatCurrencyEnum.values.map((c) =>
                DropdownMenuItem(value: c, child: Text(c.name.toUpperCase()))
            ).toList(),
            onChanged: (val) {
              if (val == null) return;
              setState(() => selectedCurrency = val);
            }
          ),
          //Stock exchange list
          const SizedBox(height: 16),
          DropdownButtonFormField<StockExchange>(
            decoration: const InputDecoration(labelText: "Exchange"),
            initialValue: selectedStockExchange,
            items: StockExchange.values.map((stockExchange) =>
              DropdownMenuItem<StockExchange>(
                value: stockExchange,
                child: Text(stockExchange.toString()),
              )
            ).toList(),
            onChanged: (StockExchange? value) {
              if (value == null) return;
              setState(() => selectedStockExchange = value);
            },
          ),
        ]
      ),
      actions: [
        BackButton(onPressed: () => Navigator.of(context).pop()),
        ElevatedButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isEmpty) return;
            final newAsset = AssetConfig(id: widget.assetConfig?.id ?? -1,
              symbol: name,
              currency: selectedCurrency.data,
              stockExchange: selectedStockExchange,
            );
            widget.onSave(newAsset);
            Navigator.of(context).pop();
          },
          child: const Text("Save"),
        )
      ]
    );
  }
}
