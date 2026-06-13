# CleanGo – Login Screen (Flutter)

## Struktur Proyek

```
cleango_login/
├── assets/
│   └── images/
│       └── bg_login.jpg        ← TARUH FOTO BACKGROUND DI SINI
├── lib/
│   ├── main.dart
│   └── screens/
│       └── login_screen.dart
└── pubspec.yaml
```

---

## Cara Menjalankan

### 1. Taruh Foto Background
Salin foto background kamu ke folder:
```
assets/images/bg_login.jpg
```
> Nama file harus persis `bg_login.jpg` (atau ubah di `login_screen.dart` baris:
> `const String bgAsset = 'assets/images/bg_login.jpg';`)

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Jalankan Virtual Device
- Buka **Android Studio → Device Manager**
- Klik ▶ pada emulator yang sudah dibuat
- Tunggu sampai emulator muncul

### 4. Jalankan di VS Code
```bash
flutter run
```
Atau tekan **F5** di VS Code setelah memilih device.

---

## Catatan
- Jika foto background belum ditaruh, layar akan tampil gradient biru sebagai fallback — tidak error.
- Tombol "Masuk ke Dashboard" sudah ada validasi kosong. 
- Untuk koneksi ke API Laravel, edit method `_handleLogin()` di `login_screen.dart`.
- Tombol "Daftar akun baru" bisa diarahkan ke screen register dengan `Navigator.push(...)`.
