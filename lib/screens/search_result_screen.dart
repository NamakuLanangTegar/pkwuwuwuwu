import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vtr/core/app_theme.dart';
import 'package:vtr/screens/booking_detail_screen.dart';
import 'package:vtr/services/api_service.dart';

class SearchResultScreen extends StatefulWidget {
  final String asal;
  final String tujuan;
  final String tanggal;

  const SearchResultScreen({
    super.key,
    required this.asal,
    required this.tujuan,
    required this.tanggal,
  });

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _allResults = [];
  List<dynamic> _filteredResults = [];
  bool _isLoading = true;
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    final result = await _apiService.getTravelList();
    if (mounted) {
      setState(() {
        if (result['status'] == 'success') {
          _allResults = result['data'];
          _applyFilter();
        }
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    setState(() {
      if (_selectedCategory == 'Semua') {
        _filteredResults = List.from(_allResults);
      } else {
        _filteredResults = _allResults
            .where((item) => item['kategori'] == _selectedCategory)
            .toList();
      }
    });
  }

  void _selectCategory(String category) {
    _selectedCategory = category;
    _applyFilter();
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
        title: Column(
          children: [
            Text(
              'Pemesanan',
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              '${widget.asal} - ${widget.tujuan}',
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
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('Semua', _selectedCategory == 'Semua'),
                  const SizedBox(width: 10),
                  _filterChip('Bis', _selectedCategory == 'Bis'),
                  const SizedBox(width: 10),
                  _filterChip('Travel', _selectedCategory == 'Travel'),
                  const SizedBox(width: 10),
                  _filterChip('Rental', _selectedCategory == 'Rental'),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  )
                : _filteredResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada jadwal tersedia',
                              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadResults,
                        color: AppTheme.primaryColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          physics: const BouncingScrollPhysics(),
                          itemCount: _filteredResults.length,
                          itemBuilder: (context, index) {
                            return _buildResultCard(context, _filteredResults[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectCategory(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          border: Border.all(color: AppTheme.primaryColor),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.white : AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTeal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getCategoryIcon(item['kategori'] ?? 'Bis'), color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['nama_pu'] ?? '', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(item['tipe'] ?? '', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(item['harga_formatted'] ?? '', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 16)),
                    Text('/ Kursi', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),
            // Rating & Sisa Kursi
            Row(
              children: [
                Icon(Icons.star_rounded, color: Colors.amber.shade700, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${item['rating'] ?? 0}',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(width: 15),
                Icon(Icons.event_seat_rounded, color: Colors.grey.shade500, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${item['sisa_kursi'] ?? 0} kursi tersisa',
                  style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTeal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item['kategori'] ?? '',
                    style: GoogleFonts.outfit(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _timeInfo(item['berangkat'] ?? '', item['asal'] ?? ''),
                const Icon(Icons.arrow_forward_rounded, color: AppTheme.primaryColor, size: 20),
                _timeInfo(item['sampai'] ?? '', item['tujuan'] ?? ''),
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
                child: Text(
                  item['kategori'] == 'Rental' ? 'Pesan Rental' : 'Pesan Tiket',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
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
