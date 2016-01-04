--
-- Author: Liu Hao
-- Date: 2015-12-03 14:04:48
-- 游戏中使用的全局变量

-- 颜色类型
enStoneType = {
    "Red", -- 红色珠子
    "Yellow", -- 黄色珠子
    "Blue", -- 蓝色珠子
    "Green", -- 绿色珠子
    "Purple", -- 紫色珠子
    "Multicolor", -- 彩色
    "Max"
}
enStoneType = EnumTable(enStoneType, 0)

enStoneType2 = {
    "Stone", -- 颜色stone
    "Cover", -- 冰块
    "Wall", -- 墙
}
enStoneType2 = EnumTable(enStoneType2, 0)

-- 珠子关联方向类型, 8个方向
Direction8ValueArr = {
    {1, 0},   -- 1, 右中
    {1, -1},   -- 2, 右下
    {0, -1},   -- 3, 中下
    {-1, -1},   -- 4, 左下
    {-1, 0},   -- 5, 左中
    {-1, 1},   -- 6, 左上
    {0, 1},   -- 7, 中上
    {1, 1},   -- 8, 右上
}

-- 溅射方向类型，4个方向
Direction4ValueArr = {
    {-1, 0}, -- 左
    {0, 1}, -- 上
    {1, 0}, -- 右
    {0, -1}, -- 下
}