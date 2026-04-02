import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/index_price.dart';
import '../providers/model_config.dart';
import '../providers/price_controller.dart';
import '../widgets/utils/shrinkable.dart';

class IndexPricePanel extends ConsumerStatefulWidget {
  const IndexPricePanel({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _IndexPricePanelState();
}

class _IndexPricePanelState extends ConsumerState<IndexPricePanel> {

  @override
  Widget build(BuildContext context) {
    final assets = ref.watch(useAssetsProvider);

    return Shrinkable(
      title: "Index Prices",
      body: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: assets.length,
        itemBuilder: (context, index) {
          final acc =  assets[index];
          return Card(
            child: ListTile(
              dense: true,
              title: Text(acc.symbol),
              subtitle: FutureBuilder<String>(
                future: ref.read(priceControllerProvider.notifier).assetPricesDetails(IndexPriceSchema(), acc),
                builder: (context, snapshot) {
                  return Text(snapshot.data ?? 'Loading...', style: const TextStyle(fontSize: 11));
                },
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.read_more, color: Colors.lightGreen, size: 18),
                    onPressed: () => (){} /// TODO: 1. fetch online new data, 2. refresh details},
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                    onPressed: () => ref.read(priceControllerProvider.notifier).deleteAssetAll(IndexPriceSchema(), acc),
                  ),
                ]
              ),
            ),
          );
        },
      ),
    );
  }
}
