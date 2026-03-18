<div align="center">

# 📖 KBBI Sambung Kata GUI

**Antarmuka visual untuk permainan Sambung Kata berbasis KBBI**

[![React](https://img.shields.io/badge/React-18.3-61DAFB?style=flat-square&logo=react&logoColor=white)](https://reactjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.5-3178C6?style=flat-square&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Vite](https://img.shields.io/badge/Vite-5.4-646CFF?style=flat-square&logo=vite&logoColor=white)](https://vitejs.dev/)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-3.4-06B6D4?style=flat-square&logo=tailwindcss&logoColor=white)](https://tailwindcss.com/)

<br />

<img src="https://img.shields.io/badge/version-v3.0-3782F0?style=for-the-badge&labelColor=0A1023" alt="Version" />
<img src="https://img.shields.io/badge/kata-181%2C651-28C864?style=for-the-badge&labelColor=0A1E10" alt="Words" />
<img src="https://img.shields.io/badge/by-Sobing4413-9646EB?style=for-the-badge&labelColor=160A26" alt="Author" />

</div>

---

## ✨ Tentang

**KBBI Sambung Kata GUI** adalah antarmuka grafis modern untuk membantu pemain dalam permainan **Sambung Kata** — sebuah permainan kata populer di mana pemain harus menyebutkan kata yang dimulai dengan huruf terakhir dari kata sebelumnya.

Aplikasi ini dilengkapi dengan **181.651 kata** dari Kamus Besar Bahasa Indonesia (KBBI), sistem penilaian tingkat bahaya kata, dan fitur auto-answer cerdas.

---

## 🎮 Fitur Utama

| Fitur | Deskripsi |
|-------|-----------|
| 🔤 **Pencarian Kata** | Filter kata berdasarkan awalan huruf (prefix) secara real-time |
| 💀 **Danger Level** | Setiap kata dinilai tingkat bahayanya: `KILLER` → `BAHAYA` → `RISKY` → `NORMAL` → `AMAN` |
| 🧠 **Strategy+ Sort** | Mode sorting cerdas — kata dengan akhiran mematikan (x/z/q/v/f) ditampilkan paling atas |
| 📊 **Difficulty Sort** | Mode sorting alternatif berdasarkan skor kesulitan huruf akhir |
| 🤖 **Auto Answer** | Toggle auto-answer untuk menjawab secara otomatis |
| 🚫 **Duplicate Filter** | Kata yang sudah digunakan otomatis difilter dari daftar opsi |
| 🎨 **5 Tema Warna** | Merah, Hijau, Biru (default), Ungu, dan Abu-abu |
| 🔔 **Notifikasi Real-time** | Sistem notifikasi dengan progress bar dan auto-dismiss |
| 📱 **Responsive** | Mendukung tampilan desktop dan mobile |

---

## 🎨 Tema Tersedia

| Tema | Warna Aksen | Preview |
|------|-------------|---------|
| 🔴 **Merah** | `#E63741` | Merah tegas, cocok untuk suasana kompetitif |
| 🟢 **Hijau** | `#28C864` | Hijau segar, nyaman di mata |
| 🔵 **Biru** | `#3782F0` | Biru elegan, tema default |
| 🟣 **Ungu** | `#9646EB` | Ungu misterius, tampilan premium |
| ⚪ **Abu-abu** | `#8C91A0` | Minimalis dan netral |

---

## 💀 Sistem Danger Level

Setiap kata diklasifikasikan berdasarkan tingkat bahaya huruf akhirnya:

```
💀 KILLER     → Akhiran x, z, q        (hampir mustahil dilanjutkan)
⚠️  BAHAYA     → Akhiran v, f           (sangat sulit dilanjutkan)
🟡 RISKY      → Akhiran w, y, j        (berisiko tinggi)
🔵 NORMAL     → Akhiran k, b, p, g, d  (cukup menantang)
🟢 AMAN       → Akhiran umum a-u       (mudah dilanjutkan)
```

---

## 🏗️ Arsitektur Proyek

```
src/
├── components/
│   ├── KBBIGui.tsx              # Komponen utama GUI
│   ├── TopBar.tsx               # Bar atas (judul, kontrol, tema)
│   ├── LeftPanel.tsx            # Panel kiri (status, auto-answer, tips)
│   ├── WordList.tsx             # Daftar kata dengan scroll
│   ├── LoadingScreen.tsx        # Layar loading animasi
│   ├── NotificationSystem.tsx   # Sistem notifikasi toast
│   └── ui/                      # Komponen shadcn/ui
├── hooks/
│   ├── use-mobile.tsx           # Hook deteksi perangkat mobile
│   └── use-toast.ts             # Hook manajemen toast
├── lib/
│   ├── themes.ts                # Definisi 5 tema warna
│   ├── utils.ts                 # Utility functions
│   ├── api.ts                   # API client setup
│   └── config.ts                # Konfigurasi runtime
├── pages/
│   └── Index.tsx                # Halaman utama
├── App.tsx                      # Root component & routing
├── main.tsx                     # Entry point aplikasi
└── index.css                    # Global styles & Tailwind
```

---

## 🚀 Memulai

### dependencies

- [Node.js](https://nodejs.org/) v18+
- [pnpm](https://pnpm.io/) v8+

### Instalasi

```bash
# Clone repository
git clone https://github.com/SOBING4413/GUI.git
cd GUI

# Install dependencies
pnpm install

# Jalankan development server
pnpm run dev
```

Aplikasi akan berjalan di `http://localhost:3000`

### Build untuk Produksi

```bash
# Build
pnpm run build

# Preview build
pnpm run preview
```

### Linting

```bash
pnpm run lint
```

---

## 🛠️ Tech Stack

| Teknologi | Versi | Kegunaan |
|-----------|-------|----------|
| **React** | 18.3 | UI Library |
| **TypeScript** | 5.5 | Type Safety |
| **Vite** | 5.4 | Build Tool & Dev Server |
| **Tailwind CSS** | 3.4 | Utility-first CSS |
| **shadcn/ui** | latest | Komponen UI |
| **React Router** | 6.x | Client-side Routing |

---

## 📋 Perintah yang Tersedia

| Perintah | Deskripsi |
|----------|-----------|
| `pnpm install` | Install semua dependencies |
| `pnpm run dev` | Jalankan development server |
| `pnpm run build` | Build untuk produksi |
| `pnpm run preview` | Preview hasil build |
| `pnpm run lint` | Jalankan ESLint |

---

## 🎯 Cara Penggunaan

1. **Buka aplikasi** — Tunggu loading screen selesai
2. **Pilih huruf awalan** — Klik tombol huruf di bagian bawah (BA, KA, MA, SA, TA)
3. **Lihat daftar kata** — Kata ditampilkan dengan indikator danger level
4. **Klik kata** — Kata akan otomatis dipilih dan notifikasi muncul
5. **Ganti mode sorting** — Klik tombol 🧠 di top bar untuk beralih antara Strategy+ dan Difficulty
6. **Ganti tema** — Klik tombol ◆ di top bar untuk memilih tema warna
7. **Auto Answer** — Aktifkan toggle di panel kiri untuk mode auto-answer

---

## 📝 Changelog

### v3.0 — SmartAuto + DupFilter
- ✅ Sistem sorting Strategy+ (kata akhiran mematikan di atas)
- ✅ Sistem sorting Difficulty (berdasarkan skor huruf akhir)
- ✅ Duplicate Filter — kata terpakai otomatis hilang
- ✅ 5 tema warna dengan transisi smooth
- ✅ Loading screen dengan animasi
- ✅ Sistem notifikasi real-time dengan progress bar
- ✅ Auto Answer toggle
- ✅ Responsive design
- ✅ Click-outside dismiss untuk theme panel

---

## 👨‍💻 Kontributor

<table>
  <tr>
    <td align="center">
      <strong>Sobing4413</strong><br />
      <sub>Creator & Developer</sub>
    </td>
  </tr>
</table>

---

## 📄 Lisensi

Project ini digarap oleh **Sobing4413**. Silakan hubungi pembuat untuk informasi lisensi.

---

<div align="center">

**⚡ Dibuat dengan ❤️ menggunakan React + TypeScript + Tailwind CSS**

</div>
