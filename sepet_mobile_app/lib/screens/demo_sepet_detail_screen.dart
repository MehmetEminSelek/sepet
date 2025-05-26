import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/sepet_model.dart';
import '../models/sepet_item_model.dart';
import '../services/demo_auth_service.dart';
import '../services/demo_firestore_service.dart';
import '../widgets/sepet_item_add_modal.dart';
import 'invite_management_screen.dart';

class DemoSepetDetailScreen extends StatefulWidget {
  final SepetModel sepet;

  const DemoSepetDetailScreen({
    super.key,
    required this.sepet,
  });

  @override
  State<DemoSepetDetailScreen> createState() => _DemoSepetDetailScreenState();
}

class _DemoSepetDetailScreenState extends State<DemoSepetDetailScreen> {
  late DemoAuthService _authService;
  late DemoFirestoreService _firestoreService;
  DemoUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _authService = context.read<DemoAuthService>();
    _firestoreService = context.read<DemoFirestoreService>();
    _currentUser = _authService.currentUser;
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

    final sepet = widget.sepet;
    print('DEBUG: Demo sepet detayı açılıyor - ${sepet.name}');

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          sepet.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _showInviteOptions,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            // Sepet bilgi kartı
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [sepet.color, sepet.color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: sepet.color.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          sepet.icon,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sepet.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _getContrastingTextColor(sepet.color),
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sepet.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: _getContrastingTextColor(sepet.color)
                                    .withOpacity(0.8),
                                letterSpacing: 0.1,
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
                  // Progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            AppStrings.progress,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${sepet.checkedItemCount}/${sepet.itemCount} ${AppStrings.completed}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: sepet.progress,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Ürün listesi başlığı ve ekle butonu
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${AppStrings.products} (${sepet.itemCount})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: _showAddProductModal,
                    icon: const Icon(Icons.add_circle_outline),
                    color: AppColors.primaryBlue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Ürün listesi veya boş state
            if (sepet.items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildEmptyProductState(),
              )
            else
              ...sepet.items.map((item) => Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: _buildProductCard(item),
                  )),
            const SizedBox(height: 100), // FAB için alan
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductModal,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyProductState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Henüz ürün yok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'İlk ürününüzü ekleyin',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onItemToggle(SepetModel sepet, SepetItemModel item) async {
    try {
      await _firestoreService.toggleItemCheck(
        sepetId: sepet.id,
        itemId: item.id,
        userWhoChecked: _currentUser!.displayName,
        userWhoCheckedId: _currentUser!.uid,
      );
    } catch (e) {
      _showErrorSnackBar('Ürün durumu değiştirilemedi: $e');
    }
  }

  Future<void> _onItemDelete(SepetModel sepet, SepetItemModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ürünü Sil'),
        content: Text('${item.name} silinsin mi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestoreService.removeItemFromSepet(sepet.id, item.id);
        _showSuccessSnackBar('${item.name} silindi');
      } catch (e) {
        _showErrorSnackBar('Ürün silinemedi: $e');
      }
    }
  }

  void _onItemEdit(SepetModel sepet, SepetItemModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SepetItemAddModal(
        editItem: item,
        onItemAdd: (updatedItem) {
          _showSuccessSnackBar('${updatedItem.name} güncellendi');
        },
      ),
    );
  }

  void _showAddProductModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SepetItemAddModal(
        onItemAdd: (item) => _onItemAdd(sepet, item),
      ),
    );
  }

  Future<void> _onItemAdd(SepetModel sepet, SepetItemModel item) async {
    try {
      await _firestoreService.addItemToSepet(
        sepetId: sepet.id,
        name: item.name,
        description: item.description ?? '',
        quantity: item.quantity,
        category: item.category ?? 'Diğer',
        unit: item.unit ?? 'adet',
        addedBy: _currentUser!.uid,
        addedByName: _currentUser!.displayName,
        note: item.note,
      );
      _showSuccessSnackBar('${item.name} eklendi');
    } catch (e) {
      _showErrorSnackBar('Ürün eklenemedi: $e');
    }
  }

  void _showEditSepetDialog(SepetModel sepet) {
    final nameController = TextEditingController(text: sepet.name);
    final descriptionController =
        TextEditingController(text: sepet.description);
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Demo Sepet Düzenle'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Sepet Adı',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Sepet adı gerekli';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama',
                    border: OutlineInputBorder(),
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
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;

                      setDialogState(() {
                        isLoading = true;
                      });

                      try {
                        final updatedSepet = sepet.copyWith(
                          name: nameController.text.trim(),
                          description: descriptionController.text.trim(),
                        );

                        await _firestoreService.updateSepet(updatedSepet);
                        Navigator.pop(context);
                        _showSuccessSnackBar('Demo sepet güncellendi');
                      } catch (e) {
                        _showErrorSnackBar('Demo sepet güncellenemedi: $e');
                      } finally {
                        setDialogState(() {
                          isLoading = false;
                        });
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Güncelle'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteSepetDialog(SepetModel sepet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Demo Sepeti Sil'),
        content: Text(
            '${sepet.name} demo sepeti silinsin mi?\nBu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestoreService.deleteSepet(sepet.id);
                Navigator.pop(context);
                _showSuccessSnackBar('${sepet.name} demo sepeti silindi');
              } catch (e) {
                _showErrorSnackBar('Demo sepet silinemedi: $e');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Helper method için sepet referansı
  SepetModel get sepet => widget.sepet;

  // Helper method untuk ürün kartı oluşturma
  Widget _buildProductCard(SepetItemModel item) {
    return DemoSepetItemCard(
      item: item,
      onToggle: () => _onItemToggle(sepet, item),
      onDelete: () => _onItemDelete(sepet, item),
      onEdit: () => _onItemEdit(sepet, item),
    );
  }

  // Davet seçeneklerini göster
  void _showInviteOptions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InviteManagementScreen(sepet: widget.sepet),
      ),
    );
  }

  // Daha fazla seçenek göster
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Sepeti Düzenle'),
              onTap: () {
                Navigator.pop(context);
                _showEditSepetDialog(widget.sepet);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title:
                  const Text('Sepeti Sil', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteSepetDialog(widget.sepet);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String? category) {
    if (category == null) return const SizedBox.shrink();

    final categoryColor = SepetItemModel.getDefaultColorForCategory(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: categoryColor,
        ),
      ),
    );
  }

  String _getItemSubtitle(SepetItemModel item) {
    final parts = <String>[];

    if (item.quantity > 1) {
      parts.add('${item.quantity} ${item.unit ?? 'adet'}');
    }

    if (item.category != null) {
      parts.add(item.category!);
    }

    return parts.join(' • ');
  }

  Color _getContrastingTextColor(Color bgColor) {
    // YIQ algoritması ile kontrast renk seçimi
    final yiq =
        ((bgColor.red * 299) + (bgColor.green * 587) + (bgColor.blue * 114)) /
            1000;
    return yiq >= 180 ? Colors.black : Colors.white;
  }
}

// Demo UrunCard Widget'ı
class DemoSepetItemCard extends StatelessWidget {
  final SepetItemModel item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const DemoSepetItemCard({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      child: Card(
        elevation: 1,
        color: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: item.isChecked
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: item.isChecked
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: item.isChecked
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ),
              const SizedBox(width: 10),

              // Ürün bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        decoration:
                            item.isChecked ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (item.category != null) ...[
                          Icon(
                            item.icon ??
                                SepetItemModel.getDefaultIconForCategory(
                                    item.category),
                            size: 14,
                            color: item.color ??
                                SepetItemModel.getDefaultColorForCategory(
                                    item.category),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.category!,
                            style: TextStyle(
                              fontSize: 12,
                              color: item.color ??
                                  SepetItemModel.getDefaultColorForCategory(
                                      item.category),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            '• Ekleyen: ${item.addedByName}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (item.note != null && item.note!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.note,
                            size: 14,
                            color: Colors.orange.shade400,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              item.note!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (item.isChecked && item.checkedBy != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 14,
                              color: AppColors.successGreen,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Alan: ${item.checkedBy}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.successGreen,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (item.checkedAt != null) ...[
                              const SizedBox(width: 4),
                              Text(
                                '• ${_formatTimeAgo(item.checkedAt!)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      AppColors.successGreen.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Düzenleme ve Silme ikonları
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Colors.blue.shade400,
                      size: 20,
                    ),
                    onPressed: onEdit,
                    tooltip: 'Düzenle',
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade400,
                      size: 20,
                    ),
                    onPressed: onDelete,
                    tooltip: 'Sil',
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Zamanı formatla
  String _formatTimeAgo(DateTime dateTime) {
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
