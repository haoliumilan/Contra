--
-- Author: Liu Hao
-- Date: 2015-12-11 15:32:22
-- 关卡配置

--[[
	id,
	target = {
		color = num, 颜色类型 = 数量
	}, 关卡完成目标 
	step, 关卡回合数限制
	name, 关卡名字
	detail, 关卡详情
	stamina, 关卡需要的体力
	picture, 关卡解锁的画 
]]

local LevelCfg = {}

local configArr = {}

configArr[1] = {
	target = {
		{3, 6},
		{2, 36},
		{1, 36},
	},
	step = 20,
	name = "艾利之书",
	detail = "月明星稀，乌鹊南飞。绕树三匝，何枝可依？山不厌高，海不厌深。周公吐哺，天下归心。",
	stamina = 1,
	picture = "pic_1",
	drop = {2, 2, 0, 1, 1},
	-- 1：红、2：黄、3：绿、4：蓝、5：紫、6：铁箱、7：木箱A、8：木箱B、9：铁墙、10：木墙
	stone = {
		{3, 3, 0, 0, 0, 3, 3},
		{},
		{},
		{},
		{0, 0, 0, 4, 0, 0, 0},
		{0, 0, 1, 1, 1, 0, 0},
		{3, 2, 2, 2, 2, 2, 3},
	},
	wallX = {
		{},
		{0, 10, 0, 10, 0, 10, 0},
		{10, 0, 10, 0, 10, 0, 10},
		{0, 10, 0, 10, 0, 10, 0},
		{10, 0, 0, 10, 0, 0, 10},
		{0, 0, 10, 0, 10, 0, 0},
		{10, 10, 0, 0, 0, 10, 10},
		{10, 0, 0, 0, 0, 0, 10},
	},
	wallY = {
		{0, 0, 10, 0, 0, 10, 0, 0},
		{0, 10, 0, 10, 10, 0, 10, 0},
		{0, 0, 10, 0, 0, 10, 0, 0},
		{0, 10, 0, 0, 0, 0, 10, 0},
		{0, 0, 0, 10, 10, 0, 0, 0},
		{0, 0, 10, 0, 0, 10, 0, 0},
		{10, 10, 0, 0, 0, 0, 10, 10},
	}
}

configArr[2] = {
	target = {
		{1, 25},
		{2, 25},
		{3, 25},
		{4, 25},
		{5, 25}
	},
	step = 20,
	name = "X档案",
	detail = "月明星稀，乌鹊南飞。绕树三匝，何枝可依？山不厌高，海不厌深。周公吐哺，天下归心。",
	stamina = 1,
	picture = "pic_2",
	drop = {0, 1, 0, 1, 1},
}

configArr[3] = {
	target = {
		{1, 30},
		{2, 30},
		{3, 30},
		{4, 30},
		{5, 30}
	},
	step = 20,
	name = "达芬奇密码",
	detail = "月明星稀，乌鹊南飞。绕树三匝，何枝可依？山不厌高，海不厌深。周公吐哺，天下归心。",
	stamina = 1,
	picture = "pic_3",
	drop = {1, 1, 1, 1, 0},
}

-- configArr[4] = {}
-- configArr[5] = {}
-- configArr[6] = {}
-- configArr[7] = {}
-- configArr[8] = {}
-- configArr[9] = {}
-- configArr[10] = {}
-- configArr[11] = {}
-- configArr[12] = {}
-- configArr[13] = {}
-- configArr[14] = {}
-- configArr[15] = {}
-- configArr[16] = {}
-- configArr[17] = {}
-- configArr[18] = {}
-- configArr[19] = {}
-- configArr[20] = {}

function LevelCfg.getLevelCount()
	return #configArr
end

function LevelCfg.get(levelId)
    assert(levelId >= 1 and levelId <= #configArr, string.format("LevelCfg.get() - invalid levelId %s", tostring(levelId)))
    local oneLevel = clone(configArr[levelId])
    oneLevel["id"] = tostring(levelId)
    return oneLevel
end

return LevelCfg
