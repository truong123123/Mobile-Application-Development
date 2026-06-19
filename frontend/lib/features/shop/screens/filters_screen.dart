import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_nhat_truong/features/shop/screens/brand_screen.dart';

class FiltersScreen extends StatefulWidget {
  final RangeValues initialPriceRange;
  final List<String> initialColors;
  final List<String> initialSizes;
  final String initialCategory;
  final List<String> initialBrands;
  final double scale;

  const FiltersScreen({
    super.key,
    required this.initialPriceRange,
    required this.initialColors,
    required this.initialSizes,
    required this.initialCategory,
    required this.initialBrands,
    required this.scale,
  });

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  late RangeValues _priceRange;
  late List<String> _selectedColors;
  late List<String> _selectedSizes;
  late String _selectedCategory;
  late List<String> _selectedBrands;

  final List<Map<String, dynamic>> _colorOptions = [
    {'name': 'Black', 'color': const Color(0xFF020202)},
    {'name': 'White', 'color': const Color(0xFFFFFFFF)},
    {'name': 'Red', 'color': const Color(0xFFDB3022)},
    {'name': 'Grey', 'color': const Color(0xFFBEBEBE)},
    {'name': 'Beige', 'color': const Color(0xFFE5C6A1)},
    {'name': 'Navy', 'color': const Color(0xFF15183F)},
  ];

  final List<String> _sizeOptions = ['XS', 'S', 'M', 'L', 'XL'];
  final List<String> _categoryOptions = [
    'All',
    'Women',
    'Men',
    'Boys',
    'Girls'
  ];

  @override
  void initState() {
    super.initState();
    _priceRange = widget.initialPriceRange;
    _selectedColors = List.from(widget.initialColors);
    _selectedSizes = List.from(widget.initialSizes);
    _selectedCategory = widget.initialCategory;
    _selectedBrands = List.from(widget.initialBrands);
  }

  void _discardFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 1000);
      _selectedColors = [];
      _selectedSizes = [];
      _selectedCategory = 'All';
      _selectedBrands = [];
    });
  }

  void _applyFilters() {
    Navigator.pop(context, {
      'priceRange': _priceRange,
      'colors': _selectedColors,
      'sizes': _selectedSizes,
      'category': _selectedCategory,
      'brands': _selectedBrands,
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: const Color(0xFF222222), size: 20 * scale),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Filters',
          style: GoogleFonts.outfit(
            fontSize: 18 * scale,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF222222),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Price Range Section ---
                    _buildSectionHeader('Price range', scale),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16 * scale, vertical: 16 * scale),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${_priceRange.start.round()}',
                                style: GoogleFonts.inter(
                                  fontSize: 14 * scale,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF222222),
                                ),
                              ),
                              Text(
                                '\$${_priceRange.end.round()}',
                                style: GoogleFonts.inter(
                                  fontSize: 14 * scale,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF222222),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8 * scale),
                          RangeSlider(
                            values: _priceRange,
                            min: 0,
                            max: 1000,
                            divisions: 100,
                            activeColor: const Color(0xFFDB3022),
                            inactiveColor: const Color(0xFFBEBEBE),
                            onChanged: (values) {
                              setState(() {
                                _priceRange = values;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // --- Colors Section ---
                    _buildSectionHeader('Colors', scale),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16 * scale, vertical: 20 * scale),
                      width: double.infinity,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _colorOptions.map((opt) {
                            final String name = opt['name'];
                            final Color color = opt['color'];
                            final isSelected = _selectedColors.contains(name);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedColors.remove(name);
                                  } else {
                                    _selectedColors.add(name);
                                  }
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.only(right: 16 * scale),
                                padding: EdgeInsets.all(4 * scale),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFDB3022)
                                        : Colors.transparent,
                                    width: 1.5 * scale,
                                  ),
                                ),
                                child: Container(
                                  width: 36 * scale,
                                  height: 36 * scale,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: color,
                                    border: (name == 'White')
                                        ? Border.all(
                                            color: const Color(0xFFE0E0E0),
                                            width: 1)
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // --- Sizes Section ---
                    _buildSectionHeader('Sizes', scale),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16 * scale, vertical: 24 * scale),
                      width: double.infinity,
                      child: Wrap(
                        spacing: 16 * scale,
                        runSpacing: 16 * scale,
                        children: _sizeOptions.map((size) {
                          final isSelected = _selectedSizes.contains(size);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedSizes.remove(size);
                                } else {
                                  _selectedSizes.add(size);
                                }
                              });
                            },
                            child: Container(
                              width: 44 * scale,
                              height: 44 * scale,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFDB3022)
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFDB3022)
                                      : const Color(0xFFE0E0E0),
                                  width: 1 * scale,
                                ),
                                borderRadius: BorderRadius.circular(8 * scale),
                              ),
                              child: Text(
                                size,
                                style: GoogleFonts.inter(
                                  fontSize: 14 * scale,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF222222),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // --- Category Section ---
                    _buildSectionHeader('Category', scale),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16 * scale, vertical: 24 * scale),
                      width: double.infinity,
                      child: Wrap(
                        spacing: 12 * scale,
                        runSpacing: 12 * scale,
                        children: _categoryOptions.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20 * scale, vertical: 12 * scale),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFDB3022)
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFDB3022)
                                      : const Color(0xFFE0E0E0),
                                  width: 1 * scale,
                                ),
                                borderRadius: BorderRadius.circular(8 * scale),
                              ),
                              child: Text(
                                cat,
                                style: GoogleFonts.inter(
                                  fontSize: 14 * scale,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF222222),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // --- Brand Row Section ---
                    Container(
                      color: const Color(0xFFF9F9F9),
                      height: 8 * scale,
                    ),
                    GestureDetector(
                      onTap: () async {
                        final selected = await Navigator.push<List<String>>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BrandScreen(
                              initialSelectedBrands: _selectedBrands,
                              scale: scale,
                            ),
                          ),
                        );
                        if (selected != null) {
                          setState(() {
                            _selectedBrands = selected;
                          });
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16 * scale, vertical: 16 * scale),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Brand',
                                    style: GoogleFonts.inter(
                                      fontSize: 16 * scale,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF222222),
                                    ),
                                  ),
                                  SizedBox(height: 4 * scale),
                                  Text(
                                    _selectedBrands.isEmpty
                                        ? 'All Brands'
                                        : _selectedBrands.join(', '),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 11 * scale,
                                      color: const Color(0xFF9B9B9B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right,
                                color: const Color(0xFF222222),
                                size: 24 * scale),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      color: const Color(0xFFF9F9F9),
                      height: 24 * scale,
                    ),
                  ],
                ),
              ),
            ),

            // --- Bottom Buttons Area ---
            Container(
              padding: EdgeInsets.all(16 * scale),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48 * scale,
                      child: OutlinedButton(
                        onPressed: _discardFilters,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFF222222), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24 * scale),
                          ),
                        ),
                        child: Text(
                          'Discard',
                          style: GoogleFonts.inter(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF222222),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16 * scale),
                  Expanded(
                    child: SizedBox(
                      height: 48 * scale,
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDB3022),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24 * scale),
                          ),
                        ),
                        child: Text(
                          'Apply',
                          style: GoogleFonts.inter(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, double scale) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF9F9F9),
      padding:
          EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16 * scale,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF222222),
        ),
      ),
    );
  }
}
