# Praktikum 1-5: Aplikasi Keuangan

Aplikasi Flutter gabungan praktikum dengan dashboard layanan, pencatatan
transaksi, kalkulator, login, dan pendaftaran akun.

## Fitur

- Registrasi dan login lokal menggunakan SQLite. Password disimpan sebagai
  hash dengan salt, bukan sebagai teks biasa.
- Pencatatan pemasukan dan pengeluaran; data transaksi tersimpan per akun dan
  tetap tersedia setelah aplikasi ditutup.
- Saldo diperbarui dari saldo awal Rp 250.000 dan transaksi tersimpan.
- Riwayat transaksi, detail transaksi, profil, logout, layanan, dan katalog
  produk.
- Kalkulator Kabataku dari praktikum sebelumnya dapat dibuka melalui menu
  **Dompet**.

## Menjalankan dan menguji

```powershell
flutter pub get
flutter test
flutter analyze
flutter run
```

SQLite memakai database lokal `praktikum_1_5.db` pada perangkat. Menghapus data
aplikasi akan menghapus akun dan transaksi lokal.

## Membuat APK

```powershell
flutter build apk --release
```

Hasil build:

`build/app/outputs/flutter-apk/app-release.apk`

Konfigurasi proyek saat ini menggunakan signing debug untuk build release,
sehingga APK cocok untuk pemasangan dan demo, bukan publikasi Play Store.
