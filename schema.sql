CREATE TABLE IF NOT EXISTS products(id text PRIMARY KEY,name text NOT NULL,description text,price_inr numeric(10,2) CHECK(price_inr>0),category text,badge text,colors text[],image text,created_at timestamptz DEFAULT now());
CREATE TABLE IF NOT EXISTS orders(id text PRIMARY KEY,customer jsonb,items jsonb,subtotal numeric,discount numeric,tax numeric,total numeric,status text DEFAULT 'demo',created_at timestamptz DEFAULT now());
ALTER TABLE products ADD COLUMN IF NOT EXISTS image text;
