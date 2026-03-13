import 'package:flutter/material.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/portfolio_config.dart';
import 'package:invest_agent/utils/database_helper.dart';
import 'package:invest_agent/widgets/utils/dropdown.dart';
import 'package:sealed_currencies/sealed_currencies.dart';

void showPortfolio(
  BuildContext context, PortfolioConfig? portfolio, DatabaseHelper db,
  Function(PortfolioConfig portfolio) onSave) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return PortfolioDialog(portfolioConfig: portfolio, onSave: onSave);
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
}

class PortfolioDialog extends StatefulWidget {
  final Function(PortfolioConfig newPortfolio) onSave;
  final PortfolioConfig? portfolioConfig;

  const PortfolioDialog({
    super.key, required this.onSave, required this.portfolioConfig});

  @override
  State<PortfolioDialog> createState() => _PortfolioDialogState();
}

class _PortfolioDialogState extends State<PortfolioDialog> {
  late String portfolioName;
  late double targetWeight;
  PortfolioConfig? selectedPortfolio;
  FiatCurrencyEnum selectedCurrency = FiatCurrencyEnum.usd;

  // final double rebalanceThreshold;
  late final TextEditingController controller;
  late List<AssetConfig> assets;

  @override
  void initState() {
    super.initState();
    //TODO:
    // controller = TextEditingController();
    // multiTitle = widget.chart?.title ?? '';
    // selectedMainChart = widget.chart?.mainChart ?? MainChartType.linePrice;
    // selectedOverlayCharts = List.from(widget.chart?.overlayCharts ?? []);
    // controller.text = multiTitle;
  }

  @override
  Widget build(BuildContext context) {
    final titleStr = widget.portfolioConfig != null ? "Add portfolio" : "Update portfolio";
    return AlertDialog(
      title: Text(titleStr),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Portfolio name
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Enter portfolio name",
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.text,
            textAlign: TextAlign.end,
          ),
          // Asset's currency
          Row(
            children: [
              Expanded(
                child: Dropdown<FiatCurrencyEnum>(
                  choices: FiatCurrencyEnum.values,
                  choiceType: selectedCurrency,
                  onSelected: (FiatCurrencyEnum? selected) {
                    if (selected != null) {
                      setState(() => selectedCurrency = selected);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text("Overlay Chart Types:"),
          Row(
            children: [
              // Expanded(
              //   child: Dropdown<SupplementChart>(
              //     choices: SupplementChart.values,
              //     // A placeholder or the first item can be used as the initial display.
              //     choiceType: overlayChart,
              //     onSelected: (SupplementChart? selected) {
              //       if (selected != null) overlayChart = selected;
              //     },
              //   ),
              // ),
              // IconButton(icon: Icon(Icons.add_box_outlined), onPressed: () {
              //   setState(() => selectedOverlayCharts.add(overlayChart));
              // }),
            ],
          ),
        ],
      ),
      actions: [
        BackButton(onPressed: () => Navigator.of(context).pop()),
        ElevatedButton(
          onPressed: () {
            // multiTitle = controller.text;
            // final newChart = MultiChart(title: multiTitle, mainChart: selectedMainChart,
            //     overlayCharts: selectedOverlayCharts);
            // if (ChartsConfiguration.validate(newChart)) {
            //   widget.onSave(newChart);
            //   Navigator.of(context).pop();
            // }
            // else {
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     const SnackBar(content: Text("Invalid chart configuration")),
            //   );
            // }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
