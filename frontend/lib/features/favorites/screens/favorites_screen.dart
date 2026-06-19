import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:le_nhat_truong/features/favorites/providers/favorites_provider.dart';
import 'package:le_nhat_truong/features/cart/providers/cart_provider.dart';
import 'package:le_nhat_truong/core/constants/constants.dart';
import 'package:le_nhat_truong/features/shop/screens/product_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isGridView = false;
  String _selectedCategory = 'All';
  String _sortLabel = 'Price: lowest to high';
  bool _sortAscending = true;

  static const List<String> _categories = [
    'All',
    'Summer',
    'T-Shirts',
    'Shirts',
    'Shoes',
    'Accessories'
  ];

  @override
  Widget build(BuildContext context) {
    final scale = (MediaQuery.of(context).size.width / 375).clamp(0.5, 1.5);

    return Consumer<FavoritesProvider>(
      builder: (context, favProvider, _) {
        var items = favProvider.favorites.toList();

        // Filter by category tag
        if (_selectedCategory != 'All') {
          items = items.where((item) {
            return item.product.tags.any((t) => t.tagName
                .toLowerCase()
                .contains(_selectedCategory.toLowerCase()));
          }).toList();
        }

        // Sort
        items.sort((a, b) => _sortAscending
            ? a.product.salePrice.compareTo(b.product.salePrice)
            : b.product.salePrice.compareTo(a.product.salePrice));

        return Scaffold(
          backgroundColor: const Color(0xFFF9F9F9),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      16 * scale, 16 * scale, 16 * scale, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Favorites',
                        style: GoogleFonts.outfit(
                          fontSize: 34 * scale,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF222222),
                          height: 1.1,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search,
                            size: 26 * scale, color: const Color(0xFF222222)),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12 * scale),

                // Category chips
                SizedBox(
                  height: 38 * scale,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                    itemCount: _categories.length,
                    itemBuilder: (ctx, i) {
                      final cat = _categories[i];
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: EdgeInsets.only(right: 8 * scale),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20 * scale, vertical: 8 * scale),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF222222)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF222222)
                                    : const Color(0xFFE0E0E0),
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.10),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text(
                              cat == 'All' ? 'All' : cat,
                              style: GoogleFonts.inter(
                                fontSize: 13 * scale,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF222222),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 12 * scale),

                // Filter/Sort Row
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                  child: Row(
                    children: [
                      // Filters button
                      GestureDetector(
                        onTap: () {},
                        child: Row(
                          children: [
                            Icon(Icons.tune,
                                size: 18 * scale,
                                color: const Color(0xFF222222)),
                            SizedBox(width: 4 * scale),
                            Text(
                              'Filters',
                              style: GoogleFonts.inter(
                                fontSize: 13 * scale,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF222222),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20 * scale),
                      // Sort button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _sortAscending = !_sortAscending;
                            _sortLabel = _sortAscending
                                ? 'Price: lowest to high'
                                : 'Price: highest to low';
                          });
                        },
                        child: Row(
                          children: [
                            Icon(Icons.swap_vert,
                                size: 18 * scale,
                                color: const Color(0xFF222222)),
                            SizedBox(width: 4 * scale),
                            Text(
                              _sortLabel,
                              style: GoogleFonts.inter(
                                fontSize: 13 * scale,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF222222),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Toggle list/grid
                      GestureDetector(
                        onTap: () => setState(() => _isGridView = !_isGridView),
                        child: Icon(
                          _isGridView
                              ? Icons.grid_view_rounded
                              : Icons.view_list_rounded,
                          size: 22 * scale,
                          color: const Color(0xFF222222),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12 * scale),

                // Content
                Expanded(
                  child: items.isEmpty
                      ? _buildEmpty(scale)
                      : _isGridView
                          ? _buildGridView(items, scale, favProvider)
                          : _buildListView(items, scale, favProvider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmpty(double scale) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_border_rounded,
              size: 80 * scale, color: const Color(0xFFE0E0E0)),
          SizedBox(height: 16 * scale),
          Text(
            'No favorites yet',
            style: GoogleFonts.outfit(
              fontSize: 22 * scale,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF222222),
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            'Add items you love to your\nfavorites list',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14 * scale,
              color: const Color(0xFF9B9B9B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(
      List<FavoriteItem> items, double scale, FavoritesProvider favProvider) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: 12 * scale),
      itemBuilder: (ctx, i) => _buildListCard(items[i], scale, favProvider),
    );
  }

  Widget _buildListCard(
      FavoriteItem item, double scale, FavoritesProvider favProvider) {
    final product = item.product;
    final isOnSale = product.comparePrice != null &&
        product.comparePrice! > product.salePrice;
    final isNew = product.tags.any((t) => t.tagName.toUpperCase() == 'NEW');
    final discountPct = isOnSale
        ? (((product.comparePrice! - product.salePrice) /
                    product.comparePrice!) *
                100)
            .round()
        : 0;
    final imageUrl = _buildImageUrl(product.imageUrl);
    final rating = product.ratingAverage ?? 0.0;
    final reviewCount = product.reviewCount ?? 0;
    final isSoldOut = product.quantity == 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product)),
        );
      },
      child: Container(
        height: 140 * scale,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  BorderRadius.horizontal(left: Radius.circular(8 * scale)),
              child: Stack(
                children: [
                  SizedBox(
                    width: 120 * scale,
                    height: 140 * scale,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            errorBuilder: (_, __, ___) =>
                                Container(color: const Color(0xFFC4C4C4)),
                          )
                        : Container(color: const Color(0xFFC4C4C4)),
                  ),
                  // Badge
                  if (isNew && !isOnSale)
                    Positioned(
                      top: 8 * scale,
                      left: 8 * scale,
                      child: _badge('NEW', const Color(0xFF222222), scale),
                    ),
                  if (isOnSale)
                    Positioned(
                      top: 8 * scale,
                      left: 8 * scale,
                      child: _badge(
                          '-$discountPct%', const Color(0xFFDB3022), scale),
                    ),
                  // Sold out overlay
                  if (isSoldOut)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white.withOpacity(0.75),
                        alignment: Alignment.bottomCenter,
                        padding: EdgeInsets.only(bottom: 8 * scale),
                        child: Text(
                          'Sorry, this item is\ncurrently sold out',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 10 * scale,
                            color: const Color(0xFF222222),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    12 * scale, 12 * scale, 8 * scale, 8 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand
                    Text(
                      product.brandName ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 11 * scale,
                        color: const Color(0xFF9B9B9B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2 * scale),
                    // Name
                    Text(
                      product.productName,
                      style: GoogleFonts.outfit(
                        fontSize: 15 * scale,
                        fontWeight: FontWeight.w700,
                        color: isSoldOut
                            ? const Color(0xFF9B9B9B)
                            : const Color(0xFF222222),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4 * scale),
                    // Color & Size
                    Row(
                      children: [
                        Text(
                          'Color: ',
                          style: GoogleFonts.inter(
                              fontSize: 11 * scale,
                              color: const Color(0xFF9B9B9B)),
                        ),
                        Flexible(
                          child: Text(
                            item.selectedColor,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11 * scale,
                              color: const Color(0xFF222222),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 8 * scale),
                        Text(
                          'Size: ',
                          style: GoogleFonts.inter(
                              fontSize: 11 * scale,
                              color: const Color(0xFF9B9B9B)),
                        ),
                        Flexible(
                          child: Text(
                            item.selectedSize,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11 * scale,
                              color: const Color(0xFF222222),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Price & Stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price
                        isOnSale
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${product.salePrice.round()}\$',
                                    style: GoogleFonts.inter(
                                      fontSize: 14 * scale,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF222222),
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                '${product.salePrice.round()}\$',
                                style: GoogleFonts.inter(
                                  fontSize: 14 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF222222),
                                ),
                              ),
                        // Stars
                        Row(
                          children: [
                            ...List.generate(
                                5,
                                (i) => Icon(
                                      Icons.star,
                                      size: 12 * scale,
                                      color: i < rating.floor()
                                          ? const Color(0xFFFFBA49)
                                          : const Color(0xFFE0E0E0),
                                    )),
                            SizedBox(width: 4 * scale),
                            Text(
                              '($reviewCount)',
                              style: GoogleFonts.inter(
                                fontSize: 11 * scale,
                                color: const Color(0xFF9B9B9B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Right side: X button + Cart button
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // X remove button
                Padding(
                  padding: EdgeInsets.only(top: 8 * scale, right: 8 * scale),
                  child: GestureDetector(
                    onTap: () => favProvider.removeFavorite(product.id),
                    child: Icon(Icons.close,
                        size: 18 * scale, color: const Color(0xFF9B9B9B)),
                  ),
                ),
                // Cart button
                Padding(
                  padding:
                      EdgeInsets.only(bottom: 10 * scale, right: 10 * scale),
                  child: GestureDetector(
                    onTap: isSoldOut
                        ? null
                        : () {
                            final size = item.selectedSize.isEmpty
                                ? 'M'
                                : item.selectedSize;
                            final color = item.selectedColor.isEmpty
                                ? 'Black'
                                : item.selectedColor;
                            Provider.of<CartProvider>(context, listen: false)
                                .addItem(product, size, color);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Added ${product.productName} to bag!'),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                    child: Container(
                      width: 36 * scale,
                      height: 36 * scale,
                      decoration: BoxDecoration(
                        color: isSoldOut
                            ? const Color(0xFFE0E0E0)
                            : const Color(0xFFDB3022),
                        shape: BoxShape.circle,
                        boxShadow: isSoldOut
                            ? []
                            : [
                                BoxShadow(
                                  color:
                                      const Color(0xFFDB3022).withOpacity(0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                      ),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.white,
                        size: 18 * scale,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(
      List<FavoriteItem> items, double scale, FavoritesProvider favProvider) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12 * scale,
        mainAxisSpacing: 12 * scale,
        childAspectRatio: 0.65,
      ),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _buildGridCard(items[i], scale, favProvider),
    );
  }

  Widget _buildGridCard(
      FavoriteItem item, double scale, FavoritesProvider favProvider) {
    final product = item.product;
    final isOnSale = product.comparePrice != null &&
        product.comparePrice! > product.salePrice;
    final isNew = product.tags.any((t) => t.tagName.toUpperCase() == 'NEW');
    final discountPct = isOnSale
        ? (((product.comparePrice! - product.salePrice) /
                    product.comparePrice!) *
                100)
            .round()
        : 0;
    final imageUrl = _buildImageUrl(product.imageUrl);
    final rating = product.ratingAverage ?? 0.0;
    final reviewCount = product.reviewCount ?? 0;
    final isSoldOut = product.quantity == 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Expanded(
              flex: 6,
              child: ClipRRect(
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(8 * scale)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            errorBuilder: (_, __, ___) =>
                                Container(color: const Color(0xFFC4C4C4)),
                          )
                        : Container(color: const Color(0xFFC4C4C4)),
                    // Badge
                    if (isNew && !isOnSale)
                      Positioned(
                        top: 8 * scale,
                        left: 8 * scale,
                        child: _badge('NEW', const Color(0xFF222222), scale),
                      ),
                    if (isOnSale)
                      Positioned(
                        top: 8 * scale,
                        left: 8 * scale,
                        child: _badge(
                            '-$discountPct%', const Color(0xFFDB3022), scale),
                      ),
                    // Sold out overlay
                    if (isSoldOut)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8 * scale, vertical: 6 * scale),
                          color: Colors.white.withOpacity(0.82),
                          child: Text(
                            'Sorry, this item is currently sold out',
                            style: GoogleFonts.inter(
                              fontSize: 10 * scale,
                              color: const Color(0xFF222222),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    // X remove button
                    Positioned(
                      top: 6 * scale,
                      right: 6 * scale,
                      child: GestureDetector(
                        onTap: () => favProvider.removeFavorite(product.id),
                        child: Container(
                          width: 26 * scale,
                          height: 26 * scale,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close,
                              size: 14 * scale, color: const Color(0xFF9B9B9B)),
                        ),
                      ),
                    ),
                    // Cart button
                    Positioned(
                      bottom: 8 * scale,
                      right: 8 * scale,
                      child: GestureDetector(
                        onTap: isSoldOut
                            ? null
                            : () {
                                final size = item.selectedSize.isEmpty
                                    ? 'M'
                                    : item.selectedSize;
                                final color = item.selectedColor.isEmpty
                                    ? 'Black'
                                    : item.selectedColor;
                                Provider.of<CartProvider>(context,
                                        listen: false)
                                    .addItem(product, size, color);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Added ${product.productName} to bag!'),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                        child: Container(
                          width: 34 * scale,
                          height: 34 * scale,
                          decoration: BoxDecoration(
                            color: isSoldOut
                                ? const Color(0xFFE0E0E0)
                                : const Color(0xFFDB3022),
                            shape: BoxShape.circle,
                            boxShadow: isSoldOut
                                ? []
                                : [
                                    BoxShadow(
                                      color: const Color(0xFFDB3022)
                                          .withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                          ),
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.white,
                            size: 16 * scale,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Info
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    10 * scale, 8 * scale, 10 * scale, 8 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stars
                    Row(
                      children: [
                        ...List.generate(
                            5,
                            (i) => Icon(
                                  Icons.star,
                                  size: 11 * scale,
                                  color: i < rating.floor()
                                      ? const Color(0xFFFFBA49)
                                      : const Color(0xFFE0E0E0),
                                )),
                        SizedBox(width: 3 * scale),
                        Text(
                          '($reviewCount)',
                          style: GoogleFonts.inter(
                            fontSize: 10 * scale,
                            color: const Color(0xFF9B9B9B),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2 * scale),
                    // Brand
                    Text(
                      product.brandName ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 10 * scale,
                        color: const Color(0xFF9B9B9B),
                      ),
                    ),
                    // Name
                    Text(
                      product.productName,
                      style: GoogleFonts.outfit(
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w700,
                        color: isSoldOut
                            ? const Color(0xFF9B9B9B)
                            : const Color(0xFF222222),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2 * scale),
                    // Color & Size
                    Row(
                      children: [
                        Text(
                          'Color: ',
                          style: GoogleFonts.inter(
                              fontSize: 10 * scale,
                              color: const Color(0xFF9B9B9B)),
                        ),
                        Flexible(
                          child: Text(
                            item.selectedColor,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 10 * scale,
                              color: const Color(0xFF222222),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 4 * scale),
                        Text(
                          'Size: ',
                          style: GoogleFonts.inter(
                              fontSize: 10 * scale,
                              color: const Color(0xFF9B9B9B)),
                        ),
                        Flexible(
                          child: Text(
                            item.selectedSize,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 10 * scale,
                              color: const Color(0xFF222222),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4 * scale),
                    // Price
                    isOnSale
                        ? Row(
                            children: [
                              Text(
                                '${product.comparePrice!.round()}\$',
                                style: GoogleFonts.inter(
                                  fontSize: 12 * scale,
                                  color: const Color(0xFF9B9B9B),
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              SizedBox(width: 4 * scale),
                              Text(
                                '${product.salePrice.round()}\$',
                                style: GoogleFonts.inter(
                                  fontSize: 13 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFDB3022),
                                ),
                              ),
                            ],
                          )
                        : Text(
                            '${product.salePrice.round()}\$',
                            style: GoogleFonts.inter(
                              fontSize: 13 * scale,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF222222),
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

  Widget _badge(String text, Color color, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 3 * scale),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(29 * scale),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10 * scale,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _buildImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http')) return imageUrl;
    return '${AppConstants.baseUrl}$imageUrl';
  }
}
