import 'package:flutter/material.dart';

import '../themes/app_themes.dart';

abstract class _AppTaskBar extends StatelessWidget {
  final List<Widget> mainActions;
  final List<Widget> overflowActions;

  const _AppTaskBar({
    super.key,
    this.mainActions = const [],
    this.overflowActions = const [],
  });

  Widget _buildOverflowFAB(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: FloatingActionButton(
          onPressed: () => _showOverflowMenu(context),
          mini: true,
          elevation: 0,
          // Remove shadow
          hoverElevation: 0,
          focusElevation: 0,
          highlightElevation: 0,
          backgroundColor: Colors.transparent,
          // Transparent background
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          child: Icon(Icons.more_vert, size: 24.0)
        // Text(
        //   ':..',
        //   style: TextStyle(
        //     fontSize: 12,
        //     fontWeight: FontWeight.bold,
        //     color: isDark ? Colors.white70 : Colors.black87,
        //   ),
        // ),
      ),
    );
  }

  void _showOverflowMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    // Position menu to the right of the vertical bar
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(button.size.topRight(Offset.zero), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: overflowActions.map((action) {
        return PopupMenuItem(
          padding: EdgeInsets.zero,
          child: action,
        );
      }).toList(),
    );
  }
}

class AppVerticalTaskBar extends _AppTaskBar {
  const AppVerticalTaskBar({super.key, super.mainActions, super.overflowActions});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      decoration: BoxDecoration(
        color: AppTheme.of(context).barColor,
        border: Border(
          right: BorderSide(
              color: AppTheme.of(context).borderColor ?? Colors.transparent,
              width: 1),
        ),
      ),
      child:
      Column(
        children: [
          const SizedBox(height: 8),
          // Main visible actions
          ...mainActions.map((action) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: action,
              )),
          const Spacer(),
          // Overflow FAB if there are other actions
          if (overflowActions.isNotEmpty) _buildOverflowFAB(context),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class AppHorizontalTaskBar extends _AppTaskBar {
  const AppHorizontalTaskBar({super.key, super.mainActions, super.overflowActions});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.of(context).barColor,
        border: Border(
          right: BorderSide(
              color: AppTheme.of(context).borderColor ?? Colors.transparent,
              width: 1),
        ),
      ),
      child:
        Row(
        children: [
          const SizedBox(width: 8),
          // Main visible actions
          ...mainActions.map((action) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: action,
          )),
          const Spacer(),
          // Overflow FAB if there are other actions
          if (overflowActions.isNotEmpty) _buildOverflowFAB(context),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

