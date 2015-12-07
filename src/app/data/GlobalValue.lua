--
-- Author: liuhao
-- Date: 2015-12-03 14:04:48
-- 游戏中使用的全局变量

-- 颜色类型
enColorType = {
    "Red",
    "Yellow",
    "Blue",
    "Green",
    "Purple",
    "Max"
}
enColorType = EnumTable(enColorType, 0)

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