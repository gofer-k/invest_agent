import 'package:flutter/material.dart';

class AppVerticalTaskBar extends StatelessWidget {
  final List<Widget> mainActions;
  final List<Widget> overflowActions;

  const AppVerticalTaskBar({
    super.key,
    this.mainActions = const [],
    this.overflowActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color barColor = isDark ? const Color(0xFF3C3F41) : const Color(0xFFF2F2F2);
    final Color borderColor = isDark ? const Color(0xFF282828) : const Color(0xFFC9C9C9);

    return Container(
      width: 40,
      decoration: BoxDecoration(
        color: barColor,
        border: Border(
          right: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Column(
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

  Widget _buildOverflowFAB(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: FloatingActionButton(
        onPressed: () => _showOverflowMenu(context),
        mini: true,
        elevation: 0, // Remove shadow
        hoverElevation: 0,
        focusElevation: 0,
        highlightElevation: 0,
        backgroundColor: Colors.transparent, // Transparent background
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

/// A specialized button for the task bar that mimics Android Studio icons
class TaskBarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final String? tooltip;

  const TaskBarIcon({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? Colors.white70 : Colors.black87;

    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            size: 20,
            color: color ?? defaultColor,
          ),
        ),
      ),
    );
  }
}
