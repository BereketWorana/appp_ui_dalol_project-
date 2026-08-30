import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/config/app_config.dart';

class RegisterHotelScreen extends StatefulWidget {
  const RegisterHotelScreen({super.key});

  @override
  State<RegisterHotelScreen> createState() => _RegisterHotelScreenState();
}

class _RegisterHotelScreenState extends State<RegisterHotelScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _videoUrlController = TextEditingController();

  // State
  bool _isSubmitting = false;
  bool _submitted = false; // true after successful pending response
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  int _starRating = 0;
  TimeOfDay _checkInTime = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _checkOutTime = const TimeOfDay(hour: 11, minute: 0);

  final List<String> _allAmenities = [
    'WiFi',
    'Pool',
    'Restaurant',
    'Parking',
    'Bar',
    'Gym',
    'Spa',
    'Room Service',
    'Airport Shuttle',
  ];
  final Set<String> _selectedAmenities = {};

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  Future<void> _pickTime({required bool isCheckIn}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isCheckIn ? _checkInTime : _checkOutTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.pink.shade400,
              surface: const Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        if (isCheckIn) {
          _checkInTime = picked;
        } else {
          _checkOutTime = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final body = <String, dynamic>{
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'confirm_password': _confirmPasswordController.text,
        'type_id': 1, // Fixed default — backend crashes without it (PHP bug)
        'star_rating': _starRating,
        'check_in_time': _formatTime(_checkInTime),
        'check_out_time': _formatTime(_checkOutTime),
      };

      final desc = _descriptionController.text.trim();
      if (desc.isNotEmpty) body['description'] = desc;

      final region = _regionController.text.trim();
      if (region.isNotEmpty) body['region'] = region;

      final videoUrl = _videoUrlController.text.trim();
      if (videoUrl.isNotEmpty) body['video_url'] = videoUrl;

      if (_selectedAmenities.isNotEmpty) {
        body['amenities'] = _selectedAmenities.toList();
      }

      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/admin/hotels'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      if (!mounted) return;

      Map<String, dynamic> responseBody;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          responseBody = decoded;
        } else {
          throw Exception('Unexpected response from server.');
        }
      } catch (_) {
        throw Exception('Could not parse server response (status ${response.statusCode}).');
      }

      // Check both HTTP status AND the body's success field, since this
      // backend is known to return 200 with success: false on validation errors.
      final bool httpOk = response.statusCode >= 200 && response.statusCode < 300;
      final dynamic successField = responseBody['status'] ?? responseBody['success'];
      final bool bodyOk = successField == true || successField == 'true' || successField == 1;

      if (httpOk && bodyOk) {
        setState(() => _submitted = true);
      } else {
        // 1. Check responseBody['errors'] first — field-level validation map.
        //    Shape: { "phone": "msg" } or { "phone": ["msg1", "msg2"] }
        String errorMsg = '';
        final rawErrors = responseBody['errors'];
        if (rawErrors is Map && rawErrors.isNotEmpty) {
          errorMsg = rawErrors.entries.map((entry) {
            final field = entry.key.toString();
            final val = entry.value;
            String fieldMsg;
            if (val is List) {
              fieldMsg = val.map((e) => e.toString()).join(', ');
            } else {
              fieldMsg = val.toString();
            }
            return '• $field: $fieldMsg';
          }).join('\n');
        }

        // 2. Fall back to responseBody['message'] if errors map was absent/empty.
        if (errorMsg.isEmpty) {
          final rawMessage = responseBody['message'];
          if (rawMessage is String && rawMessage.isNotEmpty) {
            errorMsg = rawMessage;
          } else if (rawMessage is List) {
            errorMsg = rawMessage.map((e) => e.toString()).join('\n');
          } else {
            errorMsg = 'Submission failed (HTTP ${response.statusCode}).';
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } on Exception catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg.isNotEmpty ? msg : 'Could not reach the server.'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ----------------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Register Your Hotel',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: _submitted ? _buildPendingState() : _buildForm(),
      ),
    );
  }

  // ---- Pending confirmation state ----
  Widget _buildPendingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_empty_rounded,
                color: Colors.orange,
                size: 44,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Pending Admin Approval',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Your hotel registration has been submitted successfully and is now under review. '
              'An admin will verify your details and approve your listing. '
              'You\'ll be able to manage your rooms once approved.',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Center(
                  child: Text(
                    'Back to My Rooms',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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

  // ---- Form ----
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hotel Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Fill in your hotel information. Your registration will be reviewed by an admin before going live.',
              style: TextStyle(color: Colors.white60, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 28),

            // NAME
            _buildTextField(
              controller: _nameController,
              label: 'Hotel Name *',
              hint: 'e.g. Lalibela Grand Hotel',
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Hotel name is required';
                if (val.trim().length < 3) return 'Name must be at least 3 characters';
                return null;
              },
            ),
            const SizedBox(height: 18),

            // DESCRIPTION
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Brief description of your hotel, facilities, and what makes it special...',
              maxLines: 3,
            ),
            const SizedBox(height: 18),

            // ADDRESS & CITY (row)
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: _addressController,
                    label: 'Address *',
                    hint: 'Street / area',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Required';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildTextField(
                    controller: _cityController,
                    label: 'City *',
                    hint: 'e.g. Addis Ababa',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Required';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // REGION
            _buildTextField(
              controller: _regionController,
              label: 'Region',
              hint: 'e.g. Oromia, Amhara',
            ),
            const SizedBox(height: 18),

            // PHONE & EMAIL (row)
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _phoneController,
                    label: 'Phone *',
                    hint: '+251...',
                    keyboardType: TextInputType.phone,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Required';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildTextField(
                    controller: _emailController,
                    label: 'Email *',
                    hint: 'hotel@example.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Required';
                      if (!val.contains('@')) return 'Invalid email';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // STAR RATING
            const Text(
              'Star Rating',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF181818),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return GestureDetector(
                    onTap: () => setState(() => _starRating = index),
                    child: Column(
                      children: [
                        Icon(
                          index == 0 ? Icons.star_border : Icons.star,
                          color: index <= _starRating && _starRating > 0
                              ? Colors.amber
                              : Colors.white24,
                          size: 30,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          index == 0 ? 'None' : '$index',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 18),

            // CHECK-IN / CHECK-OUT TIME (row)
            Row(
              children: [
                Expanded(
                  child: _buildTimeField(
                    label: 'Check-in Time',
                    time: _checkInTime,
                    onTap: () => _pickTime(isCheckIn: true),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildTimeField(
                    label: 'Check-out Time',
                    time: _checkOutTime,
                    onTap: () => _pickTime(isCheckIn: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // AMENITIES
            const Text(
              'Amenities',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allAmenities.map((amenity) {
                final selected = _selectedAmenities.contains(amenity);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedAmenities.remove(amenity);
                      } else {
                        _selectedAmenities.add(amenity);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.pink.shade400.withValues(alpha: 0.2)
                          : const Color(0xFF181818),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? Colors.pink.shade400 : Colors.white12,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      amenity,
                      style: TextStyle(
                        color: selected ? Colors.pink.shade300 : Colors.white54,
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // PASSWORD SECTION
            const Text(
              'Account Password',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Set a password for hotel management access.',
              style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),

            // PASSWORD
            _buildPasswordField(
              controller: _passwordController,
              label: 'Password *',
              hint: 'Min. 6 characters',
              visible: _passwordVisible,
              onToggle: () => setState(() => _passwordVisible = !_passwordVisible),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Password is required';
                if (val.length < 6) return 'Must be at least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 18),

            // CONFIRM PASSWORD
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: 'Confirm Password *',
              hint: 'Re-enter your password',
              visible: _confirmPasswordVisible,
              onToggle: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Please confirm your password';
                if (val != _passwordController.text) return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: 18),

            // VIDEO URL
            _buildTextField(
              controller: _videoUrlController,
              label: 'Video URL (optional)',
              hint: 'e.g. https://youtube.com/watch?v=...',
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 32),

            // SUBMIT BUTTON
            GestureDetector(
              onTap: _isSubmitting ? null : _submitForm,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink.shade400, Colors.pink.shade600],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Submit for Review',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Disclaimer
            const Text(
              'Your submission will be reviewed by our admin team before your hotel goes live. '
              'You will not be able to manage rooms until the registration is approved.',
              style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ---- Reusable text field — same pattern as add_room_screen.dart ----
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFF181818),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.pink.shade400),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }

  // ---- Reusable password field with show/hide toggle ----
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool visible,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !visible,
          style: const TextStyle(color: Colors.white),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFF181818),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54, size: 20),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                visible ? Icons.visibility_off : Icons.visibility,
                color: Colors.white54,
                size: 20,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.pink.shade400),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }

  // ---- Time picker display field ----
  Widget _buildTimeField({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    final formattedTime = _formatTime(time);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF181818),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white54, size: 18),
                const SizedBox(width: 10),
                Text(
                  formattedTime,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
