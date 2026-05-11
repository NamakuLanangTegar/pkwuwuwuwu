import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vtr/core/app_theme.dart';
import 'package:vtr/services/api_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final result = await _apiService.getOrderHistory();
    if (mounted) {
      setState(() {
        if (result['status'] == 'success' && result['data'] != null) {
          _orders = result['data'];
        }
        _isLoading = false;
      });
    }
  }

  List<dynamic> _getFilteredOrders(bool isActive) {
    return _orders.where((order) {
      if (isActive) {
        return order['status'] == 'Lunas';
      } else {
        return order['status'] == 'Batal';
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Pesanan',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
            unselectedLabelStyle: GoogleFonts.outfit(fontSize: 16),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'Aktif'),
              Tab(text: 'Batal'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
            : TabBarView(
                children: [
                  _buildOrderList(true),
                  _buildOrderList(false),
                ],
              ),
      ),
    );
  }

  Widget _buildOrderList(bool isActive) {
    final filtered = _getFilteredOrders(isActive);

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.receipt_long_rounded : Icons.cancel_rounded,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? 'Belum ada pesanan aktif' : 'Tidak ada pesanan yang dibatalkan',
              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: AppTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(filtered[index]);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    bool isActive = order['status'] == 'Lunas';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order['nama_pu'] ?? 'Unknown',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text(
                            order['booking_id'] ?? '',
                            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive ? AppTheme.primaryColor.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        order['status'] ?? '',
                        style: GoogleFonts.outfit(
                          color: isActive ? AppTheme.primaryColor : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRouteInfo(order['asal'] ?? '', '', order['tanggal'] ?? ''),
                    const Icon(Icons.arrow_forward_rounded, color: AppTheme.primaryColor),
                    _buildRouteInfo(order['tujuan'] ?? '', '', order['tanggal'] ?? ''),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                isActive
                    ? ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          minimumSize: const Size(120, 40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Lihat Tiket', style: TextStyle(fontSize: 14)),
                      )
                    : const SizedBox.shrink(),
                Text(
                  order['total_bayar'] ?? '',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteInfo(String city, String time, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(city, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
        if (time.isNotEmpty) Text(time, style: GoogleFonts.outfit(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
        Text(date, style: GoogleFonts.outfit(color: Colors.grey, fontSize: 10)),
      ],
    );
  }
}
