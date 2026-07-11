import 'package:flutter_test/flutter_test.dart';
import 'package:invest_agent/model/indicator_schema.dart';

void main() {
  group('Indicator.toDetailedString', () {
    test('should format standard parameters and exclude color parameters', () {
      // Setup the example input provided in the prompt
      final parameters = {
        "window": {"value": "9", "edit": "1", "type": "int", "visible": "1"},
        "smooth length": {"value": "14", "edit": "1", "type": "int", "visible": "1"},
        "smooth type": ["SMA", "EMA"],
        "upper limit": {"value": "70", "edit": "1", "type": "double", "visible": "1"},
        "rsi chart": {"value": "#FF34BBE6", "edit": "1", "type": "color", "visible": "1"},
      };

      final indicator = Indicator(
        id: 1,
        name: "RSI",
        type: IndicatorType.rsi,
        parameters: parameters,
      );

      final result = indicator.toDetailedString();

      // Expected behaviors:
      // 1. Starts with the name "RSI"
      // 2. Contains "window: 9"
      // 3. Contains "smooth length: 14"
      // 4. Contains "smooth type: [SMA, EMA]" (List behavior)
      // 5. Contains "upper limit: 70"
      // 6. DOES NOT contain "rsi chart" because its type is "color"

      expect(result, startsWith("RSI"));
      expect(result, contains("window: 9"));
      expect(result, contains("smooth length: 14"));
      expect(result, contains("smooth type: [SMA, EMA]"));
      expect(result, contains("upper limit: 70"));
      expect(result, isNot(contains("rsi chart")));
      expect(result, isNot(contains("#FF34BBE6")));
    });

    test('should handle simple primitive parameters (non-map)', () {
      final indicator = Indicator(
        id: 2,
        name: "Simple",
        type: IndicatorType.undefined,
        parameters: {
          "period": 14,
          "active": true,
        },
      );

      final result = indicator.toDetailedString();

      // Simple values go into the else block: " $param: ${values.toString()}"
      expect(result, "Simple period: 14 active: true");
    });

    test('should return only the name if parameters are empty', () {
      final indicator = Indicator(
        id: 3,
        name: "EmptyParam",
        type: IndicatorType.undefined,
        parameters: {},
      );

      expect(indicator.toDetailedString(), "EmptyParam");
    });

    test('should correctly identify non-color map parameters even if value looks like a color', () {
      final indicator = Indicator(
        id: 4,
        name: "HexTest",
        type: IndicatorType.undefined,
        parameters: {
          "hex_code": {"value": "#FFFFFF", "type": "string"}
        },
      );

      final result = indicator.toDetailedString();

      // Since type is "string" and not "color", it should be included
      expect(result, contains("hex_code: #FFFFFF"));
    });
  });
}