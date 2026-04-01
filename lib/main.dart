import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/anniversary_list_screen.dart';

void main() async {
  // [🚨 1] 비동기 바인딩 초기화 보장
  WidgetsFlutterBinding.ensureInitialized();

  // [🚨 2] 데이터 오염으로 인한 블랙스크린 방지를 위해 인스턴스만 미리 로드
  try {
    await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint('SharedPrefs 초기화 에러: $e');
  }

  runApp(const MyDDayApp());
}

class MyDDayApp extends StatelessWidget {
  const MyDDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    // [🚨 3] MaterialApp은 반드시 유효한 Scaffold를 자식으로 가져야 함
    return MaterialApp(
      title: 'D-Day App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.pink[200],
        scaffoldBackgroundColor: Colors.white,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR')],
      locale: const Locale('ko', 'KR'),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // [🚨 4] Scaffold 배경색을 흰색으로 강제하여 블랙스크린 차단
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: const [HomeScreen(), AnniversaryListScreen()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.pink[300],
        unselectedItemColor: Colors.grey[400],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.cake), label: '생일'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '기념일'),
        ],
      ),
    );
  }
}
