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
	drop, 5种颜色的掉率
	skill, 关卡技能
	stone，wallX，wallY 地图配置
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
	picture = 1,
	drop = {2, 2, 0, 1, 1},
	skill = {1, 2, 3, 4, 5},
	-- 1：红、2：黄、3：绿、4：蓝、5：紫、6：铁箱、7：木箱A、8：木箱B、9：铁墙、10：木墙、11：冰块
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
	},
}

configArr[2] = {
	target = {
		{1, 3},
		{3, 3},
	},
	step = 20,
	name = "X档案",
	detail = "月明星稀，乌鹊南飞。绕树三匝，何枝可依？山不厌高，海不厌深。周公吐哺，天下归心。",
	stamina = 1,
	picture = 2,
	drop = {0, 1, 0, 1, 1},
	skill = {1, 2, 3, 7, 8},
	-- 1：红、2：黄、3：绿、4：蓝、5：紫、6：铁箱、7：木箱A、8：木箱B、9：铁墙、10：木墙、11：冰块
	stone = {
		{{s = 3, c = 11, sk = 3}, {s = 3, c = 11}, {s = 3, c = 11}, 0, {s = 1, c = 11}, {s = 1, c = 11}, {s = 1, c = 11, sk = 1}},
		{0, {c = 11}, 0, 0, 0, {c = 11}, 0},
		{0, 0, {c = 11}, 0, {c = 11}, 0, 0},
		{0, 0, 0, {s = 2, c = 11, sk = 2}, 0, 0, 0},
		{0, 0, {c = 11}, 0, {c = 11}, 0, 0},
		{0, {c = 11}, 0, 0, 0, {c = 11}, 0},
		{{c = 11}, 0, 0, 0, 0, 0, {c = 11}},
	},
	wallX = {
		{9, 9, 9, 0, 9, 9, 9},
		{9, 9, 9, 0, 9, 9, 9},
		{0, 10, 10, 0, 10, 10, 0},
		{0, 0, 10, 10, 10, 0, 0},
		{0, 0, 10, 10, 10, 0, 0},
		{0, 10, 10, 0, 10, 10, 0},
		{10, 10, 0, 0, 0, 10, 10},
		{},
	},
	wallY = {
		{9, 9, 9, 9, 9, 9, 9, 9},
		{0, 10, 10, 0, 0, 10, 10, 0},
		{0, 0, 10, 10, 10, 10, 0, 0},
		{0, 0, 0, 10, 10, 0, 0, 0},
		{0, 0, 10, 10, 10, 10, 0, 0},
		{0, 10, 10, 0, 0, 10, 10, 0},
		{0, 10, 0, 0, 0, 0, 10, 0},
	},
}

configArr[3] = {
	target = {
		{7, 2},
		{8, 2},
	},
	step = 20,
	name = "达芬奇密码",
	detail = "月明星稀，乌鹊南飞。绕树三匝，何枝可依？山不厌高，海不厌深。周公吐哺，天下归心。",
	stamina = 1,
	picture = 3,
	drop = {1, 1, 1, 1, 0},
	skill = {1, 6, 3, 4, 8},
	-- 1：红、2：黄、3：绿、4：蓝、5：紫、6：铁箱、7：木箱A、8：木箱B、9：铁墙、10：木墙、11：冰块
	stone = {
		{0, 0, 0, {s = 7, c = 11}, 0, 0, 0},
		{},
		{0, 0, 0, {s = 2, sk = 6}, 0, 0, 0},
		{{s = 8, c = 11}, 0, {s = 1, sk = 1}, 6, {s = 3, sk = 3}, 0, {s = 8, c = 11}},
		{0, 0, 0, {s = 4, sk = 4}, 0, 0, 0},
		{},
		{0, 0, 0, {s = 7, c = 11}, 0, 0, 0},
	},
	wallX = {
		{0, 0, 0, 9, 0, 0, 0},
		{0, 0, 0, 9, 0, 0, 0},
		{0, 0, 0, 10, 0, 0, 0},
		{9, 0, 10, 0, 10, 0, 9},
		{9, 0, 10, 0, 10, 0, 9},
		{0, 0, 0, 10, 0, 0, 0},
		{0, 0, 0, 9, 0, 0, 0},
		{0, 0, 0, 9, 0, 0, 0},
	},
	wallY = {
		{0, 0, 0, 9, 9, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 10, 10, 0, 0, 0},
		{9, 9, 10, 0, 0, 10, 9, 9},
		{0, 0, 0, 10, 10, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 9, 9, 0, 0, 0},
	},
}

configArr[4] = {
	target = {
		{1, 30},
		{2, 30},
		{3, 30},
		{4, 30},
		{5, 30},
	},
	step = 20,
	name = "test",
	detail = "月明星稀，乌鹊南飞。绕树三匝，何枝可依？山不厌高，海不厌深。周公吐哺，天下归心。",
	stamina = 1,
	picture = 3,
	drop = {1, 1, 1, 1, 1},
	skill = {1, 2, 3, 4, 5},
	-- 1：红、2：黄、3：绿、4：蓝、5：紫、6：铁箱、7：木箱A、8：木箱B、9：铁墙、10：木墙、11：冰块
	stone = {
		{1, 1, 2, 2, 2, 1, 1},
		{1, 1, 2, 2, 2, 1, 1},
		{1, 1, 2, 2, 2, 1, 1},
		{1, 1, 2, 2, 2, 1, 1},
		{1, 1, 2, 2, 2, 1, 1},
		{1, 1, 2, 2, 2, 1, 1},
		{1, 1, 2, 2, 2, 1, 1},
	},
	wallX = {
		{0, 0, 0, 0, 0, 0, 0},
		{9, 0, 9, 0, 9, 0, 9},
		{0, 9, 0, 9, 0, 9, 0},
		{0, 0, 9, 0, 9, 0, 0},
		{0, 0, 9, 9, 9, 0, 0},
		{0, 0, 0, 9, 0, 0, 0},
		{0, 9, 0, 9, 0, 9, 0},
		{9, 0, 9, 0, 9, 0, 9},
	},
	wallY = {
		{0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, 0},
	},
}

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

function LevelCfg.getCount()
	return #configArr
end

function LevelCfg.get(levelId)
    assert(levelId >= 1 and levelId <= #configArr, string.format("LevelCfg.get() - invalid levelId %s", tostring(levelId)))
    local oneLevel = clone(configArr[levelId])
    oneLevel["id"] = tostring(levelId)
    return oneLevel
end

return LevelCfg
