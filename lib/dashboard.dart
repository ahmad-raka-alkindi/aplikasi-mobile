import 'package:flutter/material.dart';

import 'add_transaction_screen.dart';
import 'data/app_database.dart';
import 'kalkulator.dart' as calculator;
import 'login_screen.dart';
import 'transaction_detail_screen.dart';

void main() {
  runApp(const DashboardApp());
}

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _DashboardPage.green),
        scaffoldBackgroundColor: const Color(0xFFF5F7F6),
        useMaterial3: true,
      ),
      home: const DashboardPage(userEmail: ''),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    this.userId = 0,
    this.userName = 'Teman',
    required this.userEmail,
  });

  final int userId;
  final String userName;
  final String userEmail;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  late String _userName = widget.userName;
  List<ExpenseTransaction> _transactions = const [];
  bool _isLoadingTransactions = true;
  String? _transactionError;

  @override
  void initState() {
    super.initState();
    _refreshTransactions();
  }

  Future<void> _refreshTransactions() async {
    try {
      final transactions = widget.userId > 0
          ? await AppDatabase.instance.getTransactions(widget.userId)
          : <ExpenseTransaction>[];
      if (!mounted) return;
      setState(() {
        _transactions = transactions;
        _transactionError = null;
        _isLoadingTransactions = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _transactionError = error.toString();
        _isLoadingTransactions = false;
      });
    }
  }

  int get _balance => AppDatabase.instance.calculateBalance(_transactions);

  Future<void> _openAddTransaction() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => AddTransactionScreen(userId: widget.userId),
      ),
    );
    if (saved == true) await _refreshTransactions();
  }

  void _showTransactionDetail(ExpenseTransaction transaction) {
    final amount = NumberFormatRupiah.format(transaction.amount);
    final date =
        '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}';
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TransactionDetailScreen(
          title: transaction.title,
          amount: '${transaction.isIncome ? '+' : '-'} $amount',
          category: transaction.type,
          date: date,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _HomeContent(
              userName: _userName,
              balance: _balance,
              onTopUp: _openAddTransaction,
            ),
            _ActivityTab(
              transactions: _transactions,
              isLoading: _isLoadingTransactions,
              error: _transactionError,
              onTransactionTap: _showTransactionDetail,
            ),
            _WalletTab(balance: _balance, onTopUp: _openAddTransaction),
            _ProfileTab(
              userName: _userName,
              userEmail: widget.userEmail,
              userId: widget.userId,
              onUserNameChanged: (name) => setState(() => _userName = name),
              onLogout: _logout,
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: _openAddTransaction,
              backgroundColor: _DashboardPage.green,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Aktivitas',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Dompet',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text(
          'Kamu perlu login kembali untuk masuk ke aplikasi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (!mounted || shouldLogout != true) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.userName,
    required this.balance,
    required this.onTopUp,
  });

  final String userName;
  final int balance;
  final VoidCallback onTopUp;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 23,
                  backgroundColor: Color(0xFFD9F4E6),
                  child: Icon(Icons.person, color: _DashboardPage.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat pagi,',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Notifikasi',
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _DashboardPage.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Saldo Dompet',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          NumberFormatRupiah.format(balance),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: onTopUp,
                    icon: const Icon(Icons.add),
                    label: const Text('Top up'),
                    style: FilledButton.styleFrom(
                      foregroundColor: _DashboardPage.green,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          sliver: SliverToBoxAdapter(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari layanan atau kebutuhanmu',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Layanan untukmu',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: () {}, child: const Text('Lihat semua')),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            delegate: SliverChildListDelegate([
              _ServiceTile(
                icon: Icons.two_wheeler,
                label: 'Antar',
                color: Colors.green.shade100,
              ),
              _ServiceTile(
                icon: Icons.restaurant,
                label: 'Makan',
                color: Colors.orange.shade100,
                onTap: () => _openProducts(context, 'Makanan'),
              ),
              _ServiceTile(
                icon: Icons.local_shipping_outlined,
                label: 'Kirim',
                color: Colors.blue.shade100,
              ),
              _ServiceTile(
                icon: Icons.shopping_bag_outlined,
                label: 'Belanja',
                color: Colors.pink.shade100,
                onTap: () => _openProducts(context, 'Belanja'),
              ),
              _ServiceTile(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Bayar',
                color: Colors.purple.shade100,
              ),
              _ServiceTile(
                icon: Icons.receipt_long_outlined,
                label: 'Tagihan',
                color: Colors.teal.shade100,
              ),
            ]),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.05,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Promo hari ini',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE6B8),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hemat setiap perjalanan',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text('Dapatkan voucher hingga Rp 20.000'),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.local_offer_rounded,
                        size: 48,
                        color: Colors.orange.shade700,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap ?? () => _showMessage(context, '$label dipilih'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color,
                child: Icon(icon, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityTab extends StatelessWidget {
  const _ActivityTab({
    required this.transactions,
    required this.isLoading,
    required this.error,
    required this.onTransactionTap,
  });

  final List<ExpenseTransaction> transactions;
  final bool isLoading;
  final String? error;
  final ValueChanged<ExpenseTransaction> onTransactionTap;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      Text(
        'Aktivitas',
        style: Theme.of(context).textTheme.headlineSmall
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 6),
      Text(
        'Pantau semua transaksi kamu',
        style: TextStyle(color: Colors.grey.shade600),
      ),
      const SizedBox(height: 24),
    ];
    if (isLoading) {
      children.add(const Center(child: CircularProgressIndicator()));
    } else if (error != null) {
      children.add(Text('Gagal memuat transaksi: $error'));
    } else if (transactions.isEmpty) {
      children.add(
        const Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Belum ada transaksi. Tekan + untuk mencatat transaksi.',
            ),
          ),
        ),
      );
    } else {
      for (final transaction in transactions) {
        children.add(
          _TransactionTile(
            icon: transaction.isIncome
                ? Icons.attach_money
                : Icons.receipt_long_outlined,
            title: transaction.title,
            subtitle:
                '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
            amount:
                '${transaction.isIncome ? '+' : '-'} ${NumberFormatRupiah.format(transaction.amount)}',
            color: transaction.isIncome
                ? const Color(0xFFD9F4E6)
                : const Color(0xFFFFE1C4),
            isIncome: transaction.isIncome,
            onTap: () => onTransactionTap(transaction),
          ),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: children,
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.color,
    this.isIncome = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final Color color;
  final bool isIncome;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.black87),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Text(
          amount,
          style: TextStyle(
            color: isIncome ? _DashboardPage.green : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _WalletTab extends StatelessWidget {
  const _WalletTab({required this.balance, required this.onTopUp});

  final int balance;
  final VoidCallback onTopUp;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        Text(
          'Dompet',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: _DashboardPage.green,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Saldo tersedia',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                NumberFormatRupiah.format(balance),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _WalletAction(
                icon: Icons.add_circle_outline,
                label: 'Top up',
                onPressed: onTopUp,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _WalletAction(
                icon: Icons.arrow_upward_rounded,
                label: 'Kirim',
                onPressed: () => _showMessage(context, 'Fitur kirim dipilih'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          'Menu pembayaran',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _MenuRow(
          icon: Icons.receipt_long_outlined,
          title: 'Bayar tagihan',
          onTap: () => _showMessage(context, 'Bayar tagihan dipilih'),
        ),
        _MenuRow(
          icon: Icons.local_offer_outlined,
          title: 'Voucher dan promo',
          onTap: () => _showMessage(context, 'Voucher dipilih'),
        ),
        _MenuRow(
          icon: Icons.calculate_outlined,
          title: 'Kalkulator Kabataku',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const calculator.KalkulatorPage(),
            ),
          ),
        ),
      ],
    );
  }
}

class _WalletAction extends StatelessWidget {
  const _WalletAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
    );
  }
}

class _ProfileTab extends StatefulWidget {
  const _ProfileTab({
    required this.userName,
    required this.userEmail,
    required this.userId,
    required this.onUserNameChanged,
    required this.onLogout,
  });

  final String userName;
  final String userEmail;
  final int userId;
  final ValueChanged<String> onUserNameChanged;
  final VoidCallback onLogout;

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _editProfile() async {
    final formKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit profil'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nama lengkap',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) => value == null || value.trim().length < 3
                    ? 'Nama minimal 3 karakter'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                if (widget.userId > 0) {
                  await AppDatabase.instance.updateUserName(
                    widget.userId,
                    _nameController.text,
                  );
                }
              } catch (error) {
                if (!mounted || !dialogContext.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Profil gagal diperbarui: $error')),
                );
                return;
              }
              if (!mounted || !dialogContext.mounted) return;
              widget.onUserNameChanged(_nameController.text.trim());
              Navigator.pop(dialogContext);
              if (!mounted) return;
              _showMessage(context, 'Profil berhasil diperbarui');
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        Text(
          'Profil',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: Color(0xFFD9F4E6),
                child: Icon(
                  Icons.person,
                  size: 34,
                  color: _DashboardPage.green,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.userEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Edit profil',
                onPressed: _editProfile,
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Pengaturan akun',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _MenuRow(
          icon: Icons.person_outline,
          title: 'Data pribadi',
          onTap: _editProfile,
        ),
        _MenuRow(
          icon: Icons.location_on_outlined,
          title: 'Alamat tersimpan',
          onTap: () => _showMessage(context, 'Alamat tersimpan dipilih'),
        ),
        _MenuRow(
          icon: Icons.notifications_none,
          title: 'Notifikasi',
          onTap: () => _showMessage(context, 'Notifikasi dipilih'),
        ),
        _MenuRow(
          icon: Icons.help_outline,
          title: 'Pusat bantuan',
          onTap: () => _showMessage(context, 'Pusat bantuan dipilih'),
        ),
        _MenuRow(
          icon: Icons.logout,
          title: 'Keluar',
          textColor: Colors.red,
          onTap: widget.onLogout,
        ),
      ],
    );
  }
}

void _openProducts(BuildContext context, String category) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => ProductPage(category: category)),
  );
}

class ProductPage extends StatefulWidget {
  const ProductPage({required this.category, super.key});

  final String category;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int _cartCount = 0;

  List<_Product> get _products => widget.category == 'Makanan'
      ? const [
          _Product('Nasi ayam sambal', 'Rp 25.000', Icons.rice_bowl),
          _Product('Kopi susu gula aren', 'Rp 18.000', Icons.coffee),
          _Product('Mie goreng spesial', 'Rp 22.000', Icons.lunch_dining),
        ]
      : const [
          _Product(
            'Paket kebutuhan harian',
            'Rp 45.000',
            Icons.shopping_basket,
          ),
          _Product('Air mineral 600 ml', 'Rp 5.000', Icons.water_drop),
          _Product('Buah segar pilihan', 'Rp 30.000', Icons.eco),
        ];

  void _addToCart(_Product product) {
    setState(() => _cartCount++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} ditambahkan ke keranjang')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Badge(
              label: Text('$_cartCount'),
              isLabelVisible: _cartCount > 0,
              child: IconButton(
                tooltip: 'Keranjang',
                onPressed: () => _showMessage(
                  context,
                  _cartCount == 0
                      ? 'Keranjang masih kosong'
                      : '$_cartCount produk di keranjang',
                ),
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _products.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9F4E6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      product.icon,
                      size: 32,
                      color: _DashboardPage.green,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          product.price,
                          style: const TextStyle(color: _DashboardPage.green),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Tambah ke keranjang',
                    onPressed: () => _addToCart(product),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Product {
  const _Product(this.name, this.price, this.icon);

  final String name;
  final String price;
  final IconData icon;
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: textColor ?? Colors.black87),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class NumberFormatRupiah {
  static String format(int amount) {
    final digits = amount.toString();
    final grouped = digits.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return 'Rp $grouped';
  }
}

class _DashboardPage {
  static const green = Color(0xFF168A50);
}
