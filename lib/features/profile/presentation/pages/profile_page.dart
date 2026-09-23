import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shimmer/shimmer.dart'; // <-- Pastikan import shimmer

import '../../../../main.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfile());
  }

  Future<void> _uploadFotoProfil(String userId) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final bytes = await image.readAsBytes();
    final fileExt = image.path.split('.').last;

    if (mounted) {
      context.read<ProfileBloc>().add(UploadAvatar(userId, fileExt, bytes));
    }
  }

  void _editAlamat(String alamatSekarang) {
    final TextEditingController alamatController = TextEditingController(
        text: alamatSekarang == 'Belum diatur' ? '' : alamatSekarang
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
              'Edit Alamat Pengiriman',
              style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)
          ),
          content: TextField(
            controller: alamatController,
            maxLines: 3,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Alamat Lengkap',
              labelStyle: const TextStyle(color: Colors.grey),
              hintText: 'Contoh: Jl. Jenderal Sudirman No. 123, Palembang',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.primaryColor, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final newAddress = alamatController.text.trim();
                if (newAddress.isNotEmpty) {
                  Navigator.pop(dialogContext);
                  context.read<ProfileBloc>().add(UpdateAddress(newAddress));
                }
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // FUNGSI BARU: Efek Shimmer Khusus Profil
  // ==========================================
  Widget _buildShimmerProfile(bool isDark) {
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Shimmer Kartu Profil
          Container(
            height: 100,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(width: 60, height: 60, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 150, height: 16, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 100, height: 12, color: Colors.white),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Shimmer Label
          Container(width: 120, height: 14, color: Colors.white, margin: const EdgeInsets.only(right: 200)),
          const SizedBox(height: 16),
          // Shimmer List Tile
          Container(height: 40, color: Colors.white),
          const SizedBox(height: 32),
          Container(width: 120, height: 14, color: Colors.white, margin: const EdgeInsets.only(right: 200)),
          const SizedBox(height: 16),
          Container(height: 40, color: Colors.white),
          const SizedBox(height: 16),
          Container(height: 40, color: Colors.white),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark; // Deklarasi di atas agar bisa dipakai Shimmer

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Profil Saya', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {

          // Memanggil Shimmer saat loading
          if (state is ProfileLoading) {
            return _buildShimmerProfile(isDark);
          }

          if (state is ProfileLoaded) {
            final user = state.user;
            final userName = user.userMetadata?['full_name'] ?? 'Pengguna GearShift';
            final userEmail = user.email ?? 'pengguna@email.com';
            final avatarUrl = user.userMetadata?['avatar_url'];
            final userAddress = user.userMetadata?['address'] ?? 'Belum diatur';

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Info Pengguna (Kartu Atas)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.transparent, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _uploadFotoProfil(user.id),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: theme.primaryColor.withOpacity(0.2),
                              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                              child: avatarUrl == null ? Icon(Icons.person, size: 40, color: theme.primaryColor) : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: theme.primaryColor, shape: BoxShape.circle),
                                child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(userEmail, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // SECTION 1: Akun & Informasi
                const Text('Akun & Informasi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.location_on, color: theme.primaryColor),
                  title: Text('Alamat Pengiriman', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
                  subtitle: Text(userAddress, style: const TextStyle(color: Colors.grey)),
                  trailing: const Icon(Icons.edit, size: 18, color: Colors.grey),
                  onTap: () => _editAlamat(userAddress),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.two_wheeler_rounded, color: theme.primaryColor),
                  title: Text('Data Kendaraan', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Kelola data motor Anda', style: TextStyle(color: Colors.grey)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur Data Kendaraan segera hadir!')));
                  },
                ),

                const Divider(height: 32),

                // SECTION 2: Bantuan & Dukungan
                const Text('Bantuan & Dukungan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.help_outline_rounded, color: Colors.grey),
                  title: Text('Pusat Bantuan (FAQ)', style: TextStyle(color: theme.colorScheme.onSurface)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {},
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.article_outlined, color: Colors.grey),
                  title: Text('Syarat & Ketentuan', style: TextStyle(color: theme.colorScheme.onSurface)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {},
                ),

                const Divider(height: 32),

                // SECTION 3: Pengaturan
                const Text('Pengaturan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(theme.brightness == Brightness.dark ? Icons.dark_mode : Icons.light_mode, color: theme.colorScheme.onSurface),
                  title: Text('Mode Gelap', style: TextStyle(color: theme.colorScheme.onSurface)),
                  trailing: Switch(
                    value: theme.brightness == Brightness.dark,
                    onChanged: (bool isDark) {
                      themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
                      SharedPreferences.getInstance().then((prefs) {
                        prefs.setBool('is_dark_mode', isDark);
                      });
                    },
                    activeColor: theme.primaryColor,
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Keluar (Logout)', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  onTap: () async {
                    // Logika logout tetap sama
                    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
                    try {
                      await Supabase.instance.client.auth.signOut();
                      if (context.mounted) Navigator.pop(context);
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
                      }
                    } catch (e) {
                      if (context.mounted) Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal Logout: $e'), backgroundColor: Colors.red));
                    }
                  },
                ),

                const SizedBox(height: 40),

                // Watermark Versi Aplikasi di paling bawah
                Center(
                  child: Column(
                    children: [
                      Text('GearShift App', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Versi 1.0.0', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}