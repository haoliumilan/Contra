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
    "Iron", -- 铁珠子、不能被消除、不能移动
    "WoodA", -- 木珠子、不能移动，会被溅射
    "WoodB", -- 木珠子、不能移动，会被溅射
    "IronWall", -- 铁墙、不能被消除、不能移动
    "WoodWall", -- 木墙、不能移动、会被溅射
    "Max"
}
enStoneType = EnumTable(enStoneType, 0)

-- 珠子关联方向类型, 8个方向
DirectionValueArr = {
    {1, 0},   -- 右中
    {1, -1},   -- 右下
    {0, -1},   -- 中下
    {-1, -1},   -- 左下
    {-1, 0},   -- 左中
    {-1, 1},   -- 左上
    {0, 1},   -- 中上
    {1, 1},   -- 右上
}

-- 溅射方向类型，4个方向
DirectionSplashArr = {
    {-1, 0}, -- 左
    {0, 1}, -- 上
    {1, 0}, -- 右
    {0, -1}, -- 下
}