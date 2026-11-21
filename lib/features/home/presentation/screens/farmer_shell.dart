import 'package:flutter/material.dart';
import '../../../farms/presentation/screens/farms_list_screen.dart';
import '../../../irrigation/presentation/screens/irrigation_screen.dart';
import '../widgets/green_flow_bottom_nav.dart';
import 'farmer_home_content.dart';
import 'farmer_monitoring_screen.dart';
import 'farmer_more_hub_screen.dart';

/// Controller scope enabling child widgets to switch tabs on the persistent Farmer Shell.
class FarmerShellScope extends InheritedWidget {
  final int currentIndex;
  final void Function(int index) switchTab;

  const FarmerShellScope({
    super.key,
    required this.currentIndex,
    required this.switchTab,
    required super.child,
  });

  static FarmerShellScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FarmerShellScope>();
  }

  @override
  bool updateShouldNotify(FarmerShellScope oldWidget) {
    return currentIndex != oldWidget.currentIndex;
  }
}

/// Centralized Persistent Navigation Shell for Farm Owners.
/// Guarantees that the Green Flow bottom navigation bar is persistently visible
/// on every Farmer screen, including all secondary and nested detail pages.
class FarmerShell extends StatefulWidget {
  final int initialIndex;

  const FarmerShell({super.key, this.initialIndex = 0});

  static void switchTab(BuildContext context, int index) {
    final scope = context.findAncestorWidgetOfExactType<FarmerShellScope>();
    scope?.switchTab(index);
  }

  @override
  State<FarmerShell> createState() => _FarmerShellState();
}

class _FarmerShellState extends State<FarmerShell> {
  late int _currentIndex;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex) {
      // Pop nested stack to root of current tab
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Widget _buildTabNavigator(int index) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (routeSettings) {
        Widget rootWidget;
        switch (index) {
          case 0:
            rootWidget = const FarmerHomeContent();
            break;
          case 1:
            rootWidget = const FarmsListScreen();
            break;
          case 2:
            rootWidget = const FarmerMonitoringScreen();
            break;
          case 3:
            rootWidget = const IrrigationScreen();
            break;
          case 4:
          default:
            rootWidget = const FarmerMoreHubScreen();
            break;
        }

        return MaterialPageRoute(
          builder: (_) => rootWidget,
          settings: routeSettings,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final currentNav = _navigatorKeys[_currentIndex].currentState;
        if (currentNav != null && currentNav.canPop()) {
          currentNav.pop();
        } else if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        } else {
          // At home root: allow normal back exit
          final navigator = Navigator.of(context);
          if (navigator.canPop()) {
            navigator.pop();
          }
        }
      },
      child: FarmerShellScope(
        currentIndex: _currentIndex,
        switchTab: _onTabSelected,
        child: Scaffold(
          body: Stack(
            children: List.generate(5, (index) {
              return Offstage(
                offstage: _currentIndex != index,
                child: TickerMode(
                  enabled: _currentIndex == index,
                  child: _buildTabNavigator(index),
                ),
              );
            }),
          ),
          bottomNavigationBar: GreenFlowBottomNav(
            currentIndex: _currentIndex,
            onIndexChanged: _onTabSelected,
          ),
        ),
      ),
    );
  }
}
