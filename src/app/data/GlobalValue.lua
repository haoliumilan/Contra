--
-- Author: liuhao
-- Date: 2015-12-03 14:04:48
-- 游戏中使用的全局变量


-- 颜色类型
enStoneColor = {
	"Red",
	"Yellow",
	"Blue",
	"Green",
	"Purple",
    "Max"
}
enStoneColor = EnumTable(enStoneColor, 0)

-- 珠子关联方向类型
enDirectionType = {
    "lt",   -- 左上
    "ct",   -- 中上
    "rt",   -- 右上
    "lc",   -- 左中
    "rc",   -- 右中    
    "lb",   -- 左下
    "cb",   -- 中下
    "rb",   -- 右下
    "Max"
}
enDirectionType = EnumTable(enDirectionType, 0)