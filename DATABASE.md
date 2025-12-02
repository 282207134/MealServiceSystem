# 🗄️ 数据库设计文档

本文档详细说明校园点餐系统的数据库设计，包括表结构、关系、索引优化、以及最佳实践。

---

## 📋 目录

- [概述](#概述)
- [ER 图](#er-图)
- [表结构详解](#表结构详解)
- [关系说明](#关系说明)
- [索引策略](#索引策略)
- [触发器和函数](#触发器和函数)
- [Row Level Security (RLS)](#row-level-security-rls)
- [数据迁移](#数据迁移)
- [查询优化](#查询优化)
- [数据备份与恢复](#数据备份与恢复)
- [最佳实践](#最佳实践)

---

## 概述

### 技术栈

- **数据库：** PostgreSQL 15+（由 Supabase 托管）
- **ORM：** Supabase SDK（基于 PostgREST）
- **安全机制：** Row Level Security (RLS)

### 设计原则

1. **规范化设计：** 遵循第三范式，减少数据冗余
2. **适度反规范化：** 在订单项中存储商品名称和价格快照
3. **软删除：** 关键数据不物理删除，使用状态标记
4. **审计追踪：** 记录创建和更新时间

---

## ER 图

### 整体关系图

```
┌──────────────┐         
│    users     │         
│ (用户表)      │         
├──────────────┤         
│ id (PK)      │◄────┐   
│ email        │     │   
│ role         │     │   
│ full_name    │     │   
│ phone        │     │   
│ avatar_url   │     │   
│ created_at   │     │   
│ updated_at   │     │   
└──────────────┘     │   
                     │   
                     │   
┌──────────────┐     │   
│  merchants   │     │   
│ (商家表)      │     │   
├──────────────┤     │   
│ id (PK)      │     │   
│ user_id (FK) │─────┘   
│ name         │         
│ description  │         
│ avatar_url   │         
│ is_active    │         
│ opening_hours│         
│ created_at   │         
└──────────────┘         
       │                 
       │ 1              
       │                 
       │ N              
       ▼                 
┌──────────────┐         
│ categories   │         
│ (分类表)      │         
├──────────────┤         
│ id (PK)      │         
│ merchant_id  │         
│ name         │         
│ display_order│         
└──────────────┘         
       │                 
       │                 
       │                 
┌──────────────┐         
│  products    │◄────────┐
│ (商品表)      │         │
├──────────────┤         │
│ id (PK)      │         │
│ merchant_id  │─────────┤
│ category_id  │─────────┘
│ name         │         
│ description  │         
│ price        │         
│ image_url    │         
│ is_available │         
│ stock_qty    │         
└──────────────┘         
       │                 
       │                 
       │                 
┌──────────────┐         
│   orders     │         
│ (订单表)      │         
├──────────────┤         
│ id (PK)      │         
│ order_number │         
│ user_id (FK) │         
│ merchant_id  │         
│ total_amount │         
│ status       │         
│ note         │         
│ created_at   │         
│ updated_at   │         
└──────────────┘         
       │                 
       │ 1              
       │                 
       │ N              
       ▼                 
┌──────────────┐         
│ order_items  │         
│ (订单项表)    │         
├──────────────┤         
│ id (PK)      │         
│ order_id (FK)│         
│ product_id   │         
│ product_name │ (快照)  
│ quantity     │         
│ unit_price   │ (快照)  
│ subtotal     │         
└──────────────┘         
```

---

## 表结构详解

### 1. users（用户表）

存储所有用户的基本信息（顾客和商家）。

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('customer', 'merchant', 'admin')),
  full_name TEXT,
  phone TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 字段说明

| 字段 | 类型 | 说明 | 约束 |
|------|------|------|------|
| id | UUID | 主键，用户唯一标识 | PRIMARY KEY |
| email | TEXT | 邮箱地址 | UNIQUE, NOT NULL |
| role | TEXT | 用户角色 | CHECK (customer/merchant/admin) |
| full_name | TEXT | 用户姓名 | - |
| phone | TEXT | 手机号 | - |
| avatar_url | TEXT | 头像URL | - |
| created_at | TIMESTAMP | 创建时间 | DEFAULT NOW() |
| updated_at | TIMESTAMP | 更新时间 | DEFAULT NOW() |

#### 索引

```sql
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
```

---

### 2. merchants（商家表）

存储商家的详细信息。

```sql
CREATE TABLE merchants (
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
```

#### 字段说明

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| id | UUID | 商家ID | - |
| user_id | UUID | 关联用户ID | - |
| name | TEXT | 商家名称 | "校园咖啡厅" |
| description | TEXT | 商家简介 | "提供各种美味咖啡和小吃" |
| avatar_url | TEXT | 商家头像 | - |
| cover_image_url | TEXT | 封面图片 | - |
| is_active | BOOLEAN | 是否营业 | true |
| opening_hours | JSONB | 营业时间 | `{"monday": "9:00-18:00"}` |

#### 索引

```sql
CREATE INDEX idx_merchants_user_id ON merchants(user_id);
CREATE INDEX idx_merchants_is_active ON merchants(is_active);
CREATE INDEX idx_merchants_name ON merchants(name);
```

---

### 3. categories（分类表）

存储商品分类信息。

```sql
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  merchant_id UUID REFERENCES merchants(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 字段说明

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| id | UUID | 分类ID | - |
| merchant_id | UUID | 所属商家 | - |
| name | TEXT | 分类名称 | "热饮" |
| description | TEXT | 分类描述 | - |
| display_order | INTEGER | 显示顺序 | 1 |

#### 索引

```sql
CREATE INDEX idx_categories_merchant_id ON categories(merchant_id);
CREATE INDEX idx_categories_display_order ON categories(merchant_id, display_order);
```

---

### 4. products（商品表）

存储商品详细信息。

```sql
CREATE TABLE products (
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
```

#### 字段说明

| 字段 | 类型 | 说明 | 约束 |
|------|------|------|------|
| id | UUID | 商品ID | PRIMARY KEY |
| merchant_id | UUID | 所属商家 | NOT NULL, FK |
| category_id | UUID | 所属分类 | FK, ON DELETE SET NULL |
| name | TEXT | 商品名称 | NOT NULL |
| description | TEXT | 商品描述 | - |
| price | DECIMAL(10,2) | 商品价格 | CHECK >= 0 |
| image_url | TEXT | 商品图片 | - |
| is_available | BOOLEAN | 是否可用 | DEFAULT true |
| stock_quantity | INTEGER | 库存数量 | - |
| display_order | INTEGER | 显示顺序 | DEFAULT 0 |

#### 索引

```sql
CREATE INDEX idx_products_merchant_id ON products(merchant_id);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_is_available ON products(is_available);
CREATE INDEX idx_products_name ON products USING gin(to_tsvector('simple', name));
```

---

### 5. orders（订单表）

存储订单信息。

```sql
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_number TEXT UNIQUE NOT NULL,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  merchant_id UUID REFERENCES merchants(id) ON DELETE CASCADE,
  total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
  status TEXT NOT NULL CHECK (
    status IN ('pending', 'confirmed', 'preparing', 'ready', 'completed', 'cancelled')
  ),
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 字段说明

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| id | UUID | 订单ID | - |
| order_number | TEXT | 订单号 | "ORD20241130123456" |
| user_id | UUID | 下单用户 | - |
| merchant_id | UUID | 商家ID | - |
| total_amount | DECIMAL | 订单总金额 | 99.99 |
| status | TEXT | 订单状态 | "pending" |
| note | TEXT | 订单备注 | "少糖" |

#### 订单状态流转

```
pending → confirmed → preparing → ready → completed
   ↓
cancelled
```

#### 索引

```sql
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_merchant_id ON orders(merchant_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
CREATE UNIQUE INDEX idx_orders_order_number ON orders(order_number);
```

---

### 6. order_items（订单项表）

存储订单的详细商品信息。

```sql
CREATE TABLE order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE RESTRICT,
  product_name TEXT NOT NULL,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
  subtotal DECIMAL(10, 2) NOT NULL CHECK (subtotal >= 0),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 字段说明

| 字段 | 类型 | 说明 | 备注 |
|------|------|------|------|
| id | UUID | 订单项ID | - |
| order_id | UUID | 所属订单 | ON DELETE CASCADE |
| product_id | UUID | 商品ID | ON DELETE RESTRICT |
| product_name | TEXT | 商品名称快照 | 防止商品改名影响订单 |
| quantity | INTEGER | 购买数量 | CHECK > 0 |
| unit_price | DECIMAL | 单价快照 | 防止价格变动影响订单 |
| subtotal | DECIMAL | 小计 | quantity * unit_price |

#### 索引

```sql
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
```

---

## 关系说明

### 一对多关系

1. **users → merchants**
   - 一个用户可以创建一个商家
   - 实际场景：一个商家账号对应一个 user

2. **merchants → categories**
   - 一个商家可以有多个分类

3. **merchants → products**
   - 一个商家可以有多个商品

4. **categories → products**
   - 一个分类可以包含多个商品

5. **users → orders**
   - 一个用户可以下多个订单

6. **merchants → orders**
   - 一个商家可以接收多个订单

7. **orders → order_items**
   - 一个订单可以包含多个商品

---

## 索引策略

### 主键索引

所有表的主键 `id` 自动创建 B-Tree 索引。

### 外键索引

为提高关联查询性能，为所有外键创建索引：

```sql
CREATE INDEX idx_merchants_user_id ON merchants(user_id);
CREATE INDEX idx_categories_merchant_id ON categories(merchant_id);
CREATE INDEX idx_products_merchant_id ON products(merchant_id);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_merchant_id ON orders(merchant_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
```

### 业务逻辑索引

```sql
-- 商品搜索（全文索引）
CREATE INDEX idx_products_name_search ON products 
USING gin(to_tsvector('simple', name));

-- 订单状态筛选
CREATE INDEX idx_orders_status ON orders(status);

-- 订单时间排序
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);

-- 商家营业状态
CREATE INDEX idx_merchants_is_active ON merchants(is_active);

-- 商品可用性
CREATE INDEX idx_products_is_available ON products(is_available);
```

### 复合索引

```sql
-- 商家的可用商品（常用查询）
CREATE INDEX idx_products_merchant_available ON products(merchant_id, is_available);

-- 订单状态和时间（商家查询待处理订单）
CREATE INDEX idx_orders_merchant_status_time ON orders(merchant_id, status, created_at DESC);
```

---

## 触发器和函数

### 1. 自动更新 updated_at

```sql
-- 创建触发器函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 为各表添加触发器
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_merchants_updated_at
  BEFORE UPDATE ON merchants
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 其他表类似...
```

### 2. 自动生成订单号

```sql
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

-- 触发器
CREATE OR REPLACE FUNCTION set_order_number()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.order_number IS NULL OR NEW.order_number = '' THEN
    NEW.order_number := generate_order_number();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_order_number_trigger
  BEFORE INSERT ON orders
  FOR EACH ROW
  EXECUTE FUNCTION set_order_number();
```

### 3. 订单总金额计算

```sql
CREATE OR REPLACE FUNCTION calculate_order_total()
RETURNS TRIGGER AS $$
DECLARE
  calculated_total DECIMAL(10, 2);
BEGIN
  -- 计算订单总金额
  SELECT COALESCE(SUM(subtotal), 0)
  INTO calculated_total
  FROM order_items
  WHERE order_id = NEW.order_id;
  
  -- 更新订单总金额
  UPDATE orders
  SET total_amount = calculated_total
  WHERE id = NEW.order_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_order_total_on_insert
  AFTER INSERT ON order_items
  FOR EACH ROW
  EXECUTE FUNCTION calculate_order_total();

CREATE TRIGGER update_order_total_on_update
  AFTER UPDATE ON order_items
  FOR EACH ROW
  EXECUTE FUNCTION calculate_order_total();
```

---

## Row Level Security (RLS)

详细的 RLS 策略请参考 [SECURITY.md](SECURITY.md)。

### 基本策略示例

```sql
-- 用户只能访问自己的数据
CREATE POLICY "users_self_access"
  ON users
  FOR ALL
  USING (auth.uid() = id);

-- 所有人可以查看可用商品
CREATE POLICY "products_public_read"
  ON products
  FOR SELECT
  USING (is_available = true);

-- 商家可以管理自己的商品
CREATE POLICY "merchants_manage_products"
  ON products
  FOR ALL
  USING (
    merchant_id IN (
      SELECT id FROM merchants WHERE user_id = auth.uid()
    )
  );
```

---

## 数据迁移

### 初始迁移

使用 `supabase_migration.sql` 文件：

```bash
# 在 Supabase Dashboard 的 SQL Editor 中执行
# 或使用 CLI
supabase db reset
```

### 增量迁移

对于数据库结构变更，创建新的迁移文件：

```sql
-- migrations/002_add_merchant_rating.sql
ALTER TABLE merchants ADD COLUMN rating DECIMAL(3, 2) DEFAULT 0;
CREATE INDEX idx_merchants_rating ON merchants(rating);
```

---

## 查询优化

### 常用查询优化

#### 1. 获取商家的商品列表

```sql
-- 优化前（N+1 问题）
SELECT * FROM products WHERE merchant_id = 'xxx';
-- 然后对每个商品查询分类

-- 优化后（使用 JOIN）
SELECT p.*, c.name AS category_name
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
WHERE p.merchant_id = 'xxx'
  AND p.is_available = true
ORDER BY p.display_order;
```

#### 2. 获取订单详情

```sql
SELECT 
  o.*,
  u.full_name AS user_name,
  u.phone AS user_phone,
  m.name AS merchant_name,
  json_agg(
    json_build_object(
      'product_name', oi.product_name,
      'quantity', oi.quantity,
      'unit_price', oi.unit_price,
      'subtotal', oi.subtotal
    )
  ) AS items
FROM orders o
JOIN users u ON o.user_id = u.id
JOIN merchants m ON o.merchant_id = m.id
LEFT JOIN order_items oi ON o.id = oi.order_id
WHERE o.id = 'xxx'
GROUP BY o.id, u.full_name, u.phone, m.name;
```

### EXPLAIN 分析

```sql
EXPLAIN ANALYZE
SELECT * FROM products 
WHERE merchant_id = 'xxx' AND is_available = true;
```

---

## 数据备份与恢复

### 自动备份（Supabase Pro）

Supabase Pro 计划提供：
- 每日自动备份
- Point-in-Time Recovery (PITR)

### 手动备份

```bash
# 导出整个数据库
pg_dump -h db.xxxxx.supabase.co \
  -U postgres \
  -d postgres \
  --clean \
  --if-exists \
  > backup_$(date +%Y%m%d).sql

# 导出特定表
pg_dump -h db.xxxxx.supabase.co \
  -U postgres \
  -d postgres \
  -t orders \
  -t order_items \
  > orders_backup.sql
```

### 恢复数据

```bash
psql -h db.xxxxx.supabase.co \
  -U postgres \
  -d postgres \
  < backup_20241130.sql
```

---

## 最佳实践

### 1. 数据完整性

- ✅ 使用外键约束
- ✅ 使用 CHECK 约束
- ✅ 使用 NOT NULL 约束
- ✅ 使用 UNIQUE 约束

### 2. 性能优化

- ✅ 为常用查询字段创建索引
- ✅ 避免过度索引（写入性能下降）
- ✅ 定期分析查询计划（EXPLAIN）
- ✅ 使用连接池

### 3. 安全性

- ✅ 启用 RLS
- ✅ 最小权限原则
- ✅ 定期备份
- ✅ 审计日志

### 4. 可维护性

- ✅ 使用有意义的命名
- ✅ 添加注释
- ✅ 版本控制迁移脚本
- ✅ 文档化数据库变更

---

**数据库文档版本：** 1.0.0  
**最后更新：** 2024-11  
**维护者：** 数据库团队

**相关文档：**
- [supabase_migration.sql](supabase_migration.sql) - 完整迁移脚本
- [SECURITY.md](SECURITY.md) - RLS 安全策略
- [DEPLOYMENT.md](DEPLOYMENT.md) - 数据库部署指南
