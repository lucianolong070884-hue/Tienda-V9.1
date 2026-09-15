-- DATOS INICIALES CORREGIDOS - Tienda.xlsx
begin;
insert into public.suppliers(numero,nombre) values ('1','WLAMART') on conflict(numero) do update set nombre=excluded.nombre,updated_at=now();
insert into public.suppliers(numero,nombre) values ('2','BODEGA AURRERA') on conflict(numero) do update set nombre=excluded.nombre,updated_at=now();
insert into public.suppliers(numero,nombre) values ('3','SEVILLANA') on conflict(numero) do update set nombre=excluded.nombre,updated_at=now();
insert into public.products(numero,descripcion,costo,precio) values ('1','Papas sin picante',10.00,15.00) on conflict(numero) do update set descripcion=excluded.descripcion,costo=excluded.costo,precio=excluded.precio,updated_at=now();
insert into public.products(numero,descripcion,costo,precio) values ('2','Papas con picante',10.00,15.00) on conflict(numero) do update set descripcion=excluded.descripcion,costo=excluded.costo,precio=excluded.precio,updated_at=now();
insert into public.products(numero,descripcion,costo,precio) values ('3','Coca Cocal 3 Lts',49.00,100.00) on conflict(numero) do update set descripcion=excluded.descripcion,costo=excluded.costo,precio=excluded.precio,updated_at=now();
insert into public.products(numero,descripcion,costo,precio) values ('4','Coca Cola 330ml normal',13.00,18.00) on conflict(numero) do update set descripcion=excluded.descripcion,costo=excluded.costo,precio=excluded.precio,updated_at=now();
insert into public.products(numero,descripcion,costo,precio) values ('5','Cocal Cola 330 ml Zero',7.00,18.00) on conflict(numero) do update set descripcion=excluded.descripcion,costo=excluded.costo,precio=excluded.precio,updated_at=now();
insert into public.products(numero,descripcion,costo,precio) values ('6','Donitas',10.00,15.00) on conflict(numero) do update set descripcion=excluded.descripcion,costo=excluded.costo,precio=excluded.precio,updated_at=now();
insert into public.products(numero,descripcion,costo,precio) values ('7','Mantecadas',10.00,15.00) on conflict(numero) do update set descripcion=excluded.descripcion,costo=excluded.costo,precio=excluded.precio,updated_at=now();
insert into public.products(numero,descripcion,costo,precio) values ('8','Nito',15.00,20.00) on conflict(numero) do update set descripcion=excluded.descripcion,costo=excluded.costo,precio=excluded.precio,updated_at=now();
insert into public.products(numero,descripcion,costo,precio) values ('9','Cacahuates',10.00,15.00) on conflict(numero) do update set descripcion=excluded.descripcion,costo=excluded.costo,precio=excluded.precio,updated_at=now();
insert into public.products(numero,descripcion,costo,precio) values ('10','Doraditas',10.00,15.00) on conflict(numero) do update set descripcion=excluded.descripcion,costo=excluded.costo,precio=excluded.precio,updated_at=now();
insert into public.clients(numero,nombre,tipo) values ('1','Jorge Astorga','Crédito') on conflict(numero) do update set nombre=excluded.nombre,updated_at=now();
insert into public.clients(numero,nombre,tipo) values ('2','Chena Curti','Crédito') on conflict(numero) do update set nombre=excluded.nombre,updated_at=now();
insert into public.clients(numero,nombre,tipo) values ('3','Hefziba','Crédito') on conflict(numero) do update set nombre=excluded.nombre,updated_at=now();
insert into public.clients(numero,nombre,tipo) values ('4','Toledo Guerra','Crédito') on conflict(numero) do update set nombre=excluded.nombre,updated_at=now();
insert into public.inventory(product_id,supplier_id,existencia)
select p.id,(select s.id from public.suppliers s where s.numero='1'),10.00
from public.products p where p.numero='1'
on conflict(product_id) do update set supplier_id=excluded.supplier_id,existencia=excluded.existencia,updated_at=now();
insert into public.inventory(product_id,supplier_id,existencia)
select p.id,(select s.id from public.suppliers s where s.numero='1'),3.00
from public.products p where p.numero='2'
on conflict(product_id) do update set supplier_id=excluded.supplier_id,existencia=excluded.existencia,updated_at=now();
insert into public.inventory(product_id,supplier_id,existencia)
select p.id,(select s.id from public.suppliers s where s.numero='1'),3.00
from public.products p where p.numero='3'
on conflict(product_id) do update set supplier_id=excluded.supplier_id,existencia=excluded.existencia,updated_at=now();
insert into public.inventory(product_id,supplier_id,existencia)
select p.id,(select s.id from public.suppliers s where s.numero='1'),6.00
from public.products p where p.numero='4'
on conflict(product_id) do update set supplier_id=excluded.supplier_id,existencia=excluded.existencia,updated_at=now();
insert into public.inventory(product_id,supplier_id,existencia)
select p.id,(select s.id from public.suppliers s where s.numero='1'),18.00
from public.products p where p.numero='5'
on conflict(product_id) do update set supplier_id=excluded.supplier_id,existencia=excluded.existencia,updated_at=now();
insert into public.inventory(product_id,supplier_id,existencia)
select p.id,(select s.id from public.suppliers s where s.numero='1'),2.00
from public.products p where p.numero='6'
on conflict(product_id) do update set supplier_id=excluded.supplier_id,existencia=excluded.existencia,updated_at=now();
insert into public.inventory(product_id,supplier_id,existencia)
select p.id,(select s.id from public.suppliers s where s.numero='1'),2.00
from public.products p where p.numero='7'
on conflict(product_id) do update set supplier_id=excluded.supplier_id,existencia=excluded.existencia,updated_at=now();
insert into public.inventory(product_id,supplier_id,existencia)
select p.id,(select s.id from public.suppliers s where s.numero='1'),2.00
from public.products p where p.numero='8'
on conflict(product_id) do update set supplier_id=excluded.supplier_id,existencia=excluded.existencia,updated_at=now();
insert into public.inventory(product_id,supplier_id,existencia)
select p.id,(select s.id from public.suppliers s where s.numero='1'),0.00
from public.products p where p.numero='9'
on conflict(product_id) do update set supplier_id=excluded.supplier_id,existencia=excluded.existencia,updated_at=now();
insert into public.inventory(product_id,supplier_id,existencia)
select p.id,(select s.id from public.suppliers s where s.numero='2'),1.00
from public.products p where p.numero='10'
on conflict(product_id) do update set supplier_id=excluded.supplier_id,existencia=excluded.existencia,updated_at=now();
select public.create_sale(current_date,'Contado',null,
jsonb_build_array(jsonb_build_object('product_id',(select id from public.products where numero='1'),'cantidad',2.00,'precio',15.00)));
commit;