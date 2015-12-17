--
-- Author: Liu Hao
-- Date: 2015-12-14 16:57:17
-- 珠子的配置

--[[
	id, 即是stoneType		
	is_selected, 是否可以选中
	is_clear, 是否可以消除
	clear_target, 消除效果， 五种颜色和铁块都是nil，木头是有目标的
]]

local StoneCfg = {}

local configArr = {}

configArr[1] = { -- 红色
	is_selected = true, is_clear = true, clear_target = nil
}

configArr[2] = { -- 橙色
	is_selected = true, is_clear = true, clear_target = nil
}

configArr[3] = { -- 绿色
	is_selected = true, is_clear = true, clear_target = nil
}

configArr[4] = { -- 蓝色
	is_selected = true, is_clear = true, clear_target = nil
}

configArr[5] = { -- 紫色
	is_selected = true, is_clear = true, clear_target = nil
}

configArr[6] = { -- 铁块
	is_selected = false, is_clear = false, clear_target = nil
}

configArr[7] = { -- 木头A1
	is_selected = false, is_clear = true, clear_target = 8
}

configArr[8] = { -- 木头A2
	is_selected = false, is_clear = true, clear_target = nil
}

configArr[9] = { -- 木头B1
	is_selected = false, is_clear = true, clear_target = 10
}

configArr[10] = { -- 木头B2
	is_selected = false, is_clear = true, clear_target = nil
}

function StoneCfg.get(stoneId)
    assert(stoneId >= 1 and stoneId <= #configArr, string.format("StoneCfg.get() - invalid stoneId %s", tostring(stoneId)))
    local oneStone = clone(configArr[stoneId])
    oneStone["id"] = tostring(stoneId)
    return oneStone
end

return StoneCfg
