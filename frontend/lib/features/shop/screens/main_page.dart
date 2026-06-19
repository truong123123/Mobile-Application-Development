import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_nhat_truong/features/auth/providers/auth_provider.dart';
import 'package:le_nhat_truong/features/shop/models/product.dart';
import 'package:le_nhat_truong/features/shop/models/category.dart';
import 'package:le_nhat_truong/features/shop/services/product_service.dart';
import 'package:le_nhat_truong/features/auth/services/auth_service.dart';
import 'package:le_nhat_truong/core/constants/constants.dart';
import 'package:le_nhat_truong/features/auth/screens/login_screen.dart';
import 'package:le_nhat_truong/features/shop/screens/product_detail_screen.dart';

import 'package:le_nhat_truong/features/favorites/screens/favorites_screen.dart';
import 'package:le_nhat_truong/features/favorites/providers/favorites_provider.dart';
import 'package:le_nhat_truong/features/cart/screens/bag_screen.dart';
import 'package:le_nhat_truong/features/cart/providers/cart_provider.dart';
import 'package:le_nhat_truong/features/orders/screens/my_orders_screen.dart';
import 'package:le_nhat_truong/features/orders/screens/order_details_screen.dart';
import 'package:le_nhat_truong/features/shop/screens/settings_screen.dart';
import 'package:le_nhat_truong/features/shop/screens/filters_screen.dart';
import 'package:le_nhat_truong/features/shop/screens/admin_product_screen.dart';
import 'package:le_nhat_truong/features/shop/screens/collections_screen.dart';
import 'package:le_nhat_truong/features/auth/screens/shipping_addresses_screen.dart';
import 'package:le_nhat_truong/features/shop/screens/search_screen.dart';
import 'package:le_nhat_truong/features/shop/screens/my_reviews_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  String _homeView = 'main'; // 'main' or 'collections'
  int _selectedGenderIndex = 0;
  String _currentShopView = 'main'; // 'main' or 'sub_clothes'
  final _productService = ProductService();
  List<Product> _saleProducts = [];
  List<Product> _newProducts = [];
  bool _isLoading = true;
  final List<Product> _topsProducts = [];
  final bool _isTopsLoading = false;
  bool _isGridView = true;
  String _selectedSort = 'Price: lowest to high';

  // Filters State
  RangeValues _filterPriceRange = const RangeValues(0, 1000);
  List<String> _filterSelectedColors = [];
  List<String> _filterSelectedSizes = [];
  String _filterSelectedCategory = 'All';
  List<String> _filterSelectedBrands = [];

  List<Product> _applyFilters(List<Product> products) {
    return products.where((product) {
      // 1. Price range filter
      if (product.salePrice < _filterPriceRange.start ||
          product.salePrice > _filterPriceRange.end) {
        return false;
      }

      // 2. Color filter
      if (_filterSelectedColors.isNotEmpty) {
        bool matchColor = false;
        for (final color in _filterSelectedColors) {
          if (product.colors
              .any((c) => c.toLowerCase() == color.toLowerCase())) {
            matchColor = true;
            break;
          }
        }
        if (!matchColor) return false;
      }

      // 3. Size filter
      if (_filterSelectedSizes.isNotEmpty) {
        bool matchSize = false;
        for (final size in _filterSelectedSizes) {
          if (product.sizes.any((s) => s.toLowerCase() == size.toLowerCase())) {
            matchSize = true;
            break;
          }
        }
        if (!matchSize) return false;
      }

      // 4. Category filter
      if (_filterSelectedCategory != 'All') {
        final gender = _filterSelectedCategory.toLowerCase();
        bool matchGender = false;
        if (product.productType?.toLowerCase() == gender) {
          matchGender = true;
        }
        for (final tag in product.tags) {
          if (tag.tagName.toLowerCase() == gender) {
            matchGender = true;
          }
        }
        if (!matchGender) {
          final nameLower = product.productName.toLowerCase();
          if (nameLower.contains(gender)) {
            matchGender = true;
          } else {
            final hash = product.id.hashCode.abs();
            if (hash % 3 != 0) {
              matchGender = true;
            }
          }
        }
        if (!matchGender) return false;
      }

      // 5. Brand filter
      if (_filterSelectedBrands.isNotEmpty) {
        final brandLower = product.brandName?.toLowerCase() ?? '';
        bool matchBrand = false;
        for (final brand in _filterSelectedBrands) {
          if (brandLower.contains(brand.toLowerCase()) ||
              brand.toLowerCase().contains(brandLower)) {
            matchBrand = true;
            break;
          }
        }
        if (!matchBrand) return false;
      }

      return true;
    }).toList();
  }

  Future<void> _navigateToFilters(double scale) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => FiltersScreen(
          initialPriceRange: _filterPriceRange,
          initialColors: _filterSelectedColors,
          initialSizes: _filterSelectedSizes,
          initialCategory: _filterSelectedCategory,
          initialBrands: _filterSelectedBrands,
          scale: scale,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _filterPriceRange = result['priceRange'];
        _filterSelectedColors = result['colors'];
        _filterSelectedSizes = result['sizes'];
        _filterSelectedCategory = result['category'];
        _filterSelectedBrands = result['brands'];
      });
    }
  }

  List<CategoryModel> _backendCategories = [];
  bool _isCategoriesLoading = false;
  CategoryModel? _selectedCategory;
  List<Product> _categoryProducts = [];
  bool _isCategoryProductsLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _isCategoriesLoading = true;
    });
    try {
      final sales = await _productService.getSaleProducts();
      final news = await _productService.getNewProducts();
      final cats = await _productService.getCategories();

      // Exclude products that are on sale from the new products list
      final saleIds = sales.map((p) => p.id).toSet();
      final uniqueNews = news.where((p) => !saleIds.contains(p.id)).toList();

      setState(() {
        _saleProducts = sales;
        _newProducts = uniqueNews;
        _backendCategories = cats;
        _isLoading = false;
        _isCategoriesLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isCategoriesLoading = false;
      });
      print('>>> Error loading products in UI: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final scale = (screenWidth / 375).clamp(0.5, 1.5).toDouble();
        final bannerH = (536 * scale)
            .clamp(280, 600.0)
            .toDouble(); // Tỷ lệ dài như thiết kế ảnh 1
        final cardW = (150 * scale).clamp(120, 240.0).toDouble();
        final cardH = (260 * scale).clamp(200, 380.0).toDouble();

        return Scaffold(
          backgroundColor: const Color(0xFFF9F9F9),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: [
                      _homeView == 'main'
                          ? _buildShopTab(
                              scale: scale,
                              bannerH: bannerH,
                              cardW: cardW,
                              cardH: cardH)
                          : CollectionsScreen(scale: scale),
                      _buildCategoriesTab(scale: scale),
                      const BagScreen(),
                      const FavoritesScreen(),
                      _ProfileTab(scale: scale),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _BottomBar(
            scale: scale,
            selectedIndex: _currentIndex,
            onTap: (i) {
              setState(() {
                if (i == 0 && _currentIndex == 0) {
                  _homeView = 'main';
                }
                _currentIndex = i;
              });
              if (i == 0 || i == 1) {
                _loadProducts();
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildShopTab({
    required double scale,
    required double bannerH,
    required double cardW,
    required double cardH,
  }) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFDB3022),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      color: const Color(0xFFDB3022),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Slide/Banner
            _BigBanner(
              height: bannerH,
              scale: scale,
              onCheckPressed: () {
                setState(() {
                  _homeView = 'collections';
                });
              },
            ),

            // Section 1: Sale
            if (_saleProducts.isNotEmpty) ...[
              _SectionHeader(
                scale: scale,
                title: 'Sale',
                subtitle: 'Super summer sale',
                onViewAll: () {},
              ),
              SizedBox(height: 12 * scale),
              SizedBox(
                height: cardH,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(left: 14 * scale),
                  itemCount: _saleProducts.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 16 * scale),
                      child: _ProductCard(
                        width: cardW,
                        height: cardH,
                        scale: scale,
                        product: _saleProducts[index],
                      ),
                    );
                  },
                ),
              ),
            ],

            SizedBox(height: 8 * scale),

            // Section 2: New
            _SectionHeader(
              scale: scale,
              title: 'New',
              subtitle: "You've never seen it before!",
              onViewAll: () {},
            ),
            SizedBox(height: 12 * scale),
            _newProducts.isEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.0 * scale, vertical: 8 * scale),
                    child: Text(
                      'Không có sản phẩm mới nào',
                      style: GoogleFonts.inter(
                          color: Colors.grey, fontSize: 14 * scale),
                    ),
                  )
                : SizedBox(
                    height: cardH,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.only(left: 14 * scale),
                      itemCount: _newProducts.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(right: 4 * scale),
                          child: _ProductCard(
                            width: cardW,
                            height: cardH,
                            scale: scale,
                            product: _newProducts[index],
                          ),
                        );
                      },
                    ),
                  ),
            SizedBox(height: 40 * scale),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesTab({required double scale}) {
    if (_currentShopView == 'category_products' && _selectedCategory != null) {
      return _buildCategoryProductsView(scale: scale);
    }
    if (_currentShopView == 'sub_clothes') {
      return _buildSubClothesView(scale: scale);
    }
    if (_currentShopView == 'sub_tops') {
      return _buildTopsView(scale: scale);
    }

    if (_isCategoriesLoading) {
      return Container(
        color: const Color(0xFFF9F9F9),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFDB3022),
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFFF9F9F9),
      child: Column(
        children: [
          // AppBar Categories
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(
                horizontal: 4 * scale, vertical: 8 * scale),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new,
                      color: const Color(0xFF222222), size: 18 * scale),
                  onPressed: () {
                    setState(() {
                      _currentIndex = 0; // Go back to Home
                    });
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Categories',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF222222),
                        fontWeight: FontWeight.w700,
                        fontSize: 18 * scale,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search,
                      color: const Color(0xFF222222), size: 24 * scale),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SearchScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          // Gender tabs
          Container(
            color: Colors.white,
            child: Row(
              children: [
                _buildGenderTab('Women', 0, scale),
                _buildGenderTab('Men', 1, scale),
                _buildGenderTab('Kids', 2, scale),
              ],
            ),
          ),
          // Divider below tabs
          Container(
            height: 1,
            color: const Color(0x0D000000),
          ),
          // Scrollable area
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: 16 * scale, vertical: 16 * scale),
              child: Column(
                children: [
                  // Summer Sales banner
                  _buildSummerSaleBanner(scale),
                  SizedBox(height: 16 * scale),

                  // Empty state check
                  if (_backendCategories.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 40 * scale),
                      child: Text(
                        'Không có danh mục nào',
                        style: GoogleFonts.inter(
                            fontSize: 14 * scale, color: Colors.grey),
                      ),
                    ),

                  // Categories list dynamically loaded
                  ..._backendCategories.where((cat) => cat.parentId == null || cat.parentId!.isEmpty).map((cat) {
                    final String fallbackImg =
                        '${AppConstants.baseUrl}/images/cat_${cat.categoryName.toLowerCase().replaceAll(" ", "_")}.jpg';
                    final String imgUrl =
                        (cat.image != null && cat.image!.isNotEmpty)
                            ? (cat.image!.startsWith('http')
                                ? cat.image!
                                : '${AppConstants.baseUrl}${cat.image}')
                            : fallbackImg;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16 * scale),
                      child: _buildCategoryCard(
                        cat.categoryName,
                        imgUrl,
                        scale,
                        () {
                          if (cat.categoryName.toLowerCase() == 'clothes') {
                            setState(() {
                              _currentShopView = 'sub_clothes';
                            });
                          } else {
                            _loadCategoryProducts(cat);
                          }
                        },
                      ),
                    );
                  }),
                  SizedBox(height: 24 * scale),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderTab(String text, int index, double scale) {
    final isSelected = _selectedGenderIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGenderIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12 * scale),
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 16 * scale,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF222222)
                      : const Color(0xFF9B9B9B),
                ),
              ),
            ),
            Container(
              height: 3 * scale,
              width: double.infinity,
              color: isSelected ? const Color(0xFFDB3022) : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummerSaleBanner(double scale) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFDB3022),
        borderRadius: BorderRadius.circular(8 * scale),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDB3022).withValues(alpha: 0.12),
            blurRadius: 8 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 26 * scale),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'SUMMER SALES',
            style: GoogleFonts.outfit(
              fontSize: 24 * scale,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            'Up to 50% off',
            style: GoogleFonts.inter(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
      String title, String imageUrl, double scale, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100 * scale,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6 * scale,
              offset: Offset(0, 2 * scale),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8 * scale),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 24 * scale),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF222222),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Image.network(
                  imageUrl,
                  height: 100 * scale,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFE0E0E0),
                      child: const Icon(Icons.image, color: Colors.grey),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubClothesView({required double scale}) {
    final clothesCat = _backendCategories.firstWhere(
      (c) => c.categoryName.toLowerCase() == 'clothes',
      orElse: () => CategoryModel(id: '', categoryName: '', active: false),
    );
    
    final List<String> subCategories = _backendCategories
        .where((c) => c.parentId == clothesCat.id)
        .map((c) => c.categoryName)
        .toList();

    if (subCategories.isEmpty) {
      subCategories.addAll([
        'Tops',
        'Shirts & Blouses',
        'Cardigans & Sweaters',
        'Knitwear',
        'Blazers',
        'Outerwear',
        'Pants',
        'Jeans',
        'Shorts',
        'Skirts',
        'Dresses',
      ]);
    }

    return Container(
      color: const Color(0xFFF9F9F9),
      child: Column(
        children: [
          // AppBar Categories
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(
                horizontal: 4 * scale, vertical: 8 * scale),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new,
                      color: const Color(0xFF222222), size: 18 * scale),
                  onPressed: () {
                    setState(() {
                      _currentShopView = 'main'; // Go back to main categories
                    });
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Categories',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF222222),
                        fontWeight: FontWeight.w700,
                        fontSize: 18 * scale,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search,
                      color: const Color(0xFF222222), size: 24 * scale),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SearchScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: 16 * scale, vertical: 16 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // VIEW ALL ITEMS button
                  SizedBox(
                    width: double.infinity,
                    height: 48 * scale,
                    child: ElevatedButton(
                      onPressed: () {
                        final clothesCats = _backendCategories.where(
                            (c) => c.categoryName.toLowerCase() == 'clothes');
                        if (clothesCats.isNotEmpty) {
                          _loadCategoryProducts(clothesCats.first);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDB3022),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24 * scale),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'VIEW ALL ITEMS',
                        style: GoogleFonts.inter(
                          fontSize: 14 * scale,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16 * scale),
                  Text(
                    'Choose category',
                    style: GoogleFonts.inter(
                      fontSize: 14 * scale,
                      color: const Color(0xFF9B9B9B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8 * scale),

                  // Sub-category Items List
                  ...subCategories
                      .map((subCat) => _buildSubCategoryRow(subCat, scale)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoryRow(String title, double scale) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0x0A000000),
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        contentPadding:
            EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16 * scale,
            color: const Color(0xFF222222),
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          _loadSubCategoryProducts(title);
        },
      ),
    );
  }

  Future<void> _loadCategoryProducts(CategoryModel category) async {
    setState(() {
      _selectedCategory = category;
      _isCategoryProductsLoading = true;
      _currentShopView = 'category_products';
    });
    try {
      final products = await _productService.getProductsByCategory(category.id);
      setState(() {
        _categoryProducts = products;
        _isCategoryProductsLoading = false;
      });
    } catch (e) {
      setState(() {
        _isCategoryProductsLoading = false;
      });
      print(
          '>>> Error loading products for category ${category.categoryName}: $e');
    }
  }

  Future<void> _loadSubCategoryProducts(String subCategoryName) async {
    setState(() {
      _selectedCategory = CategoryModel(
        id: '',
        categoryName: subCategoryName,
        categoryDescription: '',
        icon: '',
        image: '',
        placeholder: '',
        active: true,
      );
      _isCategoryProductsLoading = true;
      _currentShopView = 'category_products';
    });
    try {
      // Find the Clothes category from backend categories
      final clothesCat = _backendCategories.firstWhere(
        (c) => c.categoryName.toLowerCase() == 'clothes',
        orElse: () => _backendCategories.first,
      );
      // Load all clothes products
      final allClothes =
          await _productService.getProductsByCategory(clothesCat.id);

      // Filter products based on subcategory keywords
      List<Product> filtered = [];
      final name = subCategoryName.toLowerCase();

      if (name == 'tops') {
        filtered = allClothes.where((p) {
          final pName = p.productName.toLowerCase();
          return pName.contains('t-shirt') ||
              pName.contains('tshirt') ||
              pName.contains('hoodie') ||
              pName.contains('crop top') ||
              pName.contains('top');
        }).toList();
        if (filtered.isEmpty) {
          filtered = await _productService.getProductsByTag('TOPS');
        }
      } else if (name == 'shirts & blouses') {
        filtered = allClothes.where((p) {
          final pName = p.productName.toLowerCase();
          return (pName.contains('shirt') &&
                  !pName.contains('t-shirt') &&
                  !pName.contains('tshirt')) ||
              pName.contains('blouse');
        }).toList();
      } else if (name == 'cardigans & sweaters') {
        filtered = allClothes.where((p) {
          final pName = p.productName.toLowerCase();
          return pName.contains('cardigan') ||
              pName.contains('sweater') ||
              pName.contains('pullover') ||
              pName.contains('knitwear');
        }).toList();
      } else if (name == 'knitwear') {
        filtered = allClothes.where((p) {
          final pName = p.productName.toLowerCase();
          return pName.contains('knitwear') || pName.contains('knit');
        }).toList();
      } else if (name == 'blazers') {
        filtered = allClothes.where((p) {
          final pName = p.productName.toLowerCase();
          return pName.contains('blazer') || pName.contains('suit');
        }).toList();
      } else if (name == 'outerwear') {
        filtered = allClothes.where((p) {
          final pName = p.productName.toLowerCase();
          return pName.contains('jacket') ||
              pName.contains('coat') ||
              pName.contains('parka') ||
              pName.contains('hoodie') ||
              pName.contains('wear');
        }).toList();
      } else if (name == 'pants') {
        filtered = allClothes
            .where((p) => p.productName.toLowerCase().contains('pants'))
            .toList();
      } else if (name == 'jeans') {
        filtered = allClothes
            .where((p) => p.productName.toLowerCase().contains('jeans'))
            .toList();
      } else if (name == 'shorts') {
        filtered = allClothes
            .where((p) => p.productName.toLowerCase().contains('shorts'))
            .toList();
      } else if (name == 'skirts') {
        filtered = allClothes
            .where((p) => p.productName.toLowerCase().contains('skirt'))
            .toList();
      } else if (name == 'dresses') {
        filtered = allClothes
            .where((p) => p.productName.toLowerCase().contains('dress'))
            .toList();
      } else {
        filtered = allClothes;
      }

      setState(() {
        _categoryProducts = filtered;
        _isCategoryProductsLoading = false;
      });
    } catch (e) {
      setState(() {
        _isCategoryProductsLoading = false;
      });
      print('>>> Error loading subcategory products for $subCategoryName: $e');
    }
  }

  Widget _buildCategoryProductsView({required double scale}) {
    final List<String> tags = ['T-shirts', 'Crop tops', 'Sleeveless', 'Shirts'];
    final filtered = _applyFilters(_categoryProducts);
    final sortedProducts = List<Product>.from(filtered);
    if (_selectedSort == 'Popular') {
      sortedProducts
          .sort((a, b) => (b.reviewCount ?? 0).compareTo(a.reviewCount ?? 0));
    } else if (_selectedSort == 'Newest') {
      sortedProducts.sort((a, b) => b.id.compareTo(a.id));
    } else if (_selectedSort == 'Customer review') {
      sortedProducts.sort(
          (a, b) => (b.ratingAverage ?? 0.0).compareTo(a.ratingAverage ?? 0.0));
    } else if (_selectedSort == 'Price: lowest to high') {
      sortedProducts.sort((a, b) => a.salePrice.compareTo(b.salePrice));
    } else if (_selectedSort == 'Price: highest to low') {
      sortedProducts.sort((a, b) => b.salePrice.compareTo(a.salePrice));
    }

    return Container(
      color: const Color(0xFFF9F9F9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom AppBar
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(
                horizontal: 4 * scale, vertical: 8 * scale),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new,
                      color: const Color(0xFF222222), size: 18 * scale),
                  onPressed: () {
                    setState(() {
                      final name =
                          _selectedCategory?.categoryName.toLowerCase() ?? '';
                      final List<String> subCategories = [
                        'tops',
                        'shirts & blouses',
                        'cardigans & sweaters',
                        'knitwear',
                        'blazers',
                        'outerwear',
                        'pants',
                        'jeans',
                        'shorts',
                        'skirts',
                        'dresses',
                      ];
                      if (subCategories.contains(name)) {
                        _currentShopView = 'sub_clothes';
                      } else {
                        _currentShopView = 'main';
                      }
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.search,
                      color: const Color(0xFF222222), size: 24 * scale),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SearchScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          // Large Title
          Padding(
            padding: EdgeInsets.fromLTRB(
                16 * scale, 12 * scale, 16 * scale, 12 * scale),
            child: Text(
              _selectedCategory?.categoryName ?? 'Products',
              style: GoogleFonts.outfit(
                fontSize: 34 * scale,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF222222),
              ),
            ),
          ),

          // Horizontal Tags/Chips
          SizedBox(
            height: 36 * scale,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 16 * scale),
              itemCount: tags.length,
              itemBuilder: (context, index) {
                final tag = tags[index];
                return Padding(
                  padding: EdgeInsets.only(right: 8 * scale),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF222222),
                      borderRadius: BorderRadius.circular(29 * scale),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                    alignment: Alignment.center,
                    child: Text(
                      tag,
                      style: GoogleFonts.inter(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 12 * scale),

          // Filters and Sorting Bar
          Container(
            color: const Color(0xFFF9F9F9),
            padding: EdgeInsets.symmetric(
                horizontal: 16 * scale, vertical: 8 * scale),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Filters
                GestureDetector(
                  onTap: () => _navigateToFilters(scale),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Icon(Icons.filter_list,
                          size: 18 * scale, color: const Color(0xFF222222)),
                      SizedBox(width: 6 * scale),
                      Text(
                        'Filters',
                        style: GoogleFonts.inter(
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF222222),
                        ),
                      ),
                    ],
                  ),
                ),
                // Sorting
                GestureDetector(
                  onTap: () => _showSortBottomSheet(scale),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Icon(Icons.swap_vert,
                          size: 18 * scale, color: const Color(0xFF222222)),
                      SizedBox(width: 6 * scale),
                      Text(
                        _selectedSort,
                        style: GoogleFonts.inter(
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF222222),
                        ),
                      ),
                    ],
                  ),
                ),
                // Layout view switch icon
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isGridView = !_isGridView;
                    });
                  },
                  child: Icon(
                    _isGridView ? Icons.view_list : Icons.view_module,
                    size: 20 * scale,
                    color: const Color(0xFF222222),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8 * scale),

          // Product list
          Expanded(
            child: _isCategoryProductsLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFDB3022),
                    ),
                  )
                : sortedProducts.isEmpty
                    ? Center(
                        child: Text(
                          'Không tìm thấy sản phẩm nào',
                          style: GoogleFonts.inter(
                              fontSize: 14 * scale, color: Colors.grey),
                        ),
                      )
                    : _isGridView
                        ? GridView.builder(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16 * scale, vertical: 8 * scale),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16 * scale,
                              mainAxisSpacing: 26 * scale,
                              childAspectRatio: 0.59,
                            ),
                            itemCount: sortedProducts.length,
                            itemBuilder: (context, index) {
                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  return _ProductCard(
                                    width: constraints.maxWidth,
                                    height: constraints.maxHeight,
                                    scale: scale,
                                    product: sortedProducts[index],
                                  );
                                },
                              );
                            },
                          )
                        : ListView.builder(
                            padding:
                                EdgeInsets.symmetric(horizontal: 16 * scale),
                            itemCount: sortedProducts.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 24 * scale),
                                child: _buildTopsProductRowCard(
                                    sortedProducts[index], scale),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopsView({required double scale}) {
    final List<String> tags = ['T-shirts', 'Crop tops', 'Sleeveless', 'Shirts'];

    final filtered = _applyFilters(_topsProducts);
    final sortedProducts = List<Product>.from(filtered);
    if (_selectedSort == 'Popular') {
      sortedProducts
          .sort((a, b) => (b.reviewCount ?? 0).compareTo(a.reviewCount ?? 0));
    } else if (_selectedSort == 'Newest') {
      sortedProducts.sort((a, b) => b.id.compareTo(a.id));
    } else if (_selectedSort == 'Customer review') {
      sortedProducts.sort(
          (a, b) => (b.ratingAverage ?? 0.0).compareTo(a.ratingAverage ?? 0.0));
    } else if (_selectedSort == 'Price: lowest to high') {
      sortedProducts.sort((a, b) => a.salePrice.compareTo(b.salePrice));
    } else if (_selectedSort == 'Price: highest to low') {
      sortedProducts.sort((a, b) => b.salePrice.compareTo(a.salePrice));
    }

    return Container(
      color: const Color(0xFFF9F9F9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom AppBar
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(
                horizontal: 4 * scale, vertical: 8 * scale),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new,
                      color: const Color(0xFF222222), size: 18 * scale),
                  onPressed: () {
                    setState(() {
                      _currentShopView =
                          'sub_clothes'; // Go back to Clothes subcategories
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.search,
                      color: const Color(0xFF222222), size: 24 * scale),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SearchScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          // Large Title
          Padding(
            padding: EdgeInsets.fromLTRB(
                16 * scale, 12 * scale, 16 * scale, 12 * scale),
            child: Text(
              "Women's tops",
              style: GoogleFonts.outfit(
                fontSize: 34 * scale,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF222222),
              ),
            ),
          ),

          // Horizontal Tags/Chips
          SizedBox(
            height: 36 * scale,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 16 * scale),
              itemCount: tags.length,
              itemBuilder: (context, index) {
                final tag = tags[index];
                return Padding(
                  padding: EdgeInsets.only(right: 8 * scale),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF222222),
                      borderRadius: BorderRadius.circular(29 * scale),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                    alignment: Alignment.center,
                    child: Text(
                      tag,
                      style: GoogleFonts.inter(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 12 * scale),

          // Filters and Sorting Bar
          Container(
            color: const Color(0xFFF9F9F9),
            padding: EdgeInsets.symmetric(
                horizontal: 16 * scale, vertical: 8 * scale),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Filters
                GestureDetector(
                  onTap: () => _navigateToFilters(scale),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Icon(Icons.filter_list,
                          size: 18 * scale, color: const Color(0xFF222222)),
                      SizedBox(width: 6 * scale),
                      Text(
                        'Filters',
                        style: GoogleFonts.inter(
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF222222),
                        ),
                      ),
                    ],
                  ),
                ),
                // Sorting
                GestureDetector(
                  onTap: () => _showSortBottomSheet(scale),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Icon(Icons.swap_vert,
                          size: 18 * scale, color: const Color(0xFF222222)),
                      SizedBox(width: 6 * scale),
                      Text(
                        _selectedSort,
                        style: GoogleFonts.inter(
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF222222),
                        ),
                      ),
                    ],
                  ),
                ),
                // Layout view switch icon
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isGridView = !_isGridView;
                    });
                  },
                  child: Icon(
                    _isGridView ? Icons.view_list : Icons.view_module,
                    size: 20 * scale,
                    color: const Color(0xFF222222),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8 * scale),

          // Product list
          Expanded(
            child: _isTopsLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFDB3022),
                    ),
                  )
                : sortedProducts.isEmpty
                    ? Center(
                        child: Text(
                          'Không tìm thấy sản phẩm nào',
                          style: GoogleFonts.inter(
                              fontSize: 14 * scale, color: Colors.grey),
                        ),
                      )
                    : _isGridView
                        ? GridView.builder(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16 * scale, vertical: 8 * scale),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16 * scale,
                              mainAxisSpacing: 26 * scale,
                              childAspectRatio: 0.59,
                            ),
                            itemCount: sortedProducts.length,
                            itemBuilder: (context, index) {
                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  return _ProductCard(
                                    width: constraints.maxWidth,
                                    height: constraints.maxHeight,
                                    scale: scale,
                                    product: sortedProducts[index],
                                  );
                                },
                              );
                            },
                          )
                        : ListView.builder(
                            padding:
                                EdgeInsets.symmetric(horizontal: 16 * scale),
                            itemCount: sortedProducts.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 24 * scale),
                                child: _buildTopsProductRowCard(
                                    sortedProducts[index], scale),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  void _showSortBottomSheet(double scale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10 * scale),
                  Center(
                    child: Container(
                      width: 60 * scale,
                      height: 6 * scale,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC4C4C4),
                        borderRadius: BorderRadius.circular(3 * scale),
                      ),
                    ),
                  ),
                  SizedBox(height: 20 * scale),
                  Text(
                    'Sort by',
                    style: GoogleFonts.outfit(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF222222),
                    ),
                  ),
                  SizedBox(height: 20 * scale),
                  _buildSortOption('Popular', scale),
                  _buildSortOption('Newest', scale),
                  _buildSortOption('Customer review', scale),
                  _buildSortOption('Price: lowest to high', scale),
                  _buildSortOption('Price: highest to low', scale),
                  SizedBox(height: 24 * scale),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String optionName, double scale) {
    final isSelected = _selectedSort == optionName;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSort = optionName;
        });
        Navigator.pop(context);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding:
            EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
        color: isSelected ? const Color(0xFFDB3022) : Colors.transparent,
        child: Text(
          optionName,
          style: GoogleFonts.inter(
            fontSize: 16 * scale,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF222222),
          ),
        ),
      ),
    );
  }

  Widget _buildTopsProductRowCard(Product product, double scale) {
    final photoW = 104 * scale;
    final photoH = 104 * scale;
    final String fullImageUrl = product.imageUrl != null
        ? (product.imageUrl!.startsWith('http')
            ? product.imageUrl!
            : '${AppConstants.baseUrl}${product.imageUrl}')
        : '';

    final favProvider = context.watch<FavoritesProvider>();
    final bool isFavorited = favProvider.isFavorite(product.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 104 * scale,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8 * scale),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6 * scale,
                    offset: Offset(0, 2 * scale),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8 * scale),
                      bottomLeft: Radius.circular(8 * scale),
                    ),
                    child: fullImageUrl.isNotEmpty
                        ? Image.network(
                            fullImageUrl,
                            width: photoW,
                            height: photoH,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: photoW,
                                height: photoH,
                                color: const Color(0xFFC4C4C4),
                                child: const Icon(Icons.image,
                                    color: Colors.white),
                              );
                            },
                          )
                        : Container(
                            width: photoW,
                            height: photoH,
                            color: const Color(0xFFC4C4C4),
                          ),
                  ),

                  // Product Info
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12 * scale, vertical: 8 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.productName,
                                style: GoogleFonts.outfit(
                                  fontSize: 16 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF222222),
                                ),
                              ),
                              SizedBox(height: 2 * scale),
                              Text(
                                product.brandName ?? '',
                                style: GoogleFonts.inter(
                                  fontSize: 11 * scale,
                                  color: const Color(0xFF9B9B9B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          // Rating and Review Count
                          Row(
                            children: [
                              ...List.generate(5, (i) {
                                final isFilled =
                                    i < (product.ratingAverage ?? 0).floor();
                                return Icon(
                                  Icons.star,
                                  size: 13 * scale,
                                  color: isFilled
                                      ? const Color(0xFFFFBA49)
                                      : const Color(0xFF9B9B9B),
                                );
                              }),
                              SizedBox(width: 4 * scale),
                              Text(
                                '(${product.reviewCount ?? 0})',
                                style: GoogleFonts.inter(
                                  fontSize: 10 * scale,
                                  color: const Color(0xFF9B9B9B),
                                ),
                              ),
                            ],
                          ),

                          // Price
                          Text(
                            '${product.salePrice.round()}\$',
                            style: GoogleFonts.inter(
                              fontSize: 14 * scale,
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

            // Favorite button floating on bottom-right corner
            Positioned(
              right: 0,
              bottom: -12 * scale,
              child: GestureDetector(
                onTap: () {
                  final defaultSize = product.sizes.isNotEmpty ? product.sizes.first : 'M';
                  final defaultColor = product.colors.isNotEmpty ? product.colors.first : 'Black';
                  favProvider.toggle(product, defaultSize, defaultColor);
                },
                child: Container(
                  width: 36 * scale,
                  height: 36 * scale,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x1F000000),
                        blurRadius: 4 * scale,
                        offset: Offset(0, 4 * scale),
                      ),
                    ],
                  ),
                  child: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    size: 16 * scale,
                    color: isFavorited
                        ? const Color(0xFFDB3022)
                        : const Color(0xFF9B9B9B),
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

class _ProfileTab extends StatefulWidget {
  final double scale;
  const _ProfileTab({required this.scale});

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  String _currentView =
      'main'; // 'main', 'orders', 'order_details', or 'settings'
  OrderItemData? _selectedOrder;

  int _orderCount = 0;
  int _addressCount = 0;
  String _paymentMethodSummary = 'No payment methods';
  int _couponCount = 0;
  int _reviewCount = 0;
  bool _statsLoading = true;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    if (!mounted) return;
    setState(() {
      _statsLoading = true;
    });
    try {
      final stats = await _authService.getUserProfileStats();
      if (!mounted) return;
      setState(() {
        _orderCount = stats['orderCount'] ?? 0;
        _addressCount = stats['addressCount'] ?? 0;
        _paymentMethodSummary =
            stats['paymentMethodSummary'] ?? 'No payment methods';
        _couponCount = stats['couponCount'] ?? 0;
        _reviewCount = stats['reviewCount'] ?? 0;
        _statsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statsLoading = false;
      });
    }
  }

  Widget _buildInitialsAvatar(String initials, double scale) {
    return Container(
      width: 64 * scale,
      height: 64 * scale,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFDB3022), Color(0xFFFF9F43)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text(
        initials,
        style: GoogleFonts.outfit(
          fontSize: 20 * scale,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentView == 'orders') {
      return MyOrdersScreen(
        onBack: () {
          setState(() {
            _currentView = 'main';
          });
        },
        onOrderDetails: (order) {
          setState(() {
            _selectedOrder = order;
            _currentView = 'order_details';
          });
        },
      );
    }

    if (_currentView == 'order_details' && _selectedOrder != null) {
      return OrderDetailsScreen(
        order: _selectedOrder!,
        onBack: () {
          setState(() {
            _currentView = 'orders';
          });
        },
      );
    }

    if (_currentView == 'admin_products') {
      return AdminProductScreen(
        onBack: () {
          setState(() {
            _currentView = 'main';
          });
        },
        scale: widget.scale,
      );
    }

    if (_currentView == 'settings') {
      return SettingsScreen(
        onBack: () {
          setState(() {
            _currentView = 'main';
          });
        },
      );
    }

    if (_currentView == 'my_reviews') {
      return MyReviewsScreen(
        onBack: () {
          setState(() {
            _currentView = 'main';
          });
          _fetchStats();
        },
        scale: widget.scale,
      );
    }

    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    final String displayName = user?.name ?? 'Matilda Brown';
    final String displayEmail = user?.email ?? 'matildabrown@mail.com';
    final String initials = displayName.isNotEmpty
        ? displayName
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
            .take(2)
            .join()
        : '?';

    return Container(
      color: const Color(0xFFF9F9F9),
      child: SingleChildScrollView(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24 * widget.scale),

          // Search Icon at top right
          Padding(
            padding: EdgeInsets.only(right: 12 * widget.scale),
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.search,
                    size: 26 * widget.scale, color: const Color(0xFF222222)),
                onPressed: () {},
              ),
            ),
          ),

          // Large Title "My profile"
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * widget.scale),
            child: Text(
              'My profile',
              style: GoogleFonts.outfit(
                fontSize: 34 * widget.scale,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF222222),
              ),
            ),
          ),
          SizedBox(height: 24 * widget.scale),

          // Profile Header (Avatar + Name + Email)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * widget.scale),
            child: Row(
              children: [
                Container(
                  width: 64 * widget.scale,
                  height: 64 * widget.scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8 * widget.scale,
                        offset: Offset(0, 4 * widget.scale),
                      ),
                    ],
                  ),
                  child: user?.avatarUrl != null &&
                          user!.avatarUrl!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            user.avatarUrl!,
                            width: 64 * widget.scale,
                            height: 64 * widget.scale,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildInitialsAvatar(
                              initials,
                              widget.scale,
                            ),
                          ),
                        )
                      : _buildInitialsAvatar(initials, widget.scale),
                ),
                SizedBox(width: 18 * widget.scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: GoogleFonts.outfit(
                          fontSize: 18 * widget.scale,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF222222),
                        ),
                      ),
                      SizedBox(height: 4 * widget.scale),
                      Text(
                        displayEmail,
                        style: GoogleFonts.inter(
                          fontSize: 13 * widget.scale,
                          color: const Color(0xFF9B9B9B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 28 * widget.scale),

          // Menu Items List
          _buildMenuItem(
            title: 'My orders',
            subtitle: _statsLoading
                ? 'Loading...'
                : 'Already have $_orderCount orders',
            scale: widget.scale,
            onTap: () {
              setState(() {
                _currentView = 'orders';
              });
            },
          ),
          _buildMenuItem(
            title: 'Shipping addresses',
            subtitle: _statsLoading ? 'Loading...' : '$_addressCount addresses',
            scale: widget.scale,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ShippingAddressesScreen(selectMode: false),
                ),
              );
              _fetchStats();
            },
          ),
          _buildMenuItem(
            title: 'Payment methods',
            subtitle: _statsLoading ? 'Loading...' : _paymentMethodSummary,
            scale: widget.scale,
            onTap: () {},
          ),
          _buildMenuItem(
            title: 'Promocodes',
            subtitle: _statsLoading ? 'Loading...' : '$_couponCount promocodes',
            scale: widget.scale,
            onTap: () {},
          ),
          _buildMenuItem(
            title: 'My reviews',
            subtitle: _statsLoading
                ? 'Loading...'
                : 'Reviews for $_reviewCount items',
            scale: widget.scale,
            onTap: () {
              setState(() {
                _currentView = 'my_reviews';
              });
            },
          ),
          if (user != null && user.roles.contains('ROLE_ADMIN'))
            _buildMenuItem(
              title: 'Product Management',
              subtitle: 'Add, edit or delete products (Admin)',
              scale: widget.scale,
              onTap: () {
                setState(() {
                  _currentView = 'admin_products';
                });
              },
            ),
          _buildMenuItem(
            title: 'Settings',
            subtitle: 'Notifications, password',
            scale: widget.scale,
            onTap: () {
              setState(() {
                _currentView = 'settings';
              });
            },
          ),
          SizedBox(height: 16 * widget.scale),
          _buildMenuItem(
            title: 'Log out',
            subtitle: 'Sign out of your account',
            scale: widget.scale,
            onTap: () => _logout(context),
            isDestructive: true,
          ),
          SizedBox(height: 40 * widget.scale),
        ],
      ),
    ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required String subtitle,
    required double scale,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0x0A000000),
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 4 * scale),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16 * scale,
            fontWeight: FontWeight.w600,
            color: isDestructive
                ? const Color(0xFFDB3022)
                : const Color(0xFF222222),
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 2 * scale),
          child: Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11 * scale,
              color: const Color(0xFF9B9B9B),
            ),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: 20 * scale,
          color: const Color(0xFF9B9B9B),
        ),
      ),
    );
  }



  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đăng xuất?',
            style: TextStyle(color: Color(0xFF222222))),
        content: const Text(
          'Bạn có chắc muốn đăng xuất không?',
          style: TextStyle(color: Color(0xFF9B9B9B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                const Text('Hủy', style: TextStyle(color: Color(0xFF9B9B9B))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Đăng xuất',
                style: TextStyle(color: Color(0xFFDB3022))),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<CartProvider>().clearCart();
      context.read<FavoritesProvider>().clearFavorites();
      await context.read<AuthProvider>().logout();
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Big Banner (Supporting swipe carousel between Main 1 and Main 2 styles)
// ─────────────────────────────────────────────────────────────

class _BigBanner extends StatefulWidget {
  final double height;
  final double scale;
  final VoidCallback? onCheckPressed;

  const _BigBanner({
    required this.height,
    required this.scale,
    this.onCheckPressed,
  });

  @override
  State<_BigBanner> createState() => _BigBannerState();
}

class _BigBannerState extends State<_BigBanner> {
  int _activePage = 0;
  final _pageController = PageController();
  Timer? _timer;

  final List<Map<String, String>> _bannerItems = [
    {
      'image': '${AppConstants.baseUrl}/images/banner1.jpg',
      'title': 'Street\nclothes',
    },
    {
      'image': '${AppConstants.baseUrl}/images/banner2.jpg',
      'title': 'Fashion\nsale',
    }
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _activePage + 1;
        if (nextPage >= _bannerItems.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (page) => setState(() => _activePage = page),
            itemCount: _bannerItems.length,
            itemBuilder: (context, index) {
              final item = _bannerItems[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item['image']!,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: const Color(0xFFC4C4C4));
                    },
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0x7F000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 15 * widget.scale,
                    bottom: 60 * widget.scale,
                    child: Text(
                      item['title']!,
                      style: GoogleFonts.outfit(
                        fontSize: 44 * widget.scale,
                        height: 1.0,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [
                          const Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 6.0,
                            color: Color(0x3F000000),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          // Check button
          Positioned(
            left: 15 * widget.scale,
            bottom: 12 * widget.scale,
            child: SizedBox(
              width: 140 * widget.scale,
              height: 36 * widget.scale,
              child: ElevatedButton(
                onPressed: widget.onCheckPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDB3022),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25 * widget.scale),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0xFFD32626).withValues(alpha: 0.25),
                ),
                child: Text(
                  'Check',
                  style: GoogleFonts.inter(
                    fontSize: 14 * widget.scale,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final double scale;
  final String title;
  final String subtitle;
  final VoidCallback onViewAll;

  const _SectionHeader({
    required this.scale,
    required this.title,
    required this.subtitle,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14 * scale, 24 * scale, 14 * scale, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 34 * scale,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF222222),
                  height: 1.0,
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  'View all',
                  style: GoogleFonts.inter(
                    fontSize: 11 * scale,
                    color: const Color(0xFF222222),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4 * scale),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11 * scale,
              color: const Color(0xFF9B9B9B),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Product Card
// ─────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final double width;
  final double height;
  final double scale;
  final Product product;

  const _ProductCard({
    required this.width,
    required this.height,
    required this.scale,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final favProvider = context.watch<FavoritesProvider>();
    final bool isFavorited = favProvider.isFavorite(product.id);
    final photoH = height * 0.68;
    final topNew = 8 * scale;
    final leftNew = 10 * scale;
    final topRating = photoH + 5 * scale;
    final topFav = photoH - 18 * scale;
    final topBrand = photoH + 24 * scale;
    final topName = photoH + 39 * scale;
    final topPrice = photoH + 60 * scale;

    // Check discount
    final bool isOnSale = product.comparePrice != null &&
        product.comparePrice! > product.salePrice;
    int discountPercent = 0;
    if (isOnSale) {
      discountPercent = (((product.comparePrice! - product.salePrice) /
                  product.comparePrice!) *
              100)
          .round();
    }

    // Check if it has NEW tag
    final bool isNew =
        product.tags.any((t) => t.tagName.toUpperCase() == 'NEW');

    final String fullImageUrl = product.imageUrl != null
        ? (product.imageUrl!.startsWith('http')
            ? product.imageUrl!
            : '${AppConstants.baseUrl}${product.imageUrl}')
        : '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: width,
        height: height,
        child: Stack(
          children: [
            // Product photo
            Positioned(
              left: 0,
              top: 0,
              width: width,
              height: photoH,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8 * scale),
                child: fullImageUrl.isNotEmpty
                    ? Image.network(
                        fullImageUrl,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFC4C4C4),
                            child: const Icon(Icons.image, color: Colors.white),
                          );
                        },
                      )
                    : Container(
                        color: const Color(0xFFC4C4C4),
                      ),
              ),
            ),
            // Badge
            if (isOnSale)
              Positioned(
                left: leftNew,
                top: topNew,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8 * scale, vertical: 4 * scale),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDB3022),
                    borderRadius: BorderRadius.circular(29 * scale),
                  ),
                  child: Center(
                    child: Text(
                      '-$discountPercent%',
                      style: GoogleFonts.inter(
                        fontSize: 11 * scale,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              )
            else if (isNew)
              Positioned(
                left: leftNew,
                top: topNew,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8 * scale, vertical: 4 * scale),
                  decoration: BoxDecoration(
                    color: const Color(0xFF222222),
                    borderRadius: BorderRadius.circular(29 * scale),
                  ),
                  child: Center(
                    child: Text(
                      'NEW',
                      style: GoogleFonts.inter(
                        fontSize: 11 * scale,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            // Rating
            Positioned(
              left: 0,
              top: topRating,
              child: Row(
                children: [
                  ...List.generate(5, (i) {
                    final isFilled = i < (product.ratingAverage ?? 0).floor();
                    return Icon(
                      Icons.star,
                      size: 13 * scale,
                      color: isFilled
                          ? const Color(0xFFFFBA49)
                          : const Color(0xFF9B9B9B),
                    );
                  }),
                  SizedBox(width: 4 * scale),
                  Text(
                    '(${product.reviewCount ?? 0})',
                    style: GoogleFonts.inter(
                      fontSize: 10 * scale,
                      color: const Color(0xFF9B9B9B),
                    ),
                  ),
                ],
              ),
            ),
            // Favorite
            Positioned(
              right: 0,
              top: topFav,
              child: GestureDetector(
                onTap: () {
                  final defaultSize = product.sizes.isNotEmpty ? product.sizes.first : 'M';
                  final defaultColor = product.colors.isNotEmpty ? product.colors.first : 'Black';
                  favProvider.toggle(product, defaultSize, defaultColor);
                },
                child: Container(
                  width: 36 * scale,
                  height: 36 * scale,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x14000000),
                        blurRadius: 4 * scale,
                        offset: Offset(0, 4 * scale),
                      ),
                    ],
                  ),
                  child: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                      size: 16 * scale,
                      color: isFavorited
                          ? const Color(0xFFDB3022)
                          : const Color(0xFF9B9B9B)),
                ),
              ),
            ),
            // Brand
            Positioned(
              left: 1 * scale,
              top: topBrand,
              child: Text(
                product.brandName ?? '',
                style: GoogleFonts.inter(
                  fontSize: 11 * scale,
                  color: const Color(0xFF9B9B9B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Name
            Positioned(
              left: 1 * scale,
              top: topName,
              child: Text(
                product.productName,
                style: GoogleFonts.outfit(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF222222),
                ),
              ),
            ),
            // Price
            Positioned(
              left: 1 * scale,
              top: topPrice,
              child: isOnSale
                  ? Row(
                      children: [
                        Text(
                          '${product.comparePrice!.round()}\$',
                          style: GoogleFonts.inter(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF9B9B9B),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        SizedBox(width: 8 * scale),
                        Text(
                          '${product.salePrice.round()}\$',
                          style: GoogleFonts.inter(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFDB3022),
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
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bottom Tab Bar
// ─────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final double scale;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const _BottomBar({
    required this.scale,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12 * scale),
          topRight: Radius.circular(12 * scale),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0F000000),
            blurRadius: 20 * scale,
            offset: Offset(0, -4 * scale),
          ),
        ],
      ),
      padding: EdgeInsets.only(top: 8 * scale),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * scale),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _tabItem(Icons.home, 'Home', index: 0),
                  _tabItem(Icons.shopping_cart_outlined, 'Shop', index: 1),
                  _tabItem(
                      selectedIndex == 2
                          ? Icons.shopping_bag
                          : Icons.shopping_bag_outlined,
                      'Bag',
                      index: 2),
                  _tabItem(
                      selectedIndex == 3
                          ? Icons.favorite
                          : Icons.favorite_border,
                      'Favorites',
                      index: 3),
                  _tabItem(
                      selectedIndex == 4 ? Icons.person : Icons.person_outline,
                      'Profile',
                      index: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabItem(IconData icon, String label, {required int index}) {
    final isActive = selectedIndex == index;
    final color = isActive ? const Color(0xFFDB3022) : const Color(0xFF9B9B9B);
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24 * scale, color: color),
          SizedBox(height: 2 * scale),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10 * scale,
              color: color,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
