import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'chat_screen.dart';
import 'document_screen.dart';
import 'theme.dart';
import 'widgets/dashboard_screen.dart';
import 'widgets/profile_screen.dart';
import 'widgets/search_screen.dart';
import 'widgets/cases_screen.dart';

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

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        return _buildScaffold(isWide: isWide);
      },
    );
  }

  Widget _buildScaffold({required bool isWide}) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          'assets/logo_horizontal.png',
          height: 32,
          fit: BoxFit.contain,
        ),
      ),
      body: Consumer<AppState>(builder: (context, appState, child) {
        switch (_index) {
          case 0:
            return DashboardScreen(
              onStartChat: () => setState(() => _index = 1),
              onViewDocument: () => setState(() => _index = 2),
            );
          case 1:
            if (isWide) {
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
            }
            return const ChatScreen();
          case 2:
            return DocumentScreen(document: appState.document);
          case 3:
            return const SearchScreen();
          case 4:
            return const CasesScreen();
          case 5:
          default:
            return const ProfileScreen();
        }
      }),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.layoutDashboard), label: 'Başla'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.messagesSquare), label: 'Sohbet'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.fileText), label: 'Belgem'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.search), label: 'Emsal Bul'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.folder), label: 'Dosyalarım'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: 'Ben'),
        ],
      ),
    );
  }
}
