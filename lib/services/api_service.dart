import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.10.43.57:3000';

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
}