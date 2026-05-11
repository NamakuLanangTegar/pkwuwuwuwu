import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vtr/core/app_theme.dart';
import 'package:vtr/screens/booking_detail_screen.dart';
import 'package:vtr/screens/search_result_screen.dart';
import 'package:vtr/services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  final _asalController = TextEditingController();
  final _tujuanController = TextEditingController();
  final _tanggalController = TextEditingController();
  
  List<dynamic> _travelList = [];
  List<dynamic> _destinasiPopuler = [];
  List<dynamic> _messages = [];
  int _unreadCount = 0;
  bool _isLoading = true;
  int _currentBannerIndex = 0;
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;

  final List<Map<String, String>> _banners = [
    {
      'image': 'https://blue.kumparan.com/image/upload/v1634025431/bus-27-trans.jpg',
      'title': 'SLEEPER DOUBLE DECKER\n27 TRANS',
    },
    {
      'image': 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?q=80&w=2069&auto=format&fit=crop',
      'title': 'NIKMATI PERJALANAN NYAMAN\nDENGAN ARMADA TERBAIK',
    },
  ];

  @override
  void initState() {
    super.initState();
    _asalController.text = 'Malang';
    _tujuanController.text = 'Jakarta';
    _tanggalController.text = '12 Mei 2024';
    _loadData();
    _startBannerTimer();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_bannerController.hasClients) {
        _currentBannerIndex = (_currentBannerIndex + 1) % _banners.length;
        _bannerController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _loadData() async {
    final travelRes = await _apiService.getTravelList();
    final destinasiRes = await _apiService.getDestinasiPopuler();
    final messagesRes = await _apiService.getUserMessages();

    if (mounted) {
      setState(() {
        if (travelRes['status'] == 'success') _travelList = travelRes['data'];
        if (destinasiRes['status'] == 'success') _destinasiPopuler = destinasiRes['data'];
        if (messagesRes['status'] == 'success' && messagesRes['data'] != null) {
          _messages = messagesRes['data'];
          _unreadCount = _messages.where((m) => m['is_read'] == false).length;
        }
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _asalController.dispose();
    _tujuanController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notifikasi',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    if (_unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$_unreadCount baru',
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada notifikasi',
                              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 15),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          bool isUnread = msg['is_read'] == false;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isUnread ? AppTheme.lightTeal.withOpacity(0.5) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isUnread ? AppTheme.primaryColor.withOpacity(0.3) : Colors.grey.shade200,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isUnread
                                        ? AppTheme.primaryColor.withOpacity(0.1)
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    isUnread ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                                    color: isUnread ? AppTheme.primaryColor : Colors.grey,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              msg['judul'] ?? '',
                                              style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: isUnread ? AppTheme.primaryColor : Colors.black87,
                                              ),
                                            ),
                                          ),
                                          if (isUnread)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        msg['isi'] ?? '',
                                        style: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 12),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        msg['waktu'] ?? '',
                                        style: GoogleFonts.outfit(color: Colors.grey, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMessagesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pesan',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded, size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada pesan masuk',
                        style: GoogleFonts.outfit(color: Colors.grey, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBannerCarousel(),
                      const SizedBox(height: 20),
                      _buildCategorySelector(),
                      const SizedBox(height: 25),
                      _buildSearchForm(),
                      const SizedBox(height: 30),
                      
                      // Destinasi Populer
                      _buildSectionHeader('Destinasi Populer'),
                      _isLoading 
                        ? const Center(child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(color: Colors.white),
                          ))
                        : _buildDestinasiList(),

                      const SizedBox(height: 30),

                      // Product Sections
                      _buildProductSection('Bis Populer', 'Bis'),
                      _buildProductSection('Travel Populer', 'Travel'),
                      _buildProductSection('Rental Populer', 'Rental'),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.primaryColor, size: 28),
                onPressed: _showNotificationsSheet,
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$_unreadCount',
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Text(
            'VaTeRo',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
              letterSpacing: 1.2,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.primaryColor, size: 24),
            onPressed: _showMessagesSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _bannerController,
        onPageChanged: (index) => setState(() => _currentBannerIndex = index),
        itemCount: _banners.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              image: DecorationImage(
                image: NetworkImage(_banners[index]['image']!),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  _banners[index]['title']!,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _categoryChip(Icons.directions_bus_rounded, 'Bis', true),
          _categoryChip(Icons.airport_shuttle_rounded, 'Travel', false),
          _categoryChip(Icons.car_rental_rounded, 'Rental', false),
        ],
      ),
    );
  }

  Widget _categoryChip(IconData icon, String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        border: Border.all(color: Colors.white.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? AppTheme.primaryColor : Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: isSelected ? AppTheme.primaryColor : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _searchField(Icons.location_on_outlined, 'Asal', _asalController),
          const SizedBox(height: 15),
          _searchField(Icons.location_searching_rounded, 'Tujuan', _tujuanController),
          const SizedBox(height: 15),
          _searchField(Icons.calendar_today_rounded, 'Tanggal', _tanggalController),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchResultScreen(
                    asal: _asalController.text,
                    tujuan: _tujuanController.text,
                    tanggal: _tanggalController.text,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Text('Cari', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _searchField(IconData icon, String hint, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTeal.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.outfit(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 20),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            'Lihat Semua',
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinasiList() {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 17),
        itemCount: _destinasiPopuler.length,
        itemBuilder: (context, index) {
          final dest = _destinasiPopuler[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: NetworkImage(dest['gambar']),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Center(
                child: Text(
                  dest['kota'],
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductSection(String title, String category) {
    final items = _travelList.where((i) => i['kategori'] == category).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 17),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildTravelCard(item);
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTravelCard(Map<String, dynamic> item) {
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite_border_rounded, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['nama_pu'],
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        item['tipe'],
                        style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Rating row
            Row(
              children: [
                Icon(Icons.star_rounded, color: Colors.amber.shade700, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${item['rating'] ?? 0}',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(width: 10),
                Icon(Icons.event_seat_rounded, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  '${item['sisa_kursi']} kursi',
                  style: GoogleFonts.outfit(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['asal'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Keberangkatan', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 11)),
                  ],
                ),
                const Icon(Icons.arrow_forward_rounded, size: 24, color: AppTheme.primaryColor),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(item['tujuan'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Kedatangan', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ],
            ),
            const Spacer(),
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
                    minimumSize: const Size(130, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    item['kategori'] == 'Rental' ? 'Pesan Rental' : 'Pesan Tiket',
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  item['harga_formatted'],
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
