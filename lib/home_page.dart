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

  final Color navBarBackgroundColor = Colors.grey[100]!;

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
    return Scaffold(
      body: Stack(
        children: [
          // --- Contenido principal (PageView) ---
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: screens,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),

          // --- Chatbot flotante ---
          const ChatbotFloating(),
        ],
      ),

      // --- Barra de navegación inferior ---
      bottomNavigationBar: Container(
        color: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: GNav(
            backgroundColor: primaryColor,
            color: Colors.black54,
            tabBackgroundColor: primaryColor.darker,
            selectedIndex: _currentIndex,
            tabBorderRadius: 50,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            onTabChange: _onTabChange,
            tabs: const [
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
    );
  }
}
