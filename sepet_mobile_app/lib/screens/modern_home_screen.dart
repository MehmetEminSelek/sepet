import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../models/sepet_model.dart';
import '../models/workspace_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'sepet_detail_screen.dart';
import 'join_sepet_screen.dart';
import 'product_search_screen.dart';
import 'workspace_invite_screen.dart';
import '../widgets/qr_code_widgets.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/background_widgets.dart';

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

  Future<void> _refreshData() async {
    // Refresh logic here
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null || !_isSetupComplete) {
      return Scaffold(
        body: MeshGradientBackground(
          child: Center(
            child: ScaleInWidget(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.shopping_basket_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ShimmerWidget(
                    child: Container(
                      width: 200,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: MeshGradientBackground(
        colors: const [
          Color(0xFFF8F9FE),
          Color(0xFFEEF2FF),
          Color(0xFFF0F9FF),
          Color(0xFFFDF2F8),
        ],
        child: GeometricShapesBackground(
          shapeColors: [
            AppColors.primaryBlue.withOpacity(0.03),
            AppColors.secondaryPurple.withOpacity(0.02),
            AppColors.secondaryTeal.withOpacity(0.02),
          ],
          child: RefreshIndicator(
            onRefresh: _refreshData,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Modern App Bar
                SliverAppBar(
                  expandedHeight: 120,
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
                            Colors.transparent,
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
                              FadeInWidget(
                                delay: const Duration(milliseconds: 200),
                                child: Row(
                                  children: [
                                    ProfessionalCardBackground(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          gradient: AppColors.primaryGradient,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: const Icon(
                                          Icons.shopping_basket_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Merhaba ${_currentUser?.displayName?.split(' ').first ?? 'Kullanıcı'}!',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const Text(
                                            'Sepetlerin',
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _buildProfileButton(),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Action Buttons
                        SlideInWidget(
                          delay: const Duration(milliseconds: 400),
                          child: _buildActionButtons(),
                        ),
                        const SizedBox(height: 24),

                        // Statistics Cards
                        SlideInWidget(
                          delay: const Duration(milliseconds: 600),
                          child: _buildStatCards(),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Workspaces and Lists
                StreamBuilder<List<WorkspaceModel>>(
                  stream:
                      _firestoreService.getUserWorkspaces(_currentUser!.uid),
                  builder: (context, workspaceSnapshot) {
                    if (!workspaceSnapshot.hasData) {
                      return SliverToBoxAdapter(
                        child: _buildLoadingShimmer(),
                      );
                    }

                    final workspaces = workspaceSnapshot.data!;

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final workspace = workspaces[index];
                          return SlideInWidget(
                            delay: Duration(milliseconds: 800 + (index * 100)),
                            child: _buildWorkspaceSection(workspace),
                          );
                        },
                        childCount: workspaces.length,
                      ),
                    );
                  },
                ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton() {
    return ProfessionalCardBackground(
      borderRadius: BorderRadius.circular(12),
      child: PopupMenuButton<String>(
        icon: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.person_outline,
            color: AppColors.primaryBlue,
            size: 20,
          ),
        ),
        onSelected: (value) async {
          if (value == 'logout') {
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
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ProfessionalCardBackground(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _showCreateSepetDialog,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Sepet Ekle',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ProfessionalCardBackground(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _showCreateWorkspaceDialog,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.group_add,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Grup Ekle',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
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
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ProfessionalCardBackground(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _showProductSearchScreen,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            color: AppColors.warningOrange,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Ürün Ara',
                            style: TextStyle(
                              color: AppColors.warningOrange,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ProfessionalCardBackground(
                child: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'manual') {
                      _showJoinSepetScreen();
                    } else if (value == 'qr') {
                      _showSepetQRScanner();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'manual',
                      child: ListTile(
                        leading: Icon(Icons.keyboard, size: 20),
                        title: Text('Kod Gir'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'qr',
                      child: ListTile(
                        leading: Icon(Icons.qr_code_scanner, size: 20),
                        title: Text('QR Kod Tara'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.login,
                          color: AppColors.successGreen,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Sepete Katıl',
                          style: TextStyle(
                            color: AppColors.successGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.successGreen,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ProfessionalCardBackground(
                child: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'manual') {
                      _showJoinWorkspaceDialog();
                    } else if (value == 'qr') {
                      _showWorkspaceQRScanner();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'manual',
                      child: ListTile(
                        leading: Icon(Icons.keyboard, size: 20),
                        title: Text('Kod Gir'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'qr',
                      child: ListTile(
                        leading: Icon(Icons.qr_code_scanner, size: 20),
                        title: Text('QR Kod Tara'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.group_add,
                          color: Colors.orange,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Gruba Katıl',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.orange,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCards() {
    return StreamBuilder<List<SepetModel>>(
      stream: _firestoreService.getUserSepetler(_currentUser!.uid),
      builder: (context, snapshot) {
        final sepetCount = snapshot.data?.length ?? 0;
        final totalItems = snapshot.data
                ?.fold<int>(0, (sum, sepet) => sum + sepet.items.length) ??
            0;

        return Row(
          children: [
            Expanded(
              child: ProfessionalCardBackground(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shopping_basket_outlined,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$sepetCount',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Text(
                        'Sepet',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ProfessionalCardBackground(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.list_alt,
                          color: AppColors.successGreen,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$totalItems',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Text(
                        'Ürün',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWorkspaceSection(WorkspaceModel workspace) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ProfessionalCardBackground(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: workspace.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      workspace.icon,
                      color: workspace.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workspace.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          workspace.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showWorkspaceQRCode(workspace),
                    icon: const Icon(Icons.qr_code, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<SepetModel>>(
                stream: _firestoreService.getWorkspaceSepetler(
                  workspace.id,
                  userId: _currentUser!.uid,
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return _buildLoadingShimmer();
                  }

                  final sepetler = snapshot.data!;

                  if (sepetler.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Henüz sepet yok',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: sepetler
                        .map((sepet) => _buildSepetCard(sepet))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSepetCard(SepetModel sepet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openSepetDetail(sepet.id),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: sepet.color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: sepet.color.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: sepet.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    sepet.icon,
                    color: sepet.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sepet.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${sepet.items.length} ürün',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showSepetQRCode(sepet),
                  icon: const Icon(Icons.qr_code, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ShimmerWidget(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Placeholder methods
  void _showCreateSepetDialog() {}
  void _showCreateWorkspaceDialog() {}
  void _showJoinSepetScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JoinSepetScreen()),
    );
  }

  void _showProductSearchScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductSearchScreen(),
      ),
    );
  }

  void _showJoinWorkspaceDialog() {}

  void _showSepetQRScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRCodeScannerWidget(
          title: 'Sepet QR Kodu Tara',
          subtitle: 'Sepete katılmak için QR kodu tarayın',
          onCodeScanned: (code) {
            _joinSepetWithCode(code);
          },
        ),
      ),
    );
  }

  void _showWorkspaceQRScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRCodeScannerWidget(
          title: 'Grup QR Kodu Tara',
          subtitle: 'Gruba katılmak için QR kodu tarayın',
          onCodeScanned: (code) {
            _joinWorkspaceWithCode(code);
          },
        ),
      ),
    );
  }

  void _showSepetQRCode(SepetModel sepet) {
    showDialog(
      context: context,
      builder: (context) => QRCodeDisplayWidget(
        data: sepet.id,
        title: sepet.name,
        subtitle: 'Bu QR kodu tarayarak sepete katılabilirsiniz',
        color: sepet.color,
        icon: sepet.icon,
      ),
    );
  }

  void _showWorkspaceQRCode(WorkspaceModel workspace) {
    showDialog(
      context: context,
      builder: (context) => QRCodeDisplayWidget(
        data: workspace.id,
        title: workspace.name,
        subtitle: 'Bu QR kodu tarayarak gruba katılabilirsiniz',
        color: workspace.color,
        icon: workspace.icon,
      ),
    );
  }

  Future<void> _joinSepetWithCode(String code) async {
    try {
      // Önce sepeti bul (ID veya joinCode ile)
      SepetModel? foundSepet;

      // Eğer kod sepet ID'si ise direkt bul
      try {
        final sepetSnapshot = await FirebaseFirestore.instance
            .collection('sepetler')
            .doc(code)
            .get();
        if (sepetSnapshot.exists) {
          final sepetData = sepetSnapshot.data() as Map<String, dynamic>;
          sepetData['id'] = sepetSnapshot.id;
          foundSepet = SepetModel.fromFirestore(sepetData);
        }
      } catch (e) {
        // ID ile bulunamadı, joinCode ile dene
      }

      // Eğer ID ile bulunamadıysa joinCode ile ara
      if (foundSepet == null) {
        final sepetSnapshot = await FirebaseFirestore.instance
            .collection('sepetler')
            .where('joinCode', isEqualTo: code.toUpperCase())
            .limit(1)
            .get();

        if (sepetSnapshot.docs.isNotEmpty) {
          final sepetData =
              sepetSnapshot.docs.first.data() as Map<String, dynamic>;
          sepetData['id'] = sepetSnapshot.docs.first.id;
          foundSepet = SepetModel.fromFirestore(sepetData);
        }
      }

      if (foundSepet == null) {
        throw Exception('Sepet bulunamadı');
      }

      // Kullanıcı zaten üye mi kontrol et
      if (foundSepet.memberIds.contains(_currentUser!.uid)) {
        throw Exception('Bu sepete zaten üyesiniz!');
      }

      // Sepete katıl
      await _firestoreService.addMemberToSepet(
        foundSepet.id,
        _currentUser!.uid,
        _currentUser!.displayName ?? 'Kullanıcı',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${foundSepet.name} sepetine katıldınız!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sepete katılırken hata oluştu: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _joinWorkspaceWithCode(String code) async {
    try {
      // Önce workspace'i bul (ID ile)
      final workspaceSnapshot = await FirebaseFirestore.instance
          .collection('workspaces')
          .doc(code)
          .get();

      if (!workspaceSnapshot.exists) {
        throw Exception('Grup bulunamadı');
      }

      final workspaceData = workspaceSnapshot.data() as Map<String, dynamic>;
      workspaceData['id'] = workspaceSnapshot.id;
      final foundWorkspace = WorkspaceModel.fromFirestore(workspaceData);

      // Kullanıcı zaten üye mi kontrol et
      if (foundWorkspace.memberIds.contains(_currentUser!.uid)) {
        throw Exception('Bu gruba zaten üyesiniz!');
      }

      // Workspace'e katıl - mevcut inviteUserToGroup metodunu kullan
      await _firestoreService.inviteUserToGroup(
        groupId: foundWorkspace.id,
        invitedUserId: _currentUser!.uid,
        invitedUserName: _currentUser!.displayName ?? 'Kullanıcı',
        invitedByUserId: _currentUser!.uid, // Kendisi katılıyor
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${foundWorkspace.name} grubuna katıldınız!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gruba katılırken hata oluştu: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  void _openSepetDetail(String sepetId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SepetDetailScreen(sepetId: sepetId),
      ),
    );
  }
}
