--
-- Author: liuhao
-- Date: 2015-12-03 12:10:35
-- 游戏界面

local PlayDirector = import("..director.PlayDirector")
local TargetView = import("..views.TargetView")
local LevelCfg = import("..config.LevelCfg")

local PlayLevelScene = class("PlayLevelScene", function()
    return display.newScene("PlayLevelScene")
end)

PlayLevelScene.ImgBg = "play/bg.jpg"
PlayLevelScene.ImgPause = "play/pause.png"


function PlayLevelScene:ctor(levelId)
    levelId = levelId or 1
    self.levelData_ = LevelCfg.get(levelId)

	-- background
	display.newSprite(PlayLevelScene.ImgBg, display.cx, display.cy)
		:addTo(self)

	-- 暂停button
    cc.ui.UIPushButton.new(PlayLevelScene.ImgPause)
        :onButtonPressed(function(event)
            event.target:setScale(1.1)
        end)
        :onButtonRelease(function(event)
            event.target:setScale(1.0)
        end)
        :onButtonClicked(function()
            app:enterScene("ChooseLevelScene", nil, "flipy")
        end)
        :pos(display.right - 55, display.top - 55)
        :addTo(self, 1)

    -- 
    self.playDirector_ = PlayDirector.new(self.levelData_)
	    :addTo(self)

    cc.EventProxy.new(self.playDirector_, self)
        :addEventListener(self.playDirector_.CHANGE_STEP_EVENT, handler(self, self.updateStepCount_))
        :addEventListener(self.playDirector_.CLEAR_STONE_EVENT, handler(self, self.updateTargetCount_))

    -- 剩余回合数
    local leftStep = self.playDirector_:getStepCount()
    self.stepLabel_ = display.newTTFLabel({text = tostring(leftStep), size = 55, color = display.COLOR_WHITE})
        :pos(display.right-40, display.top-190)
        :addTo(self, 1)

    -- 关卡目标
    self.targetView_ = TargetView.new(self.levelData_.target)
        :addTo(self, 1)
end

--
function PlayLevelScene:updateStepCount_()
    local leftStep = self.playDirector_:getStepCount()
    self.stepLabel_:setString(tostring(leftStep))
end

-- 
function PlayLevelScene:updateTargetCount_()
    local clearStones = self.playDirector_:getClearStones()
    self.targetView_:udpateTargetCount(clearStones)
end


return PlayLevelScene