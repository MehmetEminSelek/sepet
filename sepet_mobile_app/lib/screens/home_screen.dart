import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/sepet_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/sepet_card.dart';
import '../widgets/stat_card.dart';
import 'sepet_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          AppStrings.yourBaskets,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            onPressed: () {
              // Tema ayarları ekranı açılacak
            },
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () async {
              // Debug: Sepetleri kontrol et
              if (_currentUser != null) {
                await _firestoreService.debugUserSepetler(_currentUser!.uid);
                await _firestoreService.debugAllSepetler();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () async {
              // Demo data yükle
              if (_currentUser != null) {
                try {
                  await _firestoreService.seedDummyData(
                    _currentUser!.uid,
                    _currentUser!.displayName ?? 'Kullanıcı',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Demo verisi yüklendi'),
                      backgroundColor: AppColors.successGreen,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Demo verisi yüklenemedi: $e'),
                      backgroundColor: AppColors.errorRed,
                    ),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.build_circle),
            onPressed: () async {
              // Workspace'leri düzelt
              if (_currentUser != null) {
                try {
                  await _firestoreService.fixAllSepetWorkspaceIds();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sepet kategorileri düzeltildi'),
                      backgroundColor: AppColors.successGreen,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Düzeltme başarısız: $e'),
                      backgroundColor: AppColors.errorRed,
                    ),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              // RESET: Tüm verileri sil ve yeniden başla
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Tüm Verileri Sıfırla'),
                  content: const Text(
                    'Tüm sepetleriniz ve kategorileriniz silinecek ve temiz demo verisi yüklenecek.\n\nBu işlem geri alınamaz. Devam etmek istiyor musunuz?'
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('İptal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Sıfırla'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && _currentUser != null) {
                try {
                  await _firestoreService.resetUserDataCompletely(
                    _currentUser!.uid,
                    _currentUser!.displayName ?? 'Kullanıcı',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tüm veriler sıfırlandı ve demo verisi yüklendi'),
                      backgroundColor: AppColors.successGreen,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sıfırlama başarısız: $e'),
                      backgroundColor: AppColors.errorRed,
                    ),
                  );
                }
              }
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.person_outline),
            onSelected: (value) async {
              if (value == 'profile') {
                // Profil ekranı
              } else if (value == 'logout') {
                await _authService.signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profil'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Çıkış Yap'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<SepetModel>>(
        stream: _firestoreService.getUserSepetler(_currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.errorRed,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bir hata oluştu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sepetler yüklenirken hata oluştu',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Text('Yeniden Dene'),
                  ),
                ],
              ),
            );
          }

          final sepetler = snapshot.data ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // İstatistik kartları
                _buildStatsSection(sepetler),
                const SizedBox(height: 24),

                // Sepetler başlığı
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      AppStrings.baskets,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        // Tümünü gör
                      },
                      icon: const Icon(Icons.grid_view_rounded, size: 18),
                      label: const Text(AppStrings.viewAll),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Sepet listesi
                Expanded(
                  child: sepetler.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: sepetler.length,
                          itemBuilder: (context, index) {
                            final sepet = sepetler[index];
                            return SepetCard(
                              sepet: sepet,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SepetDetailScreen(sepetId: sepet.id),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCreateSepetDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.newBasket),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.shopping_basket_outlined,
              size: 60,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Henüz sepetiniz yok',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'İlk sepetinizi oluşturun ve\nortak alışverişe başlayın',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _showCreateSepetDialog,
            icon: const Icon(Icons.add),
            label: const Text('İlk Sepetini Oluştur'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(List<SepetModel> sepetler) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.shopping_basket_outlined,
            label: 'Toplam Sepet',
            value: sepetler.length.toString(),
          ),
          _buildStatItem(
            icon: Icons.shopping_cart_outlined,
            label: 'Toplam Ürün',
            value: _calculateTotalProducts(sepetler).toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      {required IconData icon, required String label, required String value}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 40, color: AppColors.textPrimary),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  int _calculateTotalProducts(List<SepetModel> sepetler) {
    return sepetler.fold(0, (total, sepet) => total + sepet.itemCount);
  }

  void _showCreateSepetDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Yeni Sepet Oluştur'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Sepet Adı',
                    hintText: 'Örn: Ev Alışverişi',
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
                    hintText: 'Örn: Haftalık market alışverişi',
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
                        await _firestoreService.createSepet(
                          name: nameController.text.trim(),
                          description: descriptionController.text.trim(),
                          workspaceId: 'default_ev',
                          members: [_currentUser!.displayName ?? 'Sen'],
                          memberIds: [_currentUser!.uid],
                          createdBy: _currentUser!.uid,
                          color: AppColors.modernSepetColors[
                              DateTime.now().millisecond %
                                  AppColors.modernSepetColors.length],
                          icon: Icons.shopping_basket,
                        );

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${nameController.text} sepeti oluşturuldu'),
                            backgroundColor: AppColors.successGreen,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Sepet oluşturulamadı: $e'),
                            backgroundColor: AppColors.errorRed,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
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
                  : const Text('Oluştur'),
            ),
          ],
        ),
      ),
    );
  }
}
