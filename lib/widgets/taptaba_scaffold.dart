import 'package:flutter/material.dart';
import 'taptaba_drawer.dart';
import 'taptaba_bell.dart';

class TaptabaScaffold extends StatefulWidget {
  final Widget body;
  final String title;
  final Color appBarColor;
  final Color? titleColor;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final String? overrideRole;
  final bool extendBodyBehindAppBar;
  final bool transparentAppBar;
  final bool hideAppBar;

  const TaptabaScaffold({
    super.key,
    required this.body,
    this.title = 'طبطبـة',
    this.appBarColor = Colors.transparent,
    this.titleColor,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.overrideRole,
    this.extendBodyBehindAppBar = false,
    this.transparentAppBar = false,
    this.hideAppBar = false,
  });

  @override
  State<TaptabaScaffold> createState() => _TaptabaScaffoldState();
}

class _TaptabaScaffoldState extends State<TaptabaScaffold>
    with SingleTickerProviderStateMixin {
  late AnimationController _drawerController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    if (_drawerController.isCompleted) {
      _drawerController.reverse();
      _scaffoldKey.currentState?.closeDrawer();
    } else {
      _drawerController.forward();
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: TaptabaDrawer(overrideRole: widget.overrideRole),
      appBar: widget.hideAppBar ? null : AppBar(
        backgroundColor: widget.transparentAppBar ? Colors.transparent : Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF64748b)),
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Color(0xFF64748b)),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          'طبطبـة',
          style: TextStyle(
            color: widget.titleColor ?? const Color(0xFF6C63FF),
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        actions: widget.actions ??
            [
              const TaptabaBell(),
              const SizedBox(width: 8),
            ],
      ),
      body: widget.body,
      bottomNavigationBar: widget.bottomNavigationBar,
      floatingActionButton: widget.floatingActionButton,
    );
  }
}
