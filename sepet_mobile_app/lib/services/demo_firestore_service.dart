import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import '../models/sepet_model.dart';
import '../models/user_model.dart';
import '../constants/app_colors.dart';
import '../models/sepet_item_model.dart';

/// Demo Firestore service - Firebase olmadan test için
class DemoFirestoreService {
  static final DemoFirestoreService _instance =
      DemoFirestoreService._internal();
  factory DemoFirestoreService() => _instance;
  DemoFirestoreService._internal();

  final Uuid _uuid = const Uuid();

  // In-memory data storage
  final Map<String, SepetModel> _sepetler = {};
  final Map<String, UserModel> _users = {};

  // Stream controllers
  final Map<String, StreamController<List<SepetModel>>> _sepetStreams = {};

  // Initialize with demo data
  void initialize() {
    print('DEBUG: DemoFirestoreService initialize başladı');
    _createDemoData();
    print('DEBUG: DemoFirestoreService initialize tamamlandı');
    print('DEBUG: Oluşturulan sepet sayısı: ${_sepetler.length}');
    _sepetler.forEach((id, sepet) {
      print('DEBUG: Sepet - ID: $id, Name: ${sepet.name}');
    });
  }

  void _createDemoData() {
    // Demo kullanıcılar
    _users['demo_dev_001'] = UserModel(
      uid: 'demo_dev_001',
      email: 'dev@sepet.com',
      displayName: 'Geliştirici',
      photoURL: null,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLoginAt: DateTime.now(),
      workspaceIds: [],
    );

    _users['demo_test_002'] = UserModel(
      uid: 'demo_test_002',
      email: 'test@sepet.com',
      displayName: 'Test Kullanıcısı',
      photoURL: null,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      lastLoginAt: DateTime.now(),
      workspaceIds: [],
    );

    // Demo sepetler
    final now = DateTime.now();

    // Ev alışverişi sepeti
    final evSepetId = _uuid.v4();
    _sepetler[evSepetId] = SepetModel(
      id: evSepetId,
      name: 'Ev Alışverişi',
      description: 'Haftalık ev alışverişi listesi',
      workspaceId: 'default_ev', // Default ev workspace'i
      members: ['Geliştirici', 'Test Kullanıcısı'],
      memberIds: ['demo_dev_001', 'demo_test_002'],
      joinCode: 'DEV123', // Demo kod
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
          addedBy: 'demo_dev_001',
          addedByName: 'Geliştirici',
          createdAt: now.subtract(const Duration(hours: 2)),
          updatedAt: now.subtract(const Duration(hours: 2)),
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
          addedBy: 'demo_test_002',
          addedByName: 'Test Kullanıcısı',
          createdAt: now.subtract(const Duration(hours: 4)),
          updatedAt: now.subtract(const Duration(minutes: 30)),
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
          addedBy: 'demo_dev_001',
          addedByName: 'Geliştirici',
          createdAt: now.subtract(const Duration(hours: 1)),
          updatedAt: now.subtract(const Duration(hours: 1)),
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
          addedBy: 'demo_test_002',
          addedByName: 'Test Kullanıcısı',
          createdAt: now.subtract(const Duration(minutes: 45)),
          updatedAt: now.subtract(const Duration(minutes: 45)),
          icon: Icons.restaurant,
          color: Colors.orange,
        ),
        SepetItemModel(
          id: 'item_5',
          name: 'Çikolata',
          description: 'Bitter çikolata',
          quantity: 2,
          category: 'Atıştırmalık',
          unit: 'adet',
          isCompleted: true,
          addedBy: 'demo_dev_001',
          addedByName: 'Geliştirici',
          createdAt: now.subtract(const Duration(minutes: 20)),
          updatedAt: now.subtract(const Duration(minutes: 10)),
          icon: Icons.cookie,
          color: Colors.brown,
        ),
      ],
      createdBy: 'demo_dev_001',
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(minutes: 10)),
    );

    // Ofis mutfağı sepeti
    final ofisSepetId = _uuid.v4();
    _sepetler[ofisSepetId] = SepetModel(
      id: ofisSepetId,
      name: 'Ofis Mutfağı',
      description: 'Ofis için içecek ve atıştırmalık',
      workspaceId: 'default_is', // Default iş workspace'i
      members: ['Geliştirici'],
      memberIds: ['demo_dev_001'],
      joinCode: 'OFF456', // Demo kod
      color: AppColors.modernTeal,
      icon: Icons.business,
      items: [
        SepetItemModel(
          id: 'item_6',
          name: 'Kahve',
          description: 'Filtre kahve',
          quantity: 1,
          category: 'İçecek',
          unit: 'paket',
          isCompleted: false,
          addedBy: 'demo_dev_001',
          addedByName: 'Geliştirici',
          createdAt: now.subtract(const Duration(hours: 3)),
          updatedAt: now.subtract(const Duration(hours: 3)),
          icon: Icons.local_cafe,
          color: Colors.brown,
        ),
        SepetItemModel(
          id: 'item_7',
          name: 'Şeker',
          description: 'Küp şeker',
          quantity: 2,
          category: 'Diğer',
          unit: 'kutu',
          isCompleted: true,
          addedBy: 'demo_dev_001',
          addedByName: 'Geliştirici',
          createdAt: now.subtract(const Duration(hours: 2)),
          updatedAt: now.subtract(const Duration(minutes: 15)),
          icon: Icons.cake,
          color: Colors.pink,
        ),
        SepetItemModel(
          id: 'item_8',
          name: 'Kraker',
          description: 'Tuzlu kraker',
          quantity: 3,
          category: 'Atıştırmalık',
          unit: 'paket',
          isCompleted: false,
          addedBy: 'demo_dev_001',
          addedByName: 'Geliştirici',
          createdAt: now.subtract(const Duration(minutes: 50)),
          updatedAt: now.subtract(const Duration(minutes: 50)),
          icon: Icons.cookie,
          color: Colors.amber,
        ),
      ],
      createdBy: 'demo_dev_001',
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now.subtract(const Duration(minutes: 15)),
    );
  }

  // =============== SEPET OPERATIONS ===============

  // Kullanıcının sepetlerini getir (real-time)
  Stream<List<SepetModel>> getUserSepetler(String userId) {
    if (!_sepetStreams.containsKey(userId)) {
      _sepetStreams[userId] = StreamController<List<SepetModel>>.broadcast();
    }

    // İlk veriyi gönder
    Timer.run(() {
      final userSepetler = _sepetler.values
          .where((sepet) => sepet.memberIds.contains(userId))
          .toList();
      userSepetler.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      _sepetStreams[userId]!.add(userSepetler);
    });

    return _sepetStreams[userId]!.stream;
  }

  // Sepet oluştur
  Future<SepetModel> createSepet({
    required String name,
    required String description,
    required String workspaceId,
    required List<String> members,
    required List<String> memberIds,
    required String createdBy,
    Color? color,
    IconData? icon,
  }) async {
    await Future.delayed(
        const Duration(milliseconds: 300)); // Simulate network delay

    final now = DateTime.now();
    final sepetId = _uuid.v4();

    final sepet = SepetModel(
      id: sepetId,
      name: name,
      description: description,
      workspaceId: workspaceId,
      members: members,
      memberIds: memberIds,
      joinCode: SepetModel.generateJoinCode(),
      color: color ?? AppColors.modernPink,
      icon: icon ?? Icons.shopping_basket,
      items: [],
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
    );

    _sepetler[sepetId] = sepet;
    _notifyAllUsers();

    return sepet;
  }

  // Sepet güncelle
  Future<void> updateSepet(SepetModel sepet) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final updatedSepet = sepet.copyWith(updatedAt: DateTime.now());
    _sepetler[sepet.id] = updatedSepet;
    _notifyAllUsers();
  }

  // Sepet sil
  Future<void> deleteSepet(String sepetId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    _sepetler.remove(sepetId);
    _notifyAllUsers();
  }

  // =============== ÜRÜN OPERATIONS ===============

  // Sepete ürün ekle
  Future<SepetItemModel> addItemToSepet({
    required String sepetId,
    required String name,
    required String description,
    required int quantity,
    required String category,
    required String unit,
    required String addedBy,
    required String addedByName,
    String? note,
  }) async {
    final now = DateTime.now();
    final item = SepetItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description.isEmpty ? null : description,
      quantity: quantity,
      category: category,
      unit: unit,
      note: note,
      isCompleted: false,
      addedBy: addedBy,
      addedByName: addedByName,
      createdAt: now,
      updatedAt: now,
    );

    print('DEBUG: Demo ürün eklendi - $name');
    return item;
  }

  // Ürün güncelle
  Future<void> updateItemInSepet(
      String sepetId, List<SepetItemModel> items) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final sepet = _sepetler[sepetId];
    if (sepet == null) return;

    final updatedSepet = sepet.copyWith(
      items: items,
      updatedAt: DateTime.now(),
    );

    _sepetler[sepetId] = updatedSepet;
    _notifyAllUsers();
  }

  // Ürün sil
  Future<void> removeItemFromSepet(String sepetId, String itemId) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final sepet = _sepetler[sepetId];
    if (sepet == null) return;

    final updatedItems =
        sepet.items.where((item) => item.id != itemId).toList();

    final updatedSepet = sepet.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );

    _sepetler[sepetId] = updatedSepet;
    _notifyAllUsers();
  }

  // Ürün işaretle/işaretsiz yap
  Future<void> toggleItemCheck({
    required String sepetId,
    required String itemId,
    required String userWhoChecked,
    required String userWhoCheckedId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final sepet = _sepetler[sepetId];
    if (sepet == null) return;

    final updatedItems = sepet.items.map((item) {
      if (item.id == itemId) {
        return item.toggleCheck(userWhoChecked, userWhoCheckedId);
      }
      return item;
    }).toList();

    final updatedSepet = sepet.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );

    _sepetler[sepetId] = updatedSepet;
    _notifyAllUsers();
  }

  // =============== USER OPERATIONS ===============

  // Kullanıcı ara (email ile)
  Future<UserModel?> findUserByEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _users.values
        .where((user) => user.email.toLowerCase() == email.toLowerCase())
        .firstOrNull;
  }

  // Kullanıcı bilgilerini güncelle
  Future<void> updateUser(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _users[user.uid] = user;
  }

  // =============== UTILITIES ===============

  void _notifyAllUsers() {
    for (final userId in _sepetStreams.keys) {
      final userSepetler = _sepetler.values
          .where((sepet) => sepet.memberIds.contains(userId))
          .toList();
      userSepetler.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      _sepetStreams[userId]!.add(userSepetler);
    }
  }

  // Cleanup
  void dispose() {
    for (final controller in _sepetStreams.values) {
      controller.close();
    }
    _sepetStreams.clear();
  }
}
