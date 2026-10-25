-- Jalankan di Supabase Dashboard > SQL Editor.
-- RLS mengunci materi dan data transaksi berdasarkan akun. Jangan menonaktifkan RLS.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  is_admin boolean not null default false,
  created_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', 'Member'))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  product_id text not null check (product_id in ('starter','lengkap','premium')),
  product_name text not null,
  amount integer not null check (amount > 0),
  method text not null check (method in ('transfer','qris')),
  reference text,
  notes text,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  created_at timestamptz not null default now(),
  reviewed_at timestamptz
);

create table if not exists public.lessons (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  body text not null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.payments enable row level security;
alter table public.lessons enable row level security;

-- SECURITY DEFINER avoids recursive RLS checks when policies need to know admin status.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles p where p.id = auth.uid() and p.is_admin = true
  );
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

drop policy if exists "Profiles read own or admin" on public.profiles;
create policy "Profiles read own or admin" on public.profiles
for select to authenticated using (auth.uid() = id or public.is_admin());

-- User can never update is_admin from the browser. Only the database owner can change it in SQL.
drop policy if exists "User creates own profile" on public.profiles;
create policy "User creates own profile" on public.profiles
for insert to authenticated with check (auth.uid() = id and is_admin = false);

drop policy if exists "Users read own payments or admin" on public.payments;
create policy "Users read own payments or admin" on public.payments
for select to authenticated using (auth.uid() = user_id or public.is_admin());

drop policy if exists "Users submit own pending payments" on public.payments;
create policy "Users submit own pending payments" on public.payments
for insert to authenticated with check (
  auth.uid() = user_id and status = 'pending' and reviewed_at is null
);

drop policy if exists "Admin updates payments" on public.payments;
create policy "Admin updates payments" on public.payments
for update to authenticated using (public.is_admin())
with check (public.is_admin());

drop policy if exists "Approved members read lessons" on public.lessons;
create policy "Approved members read lessons" on public.lessons
for select to authenticated using (
  exists (
    select 1 from public.payments pay
    where pay.user_id = auth.uid() and pay.status = 'approved'
  )
  or public.is_admin()
);

-- Example starter lessons. Replace with your own complete paid content.
insert into public.lessons (title, body, sort_order)
select 'Mulai dari kebiasaan kecil', 'Buat jadwal makan yang realistis dan sesuaikan pilihan makanan dengan kebutuhan pribadi. Tidak ada satu menu yang cocok untuk semua orang.', 1
where not exists (select 1 from public.lessons);
insert into public.lessons (title, body, sort_order)
select 'Menyusun piring sehari-hari', 'Sebagai panduan umum, variasikan sayuran, sumber protein, karbohidrat, dan buah. Porsi yang sesuai dapat berbeda tergantung usia, aktivitas, dan kondisi kesehatan.', 2
where (select count(*) from public.lessons) < 2;

-- Setelah akun pemilik dibuat, setujui sebagai admin dengan mengganti email di bawah:
-- update public.profiles p set is_admin = true
-- from auth.users u where p.id = u.id and u.email = 'EMAIL-ADMIN-KAMU';
