import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/workspace_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class WorkspaceInviteScreen extends StatefulWidget {
  final WorkspaceModel workspace;

  const WorkspaceInviteScreen({super.key, required this.workspace});

  @override
  State<WorkspaceInviteScreen> createState() => _WorkspaceInviteScreenState();
}

class _WorkspaceInviteScreenState extends State<WorkspaceInviteScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.workspace.name} - Davet'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Grup Kodu'),
            Tab(text: 'QR Kod'),
            Tab(text: 'Kullanıcı Ara'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildJoinCodeTab(),
          _buildQRCodeTab(),
          _buildSearchUsersTab(),
        ],
      ),
    );
  }

  // 1️⃣ Grup Kodu Sekmesi
  Widget _buildJoinCodeTab() {
    final groupCode = widget.workspace.id.substring(0, 6).toUpperCase();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.workspace.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.workspace.color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  widget.workspace.icon,
                  size: 48,
                  color: widget.workspace.color,
                ),
                const SizedBox(height: 16),
                Text(
                  'Grup Kodu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: widget.workspace.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  groupCode,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Bu kodu paylaşarak arkadaşlarınızı gruba davet edebilirsiniz.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: groupCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Grup kodu kopyalandı: $groupCode'),
                      backgroundColor: AppColors.successGreen,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Kodu Kopyala'),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () {
                  Share.share(
                    'Merhaba! Seni "${widget.workspace.name}" grubuna davet ediyorum. Katılmak için bu kodu kullan: $groupCode',
                    subject: '${widget.workspace.name} Grup Daveti',
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('Paylaş'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2️⃣ QR Kod Sekmesi
  Widget _buildQRCodeTab() {
    final groupCode = widget.workspace.id.substring(0, 6).toUpperCase();
    final qrData = 'WORKSPACE:$groupCode';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200.0,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: widget.workspace.color,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: widget.workspace.color,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.workspace.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Grup Kodu: $groupCode',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'QR kodu okutarak gruba hızlıca katılabilirsiniz.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // 3️⃣ Kullanıcı Arama Sekmesi
  Widget _buildSearchUsersTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Kullanıcı ara...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _searchUsers('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: _searchUsers,
          ),
          const SizedBox(height: 16),
          if (_isSearching)
            const Center(child: CircularProgressIndicator())
          else if (_searchError != null)
            Center(
              child: Text(
                _searchError!,
                style: const TextStyle(color: AppColors.errorRed),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final user = _searchResults[index];
                  final isAlreadyMember =
                      widget.workspace.memberIds.contains(user.uid);

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: widget.workspace.color.withOpacity(0.2),
                      child: Text(
                        user.displayName[0].toUpperCase(),
                        style: TextStyle(
                          color: widget.workspace.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(user.displayName),
                    subtitle: Text(user.email),
                    trailing: isAlreadyMember
                        ? const Chip(
                            label: Text('Üye'),
                            backgroundColor: AppColors.successGreen,
                            labelStyle: TextStyle(color: Colors.white),
                          )
                        : FilledButton(
                            onPressed: () => _inviteUser(user),
                            child: const Text('Davet Et'),
                          ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _searchError = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final firestoreService =
          Provider.of<FirestoreService>(context, listen: false);
      final results = await firestoreService.searchUsers(query);

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchError = 'Arama sırasında bir hata oluştu';
        _isSearching = false;
      });
    }
  }

  Future<void> _inviteUser(UserModel user) async {
    try {
      final firestoreService =
          Provider.of<FirestoreService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        _showErrorSnackBar('Kullanıcı oturumu bulunamadı');
        return;
      }

      await firestoreService.addUserToWorkspace(
        widget.workspace.id,
        user.uid,
        user.displayName,
      );

      _showSuccessSnackBar('${user.displayName} gruba eklendi');
    } catch (e) {
      _showErrorSnackBar('Kullanıcı eklenirken bir hata oluştu');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
