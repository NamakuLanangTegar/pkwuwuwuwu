import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vtr/core/app_theme.dart';
import 'package:vtr/screens/welcome_screen.dart';
import 'package:vtr/services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final result = await _apiService.getUserProfile();
    if (mounted) {
      setState(() {
        if (result['status'] == 'success' && result['data'] != null) {
          _profile = result['data'];
        }
        _isLoading = false;
      });
    }
  }

  void _showEditProfileDialog() {
    if (_profile == null) return;

    final namaController = TextEditingController(text: _profile!['nama_lengkap'] ?? '');
    final telpController = TextEditingController(text: _profile!['no_telp'] ?? '');
    final emailController = TextEditingController(text: _profile!['email'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 25,
                right: 25,
                top: 25,
                bottom: MediaQuery.of(context).viewInsets.bottom + 25,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Edit Profil',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 25),
                    _editField('Nama Lengkap', namaController, Icons.person_outline_rounded),
                    const SizedBox(height: 15),
                    _editField('Nomor Telepon', telpController, Icons.phone_android_rounded),
                    const SizedBox(height: 15),
                    _editField('Email', emailController, Icons.email_outlined),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              setModalState(() => isSaving = true);

                              final result = await _apiService.updateUserProfile(
                                namaLengkap: namaController.text,
                                noTelp: telpController.text,
                                email: emailController.text,
                              );

                              setModalState(() => isSaving = false);

                              if (result['status'] == 'success') {
                                if (mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(result['message'] ?? 'Profil diperbarui!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  _loadProfile(); // Reload profile data
                                }
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(result['message'] ?? 'Gagal memperbarui profil'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                      child: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Simpan Perubahan'),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _editField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: GoogleFonts.outfit(),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 20),
            hintText: 'Masukkan $label',
          ),
        ),
      ],
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Keluar', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun?',
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.outfit(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(100, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Keluar', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Akun Saya',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : RefreshIndicator(
              onRefresh: _loadProfile,
              color: AppTheme.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    // Profile Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    _profile?['foto_profil'] ??
                                        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_profile?['nama_lengkap'] ?? 'User')}',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _profile?['nama_lengkap'] ?? 'Nama User',
                                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                                  ),
                                  Text(
                                    _profile?['username'] ?? '',
                                    style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.8), fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _profile?['email'] ?? '',
                                    style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.7), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.stars_rounded, color: Colors.amber, size: 18),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${_profile?['poin'] ?? 0}',
                                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Menu Sections
                    _buildMenuSection('Informasi Pembayaran', [
                      _menuItem(Icons.account_balance_wallet_outlined, 'Saldo Saya', () {}),
                      _menuItem(Icons.history_rounded, 'Riwayat Transaksi', () {}),
                      _menuItem(Icons.discount_outlined, 'Voucher', () {}),
                    ]),

                    _buildMenuSection('Kelola Akun', [
                      _menuItem(Icons.person_outline_rounded, 'Data Pribadi', _showEditProfileDialog),
                      _menuItem(Icons.settings_outlined, 'Pengaturan Keamanan', () {}),
                    ]),

                    _buildMenuSection('Kelola Aplikasi', [
                      _menuItem(Icons.help_outline_rounded, 'Bantuan', () {}),
                      _menuItem(Icons.info_outline_rounded, 'Tentang Aplikasi', () {}),
                    ]),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          child: Text(
            title,
            style: GoogleFonts.outfit(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(label, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
    );
  }
}
