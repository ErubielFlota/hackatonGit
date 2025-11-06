import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:prueba2app/profile_page.dart';
import '/home_page_content.dart'; 
import '/categories_page.dart';
import 'formulario_quejas_sugerencias.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  // esto lo uso para controlar que pagina esta actualmente
  late PageController _pageController; 

  // mis paginas
  final List<Widget> screens = [
    const PrincipalPage(),
    const CategoriesPage(),
    const FormularioQuejasSugerenciasPage(),
    const ProfilePage(),
  ];


  final List<Color> colors = const [
    Colors.lightBlueAccent,
    Colors.lightBlueAccent,
    Colors.lightBlueAccent,
    Colors.lightBlueAccent
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

  // esto sirve para cambiar pagina cuando se da click
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
      
      
      body: PageView(
        controller: _pageController,
        
        physics: const NeverScrollableScrollPhysics(), 
        children: screens, 
        onPageChanged: (index) {
          
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      
      bottomNavigationBar: Container(
        color: navBarBackgroundColor, 
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0), 
          child: GNav(
            backgroundColor: navBarBackgroundColor,
            color: Colors.black54, 
            tabBackgroundColor: colors[_currentIndex],
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
                icon: Icons.category,
                text: 'Categorias',
                iconActiveColor: Colors.white,
                textColor: Colors.white,
              ),
              GButton(
                icon: Icons.comment,
                text: ' Quejas',
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