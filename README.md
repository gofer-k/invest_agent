# invest_agent

A new Flutter project.

## Resources

- [DNA rynków](https://dnarynkow.pl/)
- [Encyklopedia zarządania](https://mfiles.pl/pl/index.php/Strona_g%C5%82%C3%B3wna)

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Install:
sudo apt install protobuf-compiler
dart pub global activate protoc_plugin

Generate rcp API:
protoc --dart_out=grpc:lib/model/proto/generated -I proto ./*.proto

Generate riverpod API:
dart run build_runner build --delete-conflicting-outputs

flutter pub run build_runner build --delete-conflicting-outputs

#Chart config schema:
[!JSON schema:]

```
{
    "window": {             <- map element key
        "value": "9",       <- [number, color, string]  (TextField, Text, Color picker)
        "edit": "1",        <- Editable or const (TextField, Text)
        "type": "int",      <- ["int","double", "string", "color"],  #ARGB color format
        "visible": "1"      <- Visible or not (Checkbox)
    }, 
    "smooth type": ["SMA","EMA"],   <- [Dropdown, Radio] 
} 

Useful commands:
Create the output directory
mkdir -p lib/model/proto/generated

Run the compiler
protoc --dart_out=grpc:lib/model/proto/generated -I lib/model/proto lib/model/proto/*.proto  
```

### TODO:

## - support user strategies

- display multi vertical chart's key values (with custom colorful labels)
- display portfolio result's curve or signal points onto the chart
- How to check out portfolio's metrics results
- display tooltips on the chart's board

### - convert time controller to provider

- support customizable interval for chart (list defined intervals: 1M, 3, M, 6M, 1Y, 3Y, 5Y, MAX)
- extend assets config for assets type type (equity, bonds, regions: usa, acits, emi, pol)
- display candles signals
- custom style visualization, themes
- improve performance of visualization
- various signals: Golden/Death cross, EMA signal

### BUGS:

- the date with vertical line is not match to a chart data
- portfolio asset prices data isn't filter out from the one configuration timestamp period.
- Incorrect Bollinger bands' results or chart's drawing ?!
- Test indicator config dialog: Volume