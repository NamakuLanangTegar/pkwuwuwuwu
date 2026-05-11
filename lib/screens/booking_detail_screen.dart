import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vtr/core/app_theme.dart';
import 'package:vtr/screens/seat_selection_screen.dart';
import 'package:vtr/services/api_service.dart';

class BookingDetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  const BookingDetailScreen({super.key, required this.item});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final ApiService _apiService = ApiService();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _telpController = TextEditingController();
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final result = await _apiService.getUserProfile();
    if (mounted) {
      setState(() {
        if (result['status'] == 'success' && result['data'] != null) {
          final profile = result['data'];
          _namaController.text = profile['nama_lengkap'] ?? '';
          _emailController.text = profile['email'] ?? '';
          _telpController.text = profile['no_telp'] ?? '';
        }
        _isLoadingProfile = false;
      });
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _telpController.dispose();
    super.dispose();
  }

  void _proceedToSeatSelection() {
    if (_namaController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _telpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field harus diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeatSelectionScreen(
          item: widget.item,
          passengerName: _namaController.text,
          passengerEmail: _emailController.text,
          passengerPhone: _telpController.text,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String kategori) {
    switch (kategori) {
      case 'Bis':
        return Icons.directions_bus_rounded;
      case 'Travel':
        return Icons.airport_shuttle_rounded;
      case 'Rental':
        return Icons.car_rental_rounded;
      default:
        return Icons.directions_bus_rounded;
    }
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
          'Pemesanan',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected Trip Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.lightTeal.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(widget.item['kategori'] ?? ''),
                        color: AppTheme.primaryColor,
                        size: 30,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item['nama_pu'] ?? '',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              widget.item['tipe'] ?? '',
                              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        widget.item['harga_formatted'] ?? '',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item['asal'] ?? '',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            widget.item['berangkat'] ?? '',
                            style: GoogleFonts.outfit(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_rounded, color: AppTheme.primaryColor),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.item['tujuan'] ?? '',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            widget.item['sampai'] ?? '',
                            style: GoogleFonts.outfit(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: Colors.amber.shade700, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.item['rating'] ?? 0}',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.event_seat_rounded, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.item['sisa_kursi'] ?? 0} kursi tersisa',
                        style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Informasi Penumpang',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Data diisi otomatis dari profil Anda',
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _isLoadingProfile
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: CircularProgressIndicator(color: AppTheme.primaryColor),
                    ),
                  )
                : Column(
                    children: [
                      _inputField('Nama Lengkap', _namaController, Icons.person_outline_rounded),
                      const SizedBox(height: 15),
                      _inputField('Email', _emailController, Icons.email_outlined),
                      const SizedBox(height: 15),
                      _inputField('Nomor Telepon', _telpController, Icons.phone_android_rounded),
                    ],
                  ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _proceedToSeatSelection,
              child: const Text('Lanjut Pilih Kursi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: GoogleFonts.outfit(),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.primaryColor),
            hintText: 'Masukkan $label',
          ),
        ),
      ],
    );
  }
}
