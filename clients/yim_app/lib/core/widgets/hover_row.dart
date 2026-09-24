// 列表行通用组件: hover/选中时显示圆角背景 (Fluent 式),
// 圆角两侧留出空隙, 避免通栏高亮的廉价感。
import 'package:flutter/material.dart';

class HoverRow extends StatefulWidget {
  final bool selected;
  final VoidCallback? onTap;
  final Widget child;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  const HoverRow(
      {super.key,
      this.selected = false,
      this.onTap,
      required this.child,
      this.margin = const EdgeInsets.symmetric(horizontal: 8),
      this.padding =
          const EdgeInsets.symmetric(horizontal: 10, vertical: 8)});
  @override
  State<HoverRow> createState() => _HoverRowState();
}

class _HoverRowState extends State<HoverRow> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = widget.selected
        ? theme.colorScheme.primary.withValues(alpha: 0.10)
        : _hover
            ? theme.hoverColor
            : null;
    return Padding(
      padding: widget.margin,
      child: MouseRegion(
        cursor: widget.onTap != null
            ? SystemMouseCursors.click
            : MouseCursor.defer,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
