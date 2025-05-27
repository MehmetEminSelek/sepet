import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/product_model.dart';
import '../models/workspace_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/product_search_service.dart';

class ProductSearchScreen extends StatefulWidget {
  final String? workspaceId;

  const ProductSearchScreen({
    super.key,
    this.workspaceId,
  });

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _sepetNameController = TextEditingController();

  Platform _selectedPlatform = Platform.demo;
  String? _selectedCategory;
  List<ProductModel> _searchResults = [];
  List<ProductModel> _selectedProducts = [];
  List<String> _categories = [];
  bool _isLoading = false;
  bool _isCreatingSepet = false;

  final ProductSearchService _productService = ProductSearchService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCategories();
    _loadPopularProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _sepetNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Ürün Ara & Sepet Oluştur'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.search), text: 'Ara'),
            Tab(icon: Icon(Icons.shopping_cart), text: 'Sepet'),
            Tab(icon: Icon(Icons.trending_up), text: 'Popüler'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSearchTab(),
          _buildCartTab(),
          _buildPopularTab(),
        ],
      ),
      floatingActionButton: _selectedProducts.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _createSepetFromProducts,
              backgroundColor: AppColors.primaryBlue,
              icon: _isCreatingSepet
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.add_shopping_cart),
              label: Text(_isCreatingSepet
                  ? 'Oluşturuluyor...'
                  : 'Sepet Oluştur (${_selectedProducts.length})'),
            )
          : null,
    );
  }

  // 1️⃣ Arama sekmesi
  Widget _buildSearchTab() {
    return Column(
      children: [
        // Arama ve filtreler
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.cardBackground,
            border: Border(
              bottom: BorderSide(color: AppColors.borderLight),
            ),
          ),
          child: Column(
            children: [
              // Platform seçici
              Row(
                children: [
                  const Text('Platform: ',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<Platform>(
                      value: _selectedPlatform,
                      isExpanded: true,
                      items: Platform.values.map((platform) {
                        return DropdownMenuItem(
                          value: platform,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getPlatformColor(platform),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(platform.displayName),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (platform) {
                        if (platform != null) {
                          setState(() {
                            _selectedPlatform = platform;
                          });
                          _loadCategories();
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Arama çubuğu
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Ürün ara...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.backgroundSecondary,
                      ),
                      onSubmitted: (_) => _searchProducts(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _searchProducts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.search),
                  ),
                ],
              ),

              // Kategori filtresi
              if (_categories.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: const Text('Tümü'),
                            selected: _selectedCategory == null,
                            onSelected: (_) {
                              setState(() {
                                _selectedCategory = null;
                              });
                              _searchProducts();
                            },
                          ),
                        );
                      }

                      final category = _categories[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = category;
                            });
                            _searchProducts();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),

        // Arama sonuçları
        Expanded(
          child: _searchResults.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search,
                          size: 64, color: AppColors.textSecondary),
                      SizedBox(height: 16),
                      Text(
                        'Ürün aramak için yukarıdaki arama çubuğunu kullanın',
                        style: TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final product = _searchResults[index];
                    return _buildProductCard(product);
                  },
                ),
        ),
      ],
    );
  }

  // 2️⃣ Sepet sekmesi
  Widget _buildCartTab() {
    return Column(
      children: [
        // Sepet özeti
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.cardBackground,
            border: Border(
              bottom: BorderSide(color: AppColors.borderLight),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shopping_cart, color: AppColors.primaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    'Seçilen Ürünler (${_selectedProducts.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (_selectedProducts.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Toplam: ${_calculateTotalPrice().toStringAsFixed(2)} TL',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Seçilen ürünler listesi
        Expanded(
          child: _selectedProducts.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 64, color: AppColors.textSecondary),
                      SizedBox(height: 16),
                      Text(
                        'Henüz ürün seçmediniz',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Arama sekmesinden ürün ekleyin',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _selectedProducts.length,
                  itemBuilder: (context, index) {
                    final product = _selectedProducts[index];
                    return _buildSelectedProductCard(product);
                  },
                ),
        ),
      ],
    );
  }

  // 3️⃣ Popüler ürünler sekmesi
  Widget _buildPopularTab() {
    return FutureBuilder<List<ProductModel>>(
      future: _productService.getPopularProducts(_selectedPlatform),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('Popüler ürün bulunamadı'),
          );
        }

        final products = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductCard(product);
          },
        );
      },
    );
  }

  // Ürün kartı
  Widget _buildProductCard(ProductModel product) {
    final isSelected = _selectedProducts.any((p) => p.id == product.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: AppColors.primaryBlue, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Ürün resmi
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: product.categoryColor.withOpacity(0.1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.image_not_supported,
                      color: product.categoryColor,
                      size: 30,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Ürün bilgileri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.brand,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: product.categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.category,
                          style: TextStyle(
                            fontSize: 10,
                            color: product.categoryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: product.platformColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.platform.displayName,
                          style: TextStyle(
                            fontSize: 10,
                            color: product.platformColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '★ ${product.rating}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.warningOrange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Seç/Kaldır butonu
            IconButton(
              onPressed: () => _toggleProductSelection(product),
              icon: Icon(
                isSelected ? Icons.remove_circle : Icons.add_circle,
                color: isSelected ? AppColors.errorRed : AppColors.successGreen,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Seçilen ürün kartı
  Widget _buildSelectedProductCard(ProductModel product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: product.categoryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.shopping_basket,
            color: product.categoryColor,
            size: 20,
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${product.brand} • ${product.formattedPrice}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle, color: AppColors.errorRed),
          onPressed: () => _toggleProductSelection(product),
        ),
      ),
    );
  }

  // =============== HELPER METHODS ===============

  void _loadCategories() async {
    final categories = await _productService.getCategories(_selectedPlatform);
    setState(() {
      _categories = categories;
    });
  }

  void _loadPopularProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final products =
          await _productService.getPopularProducts(_selectedPlatform);
      setState(() {
        _searchResults = products;
      });
    } catch (e) {
      print('Popüler ürünler yüklenirken hata: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchProducts() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final products = await _productService.searchProducts(
        query: query,
        platform: _selectedPlatform,
        category: _selectedCategory,
        limit: 50,
      );

      setState(() {
        _searchResults = products;
      });
    } catch (e) {
      print('Ürün arama hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Arama hatası: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleProductSelection(ProductModel product) {
    setState(() {
      final isSelected = _selectedProducts.any((p) => p.id == product.id);
      if (isSelected) {
        _selectedProducts.removeWhere((p) => p.id == product.id);
      } else {
        _selectedProducts.add(product);
      }
    });
  }

  double _calculateTotalPrice() {
    return _selectedProducts.fold(0.0, (sum, product) => sum + product.price);
  }

  Color _getPlatformColor(Platform platform) {
    switch (platform) {
      case Platform.getir:
        return const Color(0xFF5D4037);
      case Platform.migros:
        return const Color(0xFFFF6F00);
      case Platform.a101:
        return const Color(0xFFD32F2F);
      case Platform.bim:
        return const Color(0xFF1976D2);
      case Platform.carrefour:
        return const Color(0xFF0277BD);
      case Platform.demo:
        return const Color(0xFF9E9E9E);
    }
  }

  void _createSepetFromProducts() async {
    if (_selectedProducts.isEmpty) return;

    // Sepet adı dialog'u göster
    final sepetName = await _showSepetNameDialog();
    if (sepetName == null || sepetName.isEmpty) return;

    setState(() {
      _isCreatingSepet = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firestoreService =
          Provider.of<FirestoreService>(context, listen: false);
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      // Workspace ID belirle
      String workspaceId = widget.workspaceId ?? 'default_ev';

      // Otomatik sepet oluştur
      final sepet = await _productService.createSepetFromProducts(
        products: _selectedProducts,
        sepetName: sepetName,
        workspaceId: workspaceId,
        userId: currentUser.uid,
        userName: currentUser.displayName ?? 'Kullanıcı',
        description:
            'Platform: ${_selectedPlatform.displayName} | ${_selectedProducts.length} ürün',
      );

      // Firestore'a kaydet
      await firestoreService.createSepet(
        name: sepet.name,
        description: sepet.description,
        workspaceId: sepet.workspaceId,
        members: sepet.members,
        memberIds: sepet.memberIds,
        createdBy: sepet.createdBy,
        createdByUserId: currentUser.uid,
        color: sepet.color,
        icon: sepet.icon,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$sepetName sepeti oluşturuldu!'),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Sepet oluşturma hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sepet oluşturulurken hata: $e'),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingSepet = false;
        });
      }
    }
  }

  Future<String?> _showSepetNameDialog() async {
    // Akıllı sepet adı önerisi al
    final suggestions =
        await _productService.getSepetSuggestions(_selectedProducts);
    _sepetNameController.text = suggestions.first;

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sepet Adı'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _sepetNameController,
                decoration: const InputDecoration(
                  labelText: 'Sepet adını girin',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              const Text(
                'Öneriler:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: suggestions.map((suggestion) {
                  return ActionChip(
                    label: Text(suggestion),
                    onPressed: () {
                      _sepetNameController.text = suggestion;
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _sepetNameController.text);
              },
              child: const Text('Oluştur'),
            ),
          ],
        );
      },
    );
  }
}
