--
-- Author: liuhao
-- Date: 2015-12-07 17:41:13
-- 技能配置

--[[
	id,
	colorType, 颜色类型
	direction, 方向类型
	effect,  威力，每个方向影响珠子的数量
	iconIndex, 技能icon的序数
	needCount, 需要消除stone的数量
]]


local SkillCfg = {}

local cofigArr = {}

cofigArr[1] = {
	colorType = 1, direction = {1}, effect = 2, iconIndex = 1, needCount = 30,
}

cofigArr[2] = {
	colorType = 2, direction = {5}, effect = 2, iconIndex = 1, needCount = 30,
}

cofigArr[3] = {
	colorType = 3, direction = {3}, effect = 2, iconIndex = 1, needCount = 30,
}

cofigArr[4] = {
	colorType = 4, direction = {1, 5}, effect = 2, iconIndex = 2, needCount = 30,
}

cofigArr[5] = {
	colorType = 5, direction = {3, 7}, effect = 2, iconIndex = 2, needCount = 30,
}

function SkillCfg.numLevels()
    return #cofigArr
end

function SkillCfg.get(skillId)
    assert(skillId >= 1 and skillId <= #cofigArr, string.format("SkillCfg.get() - invalid skillId %s", tostring(skillId)))
    local oneSkill = clone(cofigArr[skillId])
    oneSkill["id"] = tostring(skillId)
    return oneSkill
end

return SkillCfg
