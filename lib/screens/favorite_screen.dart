import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vtr/core/app_theme.dart';
import 'package:vtr/screens/booking_detail_screen.dart';
import 'package:vtr/services/api_service.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _travelList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final result = await _apiService.getTravelList();
    if (mounted) {
      setState(() {
        if (result['status'] == 'success' && result['data'] != null) {
          // Show top-rated items as "favorites" (rating >= 4.7)
          _travelList = (result['data'] as List)
              .where((item) => (item['rating'] ?? 0) >= 4.7)
              .toList();
        }
        _isLoading = false;
      });
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
          'Favorit',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _travelList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border_rounded, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada favorit',
                        style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppTheme.primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _travelList.length,
                    itemBuilder: (context, index) {
                      return _buildFavoriteCard(_travelList[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> item) {
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
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.favorite_rounded, color: Colors.red, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['nama_pu'] ?? '',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        item['tipe'] ?? '',
                        style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTeal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, color: Colors.amber.shade700, size: 16),
                      const SizedBox(width: 3),
                      Text(
                        '${item['rating'] ?? 0}',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['asal'] ?? '', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(item['berangkat'] ?? '', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const Icon(Icons.arrow_forward_rounded, color: AppTheme.primaryColor),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(item['tujuan'] ?? '', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(item['sampai'] ?? '', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.event_seat_rounded, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  '${item['sisa_kursi'] ?? 0} kursi tersisa',
                  style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingDetailScreen(item: item),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    minimumSize: const Size(130, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    item['kategori'] == 'Rental' ? 'Pesan Rental' : 'Pesan Tiket',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  item['harga_formatted'] ?? '',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
