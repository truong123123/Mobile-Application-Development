import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_nhat_truong/features/shop/models/product.dart';
import 'package:le_nhat_truong/features/shop/services/product_service.dart';
import 'package:le_nhat_truong/features/shop/screens/visual_search_screen.dart';
import 'package:le_nhat_truong/features/shop/screens/product_detail_screen.dart';
import 'package:le_nhat_truong/core/constants/constants.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ProductService _productService = ProductService();

  List<Product> _allProducts = [];
  List<Product> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  Timer? _debounce;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // Recent & trending searches
  final List<String> _recentSearches = [
    'Hoodie',
    'Summer dress',
    'Denim jacket',
  ];
  final List<String> _trendingSearches = [
    'Crop top',
    'Wide leg pants',
    'Linen shirt',
    'Mini skirt',
    'Blazer',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    _focusNode.requestFocus();
    _loadAllProducts();
  }

  Future<void> _loadAllProducts() async {
    final products = await _productService.getAllProducts();
    if (mounted) {
      setState(() => _allProducts = products);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return;
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    final filtered = _allProducts.where((p) {
      return p.productName.toLowerCase().contains(q) ||
          (p.brandName?.toLowerCase().contains(q) ?? false) ||
          p.tags.any((t) => t.tagName.toLowerCase().contains(q));
    }).toList();

    setState(() {
      _results = filtered;
      _isLoading = false;
    });

    // Add to recent searches
    if (!_recentSearches.contains(query.trim())) {
      setState(() {
        _recentSearches.insert(0, query.trim());
        if (_recentSearches.length > 5) _recentSearches.removeLast();
      });
    }
  }

  void _applyQuickSearch(String term) {
    _searchController.text = term;
    _performSearch(term);
  }

  void _openVisualSearch() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const VisualSearchScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              // ── Search bar ─────────────────────────────────────────────
              _buildSearchBar(),

              // ── Visual search chip ─────────────────────────────────────
              _buildVisualSearchChip(),

              const SizedBox(height: 4),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),

              // ── Body ───────────────────────────────────────────────────
              Expanded(
                child: _hasSearched ? _buildResults() : _buildDiscovery(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Color(0xFF222222), size: 20),
            onPressed: () => Navigator.pop(context),
          ),

          // Input field
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: _onQueryChanged,
                onSubmitted: _performSearch,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: const Color(0xFF222222),
                ),
                decoration: InputDecoration(
                  hintText: 'Search brands, products...',
                  hintStyle: GoogleFonts.inter(
                    color: const Color(0xFF9B9B9B),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Color(0xFF9B9B9B), size: 22),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: Color(0xFF9B9B9B), size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _onQueryChanged('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12),
                  isDense: true,
                ),
                textInputAction: TextInputAction.search,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Visual search chip ────────────────────────────────────────────────────
  Widget _buildVisualSearchChip() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: GestureDetector(
        onTap: _openVisualSearch,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDB3022), width: 1.5),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.camera_alt_outlined,
                  color: Color(0xFFDB3022), size: 20),
              const SizedBox(width: 8),
              Text(
                'Visual Search',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFDB3022),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDB3022),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'NEW',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Color(0xFFDB3022), size: 14),
            ],
          ),
        ),
      ),
    );
  }

  // ── Discovery view (no query yet) ─────────────────────────────────────────
  Widget _buildDiscovery() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Recent searches
        if (_recentSearches.isNotEmpty) ...[
          _buildSectionTitle('Recent Searches', onClear: () {
            setState(() => _recentSearches.clear());
          }),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches
                .map((s) => _buildChip(
                      s,
                      icon: Icons.history_rounded,
                      onTap: () => _applyQuickSearch(s),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
        ],

        // Trending
        _buildSectionTitle('Trending Now'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _trendingSearches
              .map((s) => _buildChip(
                    s,
                    icon: Icons.local_fire_department_rounded,
                    iconColor: const Color(0xFFDB3022),
                    onTap: () => _applyQuickSearch(s),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onClear}) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF222222),
          ),
        ),
        const Spacer(),
        if (onClear != null)
          TextButton(
            onPressed: onClear,
            child: Text(
              'Clear all',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF9B9B9B),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChip(
    String label, {
    required IconData icon,
    Color iconColor = const Color(0xFF9B9B9B),
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF444444),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Results view ──────────────────────────────────────────────────────────
  Widget _buildResults() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFDB3022)),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF444444),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords\nor use Visual Search',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF9B9B9B),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _openVisualSearch,
              icon: const Icon(Icons.camera_alt_outlined,
                  color: Color(0xFFDB3022), size: 18),
              label: Text(
                'Try Visual Search',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFDB3022),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side:
                    const BorderSide(color: Color(0xFFDB3022), width: 1.5),
                shape: const StadiumBorder(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            '${_results.length} result${_results.length != 1 ? 's' : ''}',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF9B9B9B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _results.length,
            itemBuilder: (_, i) => _SearchProductCard(product: _results[i]),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product card for search results
// ─────────────────────────────────────────────────────────────────────────────
class _SearchProductCard extends StatelessWidget {
  final Product product;
  const _SearchProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final imageUrl = (product.imageUrl != null && product.imageUrl!.isNotEmpty)
        ? (product.imageUrl!.startsWith('http')
            ? product.imageUrl!
            : '${AppConstants.baseUrl}${product.imageUrl!}')
        : '';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFE0E0E0),
                          child: const Icon(Icons.image,
                              color: Colors.grey),
                        ),
                      )
                    : Container(
                        color: const Color(0xFFE0E0E0),
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
              ),
            ),

            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.brandName ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: const Color(0xFF9B9B9B),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.productName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF222222),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${product.salePrice.toStringAsFixed(0)}',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFDB3022),
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
}
