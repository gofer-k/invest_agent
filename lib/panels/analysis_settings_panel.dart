import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalysisSettingsPanel extends ConsumerStatefulWidget{
  const AnalysisSettingsPanel({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AnalysisSettingsPanelState();
}

class _AnalysisSettingsPanelState extends ConsumerState<AnalysisSettingsPanel>{
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Placeholder here"),
    );
  }

  // Future<void> _handleRunAnalysis(AnalysisRequest request) async {
  //   setState(() {
  //     isLoading = true;
  //     errorMessage = null;
  //   });
  //
  //   if (analysisRequest != null && analysisRequest!.symbolTicker == request.symbolTicker) {
  //     analysisResult?.changePeriod(request.period);
  //     analysisRequest = request;
  //     setState(() {
  //       isLoading = false;
  //     });
  //     return;
  //   }
  //
  //   try {
  //     final client = ref.watch(investingDataClientProvider(LocalRequest()).notifier);
  //     final result = await client.runAnalysis(request);
  //     AnalysisRespond? receivedData;
  //
  //     if (result["format"] == "gz") {
  //       receivedData = await receiveCompressedAnalysisResult(result);
  //     }
  //     chartTitle = p.basenameWithoutExtension(request.symbolTicker);
  //
  //     setState(() {
  //       analysisRequest = request;
  //       // Only assign if we successfully got data
  //       if (receivedData != null) {
  //         analysisResult = receivedData;
  //       }
  //     });
  //   } catch (e) {
  //     setState(() {
  //       errorMessage = e.toString();
  //       log("ETF agent analysis: Error: $errorMessage");
  //       isLoading = false;
  //     });
  //   } finally {
  //     if (mounted) { // Best practice check before calling setState in async gaps
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }
  //   }
  // }
}