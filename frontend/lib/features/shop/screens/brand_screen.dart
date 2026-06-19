import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BrandScreen extends StatefulWidget {
  final List<String> initialSelectedBrands;
  final double scale;

  const BrandScreen({
    super.key,
    required this.initialSelectedBrands,
    required this.scale,
  });

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  late List<String> _selectedBrands;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _allBrands = [
    'adidas',
    'adidas Originals',
    'Blend',
    'Boutique Moschino',
    'Champion',
    'Diesel',
    'Jack & Jones',
    'Naf Naf',
    'Red Valentino',
    's.Oliver',
  ];

  @override
  void initState() {
    super.initState();
    _selectedBrands = List.from(widget.initialSelectedBrands);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _discardSelections() {
    setState(() {
      _selectedBrands.clear();
    });
  }

  void _applySelections() {
    Navigator.pop(context, _selectedBrands);
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final filteredBrands = _allBrands
        .where(
            (brand) => brand.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

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
          'Brand',
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
            // --- Search Bar ---
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 16 * scale, vertical: 12 * scale),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(24 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: GoogleFonts.inter(
                    fontSize: 14 * scale,
                    color: const Color(0xFF222222),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14 * scale,
                      color: const Color(0xFF9B9B9B),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: const Color(0xFF9B9B9B),
                      size: 20 * scale,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12 * scale),
                  ),
                ),
              ),
            ),

            // --- Brands List ---
            Expanded(
              child: filteredBrands.isEmpty
                  ? Center(
                      child: Text(
                        'No brands found',
                        style: GoogleFonts.inter(
                          fontSize: 14 * scale,
                          color: const Color(0xFF9B9B9B),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredBrands.length,
                      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                      itemBuilder: (context, index) {
                        final brand = filteredBrands[index];
                        final isSelected = _selectedBrands.contains(brand);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedBrands.remove(brand);
                              } else {
                                _selectedBrands.add(brand);
                              }
                            });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16 * scale),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  brand,
                                  style: GoogleFonts.inter(
                                    fontSize: 16 * scale,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? const Color(0xFFDB3022)
                                        : const Color(0xFF222222),
                                  ),
                                ),
                                Container(
                                  width: 20 * scale,
                                  height: 20 * scale,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFDB3022)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFDB3022)
                                          : const Color(0xFF9B9B9B),
                                      width: 1.5 * scale,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(4 * scale),
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check,
                                          size: 14 * scale,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
                        onPressed: _discardSelections,
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
                        onPressed: _applySelections,
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
}
