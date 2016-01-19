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
	award, 奖励，目前是一句话
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
		{1, 30},
		{2, 30},
		{3, 30},
		{4, 30},
		{5, 30},
		{6, 30},
	},
	step = 25,
	name = "艾利之书",
	detail = "神秘人：“完成作品。然后，你还有额外的任务要做。线索就在这个档案袋里面。",
	award = "“头发多的秀技术，头发少的玩套路。你这种情况的话…..下一关玩套路！”",
	stamina = 1,
	picture = 1,
	image = 1, 
	drop = {1, 1, 1, 1, 1},
	skill = {1, 2, 1, 2, 1},
	-- 1：红、2：黄、3：绿、4：蓝、5：紫、6：铁箱、7：木箱A、8：木箱B、9：铁墙、10：木墙、11：冰块
	stone = {
	},
}

configArr[2] = {
	target = {
		{1, 30},
		{2, 30},
		{3, 30},
		{4, 30},
		{5, 30},
		{6, 30},
	},
	step = 25,
	name = "X档案",
	detail = "书里面居然还有两份订单！难道这就是“额外的任务”？",
	award = "我相信你已经具备回答这三个问题的能力了：“早上吃什么？中午吃什么？晚上吃什么？”",
	stamina = 1,
	picture = 2,
	image = 2,
	drop = {1, 1, 1, 1, 1},
	skill = {1, 2, 1, 2, 1},
	-- 1：红、2：黄、3：绿、4：蓝、5：紫、6：铁箱、7：木箱A、8：木箱B、9：铁墙、10：木墙、11：冰块
	stone = {
	},
}

configArr[3] = {
	target = {
		{1, 30},
		{2, 30},
		{3, 30},
		{4, 30},
		{5, 30},
		{6, 30},
	},
	step = 25,
	name = "达芬奇密码",
	detail = "照片上画了一串奇怪的符号。",
	award = "“↑↑↓↓←→←→BABA！恭喜你获得了30条命！可是游戏已经通关了。再见。”",
	stamina = 1,
	picture = 3,
	image = 3,
	drop = {1, 1, 1, 1, 1},
	skill = {1, 2, 1, 2, 1},
	-- 1：红、2：黄、3：绿、4：蓝、5：紫、6：铁箱、7：木箱A、8：木箱B、9：铁墙、10：木墙、11：冰块
	stone = {
	},
}

configArr[4] = {
	target = {
		{1, 30},
		{2, 30},
		{3, 30},
		{4, 30},
		{5, 30},
		{6, 30},
	},
	step = 100,
	name = "test",
	detail = "？？？",
	award = "？？？",
	stamina = 1,
	picture = 3,
	image = 3,
	drop = {1, 1, 1, 1, 1},
	skill = {1, 2, 1, 2, 1},
	-- 1：红、2：黄、3：绿、4：蓝、5：紫、6：铁箱、7：木箱A、8：木箱B、9：铁墙、10：木墙、11：冰块
	stone = {
		{1, 1, 1, 1, 1, 1, 1, 1, 1},
		{1, 1, 1, 1, 1, 1, 1, 1, 1},
		{1, 1, 1, 1, 1, 1, 1, 1, 1},
		{7, 7, 7, 7, 7, 7, 7, 7, 7},
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
	if BEIBEI_TEST == true then
		return #configArr-1
	else
		return #configArr
	end
end

function LevelCfg.get(levelId)
    assert(levelId >= 1 and levelId <= #configArr, string.format("LevelCfg.get() - invalid levelId %s", tostring(levelId)))
    local oneLevel = clone(configArr[levelId])
    oneLevel["id"] = tostring(levelId)
    return oneLevel
end

return LevelCfg
