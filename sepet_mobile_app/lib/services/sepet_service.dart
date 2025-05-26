import 'package:flutter/material.dart';
import '../models/sepet_model.dart';
import '../models/sepet_item_model.dart';
import '../constants/app_colors.dart';

class SepetService {
  // Singleton pattern
  static final SepetService _instance = SepetService._internal();
  factory SepetService() => _instance;
  SepetService._internal();

  // Örnek veri - gerçek uygulamada veritabanından gelecek
  final List<SepetModel> _sepetler = [
    SepetModel(
      id: 'sepet_1',
      name: 'Ev Alışverişi',
      description: 'Haftalık market alışverişi',
      workspaceId: 'default_ev',
      members: ['Sen', 'Ahmet'],
      memberIds: ['user_1', 'user_2'],
      joinCode: 'EV123A',
      color: AppColors.modernPink,
      icon: Icons.home,
      items: [
        SepetItemModel(
          id: 'item_1',
          name: 'Süt',
          description: 'Yarım yağlı süt',
          quantity: 2,
          category: 'Süt Ürünleri',
          unit: 'litre',
          isCompleted: false,
          addedBy: 'user_1',
          addedByName: 'Sen',
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
          icon: Icons.local_drink,
          color: Colors.blue,
        ),
        SepetItemModel(
          id: 'item_2',
          name: 'Ekmek',
          description: 'Tam buğday ekmeği',
          quantity: 3,
          category: 'Ekmek',
          unit: 'adet',
          isCompleted: true,
          addedBy: 'user_2',
          addedByName: 'Ahmet',
          checkedBy: 'Sen',
          checkedByUserId: 'user_1',
          checkedAt: DateTime.now().subtract(const Duration(hours: 2)),
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
          icon: Icons.bakery_dining,
          color: Colors.brown,
        ),
        SepetItemModel(
          id: 'item_3',
          name: 'Domates',
          description: 'Taze domates',
          quantity: 1,
          category: 'Sebze',
          unit: 'kg',
          note: 'Çok olgun olmasın',
          isCompleted: false,
          addedBy: 'user_1',
          addedByName: 'Sen',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
          icon: Icons.local_grocery_store,
          color: Colors.red,
        ),
        SepetItemModel(
          id: 'item_4',
          name: 'Tavuk But',
          description: 'Taze tavuk but',
          quantity: 2,
          category: 'Et',
          unit: 'kg',
          isCompleted: false,
          addedBy: 'user_2',
          addedByName: 'Ahmet',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
          icon: Icons.restaurant,
          color: Colors.orange,
        ),
        SepetItemModel(
          id: 'item_5',
          name: 'Yoğurt',
          description: 'Tam yağlı yoğurt',
          quantity: 1,
          category: 'Süt Ürünleri',
          unit: 'adet',
          isCompleted: true,
          addedBy: 'user_1',
          addedByName: 'Sen',
          checkedBy: 'Ahmet',
          checkedByUserId: 'user_2',
          checkedAt: DateTime.now().subtract(const Duration(minutes: 30)),
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
          icon: Icons.icecream,
          color: Colors.white,
        ),
      ],
      createdBy: 'user_1',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    SepetModel(
      id: 'sepet_2',
      name: 'Ofis Mutfağı',
      description: 'Çay, kahve ve atıştırmalık',
      workspaceId: 'default_is',
      members: ['Sen', 'Elif', 'Murat'],
      memberIds: ['user_1', 'user_3', 'user_4'],
      joinCode: 'OFS456',
      color: AppColors.modernTeal,
      icon: Icons.business,
      items: [
        SepetItemModel(
          id: 'item_6',
          name: 'Çay',
          description: 'Bergamot çayı',
          quantity: 1,
          category: 'İçecek',
          unit: 'paket',
          isCompleted: false,
          addedBy: 'user_3',
          addedByName: 'Elif',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
          icon: Icons.local_cafe,
          color: Colors.green,
        ),
        SepetItemModel(
          id: 'item_7',
          name: 'Kahve',
          description: 'Filtre kahve',
          quantity: 2,
          category: 'İçecek',
          unit: 'paket',
          isCompleted: false,
          addedBy: 'user_1',
          addedByName: 'Sen',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
          icon: Icons.local_cafe,
          color: Colors.brown,
        ),
        SepetItemModel(
          id: 'item_8',
          name: 'Şeker',
          description: 'Küp şeker',
          quantity: 1,
          category: 'Diğer',
          unit: 'kg',
          isCompleted: true,
          addedBy: 'user_4',
          addedByName: 'Murat',
          checkedBy: 'Elif',
          checkedByUserId: 'user_3',
          checkedAt: DateTime.now().subtract(const Duration(days: 1)),
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          icon: Icons.cake,
          color: Colors.pink,
        ),
        SepetItemModel(
          id: 'item_9',
          name: 'Bisküvi',
          description: 'Çikolatalı bisküvi',
          quantity: 3,
          category: 'Atıştırmalık',
          unit: 'paket',
          isCompleted: false,
          addedBy: 'user_1',
          addedByName: 'Sen',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
          icon: Icons.cookie,
          color: Colors.brown,
        ),
      ],
      createdBy: 'user_1',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    SepetModel(
      id: 'sepet_3',
      name: 'Parti Hazırlığı',
      description: 'Cumartesi akşamı için',
      workspaceId: 'default_ev',
      members: ['Sen', 'Ayşe'],
      memberIds: ['user_1', 'user_5'],
      joinCode: 'PTY789',
      color: AppColors.modernOrange,
      icon: Icons.celebration,
      items: [
        SepetItemModel(
          id: 'item_10',
          name: 'Kola',
          description: '2.5L kola',
          quantity: 6,
          category: 'İçecek',
          unit: 'adet',
          isCompleted: false,
          addedBy: 'user_5',
          addedByName: 'Ayşe',
          createdAt: DateTime.now().subtract(const Duration(hours: 8)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
          icon: Icons.local_drink,
          color: Colors.red,
        ),
        SepetItemModel(
          id: 'item_11',
          name: 'Cips',
          description: 'Çeşitli cips',
          quantity: 4,
          category: 'Atıştırmalık',
          unit: 'paket',
          isCompleted: false,
          addedBy: 'user_1',
          addedByName: 'Sen',
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
          icon: Icons.fastfood,
          color: Colors.orange,
        ),
        SepetItemModel(
          id: 'item_12',
          name: 'Pizza',
          description: 'Büyük boy pizza',
          quantity: 2,
          category: 'Yemek',
          unit: 'adet',
          isCompleted: true,
          addedBy: 'user_5',
          addedByName: 'Ayşe',
          checkedBy: 'Sen',
          checkedByUserId: 'user_1',
          checkedAt: DateTime.now().subtract(const Duration(hours: 1)),
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
          icon: Icons.local_pizza,
          color: Colors.red,
        ),
        SepetItemModel(
          id: 'item_13',
          name: 'Dondurma',
          description: 'Vanilyalı dondurma',
          quantity: 1,
          category: 'Tatlı',
          unit: 'kutu',
          isCompleted: false,
          addedBy: 'user_1',
          addedByName: 'Sen',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
          icon: Icons.icecream,
          color: Colors.yellow,
        ),
      ],
      createdBy: 'user_1',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  // Getter methods
  List<SepetModel> get sepetler => List.unmodifiable(_sepetler);

  int get toplamSepetSayisi => _sepetler.length;

  int get toplamUrunSayisi =>
      _sepetler.fold(0, (total, sepet) => total + sepet.itemCount);

  // Sepet operations
  SepetModel? getSepetById(String id) {
    try {
      return _sepetler.firstWhere((sepet) => sepet.id == id);
    } catch (e) {
      return null;
    }
  }

  void updateSepet(SepetModel updatedSepet) {
    final index = _sepetler.indexWhere((sepet) => sepet.id == updatedSepet.id);
    if (index != -1) {
      _sepetler[index] = updatedSepet;
    }
  }

  // Ürün operations
  void toggleItemCheck(String sepetId, String itemId, String userWhoChecked,
      String userWhoCheckedName) {
    final sepet = getSepetById(sepetId);
    if (sepet != null) {
      final updatedItems = sepet.items.map((item) {
        if (item.id == itemId) {
          return item.toggleCheck(userWhoChecked, userWhoCheckedName);
        }
        return item;
      }).toList();

      final updatedSepet = sepet.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );
      updateSepet(updatedSepet);
    }
  }

  void addItem(String sepetId, SepetItemModel newItem) {
    final sepet = getSepetById(sepetId);
    if (sepet != null) {
      final updatedItems = List<SepetItemModel>.from(sepet.items)..add(newItem);
      final updatedSepet = sepet.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );
      updateSepet(updatedSepet);
    }
  }

  void removeItem(String sepetId, String itemId) {
    final sepet = getSepetById(sepetId);
    if (sepet != null) {
      final updatedItems =
          sepet.items.where((item) => item.id != itemId).toList();
      final updatedSepet = sepet.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );
      updateSepet(updatedSepet);
    }
  }

  // Utility methods
  String formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dk önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} sa önce';
    } else if (difference.inDays == 1) {
      return 'dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
