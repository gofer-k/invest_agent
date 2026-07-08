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

#TODO:
### display multi overlay charts!!!!!

- save/lodd/update persist app's cache source 
- load portfolio assets frm db cache
- add new portfolio isset: a) manual, b) from MarketPlace api ?
- load, save, remove, update MarketPlace api account (api key, secret key) ?
- display candles signals
- filter out the respond data by specific intervals??
- display configured a chart values (main, supplement charts or indicator or signals): max, min, level values on the side pane
- custom style visualization, themes
- improve performance of visualization
- various signals: Golden/Death cross, EMA signal

#BUGS:
. Filter indicator's values by npt vale type = color 
- Test indicator config dialog!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!:
1. pass indicator config's charts colors to overlay chart
- extract new Indicator parameters in the backend server (all indicators except SMA) 
- Incorrect Bollinger bands' results or chart's drawing!!