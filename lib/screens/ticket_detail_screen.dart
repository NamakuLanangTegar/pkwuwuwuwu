import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vtr/core/app_theme.dart';
import 'package:vtr/screens/main_navigation.dart';

class TicketDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;
  final String seatNo;

  const TicketDetailScreen({super.key, required this.item, required this.seatNo});

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
            const SizedBox(height: 20),
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
                                Text(item['nama_pu'], style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                                Text(item['tipe'], style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
                              ],
                            ),
                            const Icon(Icons.directions_bus_rounded, color: Colors.white, size: 30),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _routeInfo(item['asal'], item['berangkat'], 'Asal'),
                            const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                            _routeInfo(item['tujuan'], item['sampai'], 'Tujuan'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Ticket Perforation (Mockup)
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
                            _ticketDetail('Nomor Kursi', seatNo),
                            _ticketDetail('Booking ID', 'VTR-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'),
                          ],
                        ),
                        const SizedBox(height: 30),
                        // QR Code Mockup
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Image.network(
                                'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=VATERO_TICKET_${item['id']}_$seatNo',
                                width: 150,
                                height: 150,
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
            const SizedBox(height: 40),
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
