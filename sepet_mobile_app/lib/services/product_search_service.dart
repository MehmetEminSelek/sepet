import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/sepet_model.dart';
import '../models/sepet_item_model.dart';

class ProductSearchService {
  static final ProductSearchService _instance =
      ProductSearchService._internal();
  factory ProductSearchService() => _instance;
  ProductSearchService._internal();

  // Demo API endpoints (gerçek entegrasyon için değiştirilecek)
  static const String _getirApiBase = 'https://api.getir.com/v1';
  static const String _migrosApiBase = 'https://api.migros.com.tr/v1';
  static const String _a101ApiBase = 'https://api.a101.com.tr/v1';

  // Ürün arama
  Future<List<ProductModel>> searchProducts({
    required String query,
    required Platform platform,
    int limit = 20,
    String? category,
  }) async {
    try {
      print('🔍 Ürün aranıyor: "$query" - Platform: ${platform.displayName}');

      // Demo data için
      if (platform == Platform.demo) {
        return _getDemoProducts(query, limit);
      }

      // Gerçek API çağrıları (şimdilik demo data döndürüyoruz)
      return _searchFromPlatform(platform, query, limit, category);
    } catch (e) {
      print('❌ Ürün arama hatası: $e');
      return [];
    }
  }

  // Platform'dan ürün ara
  Future<List<ProductModel>> _searchFromPlatform(
    Platform platform,
    String query,
    int limit,
    String? category,
  ) async {
    // Şimdilik demo data döndürüyoruz
    // Gerçek entegrasyon için her platform'un API'si kullanılacak
    return _getDemoProducts(query, limit);
  }

  // Demo ürünler
  List<ProductModel> _getDemoProducts(String query, int limit) {
    final allProducts = [
      // Süt ürünleri
      ProductModel(
        id: '1',
        name: 'Süt 1L',
        description: 'Tam yağlı süt',
        price: 8.50,
        currency: 'TL',
        category: 'Süt Ürünleri',
        brand: 'Pınar',
        imageUrl: 'https://via.placeholder.com/150x150/4CAF50/white?text=Süt',
        platform: Platform.demo,
        unit: 'litre',
        inStock: true,
        rating: 4.5,
        reviewCount: 1250,
      ),
      ProductModel(
        id: '2',
        name: 'Yoğurt 500g',
        description: 'Doğal yoğurt',
        price: 6.75,
        currency: 'TL',
        category: 'Süt Ürünleri',
        brand: 'Danone',
        imageUrl:
            'https://via.placeholder.com/150x150/2196F3/white?text=Yoğurt',
        platform: Platform.demo,
        unit: 'gram',
        inStock: true,
        rating: 4.3,
        reviewCount: 890,
      ),

      // Meyve sebze
      ProductModel(
        id: '3',
        name: 'Elma 1kg',
        description: 'Taze kırmızı elma',
        price: 12.00,
        currency: 'TL',
        category: 'Meyve & Sebze',
        brand: 'Yerel Üretici',
        imageUrl: 'https://via.placeholder.com/150x150/F44336/white?text=Elma',
        platform: Platform.demo,
        unit: 'kilogram',
        inStock: true,
        rating: 4.7,
        reviewCount: 2100,
      ),
      ProductModel(
        id: '4',
        name: 'Domates 1kg',
        description: 'Taze domates',
        price: 15.50,
        currency: 'TL',
        category: 'Meyve & Sebze',
        brand: 'Yerel Üretici',
        imageUrl:
            'https://via.placeholder.com/150x150/FF5722/white?text=Domates',
        platform: Platform.demo,
        unit: 'kilogram',
        inStock: true,
        rating: 4.2,
        reviewCount: 1560,
      ),

      // Ekmek
      ProductModel(
        id: '5',
        name: 'Ekmek',
        description: 'Taze ekmek',
        price: 3.50,
        currency: 'TL',
        category: 'Ekmek & Unlu Mamul',
        brand: 'Uno',
        imageUrl: 'https://via.placeholder.com/150x150/795548/white?text=Ekmek',
        platform: Platform.demo,
        unit: 'adet',
        inStock: true,
        rating: 4.4,
        reviewCount: 3200,
      ),

      // Temizlik
      ProductModel(
        id: '6',
        name: 'Bulaşık Deterjanı',
        description: 'Limonlu bulaşık deterjanı',
        price: 18.90,
        currency: 'TL',
        category: 'Temizlik',
        brand: 'Fairy',
        imageUrl:
            'https://via.placeholder.com/150x150/FFEB3B/black?text=Deterjan',
        platform: Platform.demo,
        unit: 'şişe',
        inStock: true,
        rating: 4.6,
        reviewCount: 980,
      ),

      // Atıştırmalık
      ProductModel(
        id: '7',
        name: 'Cips 150g',
        description: 'Tuzlu patates cipsi',
        price: 7.25,
        currency: 'TL',
        category: 'Atıştırmalık',
        brand: 'Lays',
        imageUrl: 'https://via.placeholder.com/150x150/FF9800/white?text=Cips',
        platform: Platform.demo,
        unit: 'paket',
        inStock: true,
        rating: 4.1,
        reviewCount: 750,
      ),

      // İçecek
      ProductModel(
        id: '8',
        name: 'Kola 1L',
        description: 'Gazlı içecek',
        price: 9.50,
        currency: 'TL',
        category: 'İçecek',
        brand: 'Coca Cola',
        imageUrl: 'https://via.placeholder.com/150x150/212121/white?text=Kola',
        platform: Platform.demo,
        unit: 'şişe',
        inStock: true,
        rating: 4.0,
        reviewCount: 1800,
      ),
    ];

    // Arama query'sine göre filtrele
    final filteredProducts = allProducts
        .where((product) {
          final searchQuery = query.toLowerCase();
          return product.name.toLowerCase().contains(searchQuery) ||
              product.description.toLowerCase().contains(searchQuery) ||
              product.category.toLowerCase().contains(searchQuery) ||
              product.brand.toLowerCase().contains(searchQuery);
        })
        .take(limit)
        .toList();

    return filteredProducts;
  }

  // Kategorileri getir
  Future<List<String>> getCategories(Platform platform) async {
    return [
      'Süt Ürünleri',
      'Meyve & Sebze',
      'Et & Tavuk',
      'Ekmek & Unlu Mamul',
      'Temizlik',
      'Atıştırmalık',
      'İçecek',
      'Dondurulmuş',
      'Kahvaltılık',
      'Bebek',
      'Kişisel Bakım',
      'Ev & Yaşam',
    ];
  }

  // Popüler ürünleri getir
  Future<List<ProductModel>> getPopularProducts(Platform platform) async {
    final products = await searchProducts(
      query: '',
      platform: platform,
      limit: 10,
    );

    // Rating'e göre sırala
    products.sort((a, b) => b.rating.compareTo(a.rating));
    return products;
  }

  // Ürünlerden otomatik sepet oluştur
  Future<SepetModel> createSepetFromProducts({
    required List<ProductModel> products,
    required String sepetName,
    required String workspaceId,
    required String userId,
    required String userName,
    String? description,
  }) async {
    try {
      print('🛒 Otomatik sepet oluşturuluyor: $sepetName');
      print('   Ürün sayısı: ${products.length}');

      // Ürünleri SepetItemModel'e dönüştür
      final items = products
          .map((product) => product.toSepetItem(userId, userName))
          .toList();

      // Sepet oluştur
      final now = DateTime.now();
      final sepet = SepetModel(
        id: '', // FirestoreService tarafından atanacak
        name: sepetName,
        description: description ?? 'Otomatik oluşturulan sepet',
        workspaceId: workspaceId,
        members: [userName],
        memberIds: [userId],
        joinCode: SepetModel.generateJoinCode(userId),
        color: _getSepetColorByCategory(products),
        icon: _getSepetIconByCategory(products),
        items: items,
        createdBy: userId,
        createdAt: now,
        updatedAt: now,
      );

      print('✅ Otomatik sepet oluşturuldu');
      return sepet;
    } catch (e) {
      print('❌ Otomatik sepet oluşturma hatası: $e');
      rethrow;
    }
  }

  // Kategoriye göre sepet rengi belirle
  Color _getSepetColorByCategory(List<ProductModel> products) {
    if (products.isEmpty) return const Color(0xFF2196F3);

    // En çok tekrar eden kategoriyi bul
    final categoryCount = <String, int>{};
    for (final product in products) {
      categoryCount[product.category] =
          (categoryCount[product.category] ?? 0) + 1;
    }

    final mostCommonCategory =
        categoryCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Kategoriye göre renk döndür
    switch (mostCommonCategory) {
      case 'Süt Ürünleri':
        return const Color(0xFF2196F3); // Mavi
      case 'Meyve & Sebze':
        return const Color(0xFF4CAF50); // Yeşil
      case 'Et & Tavuk':
        return const Color(0xFFF44336); // Kırmızı
      case 'Ekmek & Unlu Mamul':
        return const Color(0xFF795548); // Kahverengi
      case 'Temizlik':
        return const Color(0xFFFFEB3B); // Sarı
      case 'Atıştırmalık':
        return const Color(0xFFFF9800); // Turuncu
      case 'İçecek':
        return const Color(0xFF9C27B0); // Mor
      case 'Dondurulmuş':
        return const Color(0xFF00BCD4); // Cyan
      default:
        return const Color(0xFF2196F3); // Varsayılan mavi
    }
  }

  // Kategoriye göre sepet ikonu belirle
  IconData _getSepetIconByCategory(List<ProductModel> products) {
    if (products.isEmpty) return Icons.shopping_basket;

    // En çok tekrar eden kategoriyi bul
    final categoryCount = <String, int>{};
    for (final product in products) {
      categoryCount[product.category] =
          (categoryCount[product.category] ?? 0) + 1;
    }

    final mostCommonCategory =
        categoryCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Kategoriye göre ikon döndür
    switch (mostCommonCategory) {
      case 'Süt Ürünleri':
        return Icons.local_drink;
      case 'Meyve & Sebze':
        return Icons.eco;
      case 'Et & Tavuk':
        return Icons.restaurant;
      case 'Ekmek & Unlu Mamul':
        return Icons.bakery_dining;
      case 'Temizlik':
        return Icons.cleaning_services;
      case 'Atıştırmalık':
        return Icons.cookie;
      case 'İçecek':
        return Icons.local_cafe;
      case 'Dondurulmuş':
        return Icons.ac_unit;
      default:
        return Icons.shopping_basket;
    }
  }

  // Akıllı sepet önerileri
  Future<List<String>> getSepetSuggestions(List<ProductModel> products) async {
    if (products.isEmpty) return ['Yeni Sepet'];

    final suggestions = <String>[];

    // Kategoriye göre öneriler
    final categories = products.map((p) => p.category).toSet();

    if (categories.contains('Meyve & Sebze') &&
        categories.contains('Süt Ürünleri')) {
      suggestions.add('Haftalık Market');
    }

    if (categories.contains('Temizlik')) {
      suggestions.add('Temizlik Malzemeleri');
    }

    if (categories.contains('Atıştırmalık') && categories.contains('İçecek')) {
      suggestions.add('Parti Alışverişi');
    }

    if (categories.contains('Ekmek & Unlu Mamul') &&
        categories.contains('Süt Ürünleri')) {
      suggestions.add('Kahvaltı Sepeti');
    }

    // Platform adına göre öneriler
    final platforms = products.map((p) => p.platform.displayName).toSet();
    if (platforms.length == 1) {
      suggestions.add('${platforms.first} Alışverişi');
    }

    // Varsayılan öneriler
    suggestions.addAll([
      'Market Listesi',
      'Günlük İhtiyaçlar',
      'Hızlı Alışveriş',
    ]);

    return suggestions.take(5).toList();
  }

  // Fiyat karşılaştırması
  Future<Map<Platform, List<ProductModel>>> compareProductPrices(
      String productName) async {
    final results = <Platform, List<ProductModel>>{};

    for (final platform in Platform.values) {
      if (platform == Platform.demo) continue;

      final products = await searchProducts(
        query: productName,
        platform: platform,
        limit: 5,
      );

      if (products.isNotEmpty) {
        results[platform] = products;
      }
    }

    return results;
  }
}
