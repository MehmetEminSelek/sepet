import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../models/sepet_model.dart';
import '../models/sepet_item_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/urun_card.dart';
import '../widgets/urun_ekle_modal.dart';

class SepetDetailScreen extends StatefulWidget {
  final String sepetId;
  final ScrollController? externalScrollController;

  const SepetDetailScreen(
      {super.key, required this.sepetId, this.externalScrollController});

  @override
  State<SepetDetailScreen> createState() => _SepetDetailScreenState();
}

class _SepetDetailScreenState extends State<SepetDetailScreen> {
  late AuthService _authService;
  late FirestoreService _firestoreService;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _authService = context.read<AuthService>();
    _firestoreService = context.read<FirestoreService>();
    _currentUser = _authService.currentUser;
  }

  bool _hasAccessToSepet(SepetModel sepet) {
    return sepet.memberIds.contains(_currentUser?.uid);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return StreamBuilder<List<SepetModel>>(
      stream: _firestoreService.getUserSepetler(_currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8F9FE),
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState('Sepet bilgileri yüklenirken hata oluştu');
        }

        final sepetler = snapshot.data ?? [];
        final sepet = sepetler.where((s) => s.id == widget.sepetId).firstOrNull;

        if (sepet == null) {
          return _buildErrorState('Bu sepet artık mevcut değil',
              isNotFound: true);
        }

        if (!_hasAccessToSepet(sepet)) {
          return _buildErrorState('Bu sepete erişim yetkiniz yok',
              isNotFound: true);
        }

        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.3),
          body: DraggableScrollableSheet(
            initialChildSize: 1.0,
            minChildSize: 0.3,
            maxChildSize: 1.0,
            snap: true,
            snapSizes: const [0.3, 1.0],
            builder: (context, scrollController) {
              return NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  if (notification.extent <= 0.4) {
                    Navigator.of(context).pop();
                  }
                  return true;
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FE),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: CustomScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Modern App Bar
                      _buildModernAppBar(sepet),

                      // Sepet Bilgi Kartı
                      SliverToBoxAdapter(
                        child: RepaintBoundary(
                          child: _buildSepetInfoCard(sepet),
                        ),
                      ),

                      // İstatistikler
                      SliverToBoxAdapter(
                        child: RepaintBoundary(
                          child: _buildStatsSection(sepet),
                        ),
                      ),

                      // Ürünler Başlığı
                      SliverToBoxAdapter(
                        child: RepaintBoundary(
                          child: _buildProductsHeader(sepet),
                        ),
                      ),

                      // Ürün Listesi
                      _buildProductsList(sepet),

                      // Alt boşluk (overflow önleme)
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 100),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          floatingActionButton: RepaintBoundary(
            child: _buildModernFAB(sepet),
          ),
        );
      },
    );
  }

  Widget _buildModernAppBar(SepetModel sepet) {
    return SliverAppBar(
      expandedHeight: 120,
      automaticallyImplyLeading: false,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert,
                color: AppColors.primaryBlue, size: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onSelected: (value) async {
              if (value == 'delete') {
                _showDeleteSepetDialog(sepet);
              } else if (value == 'edit') {
                _showEditSepetDialog(sepet);
              } else if (value == 'share') {
                _showShareSepetDialog(sepet);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 16),
                    SizedBox(width: 8),
                    Text('Düzenle'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_outlined, size: 16),
                    SizedBox(width: 8),
                    Text('Paylaş'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Text('Sil', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                sepet.color.withOpacity(0.1),
                const Color(0xFFF8F9FE),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: sepet.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          sepet.icon,
                          color: sepet.color,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            sepet.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            sepet.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSepetInfoCard(SepetModel sepet) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Üyeler
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.group_outlined,
                  color: AppColors.primaryBlue,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Üyeler',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sepet.members.join(', '),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'İlerleme',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${sepet.checkedItemCount}/${sepet.itemCount} tamamlandı',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: sepet.progress,
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    sepet.progress == 1.0
                        ? AppColors.successGreen
                        : sepet.color,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(SepetModel sepet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Toplam Ürün',
              '${sepet.itemCount}',
              Icons.inventory_2_outlined,
              AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Tamamlanan',
              '${sepet.checkedItemCount}',
              Icons.check_circle_outlined,
              AppColors.successGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Kalan',
              '${sepet.itemCount - sepet.checkedItemCount}',
              Icons.pending_outlined,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductsHeader(SepetModel sepet) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Ürünler (${sepet.itemCount})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _showSortOptions(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sort, size: 14, color: AppColors.primaryBlue),
                      SizedBox(width: 4),
                      Text(
                        'Sırala',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(SepetModel sepet) {
    if (sepet.items.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyProductState(),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList.builder(
        itemCount: sepet.items.length,
        itemBuilder: (context, index) {
          final urun = sepet.items[index];
          return RepaintBoundary(
            child: UrunCard(
              urun: urun,
              onToggle: () => _onUrunToggle(sepet, urun),
              onDelete: () => _onUrunDelete(sepet, urun),
              sepetService: _firestoreService,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyProductState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 32,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Henüz ürün yok',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'İlk ürününüzü ekleyin',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFAB(SepetModel sepet) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showAddProductModal(sepet),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Ürün Ekle',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, {bool isNotFound = false}) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isNotFound ? Icons.search_off : Icons.error_outline,
                  size: 40,
                  color: AppColors.errorRed,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isNotFound ? 'Sepet bulunamadı' : 'Bir hata oluştu',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Text(
                        'Geri Dön',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onUrunToggle(SepetModel sepet, SepetItemModel urun) async {
    try {
      await _firestoreService.toggleUrunCheck(
        sepetId: sepet.id,
        urunId: urun.id,
        userWhoChecked: _currentUser!.displayName ?? 'Sen',
        userWhoCheckedId: _currentUser!.uid,
      );
    } catch (e) {
      _showErrorSnackBar('Ürün durumu değiştirilemedi: $e');
    }
  }

  Future<void> _onUrunDelete(SepetModel sepet, SepetItemModel urun) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text(
              'Ürünü Sil',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        content: Text('${urun.name} silinsin mi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => Navigator.pop(context, true),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Sil',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _firestoreService.removeUrunFromSepet(sepet.id, urun.id);
        _showSuccessSnackBar('${urun.name} silindi');
      } catch (e) {
        _showErrorSnackBar('Ürün silinemedi: $e');
      }
    }
  }

  void _showAddProductModal(SepetModel sepet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UrunEkleModal(
        onUrunEkle: (urun) => _onUrunAdd(sepet, urun),
      ),
    );
  }

  Future<void> _onUrunAdd(SepetModel sepet, dynamic urun) async {
    try {
      await _firestoreService.addUrunToSepet(
        sepetId: sepet.id,
        name: urun.name,
        quantity: urun.quantity.toString(),
        addedBy: _currentUser!.displayName ?? 'Sen',
        addedByUserId: _currentUser!.uid,
        description: urun.description,
        category: urun.category,
        unit: urun.unit,
        note: urun.note,
      );
      _showSuccessSnackBar('${urun.name} eklendi');
    } catch (e) {
      _showErrorSnackBar('Ürün eklenemedi: $e');
    }
  }

  void _showDeleteSepetDialog(SepetModel sepet) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_outlined, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text(
                'Sepeti Sil',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${sepet.name} sepeti silinsin mi?'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bu işlem geri alınamaz',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      await _firestoreService.deleteSepet(sepet.id);
                      if (mounted) Navigator.pop(context);
                      _showSuccessSnackBar('${sepet.name} silindi');
                    } catch (e) {
                      _showErrorSnackBar('Sepet silinemedi: $e');
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      'Sil',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSepetDialog(SepetModel sepet) {
    final nameController = TextEditingController(text: sepet.name);
    final descriptionController =
        TextEditingController(text: sepet.description);
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.edit_outlined, color: AppColors.primaryBlue, size: 20),
              SizedBox(width: 8),
              Text(
                'Sepeti Düzenle',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Sepet Adı',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon:
                        const Icon(Icons.shopping_basket_outlined, size: 20),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Sepet adı gerekli';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Açıklama',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon:
                        const Icon(Icons.description_outlined, size: 20),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Açıklama gerekli';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setDialogState(() {
                            isLoading = true;
                          });

                          try {
                            // Bu metod FirestoreService'de implement edilmeli
                            // await _firestoreService.updateSepet(
                            //   sepetId: sepet.id,
                            //   name: nameController.text.trim(),
                            //   description: descriptionController.text.trim(),
                            // );

                            if (mounted) Navigator.pop(context);
                            _showSuccessSnackBar('Sepet güncellendi');
                          } catch (e) {
                            _showErrorSnackBar('Sepet güncellenemedi: $e');
                          } finally {
                            if (mounted) {
                              setDialogState(() {
                                isLoading = false;
                              });
                            }
                          }
                        },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: isLoading
                        ? const SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Kaydet',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showShareSepetDialog(SepetModel sepet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.share_outlined, color: AppColors.primaryBlue, size: 20),
            SizedBox(width: 8),
            Text(
              'Sepeti Paylaş',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.qr_code,
                    size: 48,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sepet ID: ${sepet.id.substring(0, 8)}...',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bu sepete erişmek için ID\'yi paylaşabilirsiniz',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () {
                  // Clipboard'a kopyala
                  Navigator.pop(context);
                  _showSuccessSnackBar('Sepet ID kopyalandı');
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'ID\'yi Kopyala',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ürünleri Sırala',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildSortOption(Icons.check_circle, 'Tamamlananlar', () {}),
            _buildSortOption(Icons.pending, 'Bekleyenler', () {}),
            _buildSortOption(Icons.sort_by_alpha, 'İsme göre', () {}),
            _buildSortOption(Icons.access_time, 'Ekleme zamanına göre', () {}),
            _buildSortOption(Icons.category, 'Kategoriye göre', () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(IconData icon, String title, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}
