import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_colors.dart';
import '../models/sepet_item_model.dart';

class UrunEkleModal extends StatefulWidget {
  final Function(SepetItemModel) onUrunEkle;

  const UrunEkleModal({super.key, required this.onUrunEkle});

  @override
  State<UrunEkleModal> createState() => _UrunEkleModalState();
}

class _UrunEkleModalState extends State<UrunEkleModal> {
  final _urunController = TextEditingController();
  final _miktarController = TextEditingController();
  final _aciklamaController = TextEditingController();
  final _notController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final Uuid _uuid = const Uuid();

  String _selectedCategory = 'Diğer';
  String _selectedUnit = 'adet';

  @override
  void dispose() {
    _urunController.dispose();
    _miktarController.dispose();
    _aciklamaController.dispose();
    _notController.dispose();
    super.dispose();
  }

  void _submitUrun() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final newItem = SepetItemModel(
        id: _uuid.v4(),
        name: _urunController.text.trim(),
        description: _aciklamaController.text.trim().isEmpty
            ? null
            : _aciklamaController.text.trim(),
        quantity: int.tryParse(_miktarController.text.trim()) ?? 1,
        category: _selectedCategory,
        unit: _selectedUnit,
        note: _notController.text.trim().isEmpty
            ? null
            : _notController.text.trim(),
        isCompleted: false,
        addedBy: '', // Bu Firebase service'de doldurulacak
        addedByName: '', // Bu Firebase service'de doldurulacak
        createdAt: now,
        updatedAt: now,
      );

      widget.onUrunEkle(newItem);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add_shopping_cart,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Yeni Ürün Ekle',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Ürün adı
              TextFormField(
                controller: _urunController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Ürün Adı *',
                  hintText: 'Süt, Ekmek, Domates...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon:
                      const Icon(Icons.shopping_basket_outlined, size: 20),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ürün adı gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Miktar ve Birim
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _miktarController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Miktar *',
                        hintText: '1',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.numbers, size: 20),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Miktar gerekli';
                        }
                        if (int.tryParse(value.trim()) == null ||
                            int.parse(value.trim()) <= 0) {
                          return 'Geçerli bir sayı girin';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: InputDecoration(
                        labelText: 'Birim',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.straighten, size: 20),
                      ),
                      items: ItemCategories.units.map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUnit = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Kategori
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.category_outlined, size: 20),
                ),
                items: ItemCategories.categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 14),

              // Açıklama
              TextFormField(
                controller: _aciklamaController,
                decoration: InputDecoration(
                  labelText: 'Açıklama',
                  hintText: 'Yarım yağlı, organik...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.description_outlined, size: 20),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 14),

              // Not
              TextFormField(
                controller: _notController,
                decoration: InputDecoration(
                  labelText: 'Not',
                  hintText: 'Özel istekler, marka tercihi...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.note_outlined, size: 20),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Butonlar
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'İptal',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: _submitUrun,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'Ekle',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
