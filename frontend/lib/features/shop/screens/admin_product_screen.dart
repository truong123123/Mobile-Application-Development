import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_nhat_truong/features/shop/models/product.dart';
import 'package:le_nhat_truong/features/shop/models/category.dart';
import 'package:le_nhat_truong/features/shop/services/product_service.dart';

class AdminProductScreen extends StatefulWidget {
  final VoidCallback onBack;
  final double scale;

  const AdminProductScreen({
    super.key,
    required this.onBack,
    required this.scale,
  });

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  final _productService = ProductService();
  List<Product> _allProducts = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = true;
  String _searchQuery = "";

  // Available image presets for easy picking
  final List<String> _imagePresets = [
    '/images/product1.jpg',
    '/images/product2.jpg',
    '/images/product3.jpg',
    '/images/top1.jpg',
    '/images/top2.jpg',
    '/images/top3.jpg',
    '/images/top4.jpg',
    '/images/image.png',
    '/images/image (1).png',
    '/images/image (2).png',
    '/images/image (3).png',
    '/images/image (4).png',
    '/images/image (5).png',
    '/images/image (6).png',
    '/images/image (7).png',
    '/images/image (8).png',
    '/images/image (9).png',
    '/images/jang wonyoung.jpg',
    '/images/z7888710050382_c815de657ca1f5b7ddcbf867874e8f03.jpg',
    '/images/z7888710132105_a4427b5a67d19b57addc1da878907bb5.jpg',
    '/images/z7888714530900_1a586e868ae3ca7b027c8a45b41c0d1b.jpg',
    '/images/z7888714623412_9757291a319e139f66e190e235c71734.jpg',
    '/images/z7889472051071_732f5bad4ebafe1b181a790c05127cd2.jpg',
    '/images/z7889472114938_990a1e9bb7b8741d00593e620a50ab96.jpg',
    '/images/z7896061153845_9b96b466a48f9b69b37bef5bba366cd6.jpg',
    '/images/z7896061153897_a1affd7cafd0e1981adaca17c1a00f05.jpg',
    '/images/z7896061215982_3e3ff4b587a384f8f26741ae8971bdd5.jpg',
    '/images/z7896061244018_33d1f0a4cc39f828e69a0ff3725f7383.jpg',
    '/images/z7896061272915_47399beb55c4afe59a7ae310a066eefe.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final products = await _productService.getAllProducts();
      final cats = await _productService.getCategories();
      setState(() {
        _allProducts = products;
        _categories = cats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
      );
    }
  }

  List<Product> get _filteredProducts {
    if (_searchQuery.isEmpty) return _allProducts;
    final q = _searchQuery.toLowerCase();
    return _allProducts.where((p) {
      return p.productName.toLowerCase().contains(q) ||
          (p.brandName != null && p.brandName!.toLowerCase().contains(q));
    }).toList();
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa'),
        content: Text(
            'Bạn có chắc chắn muốn xóa sản phẩm "${product.productName}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                const Text('Hủy', style: TextStyle(color: Color(0xFF9B9B9B))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Xóa', style: TextStyle(color: Color(0xFFDB3022))),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _productService.deleteProduct(product.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa sản phẩm thành công!')),
        );
        _loadData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa sản phẩm: $e')),
        );
      }
    }
  }

  void _openProductForm({Product? product}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return _ProductFormSheet(
          product: product,
          categories: _categories,
          imagePresets: _imagePresets,
          scale: widget.scale,
          onSave: (data) async {
            try {
              if (product == null) {
                // Check duplicate product name locally
                final isDup = _allProducts.any((p) =>
                    p.productName.trim().toLowerCase() ==
                    data['productName'].toString().trim().toLowerCase());
                if (isDup) {
                  throw Exception(
                      'Sản phẩm có tên "${data['productName']}" đã tồn tại trên hệ thống!');
                }
                await _productService.createProduct(data);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thêm sản phẩm thành công!')),
                );
              } else {
                // Check duplicate product name locally for edit
                final isDup = _allProducts.any((p) =>
                    p.id != product.id &&
                    p.productName.trim().toLowerCase() ==
                        data['productName'].toString().trim().toLowerCase());
                if (isDup) {
                  throw Exception(
                      'Sản phẩm có tên "${data['productName']}" đã tồn tại trên hệ thống!');
                }
                await _productService.updateProduct(product.id, data);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Cập nhật sản phẩm thành công!')),
                );
              }
              Navigator.pop(context);
              _loadData();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFFDB3022),
                  content: Text(e.toString().replaceAll('Exception: ', '')),
                ),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double scale = widget.scale;
    return Container(
      color: const Color(0xFFF9F9F9),
      child: Column(
        children: [
          // Custom AppBar
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(
                horizontal: 4 * scale, vertical: 4 * scale),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: const Color(0xFF222222), size: 24 * scale),
                  onPressed: widget.onBack,
                ),
                Expanded(
                  child: Text(
                    'Product Management',
                    style: GoogleFonts.outfit(
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF222222),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh,
                      color: const Color(0xFFDB3022), size: 24 * scale),
                  onPressed: _loadData,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),

          // Body
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFDB3022))))
                : Column(
                    children: [
                      // Search Box
                      Padding(
                        padding: EdgeInsets.all(16 * scale),
                        child: TextField(
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search products by name or brand...',
                            hintStyle: GoogleFonts.inter(
                                fontSize: 14 * scale,
                                color: const Color(0xFF9B9B9B)),
                            prefixIcon: Icon(Icons.search,
                                color: const Color(0xFF9B9B9B),
                                size: 20 * scale),
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 12 * scale),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(12 * scale),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(12 * scale),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),

                      // Products count
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16 * scale),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Products: ${_filteredProducts.length}',
                              style: GoogleFonts.inter(
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF222222),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _openProductForm(),
                              icon: Icon(Icons.add,
                                  size: 18 * scale,
                                  color: const Color(0xFFDB3022)),
                              label: Text(
                                'Add Product',
                                style: GoogleFonts.inter(
                                  fontSize: 14 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFDB3022),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Product List
                      Expanded(
                        child: _filteredProducts.isEmpty
                            ? Center(
                                child: Text(
                                  'No products found.',
                                  style: GoogleFonts.inter(
                                      fontSize: 14 * scale,
                                      color: const Color(0xFF9B9B9B)),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _filteredProducts.length,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16 * scale,
                                    vertical: 8 * scale),
                                itemBuilder: (context, index) {
                                  final product =
                                      _filteredProducts[index];
                                  return _buildProductCard(product, scale);
                                },
                              ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product, double scale) {
    final imageUrl = product.imageUrl != null && product.imageUrl!.isNotEmpty
        ? (product.imageUrl!.startsWith('http')
            ? product.imageUrl!
            : 'http://127.0.0.1:8080${product.imageUrl}')
        : 'http://127.0.0.1:8080/images/product1.jpg';

    return Container(
      margin: EdgeInsets.only(bottom: 12 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12 * scale),
        child: Row(
          children: [
            // Product image
            Container(
              width: 90 * scale,
              height: 90 * scale,
              color: Colors.grey[100],
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.image,
                    size: 30 * scale, color: const Color(0xFF9B9B9B)),
              ),
            ),
            SizedBox(width: 12 * scale),

            // Product details
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brandName ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 11 * scale,
                        color: const Color(0xFF9B9B9B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2 * scale),
                    Text(
                      product.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF222222),
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    Row(
                      children: [
                        Text(
                          '${product.salePrice.round()}\$',
                          style: GoogleFonts.inter(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFDB3022),
                          ),
                        ),
                        if (product.comparePrice != null &&
                            product.comparePrice! > product.salePrice) ...[
                          SizedBox(width: 8 * scale),
                          Text(
                            '${product.comparePrice!.round()}\$',
                            style: GoogleFonts.inter(
                              fontSize: 12 * scale,
                              color: const Color(0xFF9B9B9B),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4 * scale),
                    // Categories text representation
                    Text(
                      'Qty: ${product.quantity} | Type: ${product.productType ?? "simple"}',
                      style: GoogleFonts.inter(
                        fontSize: 11 * scale,
                        color: const Color(0xFF9B9B9B),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions (Edit/Delete)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined,
                      color: const Color(0xFF9B9B9B), size: 20 * scale),
                  onPressed: () => _openProductForm(product: product),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: const Color(0xFFDB3022), size: 20 * scale),
                  onPressed: () => _deleteProduct(product),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductFormSheet extends StatefulWidget {
  final Product? product;
  final List<CategoryModel> categories;
  final List<String> imagePresets;
  final double scale;
  final Function(Map<String, dynamic>) onSave;

  const _ProductFormSheet({
    required this.product,
    required this.categories,
    required this.imagePresets,
    required this.scale,
    required this.onSave,
  });

  @override
  State<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<_ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _imageController;
  late TextEditingController _salePriceController;
  late TextEditingController _comparePriceController;
  late TextEditingController _qtyController;
  late TextEditingController _shortDescController;
  late TextEditingController _descController;
  late TextEditingController _typeController;

  // Selected multi-value sets
  final Set<String> _selectedCategories = {};
  final Set<String> _selectedTags = {};
  final Set<String> _selectedSizes = {};
  final Set<String> _selectedColors = {};

  final List<String> _allSizes = [
    'XS',
    'S',
    'M',
    'L',
    'XL',
    'One Size',
    '39',
    '40',
    '41',
    '42',
    '43'
  ];
  final List<String> _allColors = [
    'Black',
    'White',
    'Red',
    'Blue',
    'Beige',
    'Gray',
    'Navy',
    'Gold',
    'Silver',
    'Brown'
  ];
  final List<String> _allTags = ['NEW', 'SALE', 'TOPS'];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.productName ?? '');
    _brandController = TextEditingController(text: p?.brandName ?? '');
    _imageController = TextEditingController(text: p?.imageUrl ?? '');
    _salePriceController =
        TextEditingController(text: p?.salePrice.round().toString() ?? '');
    _comparePriceController = TextEditingController(
        text:
            p?.comparePrice != null ? p!.comparePrice!.round().toString() : '');
    _qtyController =
        TextEditingController(text: p?.quantity.toString() ?? '50');
    _shortDescController =
        TextEditingController(text: p?.shortDescription ?? '');
    _descController = TextEditingController(text: p?.productDescription ?? '');
    _typeController = TextEditingController(text: p?.productType ?? 'simple');

    if (p != null) {
      _selectedCategories.addAll(p.categoryIds);
      _selectedTags.addAll(p.tags.map((t) => t.tagName.toUpperCase()));
      _selectedSizes.addAll(p.sizes);
      _selectedColors.addAll(p.colors);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _imageController.dispose();
    _salePriceController.dispose();
    _comparePriceController.dispose();
    _qtyController.dispose();
    _shortDescController.dispose();
    _descController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFFDB3022),
            content: Text('Vui lòng chọn ít nhất một Danh mục (Category)'),
          ),
        );
        return;
      }
      final data = {
        'productName': _nameController.text.trim(),
        'brandName': _brandController.text.trim(),
        'imageUrl': _imageController.text.trim(),
        'salePrice': double.tryParse(_salePriceController.text) ?? 0.0,
        'comparePrice': double.tryParse(_comparePriceController.text),
        'quantity': int.tryParse(_qtyController.text) ?? 50,
        'shortDescription': _shortDescController.text.trim(),
        'productDescription': _descController.text.trim(),
        'productType': _typeController.text.trim(),
        'tags': _selectedTags.toList(),
        'sizes': _selectedSizes.toList(),
        'colors': _selectedColors.toList(),
        'categoryIds': _selectedCategories.toList(),
      };
      widget.onSave(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double scale = widget.scale;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        children: [
          // Header handle
          Container(
            width: 40 * scale,
            height: 4 * scale,
            margin: EdgeInsets.symmetric(vertical: 12 * scale),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2 * scale),
            ),
          ),

          // Form Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * scale),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.product == null ? 'Add New Product' : 'Edit Product',
                  style: GoogleFonts.outfit(
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF222222),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF222222)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(),

          // Form Fields List
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20 * scale),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    _buildLabel('Product Name *', scale),
                    TextFormField(
                      controller: _nameController,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Nhập tên sản phẩm'
                          : null,
                      decoration: _buildInputDecoration(
                          'e.g., Casual Denim Jacket', scale),
                    ),
                    SizedBox(height: 16 * scale),

                    // Brand Name
                    _buildLabel('Brand Name', scale),
                    TextFormField(
                      controller: _brandController,
                      decoration:
                          _buildInputDecoration('e.g., Mango, adidas', scale),
                    ),
                    SizedBox(height: 16 * scale),

                    // Image Preset Selector
                    _buildLabel('Select Product Image Preset', scale),
                    SizedBox(
                      height: 70 * scale,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.imagePresets.length,
                        itemBuilder: (context, idx) {
                          final imgPath = widget.imagePresets[idx];
                          final isSelected = _imageController.text == imgPath;
                          final netUrl = 'http://127.0.0.1:8080$imgPath';
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _imageController.text = imgPath;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 10 * scale),
                              width: 60 * scale,
                              height: 60 * scale,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFDB3022)
                                      : Colors.grey[300]!,
                                  width: isSelected ? 2.5 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8 * scale),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6 * scale),
                                child: Image.network(
                                  netUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, o, s) => Icon(Icons.image,
                                      size: 20 * scale, color: Colors.grey),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 10 * scale),

                    // Image URL text input
                    _buildLabel('Image URL / Path', scale),
                    TextFormField(
                      controller: _imageController,
                      decoration: _buildInputDecoration(
                          'e.g., /images/product1.jpg', scale),
                    ),
                    SizedBox(height: 16 * scale),

                    // Prices (Sale, Compare)
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Sale Price (\$) *', scale),
                              TextFormField(
                                controller: _salePriceController,
                                keyboardType: TextInputType.number,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Nhập giá bán';
                                  }
                                  if (double.tryParse(val) == null) {
                                    return 'Giá số hợp lệ';
                                  }
                                  return null;
                                },
                                decoration:
                                    _buildInputDecoration('e.g., 99', scale),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16 * scale),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Compare Price (\$)', scale),
                              TextFormField(
                                controller: _comparePriceController,
                                keyboardType: TextInputType.number,
                                validator: (val) {
                                  if (val != null &&
                                      val.trim().isNotEmpty &&
                                      double.tryParse(val) == null) {
                                    return 'Giá số hợp lệ';
                                  }
                                  return null;
                                },
                                decoration:
                                    _buildInputDecoration('e.g., 149', scale),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16 * scale),

                    // Quantity and Product Type
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Quantity *', scale),
                              TextFormField(
                                controller: _qtyController,
                                keyboardType: TextInputType.number,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Nhập số lượng';
                                  }
                                  if (int.tryParse(val) == null) {
                                    return 'Số nguyên hợp lệ';
                                  }
                                  return null;
                                },
                                decoration:
                                    _buildInputDecoration('e.g., 50', scale),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16 * scale),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Product Type', scale),
                              TextFormField(
                                controller: _typeController,
                                decoration: _buildInputDecoration(
                                    'e.g., simple', scale),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16 * scale),

                    // Descriptions
                    _buildLabel('Short Description *', scale),
                    TextFormField(
                      controller: _shortDescController,
                      maxLines: 2,
                      maxLength: 165,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Nhập mô tả ngắn'
                          : null,
                      decoration: _buildInputDecoration(
                          'Short details for listing card...', scale),
                    ),
                    SizedBox(height: 16 * scale),

                    _buildLabel('Full Description *', scale),
                    TextFormField(
                      controller: _descController,
                      maxLines: 4,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Nhập mô tả đầy đủ'
                          : null,
                      decoration: _buildInputDecoration(
                          'Detailed specifications and description...', scale),
                    ),
                    SizedBox(height: 20 * scale),

                    // Categories Selector
                    _buildLabel('Select Categories *', scale),
                    Wrap(
                      spacing: 8 * scale,
                      runSpacing: 8 * scale,
                      children: widget.categories.map((cat) {
                        final isSelected = _selectedCategories.contains(cat.id);
                        return FilterChip(
                          selected: isSelected,
                          selectedColor: const Color(0xFFFFEAEA),
                          checkmarkColor: const Color(0xFFDB3022),
                          labelStyle: GoogleFonts.inter(
                            fontSize: 13 * scale,
                            color: isSelected
                                ? const Color(0xFFDB3022)
                                : const Color(0xFF222222),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10 * scale),
                            side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFFDB3022)
                                    : Colors.grey[300]!),
                          ),
                          label: Text(cat.categoryName),
                          onSelected: (val) {
                            setState(() {
                              if (val) {
                                _selectedCategories.add(cat.id);
                              } else {
                                _selectedCategories.remove(cat.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16 * scale),

                    // Sizes Selector
                    _buildLabel('Select Sizes', scale),
                    Wrap(
                      spacing: 8 * scale,
                      runSpacing: 8 * scale,
                      children: _allSizes.map((size) {
                        final isSelected = _selectedSizes.contains(size);
                        return FilterChip(
                          selected: isSelected,
                          selectedColor: const Color(0xFFFFEAEA),
                          checkmarkColor: const Color(0xFFDB3022),
                          labelStyle: GoogleFonts.inter(
                            fontSize: 13 * scale,
                            color: isSelected
                                ? const Color(0xFFDB3022)
                                : const Color(0xFF222222),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10 * scale),
                            side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFFDB3022)
                                    : Colors.grey[300]!),
                          ),
                          label: Text(size),
                          onSelected: (val) {
                            setState(() {
                              if (val) {
                                _selectedSizes.add(size);
                              } else {
                                _selectedSizes.remove(size);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16 * scale),

                    // Colors Selector
                    _buildLabel('Select Colors', scale),
                    Wrap(
                      spacing: 8 * scale,
                      runSpacing: 8 * scale,
                      children: _allColors.map((color) {
                        final isSelected = _selectedColors.contains(color);
                        return FilterChip(
                          selected: isSelected,
                          selectedColor: const Color(0xFFFFEAEA),
                          checkmarkColor: const Color(0xFFDB3022),
                          labelStyle: GoogleFonts.inter(
                            fontSize: 13 * scale,
                            color: isSelected
                                ? const Color(0xFFDB3022)
                                : const Color(0xFF222222),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10 * scale),
                            side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFFDB3022)
                                    : Colors.grey[300]!),
                          ),
                          label: Text(color),
                          onSelected: (val) {
                            setState(() {
                              if (val) {
                                _selectedColors.add(color);
                              } else {
                                _selectedColors.remove(color);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16 * scale),

                    // Tags Selector
                    _buildLabel('Select Tags', scale),
                    Wrap(
                      spacing: 8 * scale,
                      runSpacing: 8 * scale,
                      children: _allTags.map((tag) {
                        final isSelected = _selectedTags.contains(tag);
                        return FilterChip(
                          selected: isSelected,
                          selectedColor: const Color(0xFFFFEAEA),
                          checkmarkColor: const Color(0xFFDB3022),
                          labelStyle: GoogleFonts.inter(
                            fontSize: 13 * scale,
                            color: isSelected
                                ? const Color(0xFFDB3022)
                                : const Color(0xFF222222),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10 * scale),
                            side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFFDB3022)
                                    : Colors.grey[300]!),
                          ),
                          label: Text(tag),
                          onSelected: (val) {
                            setState(() {
                              if (val) {
                                _selectedTags.add(tag);
                              } else {
                                _selectedTags.remove(tag);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 32 * scale),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 48 * scale,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDB3022),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24 * scale),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFFDB3022).withValues(alpha: 0.3),
                        ),
                        onPressed: _submit,
                        child: Text(
                          widget.product == null
                              ? 'CREATE PRODUCT'
                              : 'SAVE CHANGES',
                          style: GoogleFonts.inter(
                            fontSize: 15 * scale,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, double scale) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6 * scale, top: 4 * scale),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13 * scale,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF222222),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, double scale) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
          fontSize: 13 * scale, color: const Color(0xFF9B9B9B)),
      fillColor: const Color(0xFFF9F9F9),
      filled: true,
      contentPadding:
          EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 10 * scale),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10 * scale),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10 * scale),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10 * scale),
        borderSide: const BorderSide(color: Color(0xFFDB3022)),
      ),
    );
  }
}
