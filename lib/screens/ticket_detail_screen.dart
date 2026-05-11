import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vtr/core/app_theme.dart';
import 'package:vtr/screens/main_navigation.dart';
import 'package:vtr/services/api_service.dart';

class TicketDetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final String seatNo;
  final String bookingId;

  const TicketDetailScreen({
    super.key,
    required this.item,
    required this.seatNo,
    this.bookingId = '',
  });

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _paymentMethods = [];
  int? _selectedPaymentId;
  bool _isLoadingPayment = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    final result = await _apiService.getPaymentMethods();
    if (mounted) {
      setState(() {
        if (result['status'] == 'success' && result['data'] != null) {
          _paymentMethods = result['data'];
        }
        _isLoadingPayment = false;
      });
    }
  }

  String get _displayBookingId {
    if (widget.bookingId.isNotEmpty) return widget.bookingId;
    return 'VTR-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
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
          'Detail Tiket',
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
          children: [
            // Success Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Pemesanan Berhasil!',
                    style: GoogleFonts.outfit(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            // Ticket Card
            Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.item['nama_pu'] ?? '', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                                Text(widget.item['tipe'] ?? '', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
                              ],
                            ),
                            const Icon(Icons.directions_bus_rounded, color: Colors.white, size: 30),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _routeInfo(widget.item['asal'] ?? '', widget.item['berangkat'] ?? '', 'Asal'),
                            const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                            _routeInfo(widget.item['tujuan'] ?? '', widget.item['sampai'] ?? '', 'Tujuan'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Ticket Perforation
                  Row(
                    children: List.generate(15, (index) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 2,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _ticketDetail('Nomor Kursi', widget.seatNo),
                            _ticketDetail('Booking ID', _displayBookingId),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _ticketDetail('Harga', widget.item['harga_formatted'] ?? '-'),
                            _ticketDetail('Status', 'Lunas'),
                          ],
                        ),
                        const SizedBox(height: 30),
                        // QR Code
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Image.network(
                                'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=VATERO_${_displayBookingId}_${widget.seatNo}',
                                width: 150,
                                height: 150,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.qr_code_2_rounded, size: 80, color: Colors.grey),
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Scan QR saat Check-in',
                                style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Payment Methods Section
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Metode Pembayaran',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              ),
            ),
            const SizedBox(height: 15),
            _isLoadingPayment
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  )
                : _paymentMethods.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Metode pembayaran tidak tersedia',
                          style: GoogleFonts.outfit(color: Colors.grey),
                        ),
                      )
                    : Column(
                        children: _paymentMethods.map((method) {
                          bool isSelected = _selectedPaymentId == method['id'];
                          return GestureDetector(
                            onTap: () => setState(() => _selectedPaymentId = method['id']),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.lightTeal : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppTheme.lightTeal,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.primaryColor, size: 20),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      method['nama'] ?? '',
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isSelected ? AppTheme.primaryColor : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor, size: 24),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainNavigation()),
                  (route) => false,
                );
              },
              child: const Text('Kembali ke Beranda'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _routeInfo(String city, String time, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11)),
        Text(city, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(time, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _ticketDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
        Text(value, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
