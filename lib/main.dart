import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'chat_screen.dart';
import 'document_screen.dart';
import 'theme.dart';
import 'widgets/dashboard_screen.dart';
import 'widgets/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Dijital Katip',
        theme: AppTheme.lightTheme,
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
          return _buildWideLayout();
        } else {
          return _buildNarrowLayout();
        }
      },
    );
  }

  Widget _buildWideLayout() {
    return Scaffold(
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return Row(
            children: [
              const Expanded(
                flex: 2,
                child: ChatScreen(),
              ),
              const VerticalDivider(width: 1, thickness: 1),
              Expanded(
                flex: 3,
                child: DocumentScreen(document: appState.document),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNarrowLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dijital Katip'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              text: '1. Sohbet',
              icon: Icon(Icons.chat_bubble_outline),
            ),
            Tab(
              text: '2. Belge / PDF',
              icon: Icon(Icons.description_outlined),
            ),
          ],
        ),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              const ChatScreen(),
              DocumentScreen(document: appState.document),
            ],
          );
        },
      ),
    );
  }
}
