import 'package:flutter/material.dart';
import 'sepet_item_model.dart';

// Platform türleri - enum'u top-level'da tanımlıyoruz
enum Platform {
  getir('Getir', 'https://getir.com'),
  migros('Migros', 'https://migros.com.tr'),
  a101('A101', 'https://a101.com.tr'),
  bim('BİM', 'https://bim.com.tr'),
  carrefour('CarrefourSA', 'https://carrefoursa.com'),
  demo('Demo Market', 'demo'); // Test için

  const Platform(this.displayName, this.baseUrl);
  final String displayName;
  final String baseUrl;
}

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String category;
  final String brand;
  final String imageUrl;
  final Platform platform;
  final String unit;
  final bool inStock;
  final double rating;
  final int reviewCount;
  final Map<String, dynamic>? metadata; // Ek bilgiler için

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.category,
    required this.brand,
    required this.imageUrl,
    required this.platform,
    required this.unit,
    required this.inStock,
    required this.rating,
    required this.reviewCount,
    this.metadata,
  });

  // JSON serialization
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'TL',
      category: json['category'] ?? '',
      brand: json['brand'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      platform: Platform.values.firstWhere(
        (p) => p.name == json['platform'],
        orElse: () => Platform.demo,
      ),
      unit: json['unit'] ?? 'adet',
      inStock: json['inStock'] ?? true,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'category': category,
      'brand': brand,
      'imageUrl': imageUrl,
      'platform': platform.name,
      'unit': unit,
      'inStock': inStock,
      'rating': rating,
      'reviewCount': reviewCount,
      'metadata': metadata,
    };
  }

  // ProductModel'i SepetItemModel'e dönüştür
  SepetItemModel toSepetItem(String userId, String userName,
      {int quantity = 1}) {
    final now = DateTime.now();

    return SepetItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      quantity: quantity,
      category: category,
      unit: unit,
      note:
          'Platform: ${platform.displayName} | Marka: $brand | Fiyat: $price $currency',
      isCompleted: false,
      addedBy: userId,
      addedByName: userName,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Fiyat formatı
  String get formattedPrice => '$price $currency';

  // Rating yıldızları
  String get ratingStars {
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;

    String stars = '★' * fullStars;
    if (hasHalfStar) stars += '☆';

    final emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
    stars += '☆' * emptyStars;

    return stars;
  }

  // Stok durumu
  String get stockStatus => inStock ? 'Stokta' : 'Stokta Yok';

  // Kategori rengi
  Color get categoryColor {
    switch (category) {
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
        return const Color(0xFF9E9E9E); // Gri
    }
  }

  // Platform rengi
  Color get platformColor {
    switch (platform) {
      case Platform.getir:
        return const Color(0xFF5D4037); // Getir mor
      case Platform.migros:
        return const Color(0xFFFF6F00); // Migros turuncu
      case Platform.a101:
        return const Color(0xFFD32F2F); // A101 kırmızı
      case Platform.bim:
        return const Color(0xFF1976D2); // BİM mavi
      case Platform.carrefour:
        return const Color(0xFF0277BD); // Carrefour mavi
      case Platform.demo:
        return const Color(0xFF9E9E9E); // Demo gri
    }
  }

  // Copy with method
  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? currency,
    String? category,
    String? brand,
    String? imageUrl,
    Platform? platform,
    String? unit,
    bool? inStock,
    double? rating,
    int? reviewCount,
    Map<String, dynamic>? metadata,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      imageUrl: imageUrl ?? this.imageUrl,
      platform: platform ?? this.platform,
      unit: unit ?? this.unit,
      inStock: inStock ?? this.inStock,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, platform: ${platform.displayName})';
  }
}
