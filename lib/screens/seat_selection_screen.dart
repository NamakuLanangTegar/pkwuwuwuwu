import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vtr/core/app_theme.dart';
import 'package:vtr/screens/ticket_detail_screen.dart';
import 'package:vtr/services/api_service.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final String passengerName;
  final String passengerEmail;
  final String passengerPhone;

  const SeatSelectionScreen({
    super.key,
    required this.item,
    this.passengerName = '',
    this.passengerEmail = '',
    this.passengerPhone = '',
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final ApiService _apiService = ApiService();
  String? _selectedSeat;
  List<dynamic> _seats = [];
  bool _isLoading = true;
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    _loadSeats();
  }

  Future<void> _loadSeats() async {
    final result = await _apiService.getTravelSeats(travelId: widget.item['id']);
    if (mounted) {
      setState(() {
        if (result['status'] == 'success' && result['data'] != null) {
          _seats = result['data']['seats'] ?? [];
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmBooking() async {
    if (_selectedSeat == null) return;

    setState(() => _isBooking = true);

    final result = await _apiService.createBooking(
      travelId: widget.item['id'] ?? 0,
      nomorKursi: _selectedSeat!,
      namaPenumpang: widget.passengerName,
      email: widget.passengerEmail,
      noTelp: widget.passengerPhone,
    );

    setState(() => _isBooking = false);

    if (result['status'] == 'success') {
      final bookingData = result['data'];
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TicketDetailScreen(
              item: widget.item,
              seatNo: _selectedSeat!,
              bookingId: bookingData?['booking_id'] ?? 'VTR-000000',
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal memproses pemesanan'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          'Pilih Kursi',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : Column(
              children: [
                const SizedBox(height: 20),
                // Trip Summary
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTeal.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_bus_rounded, color: AppTheme.primaryColor, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item['nama_pu'] ?? '',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              '${widget.item['asal']} → ${widget.item['tujuan']}',
                              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        widget.item['harga_formatted'] ?? '',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Legend
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _legendItem('Tersedia', Colors.grey.shade200),
                      _legendItem('Terisi', AppTheme.primaryColor.withOpacity(0.3)),
                      _legendItem('Dipilih', AppTheme.primaryColor),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                // Seat Layout from API
                Expanded(
                  child: _seats.isEmpty
                      ? Center(
                          child: Text(
                            'Data kursi tidak tersedia',
                            style: GoogleFonts.outfit(color: Colors.grey),
                          ),
                        )
                      : _buildSeatGrid(),
                ),
                // Bottom Bar
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -10)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Kursi Dipilih:', style: GoogleFonts.outfit(fontSize: 16)),
                          Text(
                            _selectedSeat ?? '-',
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Bayar:', style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey)),
                          Text(
                            widget.item['harga_formatted'] ?? '-',
                            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _selectedSeat == null || _isBooking ? null : _confirmBooking,
                        child: _isBooking
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Konfirmasi Pemesanan'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSeatGrid() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Driver icon at top
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.airline_seat_recline_normal_rounded, color: Colors.grey.shade500, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Seats from API
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: _seats.length,
              itemBuilder: (context, index) {
                final seat = _seats[index];
                String seatNo = seat['no'] ?? '';
                bool isTaken = seat['status'] == 'taken';
                bool isSelected = _selectedSeat == seatNo;

                return GestureDetector(
                  onTap: isTaken ? null : () => setState(() {
                    _selectedSeat = _selectedSeat == seatNo ? null : seatNo;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : (isTaken ? AppTheme.primaryColor.withOpacity(0.3) : Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isSelected
                          ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        seatNo,
                        style: GoogleFonts.outfit(
                          color: isSelected || isTaken ? Colors.white : Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 15, height: 15, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
