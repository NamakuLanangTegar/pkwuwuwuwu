import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vtr/core/app_theme.dart';
import 'package:vtr/screens/booking_detail_screen.dart';

class SearchResultScreen extends StatelessWidget {
  final String asal;
  final String tujuan;
  final String tanggal;

  const SearchResultScreen({
    super.key,
    required this.asal,
    required this.tujuan,
    required this.tanggal,
  });

  // Static dummy data – no API call needed
  static final List<Map<String, dynamic>> _staticResults = [
    {
      'id': 1,
      'kategori': 'Bis',
      'nama_pu': '27 Trans',
      'tipe': 'President Class',
      'image': 'https://blue.kumparan.com/image/upload/v1634025431/bus-27-trans.jpg',
      'asal': 'Malang',
      'tujuan': 'Jakarta',
      'berangkat': '18:30',
      'sampai': '06:00',
      'harga': 380000,
      'harga_formatted': 'Rp 380.000',
      'rating': 4.9,
      'sisa_kursi': 4,
    },
    {
      'id': 2,
      'kategori': 'Travel',
      'nama_pu': 'M-Trans',
      'tipe': 'Hiace Luxury',
      'image': 'https://example.com/mtrans.jpg',
      'asal': 'Malang',
      'tujuan': 'Kediri',
      'berangkat': '07:00',
      'sampai': '09:30',
      'harga': 85000,
      'harga_formatted': 'Rp 85.000',
      'rating': 4.7,
      'sisa_kursi': 8,
    },
    {
      'id': 3,
      'kategori': 'Rental',
      'nama_pu': 'Arbi Rental',
      'tipe': 'Innova Reborn',
      'image': 'https://example.com/innova.jpg',
      'asal': 'Yogyakarta',
      'tujuan': 'Sleman',
      'berangkat': '08:00',
      'sampai': '20:00',
      'harga': 650000,
      'harga_formatted': 'Rp 650.000',
      'rating': 4.8,
      'sisa_kursi': 1,
    },
    {
      'id': 4,
      'kategori': 'Bis',
      'nama_pu': 'Juragan 99',
      'tipe': 'Premium Class',
      'image': '',
      'asal': 'Surabaya',
      'tujuan': 'Jakarta',
      'berangkat': '19:00',
      'sampai': '07:00',
      'harga': 420000,
      'harga_formatted': 'Rp 420.000',
      'rating': 4.8,
      'sisa_kursi': 6,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Pemesanan',
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              '$asal - $tujuan',
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _filterChip('Ekonomi', true),
                const SizedBox(width: 10),
                _filterChip('Bisnis', false),
                const SizedBox(width: 10),
                _filterChip('Eksekutif', false),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: _staticResults.length,
              itemBuilder: (context, index) {
                return _buildResultCard(context, _staticResults[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor : Colors.white,
        border: Border.all(color: AppTheme.primaryColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          color: isSelected ? Colors.white : AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTeal,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.directions_bus_rounded, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['nama_pu'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(item['tipe'], style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(item['harga_formatted'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 16)),
                    Text('/ Kursi', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _timeInfo(item['berangkat'], item['asal']),
                const Icon(Icons.arrow_forward_rounded, color: AppTheme.primaryColor, size: 20),
                _timeInfo(item['sampai'], item['tujuan']),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingDetailScreen(item: item),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Pesan Tiket'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeInfo(String time, String city) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(time, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(city, style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
