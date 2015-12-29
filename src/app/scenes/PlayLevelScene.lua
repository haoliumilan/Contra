--
-- Author: Liu Hao
-- Date: 2015-12-03 12:10:35
-- 游戏界面

local PlayDirector = import("..director.PlayDirector")
local LevelCfg = import("..config.LevelCfg")
local TipsView = import("..views.TipsView")
local PauseView = import("..views.PauseView")
local SuccessView = import("..views.SuccessView")
local FailView = import("..views.FailView")
local TargetView = import("..views.TargetView")
local PicView = import("..views.PicView")

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
            self:levelPause_()
        end)
        :pos(display.right - 55, display.top - 55)
        :addTo(self, 1)

    -- 提示
    self.tipsView_ = TipsView.new()
        :addTo(self)

    --
    self.picView_ = app:createView("PicView", {picId = self.levelData_.picture})
        :addTo(self)

    -- 
    self.playDirector_ = PlayDirector.new(self.levelData_)
	    :addTo(self)

    cc.EventProxy.new(self.playDirector_, self)
        :addEventListener(self.playDirector_.CHANGE_STEP_EVENT, handler(self, self.playDirectorCb_))
        :addEventListener(self.playDirector_.CLEAR_STONE_EVENT, handler(self, self.playDirectorCb_))
        :addEventListener(self.playDirector_.LEVEL_SUCCESS_EVENT, handler(self, self.playDirectorCb_))
        :addEventListener(self.playDirector_.LEVEL_FAIL_EVENT, handler(self, self.playDirectorCb_))
        :addEventListener(self.playDirector_.TIPS_EVENT, handler(self, self.playDirectorCb_))

    -- 剩余回合数
    local leftStep = self.playDirector_:getStepCount()
    self.stepLabel_ = display.newTTFLabel({text = tostring(leftStep), size = 55, color = display.COLOR_WHITE})
        :pos(display.right-40, display.top-190)
        :addTo(self, 1)

    -- 关卡目标
    self.targetView_ = app:createView("TargetView", {targetData = self.levelData_.target, targetType = 1})
        :addTo(self, 1)

    self.successView_ = nil
    self.failView_ = nil
    self.pauseView_ = nil

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

-- 
function PlayLevelScene:levelSuccess_()
    self.successView_ = app:createView("SuccessView", {levelData = self.levelData_, callback = handler(self, self.levelSuccessCb_)})
        :addTo(self, 1)

    app:createView("SettleView", {settleData = self.playDirector_:getSettleData()})
        :addTo(self.successView_)

end

function PlayLevelScene:levelSuccessCb_(tag)
    if tag == SuccessView.EventBack then
    -- 回到选择关卡界面
        app:enterScene("ChooseLevelScene", nil, "flipy")
    elseif tag == SuccessView.EventNext then
    -- 进入下一关，小心到了最后一关
        local stepCount = LevelCfg.getCount()
        if self.levelData_.id == stepCount then
            -- 这是最后一关，回到选择关卡界面
            app:enterScene("ChooseLevelScene", nil, "flipy")
        else
            app:enterScene("PlayLevelScene", {self.levelData_.id+1}, "flipy")
        end
    end
end

-- 
function PlayLevelScene:levelFail_(isNotAddStep)
    self.failView_ = app:createView("FailView", {levelData = self.levelData_, callback = handler(self, self.levelFailCb_),
        notAddStep = isNotAddStep})
        :addTo(self, 1)
end

function PlayLevelScene:levelFailCb_(tag)
    if tag == FailView.EventAdd5 then
    -- 增加5回合，继续游戏
        if self.failView_ then
            self.failView_:removeFromParent()
            self.failView_ = nil
        end
        self.playDirector_:addStepCount()
        self:updateStepCount_()

    elseif tag == FailView.EventAgain then
    -- 重新游戏
        app:enterScene("PlayLevelScene", {checknumber(self.levelData_.id)}, "flipy")
    elseif tag == FailView.EventGiveUp then
    -- 放弃游戏，回到选择关卡界面
        app:enterScene("ChooseLevelScene", nil, "flipy")
    end
end

-- 
function PlayLevelScene:levelPause_()
    self.pauseView_ = app:createView("PauseView", {levelData = self.levelData_, callback = handler(self, self.levelPauseCb_)})
        :addTo(self, 1)
end

function PlayLevelScene:levelPauseCb_(tag)
    if tag == PauseView.EventAgain then
    -- 重新玩
        app:enterScene("PlayLevelScene", {checknumber(self.levelData_.id)}, "flipy")

    elseif tag == PauseView.EventGiveUp then
    -- 放弃，退出
        app:enterScene("ChooseLevelScene", nil, "flipy")

    elseif tag == PauseView.EventBack then
    -- 返回游戏
        if self.pauseView_ then
            self.pauseView_:removeFromParent()
            self.pauseView_ = nil
        end
    end
end

function PlayLevelScene:showTips(tips)
    self.tipsView_:showTips(tips)
end

function PlayLevelScene:playDirectorCb_(event)
    if event.name == PlayDirector.CHANGE_STEP_EVENT then
    -- 更新剩余回合数
        self:updateStepCount_()

    elseif event.name == PlayDirector.CLEAR_STONE_EVENT then
    -- 更新关卡目标进度
        self:updateTargetCount_()

    elseif event.name == PlayDirector.LEVEL_SUCCESS_EVENT then
    -- 胜利
        self:levelSuccess_()

    elseif event.name == PlayDirector.LEVEL_FAIL_EVENT then
    -- 失败
        self:levelFail_(event.isNotAddStep)

    elseif event.name == PlayDirector.TIPS_EVENT then
    -- 提示
        self:showTips(event.tips)
    end
end

return PlayLevelScene

