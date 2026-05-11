import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.10.43.57:3000';

  // ─── AUTH ─────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal terhubung ke server. Pastikan Mockoon aktif.',
      };
    }
  }

  Future<Map<String, dynamic>> register(String nama, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama': nama,
          'email': email,
          'password': password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal mendaftar akun.',
      };
    }
  }

  // ─── TRAVEL ───────────────────────────────────────────

  Future<Map<String, dynamic>> getTravelList() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/travel/list'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal memuat data perjalanan'};
    }
  }

  Future<Map<String, dynamic>> getDestinasiPopuler() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/destinasi/populer'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal memuat destinasi populer'};
    }
  }

  // ─── SEATS ────────────────────────────────────────────

  Future<Map<String, dynamic>> getTravelSeats({int? travelId}) async {
    try {
      String url = '$baseUrl/travel/seats';
      if (travelId != null) url += '?travel_id=$travelId';
      final response = await http.get(Uri.parse(url));
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal memuat data kursi'};
    }
  }

  // ─── BOOKING ──────────────────────────────────────────

  Future<Map<String, dynamic>> createBooking({
    required int travelId,
    required String nomorKursi,
    required String namaPenumpang,
    required String email,
    required String noTelp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pesanan/booking'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'travel_id': travelId,
          'nomor_kursi': nomorKursi,
          'nama_penumpang': namaPenumpang,
          'email': email,
          'no_telp': noTelp,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal memproses pemesanan'};
    }
  }

  // ─── ORDER HISTORY ────────────────────────────────────

  Future<Map<String, dynamic>> getOrderHistory() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pesanan/history'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal memuat riwayat pesanan'};
    }
  }

  // ─── PAYMENT METHODS ─────────────────────────────────

  Future<Map<String, dynamic>> getPaymentMethods() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/payment/methods'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal memuat metode pembayaran'};
    }
  }

  // ─── USER PROFILE ─────────────────────────────────────

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/user/profile'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal memuat profil pengguna'};
    }
  }

  Future<Map<String, dynamic>> updateUserProfile({
    required String namaLengkap,
    required String noTelp,
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama_lengkap': namaLengkap,
          'no_telp': noTelp,
          'email': email,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal memperbarui profil'};
    }
  }

  // ─── MESSAGES / NOTIFICATIONS ─────────────────────────

  Future<Map<String, dynamic>> getUserMessages() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/user/messages'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal memuat notifikasi'};
    }
  }
}