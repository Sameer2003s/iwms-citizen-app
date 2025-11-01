import 'package:flutter/material.dart';
// Layered imports
import '../../../core/constants.dart'; 

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // --- STATE ---
  // Mock data for the collections on the currently selected day
  final List<Map<String, dynamic>> _mockCollections = [
    {
      'time': '7:15 AM',
      'type': 'Wet Waste',
      'weight': '1.5 kg',
      'image_asset': 'assets/images/w_waste.png',
      'color': Colors.green,
    },
    {
      'time': '7:16 AM',
      'type': 'Dry Waste',
      'weight': '2.2 kg',
      'image_asset': 'assets/images/d_waste.png',
      'color': Colors.blue,
    },
    {
      'time': '7:17 AM',
      'type': 'Mixed Waste',
      'weight': '0.5 kg',
      'image_asset': 'assets/images/m_waste.png',
      'color': Colors.red,
    },
  ];

  // State for the selected date
  DateTime _selectedDate = DateTime.now();

  // --- METHODS ---

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: kPrimaryColor, // Primary color for header
              onPrimary: Colors.white, // Text color on primary
              onSurface: kTextColor, // Text color for the calendar days
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // In a real app, this would trigger a data fetch for the new date
      });
    }
  }

  // Helper widget to build each collection history card
  Widget _buildCollectionCard(Map<String, dynamic> data) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Waste Type and Weight Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data['type'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kTextColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: data['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: data['color']),
                  ),
                  child: Text(
                    data['weight'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: data['color'],
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // 2. Photo Proof and Time
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image of Collected Waste 
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    data['image_asset'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    // If the asset path is still wrong, this shows a fallback icon gracefully
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: kPlaceholderColor.withOpacity(0.3),
                        child: const Center(
                          child: Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Collection Time",
                        style: TextStyle(fontSize: 14, color: kPlaceholderColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['time'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kTextColor),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Implement viewing the full image proof
                          },
                          icon: const Icon(Icons.camera_alt_outlined, size: 20),
                          label: const Text("View Proof", style: TextStyle(fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kPrimaryColor,
                            side: const BorderSide(color: kPrimaryColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- BUILD METHOD ---

  @override
  Widget build(BuildContext context) {
    // Format the date for display
    String formattedDate = "${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}";
    String formattedHeader = "${_selectedDate.month}/${_selectedDate.day}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection History'),
        backgroundColor: kPrimaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Selection Card (Clickable Tile)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 28, color: kPrimaryColor),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Select Date", style: TextStyle(fontSize: 14, color: kPlaceholderColor)),
                          const SizedBox(height: 4),
                          Text(
                            "Viewing: $formattedDate",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextColor),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 18, color: kPlaceholderColor),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Collection Log Header
            Text(
              'Collection Log for $formattedHeader',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: kTextColor,
              ),
            ),
            const Divider(height: 20),

            // List of Collection Cards
            ..._mockCollections.map((data) => _buildCollectionCard(data)),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
