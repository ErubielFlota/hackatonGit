import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:prueba2app/profile_page.dart';
import '/home_page_content.dart';
import '/categories_page.dart';
import 'formulario_quejas_sugerencias.dart';
import '../theme/colors.dart';

//  Importacion del chatbot
import 'widgets/chatbot_floating.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> screens = [
    const PrincipalPage(),
    const CategoriesPage(),
    const FormularioQuejasSugerenciasPage(),
    const ProfilePage(),
  ];

  final Color navBarBackgroundColor = backgroundColor;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final width = mq.size.width;

    final bool isWide = width > 900;

    final double navIconSize = isWide ? 30 : 22;
    final double navTextSize = isWide ? 16 : 12;
    final EdgeInsets navPadding = isWide
        ? const EdgeInsets.symmetric(vertical: 18, horizontal: 26)
        : const EdgeInsets.symmetric(vertical: 14, horizontal: 18);

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: screens,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
          ),

          // Chatbot flotante
          const ChatbotFloating(),
        ],
      ),

      // -----------------------------
      // 🔻 Barra de navegación responsiva
      // -----------------------------
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Container(
          color: primaryColor,
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 30 : 10,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isWide ? 14 : 10,
            ),
            child: GNav(
              backgroundColor: primaryColor,
              color: Colors.black54,
              iconSize: navIconSize,
              textStyle: TextStyle(
                fontSize: navTextSize,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              tabBackgroundColor: primaryColor.darker,
              selectedIndex: _currentIndex,
              tabBorderRadius: 50,
              padding: navPadding,
              gap: isWide ? 10 : 6,
              onTabChange: _onTabChange,
              tabs: [
                GButton(
                  icon: Icons.home,
                  text: 'Principal',
                  iconActiveColor: Colors.white,
                  textColor: Colors.white,
                ),
                GButton(
                  icon: Icons.window,
                  text: 'Categorías',
                  iconActiveColor: Colors.white,
                  textColor: Colors.white,
                ),
                GButton(
                  icon: Icons.comment,
                  text: 'Quejas',
                  iconActiveColor: Colors.white,
                  textColor: Colors.white,
                ),
                GButton(
                  icon: Icons.person,
                  text: 'Perfil',
                  iconActiveColor: Colors.white,
                  textColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
