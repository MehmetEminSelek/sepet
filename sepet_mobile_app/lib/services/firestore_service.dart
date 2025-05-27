import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/sepet_model.dart';
import '../models/sepet_item_model.dart';
import '../models/user_model.dart';
import '../models/workspace_model.dart';
import '../constants/app_colors.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  // Singleton pattern
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Collections
  static const String usersCollection = 'users';
  static const String sepetlerCollection = 'sepetler';
  static const String urunlerCollection = 'urunler';
  static const String workspacesCollection = 'workspaces';

  // =============== SEPET OPERATIONS ===============

  // Kullanıcının sepetlerini getir (real-time) - YENİ MANTIK
  // 1. Kullanıcının üye olduğu gruplardaki TÜM sepetler
  // 2. Kullanıcının doğrudan davet edildiği sepetler (grup üyesi olmasa bile)
  Stream<List<SepetModel>> getUserSepetler(String userId) {
    print('🔍 getUserSepetler çağrıldı - User ID: $userId');

    return _firestore
        .collection(sepetlerCollection)
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      print(
          '📡 Firestore snapshot geldi - ${snapshot.docs.length} sepet bulundu');

      List<SepetModel> allSepetler = [];

      // Kullanıcının üye olduğu grupları al
      final userWorkspacesSnapshot = await _firestore
          .collection(workspacesCollection)
          .where('memberIds', arrayContains: userId)
          .get();

      final userWorkspaceIds =
          userWorkspacesSnapshot.docs.map((doc) => doc.id).toSet();
      print('👥 Kullanıcının grup sayısı: ${userWorkspaceIds.length}');

      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        final sepet = SepetModel.fromFirestore(data);

        // Sepet türünü belirle
        final isGroupMember = userWorkspaceIds.contains(sepet.workspaceId);
        final isDirectMember = sepet.memberIds.contains(userId);

        // Kullanıcı ya grup üyesi olmalı ya da doğrudan sepet üyesi olmalı
        if (isGroupMember || isDirectMember) {
          if (isGroupMember) {
            print(
                '   📂 GRUP SEPETİ: ${sepet.name} (Grup: ${sepet.workspaceId})');
          } else {
            print('   🎯 DOĞRUDAN DAVETLİ: ${sepet.name}');
          }
          allSepetler.add(sepet);
        } else {
          print(
              '   ❌ ERIŞIM YOK: ${sepet.name} (Kullanıcı ne grup üyesi ne de sepet üyesi)');
        }
      }

      // Client-side sorting
      allSepetler.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      print('✅ Toplam ${allSepetler.length} sepet döndürülüyor');
      return allSepetler;
    });
  }

  // Workspace'e göre sepetleri getir (real-time) - kullanıcı filtrelemeli
  Stream<List<SepetModel>> getWorkspaceSepetler(String workspaceId,
      {String? userId}) {
    print(
        '🔍 getWorkspaceSepetler çağrıldı - Workspace ID: $workspaceId, User ID: $userId');

    Query query = _firestore
        .collection(sepetlerCollection)
        .where('workspaceId', isEqualTo: workspaceId);

    // Eğer userId verilmişse, sadece o kullanıcının üye olduğu sepetleri getir
    if (userId != null) {
      query = query.where('memberIds', arrayContains: userId);
    }

    return query.snapshots().map((snapshot) {
      print(
          '📡 Workspace snapshot geldi - ${snapshot.docs.length} sepet bulundu');

      List<SepetModel> sepetler = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        final sepet = SepetModel.fromFirestore(data);

        print(
            '   📂 Workspace Sepet: ${sepet.name} (ID: ${sepet.id.substring(0, 8)}...)');
        print('      WorkspaceId: ${sepet.workspaceId}');
        print('      MemberIds: ${sepet.memberIds}');

        return sepet;
      }).toList();

      // Client-side sorting (index gerekmez)
      sepetler.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      print(
          '✅ Workspace ${workspaceId} için ${sepetler.length} sepet döndürülüyor');
      return sepetler;
    });
  }

  // Kullanıcının tüm workspace'leri ve sepetlerini gruplu getir
  Stream<Map<WorkspaceModel, List<SepetModel>>> getUserWorkspacesWithSepetler(
      String userId) {
    return getUserWorkspaces(userId).asyncMap((workspaces) async {
      Map<WorkspaceModel, List<SepetModel>> result = {};

      for (final workspace in workspaces) {
        final sepetlerSnapshot = await _firestore
            .collection(sepetlerCollection)
            .where('workspaceId', isEqualTo: workspace.id)
            .where('memberIds', arrayContains: userId)
            .get();

        final sepetler = sepetlerSnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return SepetModel.fromFirestore(data);
        }).toList();

        // Client-side sorting
        sepetler.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        result[workspace] = sepetler;
      }

      return result;
    });
  }

  // Sepet oluştur
  Future<SepetModel> createSepet({
    required String name,
    required String description,
    required String workspaceId,
    required List<String> members,
    required List<String> memberIds,
    required String createdBy,
    required String createdByUserId, // Yeni parametre
    Color? color,
    IconData? icon,
  }) async {
    final now = DateTime.now();
    final sepetId = _uuid.v4();

    final sepet = SepetModel(
      id: sepetId,
      name: name,
      description: description,
      workspaceId: workspaceId,
      members: members,
      memberIds: memberIds,
      joinCode: SepetModel.generateJoinCode(createdByUserId), // User ID ile kod üret
      color: color ?? AppColors.modernPink,
      icon: icon ?? Icons.shopping_basket,
      items: [],
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
    );

    await _firestore
        .collection(sepetlerCollection)
        .doc(sepetId)
        .set(sepet.toFirestore());

    return sepet;
  }

  // Sepet güncelle
  Future<void> updateSepet(SepetModel sepet) async {
    final updatedSepet = sepet.copyWith(updatedAt: DateTime.now());

    await _firestore
        .collection(sepetlerCollection)
        .doc(sepet.id)
        .update(updatedSepet.toFirestore());
  }

  // Sepet sil
  Future<void> deleteSepet(String sepetId) async {
    await _firestore.collection(sepetlerCollection).doc(sepetId).delete();
  }

  // Sepet'e üye ekle
  Future<void> addMemberToSepet(
      String sepetId, String userId, String userName) async {
    print('🔄 Sepete üye ekleniyor...');
    print('   Sepet ID: $sepetId');
    print('   User ID: $userId');
    print('   User Name: $userName');

    try {
      await _firestore.collection(sepetlerCollection).doc(sepetId).update({
        'memberIds': FieldValue.arrayUnion([userId]),
        'members': FieldValue.arrayUnion([userName]),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      print('✅ Sepete üye ekleme işlemi tamamlandı');

      // İşlem sonrası kontrol
      final sepetDoc =
          await _firestore.collection(sepetlerCollection).doc(sepetId).get();
      if (sepetDoc.exists) {
        final data = sepetDoc.data()!;
        final memberIds = List<String>.from(data['memberIds'] ?? []);
        final members = List<String>.from(data['members'] ?? []);

        print('📊 İşlem sonrası sepet durumu:');
        print('   MemberIds: $memberIds');
        print('   Members: $members');
        print('   Kullanıcı dahil mi: ${memberIds.contains(userId)}');
      }
    } catch (e) {
      print('❌ Sepete üye ekleme hatası: $e');
      rethrow;
    }
  }

  // Sepet'ten üye çıkar
  Future<void> removeMemberFromSepet(
      String sepetId, String userId, String userName) async {
    await _firestore.collection(sepetlerCollection).doc(sepetId).update({
      'memberIds': FieldValue.arrayRemove([userId]),
      'members': FieldValue.arrayRemove([userName]),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // =============== GRUP DAVETİ OPERATIONS ===============

  // Kullanıcıyı gruba davet et (gruptaki tüm sepetleri görebilir)
  Future<void> inviteUserToGroup({
    required String groupId,
    required String invitedUserId,
    required String invitedUserName,
    required String invitedByUserId,
  }) async {
    print('👥 Kullanıcı gruba davet ediliyor...');
    print('   Grup ID: $groupId');
    print('   Davet edilen: $invitedUserName ($invitedUserId)');

    try {
      // Kullanıcıyı gruba ekle
      await _firestore.collection(workspacesCollection).doc(groupId).update({
        'memberIds': FieldValue.arrayUnion([invitedUserId]),
        'members': FieldValue.arrayUnion([invitedUserName]),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      print('✅ Kullanıcı gruba eklendi');
    } catch (e) {
      print('❌ Grup davet hatası: $e');
      rethrow;
    }
  }

  // Kullanıcıyı sadece sepete davet et (sadece o sepeti görebilir)
  Future<void> inviteUserToSepetOnly({
    required String sepetId,
    required String invitedUserId,
    required String invitedUserName,
    required String invitedByUserId,
  }) async {
    print('🎯 Kullanıcı sadece sepete davet ediliyor...');
    print('   Sepet ID: $sepetId');
    print('   Davet edilen: $invitedUserName ($invitedUserId)');

    try {
      // Kullanıcıyı sadece sepete ekle (gruba ekleme)
      await addMemberToSepet(sepetId, invitedUserId, invitedUserName);

      print('✅ Kullanıcı sadece sepete eklendi');
    } catch (e) {
      print('❌ Sepet davet hatası: $e');
      rethrow;
    }
  }

  // =============== ÜRÜN OPERATIONS ===============

  // Sepete ürün ekle
  Future<SepetItemModel> addUrunToSepet({
    required String sepetId,
    required String name,
    required String quantity,
    required String addedBy,
    required String addedByUserId,
    String? description,
    String? category,
    String? unit,
    String? note,
  }) async {
    final now = DateTime.now();
    final urunId = _uuid.v4();

    final item = SepetItemModel(
      id: urunId,
      name: name,
      description: description,
      quantity: int.tryParse(quantity) ?? 1,
      category: category,
      unit: unit ?? 'adet',
      note: note,
      isCompleted: false,
      addedBy: addedByUserId,
      addedByName: addedBy,
      createdAt: now,
      updatedAt: now,
    );

    // Sepet'in ürünler listesini güncelle
    await _firestore.collection(sepetlerCollection).doc(sepetId).update({
      'items': FieldValue.arrayUnion([item.toFirestore()]),
      'updatedAt': now.toIso8601String(),
    });

    // Sepet üyelerine bildirim gönder
    await _sendItemAddedNotification(
      sepetId: sepetId,
      itemName: name,
      addedByName: addedBy,
      addedByUserId: addedByUserId,
    );

    return item;
  }

  // Ürün güncelle
  Future<void> updateUrunInSepet(
      String sepetId, List<SepetItemModel> items) async {
    await _firestore.collection(sepetlerCollection).doc(sepetId).update({
      'items': items.map((item) => item.toFirestore()).toList(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Ürün sil
  Future<void> removeUrunFromSepet(String sepetId, String urunId) async {
    // Önce sepeti al
    final sepetDoc =
        await _firestore.collection(sepetlerCollection).doc(sepetId).get();

    if (sepetDoc.exists) {
      final sepet = SepetModel.fromFirestore(sepetDoc.data()!);
      final updatedItems =
          sepet.items.where((item) => item.id != urunId).toList();

      await _firestore.collection(sepetlerCollection).doc(sepetId).update({
        'items': updatedItems.map((item) => item.toFirestore()).toList(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }
  }

  // Ürün işaretle/işaretsiz yap
  Future<void> toggleUrunCheck({
    required String sepetId,
    required String urunId,
    required String userWhoChecked,
    required String userWhoCheckedId,
  }) async {
    // Önce sepeti al
    final sepetDoc =
        await _firestore.collection(sepetlerCollection).doc(sepetId).get();

    if (sepetDoc.exists) {
      final sepet = SepetModel.fromFirestore(sepetDoc.data()!);
      final updatedItems = sepet.items.map((item) {
        if (item.id == urunId) {
          return item.toggleCheck(userWhoChecked, userWhoCheckedId);
        }
        return item;
      }).toList();

      await updateUrunInSepet(sepetId, updatedItems);
    }
  }

  // =============== USER OPERATIONS ===============

  // Kullanıcı ara
  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    // E-posta veya kullanıcı adına göre ara
    final usersSnapshot = await _firestore
        .collection(usersCollection)
        .where('email', isGreaterThanOrEqualTo: query.toLowerCase())
        .where('email', isLessThanOrEqualTo: query.toLowerCase() + '\uf8ff')
        .limit(10)
        .get();

    final usersByNameSnapshot = await _firestore
        .collection(usersCollection)
        .where('displayName', isGreaterThanOrEqualTo: query)
        .where('displayName', isLessThanOrEqualTo: query + '\uf8ff')
        .limit(10)
        .get();

    // Sonuçları birleştir ve tekrarları kaldır
    final allDocs = {...usersSnapshot.docs, ...usersByNameSnapshot.docs};
    return allDocs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return UserModel.fromFirestore(data);
    }).toList();
  }

  // Kullanıcıyı sepete davet et
  Future<void> inviteUserToSepet({
    required String sepetId,
    required String invitedUserId,
    required String invitedByUserId,
  }) async {
    final batch = _firestore.batch();
    final now = DateTime.now();

    // Davet bilgisini kaydet
    final inviteId = _uuid.v4();
    final inviteRef = _firestore.collection('invites').doc(inviteId);
    batch.set(inviteRef, {
      'sepetId': sepetId,
      'invitedUserId': invitedUserId,
      'invitedByUserId': invitedByUserId,
      'status': 'pending', // pending, accepted, rejected
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });

    // Davet edilen kullanıcının bildirimlerine ekle
    final notificationRef = _firestore
        .collection(usersCollection)
        .doc(invitedUserId)
        .collection('notifications')
        .doc(inviteId);
    batch.set(notificationRef, {
      'type': 'sepet_invite',
      'sepetId': sepetId,
      'inviteId': inviteId,
      'invitedByUserId': invitedByUserId,
      'isRead': false,
      'createdAt': now.toIso8601String(),
    });

    await batch.commit();
  }

  // Davet durumunu güncelle
  Future<void> updateInviteStatus({
    required String inviteId,
    required String status, // accepted, rejected
  }) async {
    final inviteRef = _firestore.collection('invites').doc(inviteId);
    final inviteDoc = await inviteRef.get();
    final inviteData = inviteDoc.data();

    if (inviteData == null) return;

    final batch = _firestore.batch();
    final now = DateTime.now();

    // Davet durumunu güncelle
    batch.update(inviteRef, {
      'status': status,
      'updatedAt': now.toIso8601String(),
    });

    // Eğer davet kabul edildiyse, kullanıcıyı sepete ekle
    if (status == 'accepted') {
      final sepetRef =
          _firestore.collection(sepetlerCollection).doc(inviteData['sepetId']);
      batch.update(sepetRef, {
        'memberIds': FieldValue.arrayUnion([inviteData['invitedUserId']]),
        'members': FieldValue.arrayUnion([inviteData['invitedUserName']]),
        'updatedAt': now.toIso8601String(),
      });
    }

    await batch.commit();
  }

  // Kullanıcının davetlerini getir
  Stream<List<Map<String, dynamic>>> getUserInvites(String userId) {
    return _firestore
        .collection('invites')
        .where('invitedUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // =============== STATISTICS ===============

  // Kullanıcının toplam sepet sayısı
  Future<int> getUserSepetCount(String userId) async {
    final querySnapshot = await _firestore
        .collection(sepetlerCollection)
        .where('memberIds', arrayContains: userId)
        .get();

    return querySnapshot.size;
  }

  // Kullanıcının toplam ürün sayısı
  Future<int> getUserTotalUrunCount(String userId) async {
    final querySnapshot = await _firestore
        .collection(sepetlerCollection)
        .where('memberIds', arrayContains: userId)
        .get();

    int totalUrunCount = 0;
    for (final doc in querySnapshot.docs) {
      final sepet = SepetModel.fromFirestore(doc.data());
      totalUrunCount += sepet.items.length;
    }

    return totalUrunCount;
  }

  // =============== BATCH OPERATIONS ===============

  // Toplu işlemler için batch
  WriteBatch get batch => _firestore.batch();

  // Batch commit
  Future<void> commitBatch(WriteBatch batch) async {
    await batch.commit();
  }

  // =============== UTILITIES ===============

  // Collection reference
  CollectionReference get sepetlerRef =>
      _firestore.collection(sepetlerCollection);
  CollectionReference get usersRef => _firestore.collection(usersCollection);

  // Document exists check
  Future<bool> documentExists(String collection, String docId) async {
    final doc = await _firestore.collection(collection).doc(docId).get();
    return doc.exists;
  }

  // Get server timestamp
  FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  // =============== WORKSPACE OPERATIONS ===============

  // Kullanıcının workspace'lerini getir (real-time)
  Stream<List<WorkspaceModel>> getUserWorkspaces(String userId) {
    return _firestore
        .collection(workspacesCollection)
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      List<WorkspaceModel> workspaces = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return WorkspaceModel.fromFirestore(data);
      }).toList();

      // Client-side sorting (index gerekmez)
      workspaces.sort((a, b) => a.name.compareTo(b.name));
      return workspaces;
    });
  }

  // Workspace oluştur
  Future<WorkspaceModel> createWorkspace({
    required String name,
    required String description,
    required String createdBy,
    required String createdByUserId, // Yeni parametre
    required List<String> memberIds,
    required List<String> members,
    Color? color,
    IconData? icon,
  }) async {
    final now = DateTime.now();
    final workspaceId = _uuid.v4();

    final workspace = WorkspaceModel(
      id: workspaceId,
      name: name,
      description: description,
      createdBy: createdBy,
      memberIds: memberIds,
      members: members,
      joinCode: WorkspaceModel.generateWorkspaceJoinCode(createdByUserId), // User ID ile kod üret
      color: color ?? AppColors.modernBlue,
      icon: icon ?? Icons.folder,
      createdAt: now,
      updatedAt: now,
    );

    await _firestore
        .collection(workspacesCollection)
        .doc(workspaceId)
        .set(workspace.toFirestore());

    return workspace;
  }

  // Varsayılan workspace'leri oluştur
  Future<void> createDefaultWorkspaces(String userId, String userName) async {
    final defaultWorkspaces =
        WorkspaceModel.getDefaultWorkspaces(userId, userName);

    for (final workspace in defaultWorkspaces) {
      // Zaten var mı kontrol et
      final exists = await documentExists(workspacesCollection, workspace.id);
      if (!exists) {
        await _firestore
            .collection(workspacesCollection)
            .doc(workspace.id)
            .set(workspace.toFirestore());
      }
    }
  }

  // Workspace güncelle
  Future<void> updateWorkspace(WorkspaceModel workspace) async {
    final updatedWorkspace = workspace.copyWith(updatedAt: DateTime.now());

    await _firestore
        .collection(workspacesCollection)
        .doc(workspace.id)
        .update(updatedWorkspace.toFirestore());
  }

  // Workspace sil
  Future<void> deleteWorkspace(String workspaceId) async {
    await _firestore.collection(workspacesCollection).doc(workspaceId).delete();
  }

  // Mevcut sepetleri workspace'lere migrate et
  Future<void> migrateSepetlerToWorkspaces(String userId) async {
    // Kullanıcının workspace'i olmayan sepetlerini bul
    final sepetlerSnapshot = await _firestore
        .collection(sepetlerCollection)
        .where('memberIds', arrayContains: userId)
        .get();

    final batch = _firestore.batch();
    int updateCount = 0;

    for (final doc in sepetlerSnapshot.docs) {
      final data = doc.data();

      // Eğer workspaceId yoksa akıllı atama yap
      if (!data.containsKey('workspaceId') || data['workspaceId'] == null) {
        String workspaceId = _determineWorkspaceForSepet(data);

        batch.update(doc.reference, {
          'workspaceId': workspaceId,
          'updatedAt': DateTime.now().toIso8601String(),
        });
        updateCount++;
      }
    }

    if (updateCount > 0) {
      await batch.commit();
      print('$updateCount sepet akıllı workspace\'lere migrate edildi');
    }
  }

  // Sepet adına göre akıllı workspace belirleme
  String _determineWorkspaceForSepet(Map<String, dynamic> sepetData) {
    final name = (sepetData['name'] as String? ?? '').toLowerCase();
    final description =
        (sepetData['description'] as String? ?? '').toLowerCase();
    final combined = '$name $description';

    // İş ile ilgili kelimeler
    if (combined.contains('ofis') ||
        combined.contains('iş') ||
        combined.contains('work') ||
        combined.contains('office') ||
        combined.contains('şirket') ||
        combined.contains('toplantı') ||
        combined.contains('meeting')) {
      return 'default_is';
    }

    // Sosyal ile ilgili kelimeler
    if (combined.contains('parti') ||
        combined.contains('etkinlik') ||
        combined.contains('party') ||
        combined.contains('kutlama') ||
        combined.contains('düğün') ||
        combined.contains('doğum günü') ||
        combined.contains('sosyal') ||
        combined.contains('arkadaş') ||
        combined.contains('kamp') ||
        combined.contains('piknik') ||
        combined.contains('tatil')) {
      return 'default_sosyal';
    }

    // Varsayılan: Ev
    return 'default_ev';
  }

  // Tüm sepetlerin workspaceId'lerini düzelt (Admin fonksiyonu)
  Future<Map<String, int>> fixAllSepetWorkspaceIds() async {
    print('Tüm sepetlerin workspace ID\'leri düzeltiliyor...');

    // Tüm sepetleri al
    final sepetlerSnapshot =
        await _firestore.collection(sepetlerCollection).get();

    final batch = _firestore.batch();
    final Map<String, int> stats = {
      'total': sepetlerSnapshot.docs.length,
      'updated': 0,
      'default_ev': 0,
      'default_is': 0,
      'default_sosyal': 0,
    };

    for (final doc in sepetlerSnapshot.docs) {
      final data = doc.data();
      final currentWorkspaceId = data['workspaceId'] as String?;

      // WorkspaceId eksik veya yanlışsa düzelt
      if (currentWorkspaceId == null ||
          !['default_ev', 'default_is', 'default_sosyal']
              .contains(currentWorkspaceId)) {
        final newWorkspaceId = _determineWorkspaceForSepet(data);

        batch.update(doc.reference, {
          'workspaceId': newWorkspaceId,
          'updatedAt': DateTime.now().toIso8601String(),
        });

        stats['updated'] = (stats['updated'] ?? 0) + 1;
        stats[newWorkspaceId] = (stats[newWorkspaceId] ?? 0) + 1;

        print('Sepet "${data['name']}" -> $newWorkspaceId');
      }
    }

    if (stats['updated']! > 0) {
      await batch.commit();
      print('✅ ${stats['updated']} sepet düzeltildi:');
      print('   - Ev: ${stats['default_ev']}');
      print('   - İş: ${stats['default_is']}');
      print('   - Sosyal: ${stats['default_sosyal']}');
    } else {
      print('✅ Tüm sepetler zaten doğru workspace\'de');
    }

    return stats;
  }

  // Kullanıcının workspace'lerindeki sepet sayılarını kontrol et
  Future<Map<String, dynamic>> checkUserWorkspaceStats(String userId) async {
    final stats = <String, dynamic>{
      'workspaces': <String, dynamic>{},
      'sepetWithoutWorkspace': 0,
      'totalSepetler': 0,
    };

    // Kullanıcının workspace'lerini al
    final workspacesSnapshot = await _firestore
        .collection(workspacesCollection)
        .where('memberIds', arrayContains: userId)
        .get();

    // Kullanıcının sepetlerini al
    final sepetlerSnapshot = await _firestore
        .collection(sepetlerCollection)
        .where('memberIds', arrayContains: userId)
        .get();

    stats['totalSepetler'] = sepetlerSnapshot.docs.length;

    // Her workspace için sepet sayısını hesapla
    for (final workspaceDoc in workspacesSnapshot.docs) {
      final workspaceData = workspaceDoc.data();
      final workspaceId = workspaceDoc.id;
      final workspaceName = workspaceData['name'] as String;

      final sepetCount = sepetlerSnapshot.docs
          .where((sepetDoc) => sepetDoc.data()['workspaceId'] == workspaceId)
          .length;

      stats['workspaces'][workspaceId] = {
        'name': workspaceName,
        'sepetCount': sepetCount,
      };
    }

    // Workspace'i olmayan sepetler
    final sepetWithoutWorkspace = sepetlerSnapshot.docs.where((sepetDoc) {
      final workspaceId = sepetDoc.data()['workspaceId'];
      return workspaceId == null || workspaceId.toString().isEmpty;
    }).length;

    stats['sepetWithoutWorkspace'] = sepetWithoutWorkspace;

    return stats;
  }

  // Kullanıcı ilk giriş yaptığında çağrılacak setup fonksiyonu
  Future<void> setupUserWorkspaces(String userId, String userName) async {
    try {
      print('🔧 Kullanıcı workspace setup başlıyor: $userName');

      // 1. Default workspace'leri oluştur
      await createDefaultWorkspaces(userId, userName);
      print('✅ Default workspace\'ler oluşturuldu');

      // 2. Mevcut sepetleri akıllı migrate et
      await migrateSepetlerToWorkspaces(userId);
      print('✅ Sepetler workspace\'lere migrate edildi');

      // 3. İstatistikleri kontrol et
      final stats = await checkUserWorkspaceStats(userId);
      print('📊 Workspace istatistikleri:');
      print('   - Toplam sepet: ${stats['totalSepetler']}');
      print('   - Workspace\'siz sepet: ${stats['sepetWithoutWorkspace']}');

      final workspaces = stats['workspaces'] as Map<String, dynamic>;
      for (final entry in workspaces.entries) {
        final workspaceInfo = entry.value as Map<String, dynamic>;
        print(
            '   - ${workspaceInfo['name']}: ${workspaceInfo['sepetCount']} sepet');
      }

      print('✅ Kullanıcı workspace setup tamamlandı');
    } catch (e) {
      print('❌ Workspace setup hatası: $e');
      rethrow;
    }
  }

  // Acil durum: Tüm kullanıcıların workspace'lerini düzelt
  Future<void> emergencyFixAllWorkspaces() async {
    print('🚨 ACİL DURUM: Tüm kullanıcıların workspace\'leri düzeltiliyor...');

    try {
      // 1. Tüm sepetlerin workspace ID'lerini düzelt
      final sepetStats = await fixAllSepetWorkspaceIds();

      // 2. Tüm kullanıcıları bul ve default workspace'leri oluştur
      final usersSnapshot = await _firestore.collection(usersCollection).get();

      for (final userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();
        final userId = userData['uid'] as String;
        final userName = userData['displayName'] as String? ?? 'Kullanıcı';

        try {
          await createDefaultWorkspaces(userId, userName);
          print('✅ $userName için workspace\'ler oluşturuldu');
        } catch (e) {
          print('❌ $userName için workspace oluşturma hatası: $e');
        }
      }

      print('🎉 ACİL DURUM düzeltmesi tamamlandı!');
      print('📊 Sepet istatistikleri: $sepetStats');
    } catch (e) {
      print('💥 ACİL DURUM düzeltmesi başarısız: $e');
      rethrow;
    }
  }

  // Acil durum: Tüm sepetleri default workspace'lere ata
  Future<int> emergencyFixAllSepetWorkspaces(String userId) async {
    print('🚨 ACİL DURUM: Tüm sepetler default workspace\'lere atanıyor...');

    try {
      // 1. Kullanıcının tüm sepetlerini al
      final sepetlerSnapshot = await _firestore
          .collection(sepetlerCollection)
          .where('memberIds', arrayContains: userId)
          .get();

      print('📊 Bulunan sepet sayısı: ${sepetlerSnapshot.docs.length}');

      final batch = _firestore.batch();
      int updateCount = 0;

      for (final doc in sepetlerSnapshot.docs) {
        final data = doc.data();
        final sepetName = data['name'] ?? '';

        // Sepet adına göre workspace belirle
        String newWorkspaceId = _determineWorkspaceForSepet(data);

        // WorkspaceId'yi güncelle
        batch.update(doc.reference, {
          'workspaceId': newWorkspaceId,
          'updatedAt': DateTime.now().toIso8601String(),
        });

        updateCount++;
        print('✅ "$sepetName" -> $newWorkspaceId');
      }

      if (updateCount > 0) {
        await batch.commit();
        print('🎉 $updateCount sepet güncellendi!');
      }

      return updateCount;
    } catch (e) {
      print('❌ Acil durum düzeltmesi başarısız: $e');
      rethrow;
    }
  }

  // ================== DEMO / SEED DATA ==================

  /// Kullanıcının mevcut workspaces ve sepetlerini siler (yalnızca bu kullanıcının üyesi olduğu dokümanlar)
  Future<void> _deleteUserData(String userId) async {
    // 1. İlgili dokümanları topla
    final sepetlerQuery = await _firestore
        .collection(sepetlerCollection)
        .where('memberIds', arrayContains: userId)
        .get();

    final workspacesQuery = await _firestore
        .collection(workspacesCollection)
        .where('memberIds', arrayContains: userId)
        .get();

    final allDocs = [...sepetlerQuery.docs, ...workspacesQuery.docs];

    if (allDocs.isEmpty) {
      print('ℹ️  $userId için silinecek veri yok');
      return;
    }

    const maxOps = 450; // Firestore limiti 500, biz güvenli tarafta kalalım
    int batchCount = 0;
    WriteBatch batch = _firestore.batch();
    int opCounter = 0;

    Future<void> commitBatch() async {
      if (opCounter == 0) return; // boş batch
      await batch.commit();
      batchCount++;
      batch = _firestore.batch();
      opCounter = 0;
    }

    for (final doc in allDocs) {
      batch.delete(doc.reference);
      opCounter++;

      if (opCounter >= maxOps) {
        await commitBatch();
      }
    }

    // Son kalan işlemler
    await commitBatch();

    print(
        '🗑️  $userId kullanıcısının verileri silindi. Toplam batch: $batchCount');
  }

  /// Demo verisi oluştur: 3 workspace + her birinde sepet & ürünler
  Future<void> seedDummyData(String userId, String userName) async {
    try {
      print('🌱 Demo veri seed başlıyor ($userName)');

      // Timeout ekle
      await _deleteUserData(userId).timeout(const Duration(seconds: 10));
      print('✅ Eski veriler silindi');

      // 1. Default workspaces
      await createDefaultWorkspaces(userId, userName)
          .timeout(const Duration(seconds: 10));
      print('✅ Default workspace\'ler oluşturuldu');

      // Workspace definitions
      const evId = 'default_ev';
      const isId = 'default_is';
      const sosyalId = 'default_sosyal';

      // Sepet tanımları
      final List<_DemoSepetDefinition> demoSepetler = [
        const _DemoSepetDefinition(
          name: 'Haftalık Market',
          description: 'Pazar günü yapılacak alışveriş',
          workspaceId: evId,
          icon: Icons.shopping_basket,
          color: AppColors.modernPink,
          items: [
            _DemoItem('Süt', 2, 'litre'),
            _DemoItem('Ekmek', 3, 'adet'),
            _DemoItem('Yumurta', 1, 'kutu'),
          ],
        ),
        const _DemoSepetDefinition(
          name: 'Pazar Sebzeleri',
          description: 'Taze sebze & meyve',
          workspaceId: evId,
          icon: Icons.eco,
          color: Colors.green,
          items: [
            _DemoItem('Domates', 2, 'kg'),
            _DemoItem('Salatalık', 1, 'kg'),
            _DemoItem('Elma', 1, 'kg'),
          ],
        ),
        const _DemoSepetDefinition(
          name: 'Ofis Mutfağı',
          description: 'Haftalık ofis ihtiyaçları',
          workspaceId: isId,
          icon: Icons.business_center,
          color: AppColors.modernTeal,
          items: [
            _DemoItem('Kahve', 1, 'paket'),
            _DemoItem('Çay', 2, 'paket'),
            _DemoItem('Şeker', 1, 'kg'),
          ],
        ),
        const _DemoSepetDefinition(
          name: 'Doğum Günü Partisi',
          description: 'Cumartesi kutlama',
          workspaceId: sosyalId,
          icon: Icons.cake,
          color: Colors.orange,
          items: [
            _DemoItem('Pasta', 1, 'adet'),
            _DemoItem('Kola', 6, 'şişe'),
            _DemoItem('Cips', 4, 'paket'),
          ],
        ),
      ];

      final now = DateTime.now();
      const uuid = Uuid();

      // Sepetleri tek tek oluştur (batch yerine)
      for (final def in demoSepetler) {
        try {
          final sepetId = uuid.v4();
          final sepet = SepetModel(
            id: sepetId,
            name: def.name,
            description: def.description,
            workspaceId: def.workspaceId,
            members: [userName],
            memberIds: [userId],
            joinCode: SepetModel.generateJoinCode(),
            color: def.color,
            icon: def.icon,
            items: def.items
                .map((it) => it.toSepetItem(userId, userName))
                .toList(),
            createdBy: userId,
            createdAt: now,
            updatedAt: now,
          );

          await _firestore
              .collection(sepetlerCollection)
              .doc(sepetId)
              .set(sepet.toFirestore())
              .timeout(const Duration(seconds: 5));

          print('✅ ${def.name} sepeti oluşturuldu');
        } catch (e) {
          print('❌ ${def.name} sepeti oluşturulamadı: $e');
        }
      }

      print('✅ Demo verisi seed edildi');
    } catch (e) {
      print('❌ Demo veri seed hatası: $e');
      rethrow;
    }
  }

  // Kullanıcının tüm verilerini sil ve temiz başlangıç yap
  Future<void> resetUserDataCompletely(String userId, String userName) async {
    print('🗑️ Kullanıcının tüm verileri siliniyor...');

    try {
      // 1. Kullanıcının tüm sepetlerini sil
      final sepetlerSnapshot = await _firestore
          .collection(sepetlerCollection)
          .where('memberIds', arrayContains: userId)
          .get();

      // 2. Kullanıcının tüm workspace'lerini sil
      final workspacesSnapshot = await _firestore
          .collection(workspacesCollection)
          .where('memberIds', arrayContains: userId)
          .get();

      // 3. Batch ile tümünü sil
      final batch = _firestore.batch();

      for (final doc in sepetlerSnapshot.docs) {
        batch.delete(doc.reference);
        print('🗑️ Sepet siliniyor: ${doc.data()['name']}');
      }

      for (final doc in workspacesSnapshot.docs) {
        batch.delete(doc.reference);
        print('🗑️ Workspace siliniyor: ${doc.data()['name']}');
      }

      await batch.commit();
      print('✅ Tüm veriler silindi');

      // 4. Default workspace'leri oluştur
      await createDefaultWorkspaces(userId, userName);
      print('✅ Default workspace\'ler oluşturuldu');

      // 5. Demo sepetleri oluştur
      await seedDummyData(userId, userName);
      print('✅ Demo verisi yüklendi');

      print('🎉 Temiz başlangıç tamamlandı!');
    } catch (e) {
      print('❌ Reset işlemi başarısız: $e');
      rethrow;
    }
  }

  // =============== WORKSPACE JOIN OPERATIONS ===============

  // Grup koduna göre workspace bul
  Future<WorkspaceModel?> findWorkspaceByCode(String groupCode) async {
    try {
      // Grup kodu workspace ID'nin ilk 6 karakteri
      final querySnapshot =
          await _firestore.collection(workspacesCollection).get();

      for (final doc in querySnapshot.docs) {
        final workspaceId = doc.id;
        if (workspaceId.substring(0, 6).toUpperCase() ==
            groupCode.toUpperCase()) {
          final data = doc.data();
          data['id'] = doc.id;
          return WorkspaceModel.fromFirestore(data);
        }
      }

      return null;
    } catch (e) {
      print('Workspace arama hatası: $e');
      return null;
    }
  }

  // Kullanıcıyı workspace'e ekle
  Future<void> addUserToWorkspace(
    String workspaceId,
    String userId,
    String userName,
  ) async {
    try {
      final batch = _firestore.batch();
      final now = DateTime.now();

      // Workspace'e kullanıcıyı ekle
      final workspaceRef =
          _firestore.collection(workspacesCollection).doc(workspaceId);
      batch.update(workspaceRef, {
        'memberIds': FieldValue.arrayUnion([userId]),
        'members': FieldValue.arrayUnion([userName]),
        'updatedAt': now.toIso8601String(),
      });

      // Kullanıcının bildirimlerine ekle
      final notificationRef = _firestore
          .collection(usersCollection)
          .doc(userId)
          .collection('notifications')
          .doc();
      batch.set(notificationRef, {
        'type': 'workspace_join',
        'workspaceId': workspaceId,
        'isRead': false,
        'createdAt': now.toIso8601String(),
      });

      await batch.commit();
    } catch (e) {
      print('Workspace\'e kullanıcı ekleme hatası: $e');
      rethrow;
    }
  }

  // Kullanıcıyı workspace'den çıkar
  Future<void> removeUserFromWorkspace(
    String workspaceId,
    String userId,
    String userName,
  ) async {
    try {
      await _firestore
          .collection(workspacesCollection)
          .doc(workspaceId)
          .update({
        'memberIds': FieldValue.arrayRemove([userId]),
        'members': FieldValue.arrayRemove([userName]),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Workspace\'den kullanıcı çıkarma hatası: $e');
      rethrow;
    }
  }

  // Kullanıcının workspace üyeliklerini getir
  Stream<List<WorkspaceModel>> getUserWorkspaceMemberships(String userId) {
    return _firestore
        .collection(workspacesCollection)
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return WorkspaceModel.fromFirestore(data);
      }).toList();
    });
  }

  // Workspace üyelerini getir
  Future<List<UserModel>> getWorkspaceMembers(String workspaceId) async {
    try {
      final workspaceDoc = await _firestore
          .collection(workspacesCollection)
          .doc(workspaceId)
          .get();

      if (!workspaceDoc.exists) {
        throw 'Workspace bulunamadı';
      }

      final memberIds = List<String>.from(workspaceDoc.data()!['memberIds']);
      final members = <UserModel>[];

      for (final userId in memberIds) {
        final userDoc =
            await _firestore.collection(usersCollection).doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          userData['uid'] = userDoc.id;
          members.add(UserModel.fromFirestore(userData));
        }
      }

      return members;
    } catch (e) {
      print('Workspace üyelerini getirme hatası: $e');
      rethrow;
    }
  }

  // =============== DEBUG OPERATIONS ===============

  // Debug: Tüm sepetleri ve memberIds bilgilerini yazdır
  Future<void> debugAllSepetler() async {
    try {
      print('🔍 DEBUG: Tüm sepetler kontrol ediliyor...');

      final snapshot = await _firestore.collection(sepetlerCollection).get();

      print('📊 Toplam sepet sayısı: ${snapshot.docs.length}');

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final sepetId = doc.id;
        final name = data['name'] ?? 'İsimsiz';
        final memberIds = List<String>.from(data['memberIds'] ?? []);
        final members = List<String>.from(data['members'] ?? []);

        print('🗂️  Sepet: $name (ID: ${sepetId.substring(0, 8)}...)');
        print('   👥 MemberIds: $memberIds');
        print('   👤 Members: $members');
        print('   📁 WorkspaceId: ${data['workspaceId'] ?? 'YOK'}');
        print('   ⏰ CreatedAt: ${data['createdAt'] ?? 'YOK'}');
        print('   ---');
      }

      print('✅ DEBUG tamamlandı');
    } catch (e) {
      print('❌ DEBUG hatası: $e');
    }
  }

  // Debug: Belirli kullanıcının sepetlerini kontrol et
  Future<void> debugUserSepetler(String userId) async {
    try {
      print('🔍 DEBUG: $userId kullanıcısının sepetleri kontrol ediliyor...');

      final snapshot = await _firestore
          .collection(sepetlerCollection)
          .where('memberIds', arrayContains: userId)
          .get();

      print('📊 Kullanıcının sepet sayısı: ${snapshot.docs.length}');

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final sepetId = doc.id;
        final name = data['name'] ?? 'İsimsiz';
        final memberIds = List<String>.from(data['memberIds'] ?? []);

        print('🗂️  Sepet: $name (ID: ${sepetId.substring(0, 8)}...)');
        print('   👥 MemberIds: $memberIds');
        print('   ✅ Kullanıcı dahil mi: ${memberIds.contains(userId)}');
        print('   ---');
      }

      print('✅ DEBUG tamamlandı');
    } catch (e) {
      print('❌ DEBUG hatası: $e');
    }
  }

  // =============== NOTIFICATION OPERATIONS ===============

  // Ürün eklendiğinde sepet üyelerine bildirim gönder
  Future<void> _sendItemAddedNotification({
    required String sepetId,
    required String itemName,
    required String addedByName,
    required String addedByUserId,
  }) async {
    try {
      print('📢 Ürün eklendi bildirimi gönderiliyor...');
      print('   Sepet ID: $sepetId');
      print('   Ürün: $itemName');
      print('   Ekleyen: $addedByName');

      // Sepet bilgilerini al
      final sepetDoc = await _firestore.collection(sepetlerCollection).doc(sepetId).get();
      if (!sepetDoc.exists) {
        print('❌ Sepet bulunamadı');
        return;
      }

      final sepetData = sepetDoc.data()!;
      final sepetName = sepetData['name'] ?? 'Sepet';
      final memberIds = List<String>.from(sepetData['memberIds'] ?? []);

      // Ürünü ekleyen kişi hariç diğer üyelere bildirim gönder
      final recipientIds = memberIds.where((id) => id != addedByUserId).toList();
      
      if (recipientIds.isEmpty) {
        print('ℹ️ Bildirim gönderilecek üye yok');
        return;
      }

      print('📤 ${recipientIds.length} üyeye bildirim gönderiliyor');

      // Her üye için FCM token al ve bildirim gönder
      for (final userId in recipientIds) {
        try {
          final userDoc = await _firestore.collection(usersCollection).doc(userId).get();
          if (userDoc.exists) {
            final userData = userDoc.data()!;
            final fcmToken = userData['fcmToken'] as String?;
            final userName = userData['displayName'] ?? 'Kullanıcı';

            if (fcmToken != null && fcmToken.isNotEmpty) {
              await _sendPushNotification(
                token: fcmToken,
                title: '🛒 $sepetName',
                body: '$addedByName "$itemName" ekledi',
                data: {
                  'type': 'item_added',
                  'sepetId': sepetId,
                  'sepetName': sepetName,
                  'itemName': itemName,
                  'addedBy': addedByName,
                },
              );
              print('✅ $userName\'a bildirim gönderildi');
            } else {
              print('⚠️ $userName\'ın FCM token\'ı yok');
            }
          }
        } catch (e) {
          print('❌ $userId için bildirim gönderme hatası: $e');
        }
      }

      print('✅ Ürün eklendi bildirimleri tamamlandı');
    } catch (e) {
      print('❌ Bildirim gönderme genel hatası: $e');
    }
  }

  // FCM push notification gönder
  Future<void> _sendPushNotification({
    required String token,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      // Firebase Cloud Messaging API endpoint
      const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';
      
      // Server key - Firebase Console'dan alınmalı
      // Şimdilik test için boş bırakıyoruz
      const String serverKey = ''; // Firebase Console'dan alınacak

      if (serverKey.isEmpty) {
        print('⚠️ Server key boş - Push notification gönderilemiyor');
        print('ℹ️ Firebase Console > Project Settings > Cloud Messaging > Server Key');
        return;
      }

      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: json.encode({
          'to': token,
          'notification': {
            'title': title,
            'body': body,
            'sound': 'default',
            'badge': '1',
          },
          'data': data ?? {},
          'priority': 'high',
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Push notification gönderildi');
      } else {
        print('❌ Push notification hatası: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Push notification gönderme hatası: $e');
    }
  }

  /// Yardımcı sınıflar
}

class _DemoSepetDefinition {
  final String name;
  final String description;
  final String workspaceId;
  final IconData icon;
  final Color color;
  final List<_DemoItem> items;
  const _DemoSepetDefinition({
    required this.name,
    required this.description,
    required this.workspaceId,
    required this.icon,
    required this.color,
    required this.items,
  });
}

class _DemoItem {
  final String name;
  final int quantity;
  final String unit;
  const _DemoItem(this.name, this.quantity, this.unit);

  SepetItemModel toSepetItem(String userId, String userName) {
    final now = DateTime.now();
    return SepetItemModel(
      id: const Uuid().v4(),
      name: name,
      description: null,
      quantity: quantity,
      category: null,
      unit: unit,
      note: null,
      isCompleted: false,
      addedBy: userId,
      addedByName: userName,
      createdAt: now,
      updatedAt: now,
    );
  }
}
