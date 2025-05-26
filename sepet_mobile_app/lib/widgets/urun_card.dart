import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/sepet_item_model.dart';
import '../services/firestore_service.dart';

class UrunCard extends StatelessWidget {
  final SepetItemModel urun;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final FirestoreService sepetService;

  const UrunCard({
    super.key,
    required this.urun,
    required this.onToggle,
    required this.onDelete,
    required this.sepetService,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _buildModernCheckbox(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildProductInfo(),
                  ),
                  _buildDeleteButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernCheckbox() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        gradient: urun.isCompleted ? AppColors.primaryGradient : null,
        color: urun.isCompleted ? null : Colors.transparent,
        border: Border.all(
          color: urun.isCompleted ? Colors.transparent : Colors.grey.shade300,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: urun.isCompleted
          ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 14,
            )
          : null,
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          urun.name,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            decoration: urun.isCompleted ? TextDecoration.lineThrough : null,
            decorationColor: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (urun.color ?? AppColors.primaryBlue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${urun.quantity} ${urun.unit ?? ''}',
                style: TextStyle(
                  fontSize: 11,
                  color: urun.color ?? AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '• ${AppStrings.addedBy} ${urun.addedByName}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (urun.isCompleted && urun.checkedBy != null) ...[
          const SizedBox(height: 3),
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                size: 12,
                color: AppColors.successGreen,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${AppStrings.checkedBy} ${urun.checkedBy}${urun.checkedAt != null ? ' • ${_formatTimeAgo(urun.checkedAt!)}' : ''}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
        if (urun.category != null) ...[
          const SizedBox(height: 3),
          Row(
            children: [
              Icon(
                urun.icon ??
                    SepetItemModel.getDefaultIconForCategory(urun.category),
                size: 12,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: 4),
              Text(
                urun.category!,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDeleteButton() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onDelete,
          child: Icon(
            Icons.delete_outline,
            color: Colors.red.shade400,
            size: 16,
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'şimdi';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}dk';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}sa';
    } else if (difference.inDays == 1) {
      return 'dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}g';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
