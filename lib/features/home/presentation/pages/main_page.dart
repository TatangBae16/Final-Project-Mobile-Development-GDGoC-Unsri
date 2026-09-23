import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Import halaman dan bloc bawaanmu ---
import '../../../order/data/repositories/order_repository_impl.dart';
import '../../../order/presentation/bloc/order_bloc.dart';
import '../../../order/presentation/pages/order_history_page.dart';
import '../../../product/presentation/pages/catalog_page.dart';
import '../../../profile/data/repositories/profile_repository_impl.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import 'package:md_midtermproject/features/profile/presentation/pages/profile_page.dart';

// --- Tambahkan Import Fitur AI Mekanik di sini ---
// (Sesuaikan path-nya jika folder ai_mechanic ada di tempat lain)
import '../../../ai_mechanic/data/repositories/ai_mechanic_repository.dart';
import '../../../ai_mechanic/presentation/bloc/ai_mechanic_bloc.dart';
import '../../../ai_mechanic/presentation/pages/ai_mechanic_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan
  final List<Widget> _pages = [
    const CatalogPage(),

    BlocProvider(
      create: (context) => OrderBloc(
        OrderRepositoryImpl(Supabase.instance.client),
      ),
      child: const OrderHistoryPage(),
    ),

    // Tab Ke-3: Mekanik AI (Disuntik dengan BlocProvider)
    BlocProvider(
      create: (context) => AiMechanicBloc(
        repository: AiMechanicRepository(),
      ),
      child: const AiMechanicPage(),
    ),

    BlocProvider(
      create: (context) => ProfileBloc(ProfileRepositoryImpl(Supabase.instance.client)),
      child: const ProfilePage(),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: theme.cardColor,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: theme.primaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed, // Penting agar >3 item tidak bergeser aneh
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront_rounded),
              label: 'Katalog',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'Riwayat',
            ),
            // Tambahan Icon untuk Mekanik AI
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_outlined), // Icon Robot
              activeIcon: Icon(Icons.smart_toy_rounded),
              label: 'Mekanik AI',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}