import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../models/sepet_model.dart';
import '../models/workspace_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'sepet_detail_screen.dart';

class ModernHomeScreen extends StatefulWidget {
  const ModernHomeScreen({super.key});

  @override
  State<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends State<ModernHomeScreen> {
  late AuthService _authService;
  late FirestoreService _firestoreService;
  User? _currentUser;
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

        setState(() {
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
  Widget build(BuildContext context) {
    if (_currentUser == null || !_isSetupComplete) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 100,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryBlue.withOpacity(0.08),
                      AppColors.backgroundLight,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        RepaintBoundary(
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.shopping_basket_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Merhaba ${_currentUser?.displayName?.split(' ').first ?? 'Kullanıcı'}!',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const Text(
                                      'Sepetlerin',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: Container(
                                  width: 36,
                                  height: 36,
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
                                  child: const Icon(
                                    Icons.person_outline,
                                    color: AppColors.primaryBlue,
                                    size: 18,
                                  ),
                                ),
                                onSelected: (value) async {
                                  if (value == 'profile') {
                                    // Profil ekranı
                                  } else if (value == 'fix_workspaces') {
                                    _fixUserWorkspaces();
                                  } else if (value == 'seed_demo') {
                                    _seedDemoData();
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
                                    value: 'fix_workspaces',
                                    child: ListTile(
                                      leading: Icon(Icons.build_circle,
                                          color: AppColors.primaryBlue),
                                      title:
                                          Text('Sepet Kategorilerini Düzelt'),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'seed_demo',
                                    child: ListTile(
                                      leading: Icon(Icons.auto_awesome,
                                          color: AppColors.successGreen),
                                      title: Text('Demo Veriyi Yükle'),
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
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // İçerik
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // İstatistik Kartları
                  RepaintBoundary(child: _buildStatCards()),
                  const SizedBox(height: 20),

                  // Yeni Sepet/Kategori Butonları
                  RepaintBoundary(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _showCreateSepetDialog(),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add,
                                          color: Colors.white, size: 18),
                                      SizedBox(width: 6),
                                      Text(
                                        'Sepet Ekle',
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
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primaryBlue.withOpacity(0.3),
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: _showCreateWorkspaceDialog,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.group_add,
                                        color: AppColors.primaryBlue,
                                        size: 18,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Grup Ekle',
                                        style: TextStyle(
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Workspace ve Sepetler Listesi
          StreamBuilder<List<WorkspaceModel>>(
            stream: _firestoreService.getUserWorkspaces(_currentUser!.uid),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              _workspaces = snapshot.data!;

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final workspace = _workspaces[index];

                    return RepaintBoundary(
                      child: _buildWorkspaceContainer(workspace),
                    );
                  },
                  childCount: _workspaces.length,
                ),
              );
            },
          ),

          // Alt padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return StreamBuilder<List<SepetModel>>(
      stream: _firestoreService.getUserSepetler(_currentUser!.uid),
      builder: (context, snapshot) {
        final sepetler = snapshot.data ?? [];
        final totalItems = sepetler.fold<int>(
          0,
          (sum, sepet) => sum + sepet.itemCount,
        );

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Sepet Sayısı',
                '${sepetler.length}',
                Icons.shopping_basket_rounded,
                AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Toplam Ürün',
                '$totalItems',
                Icons.inventory_2_rounded,
                AppColors.successGreen,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(12),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 16,
              ),
            ),
            const SizedBox(height: 8),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkspaceContainer(WorkspaceModel workspace) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: workspace.color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Workspace Header
          GestureDetector(
            onLongPress: () => _showWorkspaceOptionsDialog(workspace),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: workspace.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    workspace.icon,
                    color: workspace.color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    workspace.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () => _showCreateSepetDialog(
                      preselectedWorkspaceId: workspace.id),
                  color: workspace.color,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sepetler Grid
          StreamBuilder<List<SepetModel>>(
            stream: _firestoreService.getWorkspaceSepetler(workspace.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 60,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return SizedBox(
                  height: 60,
                  child: Center(
                    child: Text(
                      'Hata: ${snapshot.error}',
                      style: const TextStyle(color: AppColors.errorRed),
                    ),
                  ),
                );
              }

              final sepetler = snapshot.data ?? [];

              if (sepetler.isEmpty) {
                return Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: workspace.color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: workspace.color.withOpacity(0.2),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_basket_outlined,
                          color: workspace.color.withOpacity(0.5),
                          size: 28,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${workspace.name} sepetiniz yok',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.3,
                ),
                itemCount: sepetler.length,
                itemBuilder: (context, index) {
                  final sepet = sepetler[index];
                  return _buildCompactSepetCard(sepet);
                },
              );
            },
          ),
          const SizedBox(height: 8), // Alt boşluk eklendi
        ],
      ),
    );
  }

  Widget _buildCompactSepetCard(SepetModel sepet) {
    return Container(
      decoration: BoxDecoration(
        color: sepet.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: sepet.color.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openSepetDetail(sepet.id),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      sepet.icon,
                      color: sepet.color,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        sepet.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${sepet.itemCount} ürün',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateSepetDialog({String? preselectedWorkspaceId}) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;
    String? selectedWorkspaceId = preselectedWorkspaceId;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.8,
        widthFactor: 0.95,
        child: StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.all(16),
            title: const Row(
              children: [
                Icon(Icons.shopping_basket_rounded,
                    color: AppColors.primaryBlue, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Yeni Sepet Oluştur',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            content: RepaintBoundary(
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Sepet Adı',
                          hintText: 'Örn: Haftalık Alışveriş',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.shopping_cart_outlined,
                              size: 20),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
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
                          hintText: 'Örn: Market alışverişi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon:
                              const Icon(Icons.description_outlined, size: 20),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Açıklama gerekli';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      // Workspace seçimi
                      DropdownButtonFormField<String>(
                        value: selectedWorkspaceId,
                        decoration: InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon:
                              const Icon(Icons.folder_outlined, size: 20),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Kategori seçiniz'),
                          ),
                          ..._workspaces
                              .map((workspace) => DropdownMenuItem<String>(
                                    value: workspace.id,
                                    child: Row(
                                      children: [
                                        Icon(workspace.icon, size: 14),
                                        const SizedBox(width: 6),
                                        Text(workspace.name),
                                      ],
                                    ),
                                  )),
                        ],
                        onChanged: preselectedWorkspaceId != null
                            ? null
                            : (value) {
                                setDialogState(() {
                                  selectedWorkspaceId = value;
                                });
                              },
                        validator: (value) {
                          if (preselectedWorkspaceId == null && value == null) {
                            return 'Kategori seçimi gerekli';
                          }
                          return null;
                        },
                        disabledHint: preselectedWorkspaceId != null
                            ? Row(
                                children: [
                                  Icon(
                                    _workspaces
                                        .firstWhere((w) =>
                                            w.id == preselectedWorkspaceId)
                                        .icon,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(_workspaces
                                      .firstWhere(
                                          (w) => w.id == preselectedWorkspaceId)
                                      .name),
                                ],
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
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
                              final selectedWorkspace = _workspaces.firstWhere(
                                (w) => w.id == selectedWorkspaceId,
                              );

                              await _firestoreService.createSepet(
                                name: nameController.text.trim(),
                                description: descriptionController.text.trim(),
                                workspaceId: selectedWorkspaceId!,
                                members: [_currentUser!.displayName ?? 'Sen'],
                                memberIds: [_currentUser!.uid],
                                createdBy: _currentUser!.uid,
                                color: selectedWorkspace.color,
                                icon: selectedWorkspace.icon,
                              );

                              if (mounted) Navigator.pop(context);

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${nameController.text} sepeti oluşturuldu'),
                                    backgroundColor: AppColors.successGreen,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Sepet oluşturulamadı: $e'),
                                    backgroundColor: AppColors.errorRed,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              }
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
                        horizontal: 20,
                        vertical: 10,
                      ),
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
                              'Oluştur',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
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

  void _showCreateWorkspaceDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;
    IconData selectedIcon = Icons.folder;
    Color selectedColor = AppColors.primaryBlue;

    final List<IconData> availableIcons = [
      Icons.folder,
      Icons.home,
      Icons.business,
      Icons.school,
      Icons.favorite,
      Icons.sports_soccer,
      Icons.travel_explore,
      Icons.restaurant,
      Icons.local_grocery_store,
      Icons.celebration,
      Icons.pets,
      Icons.fitness_center,
    ];

    final List<Color> availableColors = [
      AppColors.primaryBlue,
      AppColors.successGreen,
      AppColors.errorRed,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.8,
        widthFactor: 0.95,
        child: StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.all(16),
            title: const Row(
              children: [
                Icon(Icons.create_new_folder,
                    color: AppColors.primaryBlue, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Yeni Kategori Oluştur',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            content: RepaintBoundary(
              child: Form(
                key: formKey,
                child: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Kategori Adı',
                            hintText: 'Örn: Spor, Hobi, Tatil',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon:
                                const Icon(Icons.label_outline, size: 20),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Kategori adı gerekli';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Açıklama',
                            hintText: 'Örn: Spor ekipmanları ve aktiviteler',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.description_outlined,
                                size: 20),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                          maxLines: 2,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Açıklama gerekli';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // İkon Seçimi
                        const Text(
                          'İkon Seçin',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: availableIcons.map((icon) {
                            final isSelected = selectedIcon == icon;
                            return GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  selectedIcon = icon;
                                });
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? selectedColor.withOpacity(0.15)
                                      : Colors.grey.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? selectedColor
                                        : Colors.grey.withOpacity(0.25),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  icon,
                                  color:
                                      isSelected ? selectedColor : Colors.grey,
                                  size: 18,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Renk Seçimi
                        const Text(
                          'Renk Seçin',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: availableColors.map((color) {
                            final isSelected = selectedColor == color;
                            return GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  selectedColor = color;
                                });
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.black.withOpacity(0.3)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 14,
                                      )
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actionsAlignment: MainAxisAlignment.end,
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
                              await _firestoreService.createWorkspace(
                                name: nameController.text.trim(),
                                description: descriptionController.text.trim(),
                                createdBy: _currentUser!.uid,
                                memberIds: [_currentUser!.uid],
                                members: [_currentUser!.displayName ?? 'Sen'],
                                color: selectedColor,
                                icon: selectedIcon,
                              );

                              if (mounted) Navigator.pop(context);

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${nameController.text} kategorisi oluşturuldu'),
                                    backgroundColor: AppColors.successGreen,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Kategori oluşturulamadı: $e'),
                                    backgroundColor: AppColors.errorRed,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              }
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
                        horizontal: 20,
                        vertical: 10,
                      ),
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
                              'Oluştur',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
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

  void _showWorkspaceOptionsDialog(WorkspaceModel workspace) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.all(0),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: workspace.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                workspace.icon,
                color: workspace.color,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                workspace.name,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primaryBlue),
              title: const Text('Düzenle'),
              onTap: () {
                Navigator.pop(context);
                _showEditWorkspaceDialog(workspace);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.errorRed),
              title: const Text('Sil'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteWorkspaceDialog(workspace);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditWorkspaceDialog(WorkspaceModel workspace) {
    final nameController = TextEditingController(text: workspace.name);
    final descriptionController =
        TextEditingController(text: workspace.description);
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;
    IconData selectedIcon = workspace.icon;
    Color selectedColor = workspace.color;

    final List<IconData> availableIcons = [
      Icons.folder,
      Icons.home,
      Icons.business,
      Icons.school,
      Icons.favorite,
      Icons.sports_soccer,
      Icons.travel_explore,
      Icons.restaurant,
      Icons.local_grocery_store,
      Icons.celebration,
      Icons.pets,
      Icons.fitness_center,
    ];

    final List<Color> availableColors = [
      AppColors.primaryBlue,
      AppColors.successGreen,
      AppColors.errorRed,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.8,
        widthFactor: 0.95,
        child: StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.all(16),
            title: const Row(
              children: [
                Icon(Icons.edit, color: AppColors.primaryBlue, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Grubu Düzenle',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            content: Form(
              key: formKey,
              child: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Grup Adı',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.label_outline, size: 20),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Grup adı gerekli';
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
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Açıklama gerekli';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // İkon ve Renk seçimi (aynı eski kod...)
                      const Text(
                        'İkon Seçin',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: availableIcons.map((icon) {
                          final isSelected = selectedIcon == icon;
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedIcon = icon;
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? selectedColor.withOpacity(0.15)
                                    : Colors.grey.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? selectedColor
                                      : Colors.grey.withOpacity(0.25),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                icon,
                                color: isSelected ? selectedColor : Colors.grey,
                                size: 18,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Renk Seçin',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: availableColors.map((color) {
                          final isSelected = selectedColor == color;
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.black.withOpacity(0.3)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 14,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actionsAlignment: MainAxisAlignment.end,
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
                              final updatedWorkspace = workspace.copyWith(
                                name: nameController.text.trim(),
                                description: descriptionController.text.trim(),
                                color: selectedColor,
                                icon: selectedIcon,
                              );

                              await _firestoreService
                                  .updateWorkspace(updatedWorkspace);

                              if (mounted) Navigator.pop(context);

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${nameController.text} güncellendi'),
                                    backgroundColor: AppColors.successGreen,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Güncelleme hatası: $e'),
                                    backgroundColor: AppColors.errorRed,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              }
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
                        horizontal: 20,
                        vertical: 10,
                      ),
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
                              'Güncelle',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
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

  void _showDeleteWorkspaceDialog(WorkspaceModel workspace) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.errorRed, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Grubu Sil',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: Text(
          '${workspace.name} grubunu silmek istediğinizden emin misiniz?\n\nBu gruba ait tüm sepetler de silinecektir.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.errorRed,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () async {
                  Navigator.pop(context);

                  try {
                    await _firestoreService.deleteWorkspace(workspace.id);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${workspace.name} grubu silindi'),
                          backgroundColor: AppColors.successGreen,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Silme hatası: $e'),
                          backgroundColor: AppColors.errorRed,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Text(
                    'Sil',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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

  // Kullanıcının workspace'lerini ve sepetlerini düzelt
  void _fixUserWorkspaces() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Row(
          children: [
            Icon(Icons.build_circle, color: AppColors.primaryBlue, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Sepet Kategorilerini Düzelt',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: const Text(
          'Sepetlerinizi isimlere göre doğru kategorilere (Ev, İş, Sosyal) yerleştirilecek.\n\n'
          'Bu işlem birkaç saniye sürebilir. Devam etmek istiyor musunuz?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
                onTap: () async {
                  Navigator.pop(context);

                  // Loading göster
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const AlertDialog(
                      content: Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 16),
                          Expanded(child: Text('Sepetler düzeltiliyor...')),
                        ],
                      ),
                    ),
                  );

                  try {
                    // Kullanıcının workspace'lerini setup et
                    await _firestoreService.setupUserWorkspaces(
                      _currentUser!.uid,
                      _currentUser!.displayName ?? 'Kullanıcı',
                    );

                    // İstatistikleri al
                    final stats = await _firestoreService
                        .checkUserWorkspaceStats(_currentUser!.uid);

                    // Loading'i kapat
                    if (mounted) Navigator.pop(context);

                    // Sonuçları göster
                    if (mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: const Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: AppColors.successGreen, size: 20),
                              SizedBox(width: 8),
                              Text('Düzeltme Tamamlandı'),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Toplam Sepet: ${stats['totalSepetler']}'),
                              const SizedBox(height: 8),
                              const Text('Kategori Dağılımı:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              ...((stats['workspaces'] as Map<String, dynamic>)
                                  .entries
                                  .map(
                                (entry) {
                                  final workspaceInfo =
                                      entry.value as Map<String, dynamic>;
                                  return Text(
                                      '• ${workspaceInfo['name']}: ${workspaceInfo['sepetCount']} sepet');
                                },
                              )),
                              if (stats['sepetWithoutWorkspace'] > 0) ...[
                                const SizedBox(height: 4),
                                Text(
                                    '• Kategorisiz: ${stats['sepetWithoutWorkspace']} sepet',
                                    style: const TextStyle(
                                        color: AppColors.errorRed)),
                              ],
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Tamam'),
                            ),
                          ],
                        ),
                      );
                    }

                    // Success snackbar
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Sepet kategorileri başarıyla düzeltildi'),
                          backgroundColor: AppColors.successGreen,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    // Loading'i kapat
                    if (mounted) Navigator.pop(context);

                    // Error göster
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Düzeltme hatası: $e'),
                          backgroundColor: AppColors.errorRed,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Text(
                    'Düzelt',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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

  // Demo data seeding
  void _seedDemoData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.successGreen, size: 20),
            SizedBox(width: 8),
            Expanded(
                child:
                    Text('Demo Veriyi Yükle', style: TextStyle(fontSize: 16))),
          ],
        ),
        content: const Text(
            'Mevcut verileriniz silinecek ve örnek gruplar & sepetler yüklenecek. Devam etmek istiyor musunuz?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen),
            onPressed: () async {
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Row(children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 12),
                    Text('Demo verisi oluşturuluyor...')
                  ]),
                ),
              );
              try {
                await _firestoreService.seedDummyData(_currentUser!.uid,
                    _currentUser!.displayName ?? 'Kullanıcı');
                if (mounted) Navigator.pop(context); // close loading
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Demo verisi yüklendi'),
                      backgroundColor: AppColors.successGreen));
                }
              } catch (e) {
                if (mounted) Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Demo verisi yüklenemedi: $e'),
                      backgroundColor: AppColors.errorRed));
                }
              }
            },
            child: const Text('Yükle'),
          ),
        ],
      ),
    );
  }

  // Modal sepet detayı
  void _openSepetDetail(String sepetId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 1.0,
          builder: (context, scrollController) {
            return SafeArea(
              top: false,
              child: SepetDetailScreen(
                sepetId: sepetId,
                externalScrollController: scrollController,
              ),
            );
          },
        ),
      ),
    );
  }
}
