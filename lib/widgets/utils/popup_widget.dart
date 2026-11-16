import 'package:flutter/material.dart';

class PopupWidget extends StatefulWidget {
  final Widget content;
  final Widget? popupDialog;
  final double horizontalPadding;
  final double verticalPadding;
  final Color barrierColor;

  const PopupWidget({
    super.key,
    required this.content,
    this.popupDialog,
    this.horizontalPadding = 0,
    this.verticalPadding = 0,
    this.barrierColor = Colors.transparent,
  });

  @override
  State<PopupWidget> createState() => _PopupWidgetState();
}

class _PopupWidgetState extends State<PopupWidget> {
  final GlobalKey _itemKey = GlobalKey();

  void _showCustomPopup() {
    if (widget.popupDialog == null) return;

    final RenderBox itemBox = _itemKey.currentContext!.findRenderObject() as RenderBox;
    final Offset itemPosition = itemBox.localToGlobal(Offset.zero);
    final Size itemSize = itemBox.size;

    showGeneralDialog(
      context: context,
      barrierLabel: 'Popup',
      barrierDismissible: true,
      barrierColor: widget.barrierColor,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        final screenSize = MediaQuery.of(context).size;
        
        // Calculate if we should show above or below to avoid clipping
        // We assume a max height of about 300px for safety check
        final bool showAbove = (itemPosition.dy + itemSize.height + 250) > screenSize.height;

        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.transparent),
            ),
            Positioned(
              left: itemPosition.dx + 8,
              // If showing above, align bottom of popup to top of item
              top: showAbove ? null : itemPosition.dy + itemSize.height * 0.8,
              bottom: showAbove ? screenSize.height - itemPosition.dy + 8 : null,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: Colors.transparent,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 10,
                    maxWidth: 420,
                    // "Extend" vertically up to 50% of screen height before scrolling
                    maxHeight: screenSize.height * 0.5,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor.withValues(alpha: 0.98),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    // Use SingleChildScrollView to allow the text to "extend" without clipping
                    child: SingleChildScrollView(
                      padding: EdgeInsets.zero,
                      child: widget.popupDialog,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
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
        onTap: _showCustomPopup,
        child: widget.content,
      ),
    );
  }
}
