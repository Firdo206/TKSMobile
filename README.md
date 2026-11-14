# Aplikasi Olahraga Siswa

Aplikasi mobile untuk Tes Kemampuan Siswa (TKS) dan kegiatan olahraga
siswa Sekolah Dasar, dibangun dengan Flutter.

## Deskripsi

Aplikasi ini membantu sekolah dalam melaksanakan dan mencatat Tes Kemampuan
Siswa (TKS) serta kegiatan olahraga siswa SD. [Jelaskan singkat siapa
penggunanya: siswa / guru / admin sekolah.]

## Fitur Utama

- Login pengguna ([siswa])
- Tes Kemampuan Siswa (TKS)
- Pencatatan dan penilaian hasil tes olahraga
- Riwayat dan rekap hasil siswa
- [jenis olahraga]

## Teknologi yang Digunakan

- Flutter & Dart
- [Backend: Laravel / Firebase / dll.]
- [Database: MySQL ]

## Cara Menjalankan Project

1. Clone repository
   ```bash
   git clone https://github.com/Firdo206/aplikasi_olahragasiswa.git
   cd aplikasi_olahragasiswa
   ```
2. Install dependency
   ```bash
   flutter pub get
   ```
3. [Atur URL API / konfigurasi di file `lib/config/...`]
4. Jalankan aplikasi
   ```bash
   flutter run
   ```

## Build APK

```bash
flutter build apk --release
```

## Struktur Folder

```
lib/
├── models/      # model data
├── screens/     # halaman aplikasi
├── services/    # komunikasi dengan API
└── widgets/     # komponen UI
```

## Pengembang

- Firdo ([@Firdo206](https://github.com/Firdo206))
- Klien: [SD Pandansari 02 / Iqbal Atma]
