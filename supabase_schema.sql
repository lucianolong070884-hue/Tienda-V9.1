
-- TIENDA V9 - Supabase database
create extension if not exists pgcrypto;

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  numero text unique not null,
  descripcion text not null,
  costo numeric(12,2) not null default 0,
  precio numeric(12,2) not null default 0,
  activo boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.suppliers (
  id uuid primary key default gen_random_uuid(),
  numero text unique not null,
  nombre text not null,
  activo boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.clients (
  id uuid primary key default gen_random_uuid(),
  numero text unique not null,
  nombre text not null,
  tipo text not null default 'Crédito',
  activo boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.inventory (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null unique references public.products(id) on update cascade,
  supplier_id uuid references public.suppliers(id) on update cascade,
  existencia numeric(12,2) not null default 0 check (existencia >= 0),
  updated_at timestamptz not null default now()
);

create table if not exists public.sales (
  id uuid primary key default gen_random_uuid(),
  fecha date not null default current_date,
  tipo text not null check (tipo in ('Contado','Crédito')),
  client_id uuid references public.clients(id),
  total numeric(12,2) not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check ((tipo='Crédito' and client_id is not null) or (tipo='Contado' and client_id is null))
);

create table if not exists public.sale_items (
  id uuid primary key default gen_random_uuid(),
  sale_id uuid not null references public.sales(id) on delete cascade,
  product_id uuid not null references public.products(id),
  cantidad numeric(12,2) not null check (cantidad > 0),
  precio numeric(12,2) not null default 0,
  costo numeric(12,2) not null default 0,
  total numeric(12,2) generated always as (cantidad*precio) stored
);

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.clients(id),
  fecha date not null default current_date,
  monto numeric(12,2) not null check (monto > 0),
  nota text default '',
  created_at timestamptz not null default now()
);

create or replace view public.account_balances as
select c.id, c.numero, c.nombre,
       coalesce((select sum(s.total) from public.sales s where s.tipo='Crédito' and s.client_id=c.id),0) as credit,
       coalesce((select sum(p.monto) from public.payments p where p.client_id=c.id),0) as paid,
       greatest(
         coalesce((select sum(s.total) from public.sales s where s.tipo='Crédito' and s.client_id=c.id),0)
         - coalesce((select sum(p.monto) from public.payments p where p.client_id=c.id),0),0
       ) as balance
from public.clients c where c.activo=true;

alter table public.products enable row level security;
alter table public.suppliers enable row level security;
alter table public.clients enable row level security;
alter table public.inventory enable row level security;
alter table public.sales enable row level security;
alter table public.sale_items enable row level security;
alter table public.payments enable row level security;

-- Single-company app: authenticated users can work with company data.
do $$ begin
  create policy products_auth on public.products for all to authenticated using (true) with check (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy suppliers_auth on public.suppliers for all to authenticated using (true) with check (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy clients_auth on public.clients for all to authenticated using (true) with check (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy inventory_auth on public.inventory for all to authenticated using (true) with check (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy sales_auth on public.sales for all to authenticated using (true) with check (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy sale_items_auth on public.sale_items for all to authenticated using (true) with check (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy payments_auth on public.payments for all to authenticated using (true) with check (true);
exception when duplicate_object then null; end $$;

grant select on public.account_balances to authenticated;

create or replace function public.create_sale(
  p_fecha date, p_tipo text, p_client_id uuid,
  p_items jsonb
) returns uuid
language plpgsql security invoker set search_path=public as $$
declare
  v_sale uuid := gen_random_uuid();
  item jsonb; v_total numeric := 0; v_stock numeric;
begin
  if p_tipo='Crédito' and p_client_id is null then raise exception 'El crédito requiere cliente'; end if;
  if p_tipo='Contado' then p_client_id := null; end if;

  insert into sales(id,fecha,tipo,client_id,total) values(v_sale,p_fecha,p_tipo,p_client_id,0);

  for item in select * from jsonb_array_elements(p_items) loop
    select existencia into v_stock from inventory where product_id=(item->>'product_id')::uuid for update;
    if v_stock is null then raise exception 'Producto sin inventario'; end if;
    if v_stock < (item->>'cantidad')::numeric then raise exception 'Existencia insuficiente'; end if;

    insert into sale_items(sale_id,product_id,cantidad,precio,costo)
    select v_sale,(item->>'product_id')::uuid,(item->>'cantidad')::numeric,
           (item->>'precio')::numeric,p.costo
    from products p where p.id=(item->>'product_id')::uuid;

    v_total := v_total + ((item->>'cantidad')::numeric*(item->>'precio')::numeric);
    update inventory set existencia=existencia-(item->>'cantidad')::numeric, updated_at=now()
      where product_id=(item->>'product_id')::uuid;
  end loop;

  update sales set total=v_total, updated_at=now() where id=v_sale;
  return v_sale;
end $$;

create or replace function public.delete_sale(p_sale_id uuid)
returns void language plpgsql security invoker set search_path=public as $$
begin
  update inventory i set existencia=i.existencia+x.cantidad, updated_at=now()
  from (select product_id,sum(cantidad) cantidad from sale_items where sale_id=p_sale_id group by product_id) x
  where i.product_id=x.product_id;
  delete from sales where id=p_sale_id;
end $$;

create or replace function public.update_sale(
  p_sale_id uuid, p_fecha date, p_tipo text, p_client_id uuid,
  p_product_id uuid, p_cantidad numeric, p_precio numeric
) returns void language plpgsql security invoker set search_path=public as $$
declare old_qty numeric; old_product uuid; stock numeric;
begin
  select product_id,cantidad into old_product,old_qty from sale_items where sale_id=p_sale_id limit 1 for update;
  if old_product is null then raise exception 'Venta no encontrada'; end if;

  update inventory set existencia=existencia+old_qty,updated_at=now() where product_id=old_product;
  select existencia into stock from inventory where product_id=p_product_id for update;
  if stock is null or stock<p_cantidad then
    update inventory set existencia=existencia-old_qty,updated_at=now() where product_id=old_product;
    raise exception 'Existencia insuficiente';
  end if;

  update inventory set existencia=existencia-p_cantidad,updated_at=now() where product_id=p_product_id;
  if p_tipo='Contado' then p_client_id:=null; end if;
  update sales set fecha=p_fecha,tipo=p_tipo,client_id=p_client_id,total=p_cantidad*p_precio,updated_at=now()
    where id=p_sale_id;
  update sale_items set product_id=p_product_id,cantidad=p_cantidad,precio=p_precio,
    costo=(select costo from products where id=p_product_id) where sale_id=p_sale_id;
end $$;

create or replace function public.client_balance(p_client_id uuid)
returns numeric language sql stable security invoker set search_path=public as $$
select greatest(
 coalesce((select sum(total) from sales where tipo='Crédito' and client_id=p_client_id),0)
 - coalesce((select sum(monto) from payments where client_id=p_client_id),0),0);
$$;
