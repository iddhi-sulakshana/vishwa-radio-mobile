import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_drawer.dart';

/// Whether the nav drawer is currently drawn over the page.
///
/// Only matters to screens hosting an Android platform view. The drawer is
/// ordinary Flutter widgets painted after the page, which is enough for
/// everything Flutter draws itself — but a platform view (the YouTube
/// WebView) is composited by Android and paints straight over the drawer.
/// Those screens watch this and take the view off stage while it's open.
class DrawerVisibility extends InheritedNotifier<ValueNotifier<bool>> {
  const DrawerVisibility({
    super.key,
    required ValueNotifier<bool> isOpen,
    required super.child,
  }) : super(notifier: isOpen);

  /// Defaults to false so a screen used outside [AppScaffold] still builds.
  static bool isOpenOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<DrawerVisibility>()
          ?.notifier
          ?.value ??
      false;
}

/// Shared page shell: renders [builder]'s screen content and overlays the
/// slide-in nav drawer (backdrop + panel) on top, so every screen can open
/// the same drawer from its hamburger button.
class AppScaffold extends StatefulWidget {
  final Widget Function(BuildContext context, VoidCallback openDrawer) builder;
  final String activeLabel;
  final void Function(String label) onSelect;

  const AppScaffold({
    super.key,
    required this.builder,
    required this.activeLabel,
    required this.onSelect,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;

  /// Separate from the controller so the page content rebuilds twice per
  /// open/close rather than on every animation frame.
  final _drawerOpen = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
    _slide = Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic),
    );
    _controller.addListener(_syncDrawerOpen);
  }

  /// Open the instant the drawer starts sliding in, and not closed again
  /// until it is fully gone — anything painted over must stay hidden for the
  /// whole animation, not just once it settles.
  void _syncDrawerOpen() {
    final open = _controller.value > 0;
    if (_drawerOpen.value != open) _drawerOpen.value = open;
  }

  void _open() => _controller.forward();
  void _close() => _controller.reverse();

  @override
  void dispose() {
    _controller.removeListener(_syncDrawerOpen);
    _controller.dispose();
    _drawerOpen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          DrawerVisibility(
            isOpen: _drawerOpen,
            child: widget.builder(context, _open),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              if (_controller.value == 0) return const SizedBox.shrink();
              return Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _close,
                      child: Container(color: Colors.black.withValues(alpha: 0.6 * _controller.value)),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    child: SlideTransition(
                      position: _slide,
                      child: AppDrawerPanel(
                        activeLabel: widget.activeLabel,
                        onSelect: (label) {
                          _close();
                          widget.onSelect(label);
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
