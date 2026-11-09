// import 'package:flutter/material.dart';
//
// class PopupWidget extends StatefulWidget {
//   final Widget content;
//   final Widget? popupDialog;
//   final double horizontalPadding;
//   final double verticalPadding;
//
//   const PopupWidget(
//       {super.key,
//        required this.content,
//        this.popupDialog,
//        this.horizontalPadding = 0,
//        this.verticalPadding = 0});
//
//   @override
//   State<StatefulWidget> createState() => _PopupWidgetState();
// }
//
// class _PopupWidgetState extends State<PopupWidget> {
//   @override
//   Widget build(BuildContext context) {
//     /// Use a GlobalKey to get the position of the item
//     final GlobalKey itemKey = GlobalKey();
//
//     return Container(
//       key: itemKey,
//       padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding, vertical: widget.verticalPadding),
//       child: GestureDetector(
//         onLongPress: () {
//           if (widget.popupDialog != null) {
//             final RenderBox itemBox = itemKey.currentContext!.findRenderObject() as RenderBox;
//             final Offset itemPosition = itemBox.localToGlobal(Offset.zero);
//             final Size size = itemBox.size;
//
//             showMenu(
//                 context: context,
//                 menuPadding: EdgeInsets.zero,
//                 elevation: 0,
//                 color: Colors.transparent,
//                 position: RelativeRect.fromLTRB(
//                   itemPosition.dx + size.width / 2,
//                   itemPosition.dy + size.height / 2,
//                   itemPosition.dx + size.width / 2,
//                   itemPosition.dy + size.height / 2,
//                 ),
//                 items: [
//                   PopupMenuItem(
//                     value: 0,
//                     padding: EdgeInsets.zero,
//                     enabled: false,
//                     child: widget.popupDialog,
//                   ),
//                 ]
//             );
//           }
//         },
//         child: widget.content,
//       )
//     );
//   }
// }

import 'package:flutter/material.dart';

class PopupWidget extends StatefulWidget {
  final Widget content;
  final Widget? popupDialog;
  final double horizontalPadding;
  final double verticalPadding;

  const PopupWidget({
    super.key,
    required this.content,
    this.popupDialog,
    this.horizontalPadding = 0,
    this.verticalPadding = 0,
  });

  @override
  State<PopupWidget> createState() => _PopupWidgetState();
}

class _PopupWidgetState extends State<PopupWidget> {
  final GlobalKey _itemKey = GlobalKey();

  void _showCustomPopup() {
    if (widget.popupDialog == null) return;

    final RenderBox itemBox =
    _itemKey.currentContext!.findRenderObject() as RenderBox;
    final Offset itemPosition = itemBox.localToGlobal(Offset.zero);
    final Size itemSize = itemBox.size;

    showGeneralDialog(
      context: context,
      barrierLabel: 'Popup',
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            // Dismiss by tapping outside
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.transparent),
            ),
            Positioned(
              left: itemPosition.dx + 8,
              top: itemPosition.dy + itemSize.height * 0.9,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                color: Colors.transparent,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 10,
                    maxWidth: 400,
                  ),
                  child: widget.popupDialog,
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // Optional fade/scale animation
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _itemKey,
      padding: EdgeInsets.symmetric(
        horizontal: widget.horizontalPadding,
        vertical: widget.verticalPadding,
      ),
      child: GestureDetector(
        onLongPress: _showCustomPopup,
        child: widget.content,
      ),
    );
  }
}
