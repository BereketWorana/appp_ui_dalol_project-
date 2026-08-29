import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

const guestImage = "assets/images/explore/pp4.jpg";
const guestImage1 = "assets/images/explore/pp2.jpg";

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "D'Allol",
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.white,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.white70,
        ),
      ),
      home: const ExploreScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ================= DUMMY DATA =================
class Hotel {
  final String name;
  final String image;
  final String location;
  final double rating;
  final int price;
  final String category;

  Hotel({
    required this.name,
    required this.image,
    required this.location,
    required this.rating,
    required this.price,
    required this.category,
  });
}

List<Hotel> getAllHotels() {
  return [
    Hotel(
      name: 'Sheraton Addis',
      image: "assets/images/r1.jpg",
      location: 'Addis Ababa',
      rating: 4.9,
      price: 8500,
      category: 'Luxury',
    ),
    Hotel(
      name: 'Marriott Executive',
      image: "assets/images/explore/luxury.jpg",
      location: 'Addis Ababa',
      rating: 4.8,
      price: 7200,
      category: 'Luxury',
    ),
    Hotel(
      name: 'Radisson Blu',
      image: 'assets/images/explore/resort.webp',
      location: 'Addis Ababa',
      rating: 4.7,
      price: 6500,
      category: 'Resort',
    ),
    Hotel(
      name: 'Goha Hotel',
      image: "assets/images/explore/bs (3).jpg",
      location: 'Gondar',
      rating: 4.6,
      price: 4200,
      category: 'Boutique',
    ),
    Hotel(
      name: 'Mountain View Lodge',
      image: "assets/images/explore/resort.jpg",
      location: 'Lalibela',
      rating: 4.8,
      price: 3800,
      category: 'Resort',
    ),
    Hotel(
      name: 'Axum Heritage Hotel',
      image: "assets/images/explore/bs (2).jpg",
      location: 'Axum',
      rating: 4.4,
      price: 3100,
      category: 'Boutique',
    ),
    Hotel(
      name: 'Ethiopian Skylight Hotel',
      image: "assets/images/r2.jpg",
      location: 'Addis Ababa',
      rating: 4.3,
      price: 4800,
      category: 'Luxury',
    ),
    Hotel(
      name: 'Kuriftu Resort',
      image: "assets/images/explore/resort (2).jpg",
      location: 'Bishoftu',
      rating: 4.7,
      price: 5200,
      category: 'Resort',
    ),
    Hotel(
      name: 'Ghion Hotel',
      image: "assets/images/explore/restorant (2).jpg",
      location: 'Addis Ababa',
      rating: 4.1,
      price: 2800,
      category: 'Restaurants',
    ),

    // ================= SPA =================
    Hotel(
      name: 'Kuriftu Spa Resort',
      image: "assets/images/explore/spa.jpg",
      location: 'Bishoftu',
      rating: 4.8,
      price: 6400,
      category: 'Spa',
    ),

    Hotel(
      name: 'Harmony Wellness Hotel',
      image: "assets/images/explore/spa (2).jpg",
      location: 'Addis Ababa',
      rating: 4.6,
      price: 5100,
      category: 'Spa',
    ),

    Hotel(
      name: 'Blue Nile Spa Lodge',
      image: "assets/images/explore/spa (3).jpg",
      location: 'Bahir Dar',
      rating: 4.5,
      price: 4700,
      category: 'Spa',
    ),

    // ================= BUSINESS =================
    Hotel(
      name: 'Capital Business Hotel',
      image: "assets/images/explore/business.jpg",
      location: 'Addis Ababa',
      rating: 4.7,
      price: 5900,
      category: 'Business',
    ),

    Hotel(
      name: 'Skyline Executive Hotel',
      image: "assets/images/explore/business.jpeg",
      location: 'Addis Ababa',
      rating: 4.6,
      price: 5600,
      category: 'Business',
    ),

    Hotel(
      name: 'Panorama Business Suites',
      image: "assets/images/explore/business (2).jpeg",
      location: 'Hawassa',
      rating: 4.4,
      price: 4300,
      category: 'Business',
    ),
    Hotel(
      name: 'Yod Abyssinia Restaurant',
      image: "assets/images/explore/restorant (4).jpg",
      location: 'Addis Ababa',
      rating: 4.8,
      price: 1800,
      category: 'Restaurants',
    ),

    Hotel(
      name: 'Habesha 2000 Restaurant',
      image: "assets/images/explore/restorant (3).jpg",
      location: 'Addis Ababa',
      rating: 4.6,
      price: 1500,
      category: 'Restaurants',
    ),
  ];
}

// ================= SCREEN =================
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _locationController = TextEditingController();
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _adults = 2;
  int _children = 0;
  int _rooms = 1;
  String _selectedCategory = 'All';
  final PageController _pageController = PageController();
  final List<String> _categories = [
    'All',
    'Luxury',
    'Resort',
    'Restaurants',
    'Boutique',
    'Spa',
    'Business',
  ];

  @override
  void dispose() {
    _locationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allHotels = getAllHotels();

    // Filter hotels based on selected category
    // ignore: unused_local_variable
    List<Hotel> filteredHotels = allHotels;
    if (_selectedCategory != 'All') {
      filteredHotels = allHotels
          .where((hotel) => hotel.category == _selectedCategory)
          .toList();
    }

    final topHotels = allHotels
        .where((h) => h.category == 'Luxury')
        .take(3)
        .toList();
    // ignore: unused_local_variable
    final trendingHotels = allHotels
        .where((h) => h.category != 'Luxury')
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ========== HERO BANNER ==========
                    Stack(
                      children: [
                        Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.grey.shade900,
                                Colors.grey.shade700,
                              ],
                            ),
                          ),

                          child: Image.asset(
                            guestImage,
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,

                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade800,
                                child: const Icon(
                                  Icons.hotel,
                                  color: Colors.white24,
                                  size: 60,
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.1),
                                Colors.black.withValues(alpha: 1),
                              ],
                              stops: const [0.1, 1],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Spacer(),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.1,
                                        ),
                                      ),
                                    ),
                                    child: IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.notifications_none,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Hello, Traveller",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "Where will you go today?",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ---- Find Hotels & Recent Searches ----
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Find Hotels",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                "Recent Searches",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // ---- Location Text Field ----
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: TextField(
                              controller: _locationController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                hintText: "Where are you going?",
                                hintStyle: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 13,
                                ),
                                prefixIcon: Icon(
                                  Icons.location_on,
                                  color: Colors.white54,
                                  size: 18,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 4,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // ---- Check-in & Check-out Row ----
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectDate(context, true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.06,
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.08,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: Colors.white54,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _checkInDate == null
                                                ? "Check-in"
                                                : "${_checkInDate!.day} ${_getMonth(_checkInDate!.month)} ${_getDayOfWeek(_checkInDate!.weekday)}",
                                            style: TextStyle(
                                              color: _checkInDate == null
                                                  ? Colors.white38
                                                  : Colors.white,
                                              fontSize: 12,
                                              fontWeight: _checkInDate == null
                                                  ? FontWeight.normal
                                                  : FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.white54,
                                          size: 22,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectDate(context, false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.06,
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.08,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: Colors.white54,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _checkOutDate == null
                                                ? "Check-out"
                                                : "${_checkOutDate!.day} ${_getMonth(_checkOutDate!.month)} ${_getDayOfWeek(_checkOutDate!.weekday)}",
                                            style: TextStyle(
                                              color: _checkOutDate == null
                                                  ? Colors.white38
                                                  : Colors.white,
                                              fontSize: 12,
                                              fontWeight: _checkOutDate == null
                                                  ? FontWeight.normal
                                                  : FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.white54,
                                          size: 22,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // ---- Guests & Rooms ----
                          GestureDetector(
                            onTap: () => _showGuestDialog(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.people,
                                    size: 16,
                                    color: Colors.white54,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Guests & Rooms",
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const Spacer(),
                                  Flexible(
                                    child: Text(
                                      "$_adults Adults · $_children Children · $_rooms Room${_rooms > 1 ? 's' : ''}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.white54,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // ---- Search Button ----
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Searching for hotels...'),
                                    backgroundColor: Colors.white,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.search, size: 18),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Search Hotels",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.flight, size: 18),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ---- D'Allol Deals Banner (Fixed with padding and View Details) ----
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: const DecorationImage(
                                image: AssetImage(guestImage1),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.75),
                                    Colors.black.withValues(alpha: 0.3),
                                  ],
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "D'Allol Deals",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          "Save more on amazing stays",
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // View Details Button inside banner
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: const Text(
                                            "View Details",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.25,
                                        ),
                                      ),
                                    ),
                                    child: const Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "30%",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              height: 1,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            "OFF",
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              height: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ---- Category Filters with PageView ----
                          const Text(
                            "Filters",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Category tabs
                          SizedBox(
                            height: 36,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: _categories.map((label) {
                                final isSelected = label == _selectedCategory;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = label;
                                      _pageController.animateToPage(
                                        _categories.indexOf(label),
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white.withValues(
                                              alpha: 0.06,
                                            ),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white.withValues(
                                                alpha: 0.1,
                                              ),
                                      ),
                                    ),
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.white70,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ---- PageView for content (Vertical list) ----
                          SizedBox(
                            height: 320,
                            child: PageView(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _selectedCategory = _categories[index];
                                });
                              },
                              children: _categories.map((category) {
                                List<Hotel> categoryHotels = allHotels;
                                if (category != 'All') {
                                  categoryHotels = allHotels
                                      .where(
                                        (hotel) => hotel.category == category,
                                      )
                                      .toList();
                                }
                                return _buildCategoryContentVertical(
                                  categoryHotels,
                                  category,
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ---- Popular Destinations ----
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Popular Destinations",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  "View all",
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 110,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _destinationCard(
                                  "Addis Ababa",
                                  "assets/images/explore/addisababa.jpg",
                                ),
                                _destinationCard(
                                  "Lalibela",
                                  "assets/images/explore/lalibela.jpeg",
                                ),
                                _destinationCard(
                                  "Gondar",
                                  "assets/images/explore/gonder.jpeg",
                                ),
                                _destinationCard(
                                  "Axum",
                                  "assets/images/explore/axum.jpg",
                                ),
                                _destinationCard(
                                  "Afar",
                                  "assets/images/explore/afar.jpg",
                                ),
                                _destinationCard(
                                  "Harar",
                                  "assets/images/explore/harar.jpg",
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ---- Popular Hotels ----
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Popular Hotels",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  "View all",
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 210,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: topHotels.length,
                              itemBuilder: (context, index) {
                                final hotel = topHotels[index];
                                return Container(
                                  width: 150,
                                  margin: const EdgeInsets.only(right: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.06,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(18),
                                            ),
                                        child: Image.asset(
                                          hotel.image,
                                          height: 110,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  height: 110,
                                                  color: Colors.grey.shade800,
                                                  child: const Icon(
                                                    Icons.hotel,
                                                    color: Colors.white24,
                                                    size: 35,
                                                  ),
                                                );
                                              },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              hotel.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 12,
                                                ),
                                                const SizedBox(width: 3),
                                                Text(
                                                  hotel.rating.toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              "${hotel.price} ETB",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
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
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build category content (Vertical list like Recommended)
  Widget _buildCategoryContentVertical(List<Hotel> hotels, String category) {
    if (hotels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hotel_outlined, size: 40, color: Colors.white24),
            const SizedBox(height: 10),
            Text(
              "No $category hotels found",
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: hotels.length,
      itemBuilder: (context, index) {
        final hotel = hotels[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(14),
                ),
                child: Image.asset(
                  hotel.image,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 90,
                      height: 90,
                      color: Colors.grey.shade800,
                      child: const Icon(
                        Icons.hotel,
                        color: Colors.white24,
                        size: 30,
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hotel.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.white54,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            hotel.location,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 13),
                          const SizedBox(width: 3),
                          Text(
                            hotel.rating.toString(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "${hotel.price} ETB",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
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

  // Helper: Select date
  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.grey.shade900),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

  // Helper: Show guests dialog
  void _showGuestDialog(BuildContext context) {
    int tempAdults = _adults;
    int tempChildren = _children;
    int tempRooms = _rooms;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.grey.shade900,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Guests & Rooms",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCounterDialog("Adults", tempAdults, 1, 10, (val) {
                      setStateDialog(() {
                        tempAdults = val;
                      });
                    }),
                    const SizedBox(height: 12),
                    _buildCounterDialog("Children", tempChildren, 0, 5, (val) {
                      setStateDialog(() {
                        tempChildren = val;
                      });
                    }),
                    const SizedBox(height: 12),
                    _buildCounterDialog("Rooms", tempRooms, 1, 5, (val) {
                      setStateDialog(() {
                        tempRooms = val;
                      });
                    }),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _adults = tempAdults;
                                _children = tempChildren;
                                _rooms = tempRooms;
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text("Apply"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCounterDialog(
    String label,
    int value,
    int min,
    int max,
    Function(int) onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
          color: value > min ? Colors.white : Colors.white24,
          iconSize: 24,
        ),
        SizedBox(
          width: 32,
          child: Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
          color: value < max ? Colors.white : Colors.white24,
          iconSize: 24,
        ),
      ],
    );
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _getDayOfWeek(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  Widget _destinationCard(String name, String image) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
          ),
        ),
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(10),
        child: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
