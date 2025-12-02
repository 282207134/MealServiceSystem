-- ============================================
-- 校园点餐系统数据库迁移脚本
-- 适用于 Supabase PostgreSQL
-- ============================================

-- 启用 UUID 扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. 创建表结构
-- ============================================

-- 用户表
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('customer', 'merchant', 'admin')),
  full_name TEXT,
  phone TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 商家表
CREATE TABLE IF NOT EXISTS merchants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  avatar_url TEXT,
  cover_image_url TEXT,
  is_active BOOLEAN DEFAULT true,
  opening_hours JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 分类表
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  merchant_id UUID REFERENCES merchants(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 商品表
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  merchant_id UUID REFERENCES merchants(id) ON DELETE CASCADE,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
  image_url TEXT,
  is_available BOOLEAN DEFAULT true,
  stock_quantity INTEGER,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 订单表
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_number TEXT UNIQUE NOT NULL,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  merchant_id UUID REFERENCES merchants(id) ON DELETE CASCADE,
  total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
  status TEXT NOT NULL CHECK (status IN ('pending', 'confirmed', 'preparing', 'ready', 'completed', 'cancelled')),
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 订单项表
CREATE TABLE IF NOT EXISTS order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE RESTRICT,
  product_name TEXT NOT NULL,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
  subtotal DECIMAL(10, 2) NOT NULL CHECK (subtotal >= 0),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 2. 创建索引
-- ============================================

-- 商家索引
CREATE INDEX IF NOT EXISTS idx_merchants_user_id ON merchants(user_id);
CREATE INDEX IF NOT EXISTS idx_merchants_is_active ON merchants(is_active);

-- 分类索引
CREATE INDEX IF NOT EXISTS idx_categories_merchant_id ON categories(merchant_id);

-- 商品索引
CREATE INDEX IF NOT EXISTS idx_products_merchant_id ON products(merchant_id);
CREATE INDEX IF NOT EXISTS idx_products_category_id ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_is_available ON products(is_available);

-- 订单索引
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_merchant_id ON orders(merchant_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_orders_order_number ON orders(order_number);

-- 订单项索引
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);

-- ============================================
-- 3. 创建触发器函数
-- ============================================

-- 更新 updated_at 时间戳的函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 为各表创建 updated_at 触发器
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_merchants_updated_at BEFORE UPDATE ON merchants
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 生成订单号的函数
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TEXT AS $$
DECLARE
  new_order_number TEXT;
  done BOOLEAN := FALSE;
BEGIN
  WHILE NOT done LOOP
    -- 格式：ORD + 年月日 + 6位随机数字
    new_order_number := 'ORD' || 
                       TO_CHAR(NOW(), 'YYYYMMDD') || 
                       LPAD(FLOOR(RANDOM() * 1000000)::TEXT, 6, '0');
    
    -- 检查是否重复
    IF NOT EXISTS (SELECT 1 FROM orders WHERE order_number = new_order_number) THEN
      done := TRUE;
    END IF;
  END LOOP;
  
  RETURN new_order_number;
END;
$$ LANGUAGE plpgsql;

-- 自动生成订单号的触发器
CREATE OR REPLACE FUNCTION set_order_number()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.order_number IS NULL OR NEW.order_number = '' THEN
    NEW.order_number := generate_order_number();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_order_number_trigger BEFORE INSERT ON orders
  FOR EACH ROW EXECUTE FUNCTION set_order_number();

-- ============================================
-- 4. 启用 Row Level Security (RLS)
-- ============================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE merchants ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 5. 创建 RLS 策略
-- ============================================

-- Users 策略
DROP POLICY IF EXISTS "Users can view their own data" ON users;
CREATE POLICY "Users can view their own data"
  ON users FOR SELECT
  USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update their own data" ON users;
CREATE POLICY "Users can update their own data"
  ON users FOR UPDATE
  USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert their own data" ON users;
CREATE POLICY "Users can insert their own data"
  ON users FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Merchants 策略
DROP POLICY IF EXISTS "Anyone can view active merchants" ON merchants;
CREATE POLICY "Anyone can view active merchants"
  ON merchants FOR SELECT
  USING (is_active = true OR user_id = auth.uid());

DROP POLICY IF EXISTS "Merchants can update their own data" ON merchants;
CREATE POLICY "Merchants can update their own data"
  ON merchants FOR UPDATE
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Merchants can insert their own data" ON merchants;
CREATE POLICY "Merchants can insert their own data"
  ON merchants FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- Categories 策略
DROP POLICY IF EXISTS "Anyone can view categories" ON categories;
CREATE POLICY "Anyone can view categories"
  ON categories FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Merchants can manage their categories" ON categories;
CREATE POLICY "Merchants can manage their categories"
  ON categories FOR ALL
  USING (
    merchant_id IN (
      SELECT id FROM merchants WHERE user_id = auth.uid()
    )
  );

-- Products 策略
DROP POLICY IF EXISTS "Anyone can view available products" ON products;
CREATE POLICY "Anyone can view available products"
  ON products FOR SELECT
  USING (
    is_available = true OR 
    merchant_id IN (
      SELECT id FROM merchants WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Merchants can manage their products" ON products;
CREATE POLICY "Merchants can manage their products"
  ON products FOR ALL
  USING (
    merchant_id IN (
      SELECT id FROM merchants WHERE user_id = auth.uid()
    )
  );

-- Orders 策略
DROP POLICY IF EXISTS "Users can view their own orders" ON orders;
CREATE POLICY "Users can view their own orders"
  ON orders FOR SELECT
  USING (
    user_id = auth.uid() OR
    merchant_id IN (
      SELECT id FROM merchants WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can create orders" ON orders;
CREATE POLICY "Users can create orders"
  ON orders FOR INSERT
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Merchants can update their orders" ON orders;
CREATE POLICY "Merchants can update their orders"
  ON orders FOR UPDATE
  USING (
    merchant_id IN (
      SELECT id FROM merchants WHERE user_id = auth.uid()
    )
  );

-- Order Items 策略
DROP POLICY IF EXISTS "Users can view order items of their orders" ON order_items;
CREATE POLICY "Users can view order items of their orders"
  ON order_items FOR SELECT
  USING (
    order_id IN (
      SELECT id FROM orders 
      WHERE user_id = auth.uid() OR 
            merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
    )
  );

DROP POLICY IF EXISTS "Users can insert order items for their orders" ON order_items;
CREATE POLICY "Users can insert order items for their orders"
  ON order_items FOR INSERT
  WITH CHECK (
    order_id IN (
      SELECT id FROM orders WHERE user_id = auth.uid()
    )
  );

-- ============================================
-- 6. 创建视图（可选）
-- ============================================

-- 订单详情视图（包含用户和商家信息）
CREATE OR REPLACE VIEW order_details AS
SELECT 
  o.id,
  o.order_number,
  o.total_amount,
  o.status,
  o.note,
  o.created_at,
  o.updated_at,
  u.id AS user_id,
  u.full_name AS user_name,
  u.phone AS user_phone,
  m.id AS merchant_id,
  m.name AS merchant_name
FROM orders o
LEFT JOIN users u ON o.user_id = u.id
LEFT JOIN merchants m ON o.merchant_id = m.id;

-- 商品完整信息视图（包含分类信息）
CREATE OR REPLACE VIEW products_with_category AS
SELECT 
  p.id,
  p.merchant_id,
  p.category_id,
  p.name,
  p.description,
  p.price,
  p.image_url,
  p.is_available,
  p.stock_quantity,
  p.display_order,
  p.created_at,
  p.updated_at,
  c.name AS category_name
FROM products p
LEFT JOIN categories c ON p.category_id = c.id;

-- ============================================
-- 7. 插入测试数据（可选）
-- ============================================

-- 注意：以下为测试数据，生产环境请删除或注释

-- 插入测试用户
INSERT INTO users (id, email, role, full_name, phone) VALUES
  ('550e8400-e29b-41d4-a716-446655440001', 'merchant1@test.com', 'merchant', '测试商家1', '13800138001'),
  ('550e8400-e29b-41d4-a716-446655440002', 'customer1@test.com', 'customer', '测试顾客1', '13800138002')
ON CONFLICT (id) DO NOTHING;

-- 插入测试商家
INSERT INTO merchants (id, user_id, name, description, is_active) VALUES
  ('660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', '校园咖啡厅', '提供各种美味咖啡和小吃', true)
ON CONFLICT (id) DO NOTHING;

-- 插入测试分类
INSERT INTO categories (merchant_id, name, display_order) VALUES
  ('660e8400-e29b-41d4-a716-446655440001', '热饮', 1),
  ('660e8400-e29b-41d4-a716-446655440001', '冷饮', 2),
  ('660e8400-e29b-41d4-a716-446655440001', '小吃', 3);

-- 插入测试商品
INSERT INTO products (merchant_id, category_id, name, description, price, is_available) 
SELECT 
  '660e8400-e29b-41d4-a716-446655440001',
  c.id,
  '美式咖啡',
  '经典美式咖啡，口感浓郁',
  18.00,
  true
FROM categories c 
WHERE c.merchant_id = '660e8400-e29b-41d4-a716-446655440001' 
  AND c.name = '热饮'
LIMIT 1;

-- ============================================
-- 完成
-- ============================================

-- 验证表创建
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- 显示完成消息
DO $$
BEGIN
  RAISE NOTICE '数据库迁移完成！';
  RAISE NOTICE '已创建以下表：users, merchants, categories, products, orders, order_items';
  RAISE NOTICE '已创建索引和触发器';
  RAISE NOTICE '已启用 Row Level Security (RLS)';
END $$;
