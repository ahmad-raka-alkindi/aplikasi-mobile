import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator Kabataku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFFF4F4FB),
      ),
      home: const KalkulatorPage(),
    );
  }
}

class KalkulatorPage extends StatefulWidget {
  const KalkulatorPage({super.key});

  @override
  State<KalkulatorPage> createState() => _KalkulatorPageState();
}

class _KalkulatorPageState extends State<KalkulatorPage> {
  final TextEditingController _angka1Controller = TextEditingController();
  final TextEditingController _angka2Controller = TextEditingController();

  String _hasil = '0';
  String _operatorAktif = '';

  void _hitung(String operator) {
    double angka1 = double.tryParse(_angka1Controller.text) ?? 0;
    double angka2 = double.tryParse(_angka2Controller.text) ?? 0;
    double hasilOperasi = 0;

    setState(() {
      _operatorAktif = operator;

      switch (operator) {
        case 'kali':
          hasilOperasi = angka1 * angka2;
          break;
        case 'bagi':
          if (angka2 == 0) {
            _hasil = '∞';
            return;
          }
          hasilOperasi = angka1 / angka2;
          break;
        case 'tambah':
          hasilOperasi = angka1 + angka2;
          break;
        case 'kurang':
          hasilOperasi = angka1 - angka2;
          break;
      }

      _hasil = hasilOperasi == hasilOperasi.toInt()
          ? hasilOperasi.toInt().toString()
          : hasilOperasi.toStringAsFixed(2);
    });
  }

  @override
  void dispose() {
    _angka1Controller.dispose();
    _angka2Controller.dispose();
    super.dispose();
  }

  Widget _buildOpButton({
    required String label,
    required IconData icon,
    required String opKey,
    required Color color,
  }) {
    final bool aktif = _operatorAktif == opKey;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(aktif ? 0.45 : 0.25),
                blurRadius: aktif ? 16 : 8,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _hitung(opKey),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.75)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 22),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF9C6BFF)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.calculate_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kalkulator Kabataku',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D3A),
                        ),
                      ),
                      Text(
                        'kali · bagi · tambah · kurang',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF8A6BFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'HASIL',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _hasil,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              _buildInputField(
                controller: _angka1Controller,
                label: 'Angka Pertama',
                icon: Icons.filter_1_rounded,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _angka2Controller,
                label: 'Angka Kedua',
                icon: Icons.filter_2_rounded,
              ),
              const SizedBox(height: 28),

              Row(
                children: [
                  _buildOpButton(
                    label: 'Kali',
                    icon: Icons.close_rounded,
                    opKey: 'kali',
                    color: const Color(0xFFFF9800),
                  ),
                  _buildOpButton(
                    label: 'Bagi',
                    icon: Icons.percent_rounded,
                    opKey: 'bagi',
                    color: const Color(0xFF9C27B0),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildOpButton(
                    label: 'Tambah',
                    icon: Icons.add_rounded,
                    opKey: 'tambah',
                    color: const Color(0xFF4CAF50),
                  ),
                  _buildOpButton(
                    label: 'Kurang',
                    icon: Icons.remove_rounded,
                    opKey: 'kurang',
                    color: const Color(0xFFF44336),
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
