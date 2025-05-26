import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_colors.dart';
import '../models/sepet_model.dart';

/// Davet Yönetimi Ekranı - 3 farklı davet yöntemi
class InviteManagementScreen extends StatefulWidget {
  final SepetModel sepet;

  const InviteManagementScreen({super.key, required this.sepet});

  @override
  State<InviteManagementScreen> createState() => _InviteManagementScreenState();
}

class _InviteManagementScreenState extends State<InviteManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('${widget.sepet.name} - Davet Et'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.code), text: 'Kod'),
            Tab(icon: Icon(Icons.qr_code), text: 'QR Kod'),
            Tab(icon: Icon(Icons.share), text: 'Link'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildJoinCodeTab(),
          _buildQRCodeTab(),
          _buildShareLinkTab(),
        ],
      ),
    );
  }

  // 1️⃣ Sepet Kodu Sekmesi
  Widget _buildJoinCodeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Kod gösterimi
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
            child: Column(
              children: [
                const Icon(Icons.code, size: 40, color: Colors.white),
                const SizedBox(height: 12),
                const Text(
                  'Sepet Kodu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.sepet.joinCode,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
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
                    Icon(Icons.info_outline,
                        color: AppColors.primaryBlue, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Nasıl Kullanılır?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '1. Bu kodu arkadaşlarınızla paylaşın\n'
                  '2. Uygulama açıp "Sepete Katıl" seçsin\n'
                  '3. Kodu girsin ve sepete katılsın!',
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

          // Kopyala butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _copyJoinCode(),
              icon: const Icon(Icons.copy),
              label: const Text('Kodu Kopyala'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
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
    );
  }

  // 2️⃣ QR Kod Sekmesi
  Widget _buildQRCodeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive QR kod boyutu
          final qrSize = constraints.maxWidth > 350 ? 180.0 : 150.0;

          return Column(
            children: [
              const SizedBox(height: 20), // Azaltıldı: 40 → 20

              // QR Kod
              Container(
                padding: const EdgeInsets.all(20), // Azaltıldı: 24 → 20
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'QR Kod ile Davet Et',
                      style: TextStyle(
                        fontSize: 16, // Azaltıldı: 18 → 16
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16), // Azaltıldı: 20 → 16
                    // Responsive QR kod
                    QrImageView(
                      data: _generateQRData(),
                      version: QrVersions.auto,
                      size: qrSize, // Responsive boyut
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryBlue,
                    ),
                    const SizedBox(height: 12), // Azaltıldı: 16 → 12
                    Text(
                      widget.sepet.joinCode,
                      style: const TextStyle(
                        fontSize: 14, // Azaltıldı: 16 → 14
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        letterSpacing: 1.5, // Azaltıldı: 2 → 1.5
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24), // Azaltıldı: 40 → 24

              // Açıklama
              Container(
                padding: const EdgeInsets.all(16), // Azaltıldı: 20 → 16
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
                        Icon(Icons.qr_code_scanner,
                            color: AppColors.primaryBlue,
                            size: 18), // Azaltıldı: 20 → 18
                        SizedBox(width: 8),
                        Text(
                          'QR Kod Taratın',
                          style: TextStyle(
                            fontSize: 14, // Azaltıldı: 16 → 14
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8), // Azaltıldı: 12 → 8
                    Text(
                      'Arkadaşlarınız bu QR kodu telefonlarıyla '
                      'tarayarak sepete anında katılabilirler.',
                      style: TextStyle(
                        fontSize: 12, // Azaltıldı: 14 → 12
                        color: AppColors.textSecondary,
                        height: 1.4, // Azaltıldı: 1.5 → 1.4
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32), // Spacer yerine sabit boşluk

              // Paylaş butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _shareQRCode(),
                  icon: const Icon(Icons.share),
                  label: const Text('QR Kod Paylaş'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14), // Azaltıldı: 16 → 14
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20), // Alt boşluk
            ],
          );
        },
      ),
    );
  }

  // 3️⃣ Davet Linki Sekmesi
  Widget _buildShareLinkTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(height: 20), // Azaltıldı: 40 → 20

          // Link gösterimi
          Container(
            padding: const EdgeInsets.all(24), // Azaltıldı: 32 → 24
            decoration: BoxDecoration(
              gradient: AppColors.secondaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondaryTeal.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.link,
                    size: 40, color: Colors.white), // Azaltıldı: 48 → 40
                const SizedBox(height: 12), // Azaltıldı: 16 → 12
                const Text(
                  'Davet Linki',
                  style: TextStyle(
                    fontSize: 16, // Azaltıldı: 18 → 16
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12), // Azaltıldı: 16 → 12
                Container(
                  padding: const EdgeInsets.all(12), // Azaltıldı: 16 → 12
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _generateShareLink(),
                    style: const TextStyle(
                      fontSize: 11, // Azaltıldı: 12 → 11
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis, // Overflow koruması
                    maxLines: 2, // Maximum 2 satır
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24), // Azaltıldı: 40 → 24

          // Paylaşım seçenekleri
          Container(
            padding: const EdgeInsets.all(16), // Azaltıldı: 20 → 16
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kolay Paylaşım',
                  style: TextStyle(
                    fontSize: 14, // Azaltıldı: 16 → 14
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12), // Azaltıldı: 16 → 12
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                      // Responsive butonlar için
                      child: _buildShareButton(
                        'WhatsApp',
                        Icons.chat,
                        AppColors.successGreen,
                        () => _shareViaWhatsApp(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: _buildShareButton(
                        'Mesaj',
                        Icons.sms,
                        AppColors.primaryBlue,
                        () => _shareViaSMS(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: _buildShareButton(
                        'Diğer',
                        Icons.share,
                        AppColors.secondaryPurple,
                        () => _shareLink(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32), // Spacer yerine sabit boşluk

          // Link kopyala butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _copyShareLink(),
              icon: const Icon(Icons.copy),
              label: const Text('Linki Kopyala'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    vertical: 14), // Azaltıldı: 16 → 14
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20), // Alt boşluk
        ],
      ),
    );
  }

  Widget _buildShareButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============== HELPER METHODS ===============

  String _generateQRData() {
    return 'sepet://${widget.sepet.joinCode}';
  }

  String _generateShareLink() {
    return 'https://sepetapp.com/join/${widget.sepet.joinCode}';
  }

  void _copyJoinCode() {
    Clipboard.setData(ClipboardData(text: widget.sepet.joinCode));
    _showSuccessSnackBar('Sepet kodu kopyalandı: ${widget.sepet.joinCode}');
  }

  void _copyShareLink() {
    Clipboard.setData(ClipboardData(text: _generateShareLink()));
    _showSuccessSnackBar('Davet linki kopyalandı!');
  }

  void _shareQRCode() {
    Share.share(
      'Sepetim "${widget.sepet.name}" ile alışveriş yapalım!\n\n'
      'Kod: ${widget.sepet.joinCode}\n'
      'Link: ${_generateShareLink()}',
      subject: 'Sepet Daveti - ${widget.sepet.name}',
    );
  }

  void _shareLink() {
    Share.share(
      'Sepetim "${widget.sepet.name}" ile alışveriş yapalım!\n\n'
      'Bu linke tıklayarak sepete katıl: ${_generateShareLink()}\n\n'
      'Veya kodu gir: ${widget.sepet.joinCode}',
      subject: 'Sepet Daveti - ${widget.sepet.name}',
    );
  }

  void _shareViaWhatsApp() {
    final message = 'Merhaba! 👋\n\n'
        '"${widget.sepet.name}" sepetime katılmak ister misin?\n\n'
        '📱 Sepet uygulamasını aç\n'
        '✅ "Sepete Katıl" seçeneğini seç\n'
        '🔢 Bu kodu gir: ${widget.sepet.joinCode}\n\n'
        'Veya bu linke tıkla: ${_generateShareLink()}';

    Share.share(message, subject: 'Sepet Daveti');
  }

  void _shareViaSMS() {
    final message = '"${widget.sepet.name}" sepetime katıl!\n'
        'Kod: ${widget.sepet.joinCode}\n'
        'Link: ${_generateShareLink()}';

    Share.share(message);
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
}
