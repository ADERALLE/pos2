-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.categories (
id uuid NOT NULL DEFAULT uuid_generate_v4(),
shop_id uuid NOT NULL,
label text NOT NULL,
sort_order smallint NOT NULL DEFAULT 0,
created_at timestamp with time zone NOT NULL DEFAULT now(),
is_supp boolean NOT NULL DEFAULT false,
CONSTRAINT categories_pkey PRIMARY KEY (id),
CONSTRAINT categories_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id)
);
CREATE TABLE public.combo_categories (
id uuid NOT NULL DEFAULT gen_random_uuid(),
shop_id uuid NOT NULL,
label text NOT NULL,
sort_order integer NOT NULL DEFAULT 0,
created_at timestamp with time zone DEFAULT now(),
CONSTRAINT combo_categories_pkey PRIMARY KEY (id),
CONSTRAINT combo_categories_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id)
);
CREATE TABLE public.combo_menu_items (
id uuid NOT NULL DEFAULT uuid_generate_v4(),
combo_menu_id uuid NOT NULL,
menu_item_id uuid NOT NULL,
quantity smallint NOT NULL DEFAULT 1 CHECK (quantity > 0),
created_at timestamp with time zone NOT NULL DEFAULT now(),
choice_group text,
CONSTRAINT combo_menu_items_pkey PRIMARY KEY (id),
CONSTRAINT combo_menu_items_combo_menu_id_fkey FOREIGN KEY (combo_menu_id) REFERENCES public.combo_menus(id),
CONSTRAINT combo_menu_items_menu_item_id_fkey FOREIGN KEY (menu_item_id) REFERENCES public.menu_items(id)
);
CREATE TABLE public.combo_menus (
id uuid NOT NULL DEFAULT uuid_generate_v4(),
shop_id uuid NOT NULL,
name text NOT NULL,
description text,
price numeric NOT NULL CHECK (price >= 0::numeric),
image_url text,
is_active boolean NOT NULL DEFAULT true,
sort_order smallint NOT NULL DEFAULT 0,
created_at timestamp with time zone NOT NULL DEFAULT now(),
updated_at timestamp with time zone NOT NULL DEFAULT now(),
category_id uuid,
CONSTRAINT combo_menus_pkey PRIMARY KEY (id),
CONSTRAINT combo_menus_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id),
CONSTRAINT combo_menus_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.combo_categories(id)
);
CREATE TABLE public.menu_items (
id uuid NOT NULL DEFAULT uuid_generate_v4(),
shop_id uuid NOT NULL,
category_id uuid,
name text NOT NULL,
price numeric NOT NULL CHECK (price >= 0::numeric),
image_url text,
is_active boolean NOT NULL DEFAULT true,
sort_order smallint NOT NULL DEFAULT 0,
created_at timestamp with time zone NOT NULL DEFAULT now(),
updated_at timestamp with time zone NOT NULL DEFAULT now(),
CONSTRAINT menu_items_pkey PRIMARY KEY (id),
CONSTRAINT menu_items_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id),
CONSTRAINT menu_items_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id)
);
CREATE TABLE public.notifications (
id uuid NOT NULL DEFAULT uuid_generate_v4(),
shop_id uuid NOT NULL,
staff_id uuid,
target_role text NOT NULL DEFAULT 'manager'::text,
title text NOT NULL,
body text NOT NULL,
is_read boolean NOT NULL DEFAULT false,
created_at timestamp with time zone NOT NULL DEFAULT now(),
CONSTRAINT notifications_pkey PRIMARY KEY (id),
CONSTRAINT notifications_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id),
CONSTRAINT notifications_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES public.staff(id)
);
CREATE TABLE public.order_items (
id uuid NOT NULL DEFAULT uuid_generate_v4(),
order_id uuid NOT NULL,
menu_item_id uuid NOT NULL,
name text NOT NULL,
unit_price numeric NOT NULL,
quantity smallint NOT NULL DEFAULT 1 CHECK (quantity > 0),
subtotal numeric DEFAULT (unit_price * (quantity)::numeric),
CONSTRAINT order_items_pkey PRIMARY KEY (id),
CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id),
CONSTRAINT order_items_menu_item_id_fkey FOREIGN KEY (menu_item_id) REFERENCES public.menu_items(id)
);
CREATE TABLE public.order_notes (
id uuid NOT NULL DEFAULT uuid_generate_v4(),
order_item_id uuid NOT NULL,
note text NOT NULL,
CONSTRAINT order_notes_pkey PRIMARY KEY (id),
CONSTRAINT order_notes_order_item_id_fkey FOREIGN KEY (order_item_id) REFERENCES public.order_items(id)
);
CREATE TABLE public.orders (
id uuid NOT NULL DEFAULT uuid_generate_v4(),
shop_id uuid NOT NULL,
shift_id uuid,
cashier_id uuid NOT NULL,
status USER-DEFINED NOT NULL DEFAULT 'pending'::order_status,
table_label text,
total numeric NOT NULL DEFAULT 0,
note text,
created_at timestamp with time zone NOT NULL DEFAULT now(),
updated_at timestamp with time zone NOT NULL DEFAULT now(),
payment_method text NOT NULL DEFAULT 'cash'::text CHECK (payment_method = ANY (ARRAY['cash'::text, 'card'::text, 'split'::text])),
tip numeric NOT NULL DEFAULT 0 CHECK (tip >= 0::numeric),
id_short text DEFAULT "right"((id)::text, 6),
cash_amount numeric NOT NULL DEFAULT 0 CHECK (cash_amount >= 0::numeric),
card_amount numeric NOT NULL DEFAULT 0 CHECK (card_amount >= 0::numeric),
CONSTRAINT orders_pkey PRIMARY KEY (id),
CONSTRAINT orders_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id),
CONSTRAINT orders_shift_id_fkey FOREIGN KEY (shift_id) REFERENCES public.shifts(id),
CONSTRAINT orders_cashier_id_fkey FOREIGN KEY (cashier_id) REFERENCES public.staff(id)
);
CREATE TABLE public.shifts (
id uuid NOT NULL DEFAULT uuid_generate_v4(),
shop_id uuid NOT NULL,
staff_id uuid NOT NULL,
opened_at timestamp with time zone NOT NULL DEFAULT now(),
closed_at timestamp with time zone,
opening_note text,
closing_note text,
passation_amount numeric NOT NULL DEFAULT 0 CHECK (passation_amount >= 0::numeric),
CONSTRAINT shifts_pkey PRIMARY KEY (id),
CONSTRAINT shifts_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id),
CONSTRAINT shifts_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES public.staff(id)
);
CREATE TABLE public.shops (
id uuid NOT NULL DEFAULT uuid_generate_v4(),
name text NOT NULL,
timezone text NOT NULL DEFAULT 'UTC'::text,
created_at timestamp with time zone NOT NULL DEFAULT now(),
CONSTRAINT shops_pkey PRIMARY KEY (id)
);
CREATE TABLE public.staff (
id uuid NOT NULL DEFAULT uuid_generate_v4(),
shop_id uuid NOT NULL,
auth_user_id uuid,
name text NOT NULL,
role USER-DEFINED NOT NULL DEFAULT 'cashier'::staff_role,
pin text,
is_active boolean NOT NULL DEFAULT true,
created_at timestamp with time zone NOT NULL DEFAULT now(),
CONSTRAINT staff_pkey PRIMARY KEY (id),
CONSTRAINT staff_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id),
CONSTRAINT staff_auth_user_id_fkey FOREIGN KEY (auth_user_id) REFERENCES auth.users(id)
);