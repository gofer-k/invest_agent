# invest_agent

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Install:
sudo apt  install protobuf-compiler
dart pub global activate protoc_plugin

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
```

### TODO:
- support different price chart type: candle sticks, etc. 
- load portfolio assets frm db cache
- add new portfolio isset: a) manual, b) from MarketPlace api ?
- display candles signals
- filter out the respond data by specific intervals??
- custom style visualization, themes
- improve performance of visualization
- various signals: Golden/Death cross, EMA signal

### BUGS:
- Incorrect Bollinger bands' results or chart's drawing ?!
- Test indicator config dialog: Volume