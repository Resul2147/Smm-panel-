-- Supabase SQL Editor içinde çalıştırın. Yalnızca kendi projenizde kullanın.
create table if not exists public.profiles(id uuid primary key references auth.users(id) on delete cascade,balance numeric(14,2) not null default 0 check(balance>=0),is_admin boolean not null default false,created_at timestamptz not null default now());
create table if not exists public.services(id uuid primary key default gen_random_uuid(),name text not null check(length(name) between 1 and 100),category text not null check(length(category) between 1 and 60),price numeric(14,2) not null check(price>=0),active boolean not null default true,created_at timestamptz not null default now());
create table if not exists public.orders(id uuid primary key default gen_random_uuid(),user_id uuid not null references auth.users(id) on delete cascade,service_id uuid not null references public.services(id),target text not null check(length(target) between 8 and 2000),quantity integer not null check(quantity between 1 and 100000),total_price numeric(14,2) not null check(total_price>=0),status text not null default 'pending' check(status in ('pending','processing','completed','cancelled')),created_at timestamptz not null default now());
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path = '' as $$
begin insert into public.profiles(id) values(new.id) on conflict(id) do nothing;return new;end;$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();
insert into public.profiles(id) select id from auth.users on conflict(id) do nothing;
create or replace function public.is_panel_admin() returns boolean language sql stable security definer set search_path = '' as $$
select exists(select 1 from public.profiles where id=(select auth.uid()) and is_admin=true);$$;
revoke all on function public.is_panel_admin() from public;
grant execute on function public.is_panel_admin() to authenticated;
alter table public.profiles enable row level security;
alter table public.services enable row level security;
alter table public.orders enable row level security;
drop policy if exists profile_read on public.profiles;
create policy profile_read on public.profiles for select to authenticated using(id=(select auth.uid()) or (select public.is_panel_admin()));
drop policy if exists service_read on public.services;
create policy service_read on public.services for select to anon,authenticated using(active=true or (select public.is_panel_admin()));
drop policy if exists service_admin_insert on public.services;
create policy service_admin_insert on public.services for insert to authenticated with check((select public.is_panel_admin()));
drop policy if exists service_admin_update on public.services;
create policy service_admin_update on public.services for update to authenticated using((select public.is_panel_admin())) with check((select public.is_panel_admin()));
drop policy if exists orders_read on public.orders;
create policy orders_read on public.orders for select to authenticated using(user_id=(select auth.uid()) or (select public.is_panel_admin()));
drop policy if exists orders_admin_update on public.orders;
create policy orders_admin_update on public.orders for update to authenticated using((select public.is_panel_admin())) with check((select public.is_panel_admin()));
create or replace function public.create_order(p_service_id uuid,p_target text,p_quantity integer)
returns uuid language plpgsql security definer set search_path = '' as $$
declare v_user uuid := auth.uid();v_price numeric(14,2);v_id uuid;
begin
if v_user is null then raise exception 'Önce giriş yapın';end if;
if p_quantity is null or p_quantity<1 or p_quantity>100000 then raise exception 'Geçersiz adet';end if;
if p_target is null or length(p_target)<8 or length(p_target)>2000 or p_target !~* '^https?://[^[:space:]]+$' then raise exception 'Geçersiz hedef bağlantısı';end if;
select price into v_price from public.services where id=p_service_id and active=true;
if not found then raise exception 'Hizmet bulunamadı';end if;
insert into public.orders(user_id,service_id,target,quantity,total_price) values(v_user,p_service_id,p_target,p_quantity,v_price*p_quantity) returning id into v_id;
return v_id;end;$$;
revoke all on function public.create_order(uuid,text,integer) from public;
grant execute on function public.create_order(uuid,text,integer) to authenticated;
-- Yönetici yapmak için, kayıt sonrasında kendi e-postanızı girerek ayrıca çalıştırın:
-- update public.profiles set is_admin=true where id=(select id from auth.users where email='SIZIN_EPOSTANIZ');
-- Gerçek ödeme ve otomatik teslimat entegre değildir.

-- Başlangıç hizmet kataloğu: yalnızca meşru içerik ve hesap danışmanlığı
insert into public.services(name,category,price,active)
select seed.name,seed.category,seed.price,true
from (values
 ('Instagram Profil Analizi','Instagram',149.00::numeric),
 ('TikTok İçerik Planı','TikTok',199.00::numeric),
 ('YouTube Kanal Analizi','YouTube',249.00::numeric),
 ('Sosyal Medya İçerik Danışmanlığı','Genel',299.00::numeric)
) as seed(name,category,price)
where not exists(select 1 from public.services s where s.name=seed.name);
