--
-- Author: liuhao
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
    "WoodA1", -- 木珠子、不能移动，会变成woodA2
    "WoodA2", -- 木柱子、不能移动、可消除
    "WoodB1", -- 木珠子、不能移动，会变成woodB2
    "WoodB2", -- 木柱子、不能移动、可消除
    "Max"
}
enStoneType = EnumTable(enStoneType, 0)

-- 珠子关联方向类型
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