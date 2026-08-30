import 'package:flutter/material.dart';
import '../../../../data/models/room_type.dart';
import '../../../../data/services/room_service.dart';

class AddRoomScreen extends StatefulWidget {
  final int hotelId;

  const AddRoomScreen({
    super.key,
    required this.hotelId,
  });

  @override
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _remainingController = TextEditingController();
  final _occupancyController = TextEditingController();
  final _bedTypeController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<RoomType> _roomTypes = [];
  RoomType? _selectedRoomType;

  bool _isLoadingTypes = true;
  bool _isSubmitting = false;
  String? _typesError;

  @override
  void initState() {
    super.initState();
    _loadRoomTypes();
  }

  Future<void> _loadRoomTypes() async {
    setState(() {
      _isLoadingTypes = true;
      _typesError = null;
    });

    try {
      final types = await RoomService.getRoomTypes();
      if (mounted) {
        setState(() {
          _roomTypes = types;
          if (types.isNotEmpty) {
            _selectedRoomType = types.first;
          }
          _isLoadingTypes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _typesError = 'Failed to load room types';
          _isLoadingTypes = false;
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRoomType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a room type'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final double? price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price per night'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final int? remaining = int.tryParse(_remainingController.text.trim());
    if (remaining == null || remaining < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid remaining rooms count'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final int? occupancy = int.tryParse(_occupancyController.text.trim());
    if (occupancy == null || occupancy <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid max occupancy'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await RoomService.createRoom(
        hotelId: widget.hotelId,
        roomTypeId: _selectedRoomType!.id,
        name: _nameController.text.trim(),
        pricePerNight: price,
        remainingRooms: remaining,
        maxOccupancy: occupancy,
        bedType: _bedTypeController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      final errorMessage = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add room: $errorMessage'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Add New Room', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Room Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enter information to list a new room for this hotel.',
                  style: TextStyle(color: Colors.white60, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // ROOM TYPE DROPDOWN
                const Text(
                  'Room Type *',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                if (_isLoadingTypes)
                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF181818),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white54,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Loading room types...',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  )
                else if (_typesError != null)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _typesError!,
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ),
                      TextButton(
                        onPressed: _loadRoomTypes,
                        child: const Text('Retry'),
                      ),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF181818),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<RoomType>(
                        value: _selectedRoomType,
                        dropdownColor: const Color(0xFF222222),
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        items: _roomTypes.map((type) {
                          return DropdownMenuItem<RoomType>(
                            value: type,
                            child: Text(
                              type.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRoomType = value;
                          });
                        },
                      ),
                    ),
                  ),

                const SizedBox(height: 18),

                // ROOM NAME
                _buildTextField(
                  controller: _nameController,
                  label: 'Room Name *',
                  hint: 'e.g. Deluxe Sea View Suite 201',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Room name is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // PRICE PER NIGHT & REMAINING ROOMS ROW
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _priceController,
                        label: 'Price per Night (ETB) *',
                        hint: 'e.g. 150.00',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(val.trim()) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildTextField(
                        controller: _remainingController,
                        label: 'Available Rooms *',
                        hint: 'e.g. 5',
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Required';
                          }
                          if (int.tryParse(val.trim()) == null) {
                            return 'Invalid integer';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // MAX OCCUPANCY & BED TYPE ROW
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _occupancyController,
                        label: 'Max Occupancy *',
                        hint: 'e.g. 2',
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Required';
                          }
                          if (int.tryParse(val.trim()) == null) {
                            return 'Invalid integer';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildTextField(
                        controller: _bedTypeController,
                        label: 'Bed Type',
                        hint: 'e.g. King Bed',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // DESCRIPTION
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Detailed room description, view, and amenities...',
                  maxLines: 3,
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
                              'Save Room',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
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

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _remainingController.dispose();
    _occupancyController.dispose();
    _bedTypeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
