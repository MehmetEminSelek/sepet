import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/sepet_model.dart';
import '../models/workspace_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/sepet_card.dart';
import '../widgets/stat_card.dart';
import 'sepet_detail_screen.dart';

class WorkspaceHomeScreen extends StatefulWidget {
  const WorkspaceHomeScreen({super.key});

  @override
  State<WorkspaceHomeScreen> createState() => _WorkspaceHomeScreenState();
}

class _WorkspaceHomeScreenState extends State<WorkspaceHomeScreen>
    with TickerProviderStateMixin {
  late AuthService _authService;
  late FirestoreService _firestoreService;
  User? _currentUser;
  late TabController _tabController;
  List<WorkspaceModel> _workspaces = [];
  bool _isSetupComplete = false;

  @override
  void initState() {
    super.initState();
    _authService = context.read<AuthService>();
    _firestoreService = context.read<FirestoreService>();
    _currentUser = _authService.currentUser;
    _setupUserWorkspaces();
  }

  Future<void> _setupUserWorkspaces() async {
    if (_currentUser != null) {
      try {
        // Kullanıcının workspace'lerini setup et
        await _firestoreService.setupUserWorkspaces(
          _currentUser!.uid,
          _currentUser!.displayName ?? 'Kullanıcı',
        );

        // Workspace'leri getir
        final workspaces =
            await _firestoreService.getUserWorkspaces(_currentUser!.uid).first;

        setState(() {
          _workspaces = workspaces;
          _tabController = TabController(
            length: _workspaces.length,
            vsync: this,
          );
          _isSetupComplete = true;
        });
      } catch (e) {
        print('Workspace setup error: $e');
        setState(() {
          _isSetupComplete = true;
        });
      }
    }
  }

  @override
  void dispose() {
    if (_workspaces.isNotEmpty) {
      _tabController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null || !_isSetupComplete) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_workspaces.isEmpty) {
      return _buildEmptyWorkspaceState();
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
        bottom: TabBar(
          controller: _tabController,
          tabs: _workspaces.map((workspace) {
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(workspace.icon, size: 16),
                  const SizedBox(width: 8),
                  Text(workspace.name),
                ],
              ),
            );
          }).toList(),
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryBlue,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _workspaces.map((workspace) {
          return _buildWorkspaceTab(workspace);
        }).toList(),
      ),
    );
  }

  Widget _buildWorkspaceTab(WorkspaceModel workspace) {
    return StreamBuilder<List<SepetModel>>(
      stream: _firestoreService.getWorkspaceSepetler(workspace.id),
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
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Sepet Sayısı',
                      value: '${sepetler.length}',
                      icon: Icons.shopping_basket_outlined,
                      backgroundColor: workspace.color.withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Toplam Ürün',
                      value: '${_calculateTotalProducts(sepetler)}',
                      icon: Icons.inventory_2_outlined,
                      backgroundColor: AppColors.statCardGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sepetler başlığı
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${workspace.name} Sepetleri',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _showCreateSepetDialog(workspace),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Sepet Ekle'),
                    style: FilledButton.styleFrom(
                      backgroundColor: workspace.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sepet listesi
              Expanded(
                child: sepetler.isEmpty
                    ? _buildEmptyWorkspaceTab(workspace)
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
    );
  }

  Widget _buildEmptyWorkspaceTab(WorkspaceModel workspace) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: workspace.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              workspace.icon,
              size: 60,
              color: workspace.color,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '${workspace.name} sepetiniz yok',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            workspace.description,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => _showCreateSepetDialog(workspace),
            icon: const Icon(Icons.add),
            label: Text('${workspace.name} Sepeti Oluştur'),
            style: FilledButton.styleFrom(
              backgroundColor: workspace.color,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWorkspaceState() {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(
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
                Icons.folder_outlined,
                size: 60,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Workspace\'ler yükleniyor...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Lütfen bekleyin',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateTotalProducts(List<SepetModel> sepetler) {
    return sepetler.fold(0, (total, sepet) => total + sepet.itemCount);
  }

  void _showCreateSepetDialog(WorkspaceModel workspace) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('${workspace.name} Sepeti Oluştur'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Sepet Adı',
                    hintText: 'Örn: Haftalık Alışveriş',
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
                    hintText: 'Örn: Market alışverişi',
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
                          workspaceId: workspace.id,
                          members: [_currentUser!.displayName ?? 'Sen'],
                          memberIds: [_currentUser!.uid],
                          createdBy: _currentUser!.uid,
                          color: workspace.color,
                          icon: workspace.icon,
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
