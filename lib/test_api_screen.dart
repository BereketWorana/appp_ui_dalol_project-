import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TestApiScreen extends StatefulWidget {
  const TestApiScreen({super.key});

  @override
  State<TestApiScreen> createState() => _TestApiScreenState();
}

class _TestApiScreenState extends State<TestApiScreen> {
  String _response = 'Press button to test API';
  bool _isLoading = false;
  String _selectedHotelId = '1';
  String _selectedDate = '2026-09-01';

  final List<String> hotelIds = ['1', '2', '3', '4', '5'];
  final List<String> dates = ['2026-09-01', '2026-09-10', '2026-10-01'];

  Future<void> _testApi() async {
    setState(() {
      _isLoading = true;
      _response = 'Testing API...';
    });

    try {
      // Build the URL
      final String url = 
          'https://booking.dalloltech.com/api/check-availability-by-hotel'
          '?hotel_id=$_selectedHotelId'
          '&check_in=$_selectedDate'
          '&check_out=2026-09-05'
          '&rooms=1';

      print('🔄 Testing URL: $url');

      // Try direct request
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📥 Status: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      setState(() {
        _isLoading = false;
        _response = '''
Status Code: ${response.statusCode}

Response:
${_formatJson(response.body)}
''';
      });
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        _isLoading = false;
        _response = 'Error: $e';
      });
    }
  }

  Future<void> _testApiWithCors() async {
    setState(() {
      _isLoading = true;
      _response = 'Testing API with CORS proxy...';
    });

    try {
      // Try with CORS proxy
      final String url = 
          'https://cors-anywhere.herokuapp.com/https://booking.dalloltech.com/api/check-availability-by-hotel'
          '?hotel_id=$_selectedHotelId'
          '&check_in=$_selectedDate'
          '&check_out=2026-09-05'
          '&rooms=1';

      print('🔄 Testing URL (with CORS): $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📥 Status: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      setState(() {
        _isLoading = false;
        _response = '''
Status Code: ${response.statusCode}

Response:
${_formatJson(response.body)}
''';
      });
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        _isLoading = false;
        _response = 'Error: $e';
      });
    }
  }

  String _formatJson(String json) {
    try {
      final decoded = jsonDecode(json);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      return json;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'API Test Screen',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel ID Selector
            const Text(
              'Hotel ID:',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: hotelIds.map((id) {
                return ChoiceChip(
                  label: Text(id),
                  selected: _selectedHotelId == id,
                  onSelected: (selected) {
                    setState(() {
                      _selectedHotelId = id;
                    });
                  },
                  selectedColor: Colors.blue,
                  backgroundColor: Colors.grey[800],
                  labelStyle: TextStyle(
                    color: _selectedHotelId == id ? Colors.white : Colors.white70,
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),

            // Date Selector
            const Text(
              'Check-in Date:',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: dates.map((date) {
                return ChoiceChip(
                  label: Text(date),
                  selected: _selectedDate == date,
                  onSelected: (selected) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  selectedColor: Colors.blue,
                  backgroundColor: Colors.grey[800],
                  labelStyle: TextStyle(
                    color: _selectedDate == date ? Colors.white : Colors.white70,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

            // Test Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testApi,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Test Direct API'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testApiWithCors,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Test with CORS'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Response Display
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _response,
                    style: const TextStyle(
                      color: Colors.green,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
