import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// 1. WIDGET UTAMA (Root Aplikasi)
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DashboardScreen(),
    );
  }
}

// 2. HALAMAN UTAMA (Scaffold) - DIPERBARUI
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Praktikum 2: Layouting'),
        backgroundColor: Colors.blue,
      ),
      // MENGGUNAKAN SingleChildScrollView agar layar bisa di-scroll
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GreetingWidget(),
              SizedBox(height: 20),
              BalanceCardWidget(),
              SizedBox(height: 20),
              ActionButtonsWidget(),
              SizedBox(height: 20),
              RecentTransactionsWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

// 3. STATELESS WIDGET (Sapaan - Dari Modul 1)
class GreetingWidget extends StatelessWidget {
  const GreetingWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.person, size: 30, color: Colors.white),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, Budi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Selamat datang kembali!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}

// 4. STATEFUL WIDGET (Kartu Saldo dengan Toggle)

class BalanceCardWidget extends StatefulWidget {
  const BalanceCardWidget({super.key});

  @override
  State<BalanceCardWidget> createState() => _BalanceCardWidgetState();
}

class _BalanceCardWidgetState extends State<BalanceCardWidget> {
  // Variabel State: Menyimpan status apakah saldo terlihat atau disensor
  bool _isBalanceVisible = true;

  // Fungsi untuk mengubah state
  void _toggleVisibility() {
    setState(() {
      _isBalanceVisible =
          !_isBalanceVisible; // Membalik nilai boolean (true <-> false)
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.teal,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris atas kartu: Teks "Saldo Utama" & Tombol Ikon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Saldo Utama',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                // Tombol Mata
                IconButton(
                  icon: Icon(
                    // Logika if-else singkat (Ternary Operator)
                    _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                  ),
                  onPressed: _toggleVisibility, // Memanggil fungsi ubah state
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Teks Nominal Saldo
            Text(
              // Logika if-else untuk menampilkan saldo atau sensor
              _isBalanceVisible ? 'Rp 5.000.000' : 'Rp *********',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'No. Rekening: 1234-5678',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

// 5. WIDGET TOMBOL AKSI (ROW) - BARU
class ActionButtonsWidget extends StatelessWidget {
  const ActionButtonsWidget({super.key});
  @override
  Widget build(BuildContext context) {
    // Menggunakan Row untuk menata tombol secara horizontal
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Jarak dibagi rata
      children: [
        _buildActionButton(Icons.arrow_downward, 'Pemasukan', Colors.green),
        _buildActionButton(Icons.arrow_upward, 'Pengeluaran', Colors.red),
        _buildActionButton(Icons.swap_horiz, 'Transfer', Colors.blue),
      ],
    );
  }

  // Fungsi pembantu untuk membuat desain tombol agar kode tidak berulang
  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Column(
      children: [
        // Container untuk membungkus ikon dengan warna background
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2), // Warna transparan
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// 6. WIDGET DAFTAR TRANSAKSI (COLUMN & LISTTILE) - BARU
class RecentTransactionsWidget extends StatelessWidget {
  const RecentTransactionsWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transaksi Terakhir',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        // Menggunakan Card agar daftar transaksi memiliki bayangan/bingkai
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Item Transaksi 1
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  child: Icon(Icons.fastfood, color: Colors.white),
                ),
                title: const Text('Makan Siang'),
                subtitle: const Text('13 Sep 2026'), // Tanggal statis
                trailing: const Text(
                  '- Rp 50.000',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1), // Garis pemisah
              // Item Transaksi 2
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.attach_money, color: Colors.white),
                ),
                title: const Text('Gaji Bulanan'),
                subtitle: const Text('01 Sep 2026'),
                trailing: const Text(
                  '+ Rp 5.000.000',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),

              // Item Transaksi 3
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.directions_car, color: Colors.white),
                ),
                title: const Text('Isi Bensin'),
                subtitle: const Text('10 Sep 2026'),
                trailing: const Text(
                  '- Rp 150.000',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
