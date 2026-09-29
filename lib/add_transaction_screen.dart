import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // GlobalKey untuk mengontrol form dan memicu validasi
  final _formKey = GlobalKey<FormState>();

  // Controller untuk mengambil teks dari input
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _dateController = TextEditingController(); // ini yang buat latihan

  // State untuk Dropdown
  String _selectedCategory = 'Makanan';
  String _selectedType = 'Pengeluaran';
  DateTime _selectedDate = DateTime.now();
  final List<String> _categories = [
    'Makanan',
    'Transportasi',
    'Hiburan',
    'Lainnya',
  ];

  @override
  void dispose() {
    // Bersihkan controller saat halaman ditutup untuk mencegah memory leak
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _dateController.dispose(); // ini controller barunya yang buat latihan
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
        // Mengisi teks ke _dateController sesuai format DD/MM/YYYY
        _dateController.text =
            '${date.day.toString().padLeft(2, '0')}/'
            '${date.month.toString().padLeft(2, '0')}/'
            '${date.year}';
      });
    }
  }

  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) return;

    final formattedDate =
        '${_selectedDate.day.toString().padLeft(2, '0')}/'
        '${_selectedDate.month.toString().padLeft(2, '0')}/'
        '${_selectedDate.year}';
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Transaksi tersimpan'),
        content: Text(
          '$_selectedType Rp ${_amountController.text}\n'
          '${_titleController.text.trim()}\n'
          '$_selectedCategory - $formattedDate',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _titleController.clear();
              _amountController.clear();
              _notesController.clear();
              _dateController.clear(); // Ikut dibersihkan saat form di-reset
              setState(() {
                _selectedCategory = _categories.first;
                _selectedType = 'Pengeluaran';
                _selectedDate = DateTime.now();
              });
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Catat Transaksi Baru"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      // SingleChildScrollView mencegah error layout saat keyboard muncul
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Jenis transaksi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.swap_vert),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Pengeluaran',
                    child: Text('Pengeluaran'),
                  ),
                  DropdownMenuItem(
                    value: 'Pemasukan',
                    child: Text('Pemasukan'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _selectedType = value);
                },
              ),

              const SizedBox(height: 16),

              // Input 1: Judul Transaksi
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Judul Transaksi",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Judul transaksi tidak boleh kosong";
                  }
                  if (value.trim().length < 3) return 'Minimal 3 karakter';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Input 2: Nominal Saldo (Keyboard Angka)
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: "Nominal (Rp)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Nominal wajib diisi";
                  }

                  final amount = int.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return "Harus berupa angka bulat yang valid";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Input 3: Kategori Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Kategori",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    if (newValue != null) _selectedCategory = newValue;
                  });
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes_outlined),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 16),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Tanggal transaksi'),
                subtitle: Text(
                  '${_selectedDate.day.toString().padLeft(2, '0')}/'
                  '${_selectedDate.month.toString().padLeft(2, '0')}/'
                  '${_selectedDate.year}',
                ),
                trailing: OutlinedButton(
                  onPressed: _selectDate,
                  child: const Text('Ubah'),
                ),
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                readOnly: true, // Tidak bisa diketik manual via keyboard
                onTap: _selectDate, // Menampilkan date picker saat diklik
                decoration: InputDecoration(
                  labelText: "Tanggal Transaksi (DD/MM/YYYY)",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.edit_calendar),
                    onPressed: _selectDate,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Tanggal transaksi wajib diisi!";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Tombol Simpan
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _saveTransaction,
                child: const Text(
                  "Simpan Transaksi",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
