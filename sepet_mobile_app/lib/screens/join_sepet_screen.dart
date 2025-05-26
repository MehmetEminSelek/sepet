import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/sepet_model.dart';
import '../services/demo_auth_service.dart';
import '../services/demo_firestore_service.dart';

/// Sepete Katıl Ekranı - Kod, QR veya link ile sepete katılım
class JoinSepetScreen extends StatefulWidget {
  const JoinSepetScreen({super.key});

  @override
  State<JoinSepetScreen> createState() => _JoinSepetScreenState();
}

class _JoinSepetScreenState extends State<JoinSepetScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _joinCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  SepetModel? _foundSepet;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _joinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Sepete Katıl'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.code), text: 'Kod Gir'),
            Tab(icon: Icon(Icons.qr_code_scanner), text: 'QR Tara'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildJoinByCodeTab(),
          _buildQRScannerTab(),
        ],
      ),
    );
  }

  // 1️⃣ Kod ile katılma sekmesi
  Widget _buildJoinByCodeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Başlık
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(Icons.group_add, size: 40, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Sepet Kodunu Girin',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Arkadaşınızdan aldığınız 6 haneli kodu girin',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Kod giriş alanı
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _joinCodeController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3,
                      ),
                      decoration: InputDecoration(
                        hintText: 'ABC123',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.5),
                          letterSpacing: 3,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.borderLight,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryBlue,
                            width: 2,
                          ),
                        ),
                        fillColor: AppColors.backgroundSecondary,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 6,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen sepet kodunu girin';
                        }
                        if (value.length != 6) {
                          return 'Sepet kodu 6 haneli olmalıdır';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value.length == 6) {
                          _searchSepetByCode(value);
                        } else {
                          setState(() {
                            _foundSepet = null;
                          });
                        }
                      },
                    ),
                    if (_foundSepet != null) ...[
                      const SizedBox(height: 16),
                      _buildFoundSepetCard(),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Katıl butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _foundSepet != null && !_isLoading ? _joinSepet : null,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(_isLoading ? 'Katılınıyor...' : 'Sepete Katıl'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _foundSepet != null
                      ? AppColors.successGreen
                      : AppColors.borderLight,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 2️⃣ QR kod tarama sekmesi
  Widget _buildQRScannerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive QR tarayıcı yüksekliği
          final qrHeight = constraints.maxWidth > 350 ? 250.0 : 200.0;

          return Column(
            children: [
              const SizedBox(height: 20),

              // QR Tarayıcı placeholder
              Container(
                width: double.infinity,
                height: qrHeight,
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.borderLight,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      size: constraints.maxWidth > 350 ? 64 : 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'QR Kod Tarayıcı',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'QR kod tarama özelliği yakında!',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Açıklama
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline,
                            color: AppColors.warningOrange, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'İpucu',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Şimdilik "Kod Gir" sekmesini kullanabilirsiniz. '
                      'QR kod özelliği sonraki güncellemede eklenecek.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Manuel kod girişi butonu
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _tabController.animateTo(0),
                  icon: const Icon(Icons.keyboard),
                  label: const Text('Manuel Kod Girişi'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  // Bulunan sepet kartı
  Widget _buildFoundSepetCard() {
    if (_foundSepet == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _foundSepet!.color.withOpacity(0.1),
            _foundSepet!.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _foundSepet!.color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _foundSepet!.color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _foundSepet!.icon,
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
                      _foundSepet!.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _foundSepet!.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.check_circle,
                color: AppColors.successGreen,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.people_outline,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${_foundSepet!.members.length} üye',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.shopping_basket_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${_foundSepet!.itemCount} ürün',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =============== HELPER METHODS ===============

  void _searchSepetByCode(String code) async {
    // Demo olarak mevcut sepetleri ara
    final service = DemoFirestoreService();

    // Demo sepetlerin kodları: DEV123, OFF456
    SepetModel? foundSepet;

    if (code.toUpperCase() == 'DEV123') {
      // Demo sepet verilerini manuel oluştur
      foundSepet = SepetModel(
        id: 'demo_sepet_1',
        name: 'Ev Alışverişi',
        description: 'Haftalık market alışverişi',
        workspaceId: 'default_ev', // Default ev workspace
        members: ['Geliştirici', 'Test Kullanıcısı'],
        memberIds: ['demo_dev_001', 'demo_test_002'],
        joinCode: 'DEV123',
        color: AppColors.modernPink,
        icon: Icons.home,
        items: [],
        createdBy: 'demo_dev_001',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now(),
      );
    } else if (code.toUpperCase() == 'OFF456') {
      foundSepet = SepetModel(
        id: 'demo_sepet_2',
        name: 'Ofis Mutfağı',
        description: 'Çay, kahve ve atıştırmalık',
        workspaceId: 'default_is', // Default iş workspace
        members: ['Geliştirici'],
        memberIds: ['demo_dev_001'],
        joinCode: 'OFF456',
        color: AppColors.modernTeal,
        icon: Icons.business,
        items: [],
        createdBy: 'demo_dev_001',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      );
    }

    setState(() {
      _foundSepet = foundSepet;
    });
  }

  void _joinSepet() async {
    if (_foundSepet == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<DemoAuthService>(context, listen: false);
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        _showErrorSnackBar('Kullanıcı oturumu bulunamadı');
        return;
      }

      // Kullanıcı zaten üye mi kontrol et
      if (_foundSepet!.memberIds.contains(currentUser.uid)) {
        _showErrorSnackBar('Bu sepete zaten üyesiniz!');
        return;
      }

      // Demo olarak başarılı mesajı göster
      _showSuccessSnackBar(
          '"${_foundSepet!.name}" sepetine başarıyla katıldınız!');

      // Ana sayfaya dön
      Navigator.of(context).pop();
    } catch (e) {
      _showErrorSnackBar('Bir hata oluştu: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
