import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class UserAccount {
  const UserAccount({
    required this.id,
    required this.name,
    required this.email,
  });

  final int id;
  final String name;
  final String email;
}

class ExpenseTransaction {
  const ExpenseTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
  });

  final int id;
  final String title;
  final int amount;
  final String type;
  final DateTime date;

  bool get isIncome => type == 'Pemasukan';
}

class EmailAlreadyRegisteredException implements Exception {
  const EmailAlreadyRegisteredException();
}

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  static const int _openingBalance = 250000;

  late final Future<Database> _database = _openDatabase();

  Future<Database> _openDatabase() async {
    final databasePath = join(await getDatabasesPath(), 'praktikum_1_5.db');
    return openDatabase(
      databasePath,
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL COLLATE NOCASE UNIQUE,
            password_hash TEXT NOT NULL,
            password_salt TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
        await database.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            amount INTEGER NOT NULL CHECK (amount > 0),
            type TEXT NOT NULL CHECK (type IN ('Pemasukan', 'Pengeluaran')),
            transaction_date TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  Future<UserAccount> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final database = await _database;
    final salt = _createSalt();
    try {
      final id = await database.insert('users', {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password_hash': _hashPassword(password, salt),
        'password_salt': salt,
        'created_at': DateTime.now().toIso8601String(),
      });
      return UserAccount(id: id, name: name.trim(), email: email.trim());
    } on DatabaseException catch (error) {
      if (error.isUniqueConstraintError()) {
        throw const EmailAlreadyRegisteredException();
      }
      rethrow;
    }
  }

  Future<UserAccount?> login({
    required String email,
    required String password,
  }) async {
    final database = await _database;
    final normalizedEmail = email.trim().toLowerCase();
    final users = await database.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );
    if (users.isEmpty) return null;

    final user = users.single;
    final salt = user['password_salt'] as String;
    if (_hashPassword(password, salt) != user['password_hash']) return null;
    return UserAccount(
      id: user['id'] as int,
      name: user['name'] as String,
      email: user['email'] as String,
    );
  }

  Future<void> updateUserName(int userId, String name) async {
    final database = await _database;
    final updated = await database.update(
      'users',
      {'name': name.trim()},
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (updated != 1) {
      throw StateError('Data pengguna tidak ditemukan.');
    }
  }

  Future<List<ExpenseTransaction>> getTransactions(int userId) async {
    final database = await _database;
    final rows = await database.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'transaction_date DESC, id DESC',
    );
    return rows
        .map(
          (row) => ExpenseTransaction(
            id: row['id'] as int,
            title: row['title'] as String,
            amount: row['amount'] as int,
            type: row['type'] as String,
            date: DateTime.parse(row['transaction_date'] as String),
          ),
        )
        .toList(growable: false);
  }

  Future<void> addTransaction({
    required int userId,
    required String title,
    required int amount,
    required String type,
    required DateTime date,
  }) async {
    final database = await _database;
    await database.insert('transactions', {
      'user_id': userId,
      'title': title.trim(),
      'amount': amount,
      'type': type,
      'transaction_date': date.toIso8601String(),
    });
  }

  int calculateBalance(Iterable<ExpenseTransaction> transactions) {
    return transactions.fold<int>(_openingBalance, (balance, transaction) {
      return balance +
          (transaction.isIncome ? transaction.amount : -transaction.amount);
    });
  }

  String _createSalt() {
    final random = Random.secure();
    return List<int>.generate(
      16,
      (_) => random.nextInt(256),
    ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  String _hashPassword(String password, String salt) {
    return sha256.convert(utf8.encode('$salt$password')).toString();
  }
}
