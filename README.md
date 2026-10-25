# Piring Seimbang

Starter website custom Next.js + Supabase untuk program digital dengan akun member, materi terkunci, dan verifikasi pembayaran manual.

## Fitur yang ada di kode
- Landing page responsif dengan contoh produk dan harga placeholder.
- Daftar dan masuk akun lewat Supabase Auth.
- Halaman member menampilkan status permintaan pembayaran.
- Form permintaan pembayaran transfer bank atau QRIS.
- Panel admin untuk menyetujui/menolak permintaan pembayaran.
- Materi hanya bisa dibaca akun dengan pembayaran berstatus `approved` (ditegakkan juga oleh Row Level Security/RLS di database).
- Halaman disclaimer.

## Yang BELUM otomatis / wajib dikonfigurasi
- Pembayaran tidak diproses atau diverifikasi otomatis. Pengelola harus mengecek rekening/QRIS sendiri.
- Tidak ada nomor rekening atau gambar QRIS asli di template. Tambahkan detail resmi setelah memeriksa kepemilikan rekening.
- Konten produk, harga, kebijakan privasi, ketentuan refund, dan informasi kontak masih contoh.
- Email verifikasi, reset kata sandi, domain, serta deployment belum disetel.
- Ini starter untuk dikembangkan dan diuji, bukan sistem yang sudah diaudit atau siap menangani data sensitif dalam skala besar.

## A. Buat project Supabase gratis
1. Buat project di https://supabase.com/ dan simpan password database di tempat aman.
2. Di Project Settings > API, salin Project URL dan `anon` / publishable key. Jangan pernah memasukkan `service_role` key ke browser atau repo.
3. Buka SQL Editor, jalankan seluruh isi `supabase/schema.sql`.
4. Daftarkan akun pemilik melalui halaman `/daftar` setelah website berjalan.
5. Verifikasi akun bila konfirmasi email diaktifkan.
6. Di SQL Editor, jalankan query ini dengan email pemilik yang benar:

   ```sql
   update public.profiles p
   set is_admin = true
   from auth.users u
   where p.id = u.id and u.email = 'EMAIL-ADMIN-KAMU';
   ```

   Ganti email contoh. Jangan berikan peran admin ke pengguna lain.
7. Di Authentication > URL Configuration, set Site URL ke URL website dan tambahkan URL lokal `http://localhost:3000/**` ke Redirect URLs bila dibutuhkan.

## B. Jalankan lokal
Butuh Node.js versi 18.17+ atau versi LTS terbaru.
1. Ekstrak ZIP dan buka folder `piring-seimbang`.
2. Salin `.env.example` menjadi `.env.local`.
3. Isi `NEXT_PUBLIC_SUPABASE_URL` dan `NEXT_PUBLIC_SUPABASE_ANON_KEY`.
4. Buka terminal di folder proyek dan jalankan:

   ```bash
   npm install
   npm run dev
   ```

5. Buka http://localhost:3000.
6. Daftar akun, lalu masuk. Untuk admin, jalankan query SQL di atas setelah akun terdaftar.

## C. Cara kerja verifikasi pembayaran manual
1. Member masuk ke `/pembayaran`, pilih paket dan metode transfer/QRIS, lalu kirim referensi transaksi.
2. Admin masuk dengan akun admin dan membuka `/admin`.
3. Admin mencocokkan transaksi di aplikasi bank atau dashboard QRIS yang sebenarnya.
4. Hanya jika dana benar-benar diterima, admin klik **Setujui**. Jangan percaya hanya pada screenshot atau nomor referensi.
5. Database mengubah status pembayaran; halaman member menampilkan materi yang hanya dapat dibaca oleh akun yang punya pembayaran disetujui.

**Penting:** form ini belum meminta upload bukti transfer. Kalau mau upload gambar, buat bucket privat dan kebijakan Storage yang benar; jangan mengunggah bukti yang berisi data pribadi ke folder publik.

## D. Deploy gratis ke Vercel
1. Buat akun GitHub dan buat repository baru privat atau publik sesuai pilihanmu.
2. Upload semua file proyek kecuali `.env.local`, `node_modules`, dan `.next`.
3. Import repository ke https://vercel.com/.
4. Tambahkan Environment Variables berikut di pengaturan project Vercel:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
5. Deploy. Tambahkan URL Vercel yang muncul ke Supabase Authentication > URL Configuration > Redirect URLs, lalu jadikan URL tersebut Site URL.
6. Uji daftar, login, permintaan pembayaran, akses admin, dan penguncian materi di website hasil deploy.

Hosting gratis dan layanan gratis memiliki batas penggunaan dan ketentuan yang bisa berubah. Domain Vercel gratis dapat digunakan untuk uji awal; domain sendiri biasanya berbayar.

## E. Uji keamanan sebelum diluncurkan
- Buat dua akun biasa. Pastikan akun A tidak bisa melihat pembayaran akun B.
- Pastikan akun biasa tidak dapat menyetujui transaksi atau mengubah `is_admin`.
- Pastikan materi tidak bisa dibaca sebelum ada transaksi approved. RLS di schema melakukan pemeriksaan ini pada database.
- Pastikan akun admin ditetapkan hanya melalui SQL/dashboard tepercaya.
- Pastikan tidak ada `service_role` key di frontend, GitHub, atau variabel `NEXT_PUBLIC_*`.
- Jangan mengklaim program memberi hasil medis atau berat badan tertentu.
- Tambahkan kontak dukungan, kebijakan privasi, ketentuan pembelian, dan aturan refund yang benar.

## Struktur
```text
piring-seimbang/
├── app/
│   ├── admin/page.tsx
│   ├── daftar/page.tsx
│   ├── disclaimer/page.tsx
│   ├── globals.css
│   ├── layout.tsx
│   ├── masuk/page.tsx
│   ├── member/page.tsx
│   ├── pembayaran/page.tsx
│   └── page.tsx
├── components/
│   ├── SiteFooter.tsx
│   └── SiteHeader.tsx
├── lib/supabase.ts
├── supabase/schema.sql
├── .env.example
├── package.json
└── README.md
```
