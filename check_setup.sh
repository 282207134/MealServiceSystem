#!/bin/bash

# 项目配置检查脚本
# 用于快速验证项目配置是否完整

echo "🔍 检查项目配置状态..."
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查配置文件
echo "📁 检查配置文件..."
if [ -f "lib/core/config/supabase_config.dart" ]; then
    echo -e "${GREEN}✅ supabase_config.dart 存在${NC}"
    
    # 检查是否包含实际配置（不是示例值）
    if grep -q "https://fpxdfnevjeyzxuzhfumb.supabase.co" lib/core/config/supabase_config.dart; then
        echo -e "${GREEN}✅ Supabase URL 已配置${NC}"
    else
        echo -e "${YELLOW}⚠️  Supabase URL 可能需要更新${NC}"
    fi
    
    if grep -q "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9" lib/core/config/supabase_config.dart; then
        echo -e "${GREEN}✅ Supabase anon key 已配置${NC}"
    else
        echo -e "${YELLOW}⚠️  Supabase anon key 可能需要更新${NC}"
    fi
else
    echo -e "${RED}❌ supabase_config.dart 不存在${NC}"
fi

# 检查 pubspec.yaml
echo ""
echo "📦 检查依赖..."
if [ -f "pubspec.yaml" ]; then
    if grep -q "supabase_flutter" pubspec.yaml; then
        echo -e "${GREEN}✅ supabase_flutter 依赖已添加${NC}"
    else
        echo -e "${RED}❌ supabase_flutter 依赖未添加${NC}"
    fi
    
    if grep -q "flutter_riverpod" pubspec.yaml; then
        echo -e "${GREEN}✅ flutter_riverpod 依赖已添加${NC}"
    else
        echo -e "${RED}❌ flutter_riverpod 依赖未添加${NC}"
    fi
else
    echo -e "${RED}❌ pubspec.yaml 不存在${NC}"
fi

# 检查 .gitignore
echo ""
echo "🔒 检查 .gitignore..."
if [ -f ".gitignore" ]; then
    if grep -q "supabase_config.dart" .gitignore; then
        echo -e "${GREEN}✅ supabase_config.dart 已在 .gitignore 中${NC}"
    else
        echo -e "${YELLOW}⚠️  supabase_config.dart 未在 .gitignore 中（建议添加）${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  .gitignore 不存在${NC}"
fi

# 检查 Flutter 环境
echo ""
echo "🛠️  检查 Flutter 环境..."
if command -v flutter &> /dev/null; then
    echo -e "${GREEN}✅ Flutter 已安装${NC}"
    flutter --version | head -n 1
else
    echo -e "${RED}❌ Flutter 未安装或不在 PATH 中${NC}"
fi

# 检查依赖是否安装
echo ""
echo "📚 检查依赖安装..."
if [ -d ".dart_tool" ]; then
    echo -e "${GREEN}✅ 依赖已安装（.dart_tool 存在）${NC}"
    echo "   运行 'flutter pub get' 确保依赖最新"
else
    echo -e "${YELLOW}⚠️  依赖可能未安装，运行 'flutter pub get'${NC}"
fi

# 总结
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 配置检查完成！"
echo ""
echo "📝 下一步："
echo "   1. 在 Supabase Dashboard 中启用 Email 认证"
echo "   2. 运行 'flutter pub get' 安装依赖"
echo "   3. 运行 'flutter run' 启动应用"
echo ""
echo "📖 详细指南请查看: PREPARATION_GUIDE.md"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

