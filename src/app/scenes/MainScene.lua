
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

MainScene.ImgBtnPlay = "login/play.png"
MainScene.ImgBlackCover = "login/black_cover.png"
MainScene.ImgPicRoom = "login/pic_room.jpg"

function MainScene:ctor()
    -- touchLayer 用于接收触摸事件
    self.touchLayer = display.newLayer()
    self:addChild(self.touchLayer)

    -- 启用触摸
    self.touchLayer:setTouchEnabled(true)   
    -- 添加触摸事件处理函数
    self.touchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch))

    self.bigImg = display.newSprite(MainScene.ImgPicRoom)
        :addTo(self)
        :pos(display.cx, display.cy)
        :scale(1.2)
    local size = self.bigImg:getContentSize()
    self.imgMaxX = size.width/2*1.2
    self.imgMinX = display.width - size.width/2*1.2
    self.imgMaxY = size.height/2*1.2
    self.imgMinY = display.height - size.height/2*1.2

    display.newSprite(MainScene.ImgBlackCover)
        :addTo(self, 1)
        :pos(display.cx, display.cy)

    cc.ui.UIPushButton.new(MainScene.ImgBtnPlay)
        :onButtonPressed(function(event)
            event.target:setScale(1.1)
        end)
        :onButtonRelease(function(event)
            event.target:setScale(1.0)
        end)
        :onButtonClicked(function()
            app:enterScene("ChooseLevelScene", nil, "flipy")
        end)
        :pos(display.cx, display.bottom + 100)
        :addTo(self, 1)

end

-- 触摸回调
function MainScene:onTouch(event)
    -- event.name 是触摸事件的状态：began, moved, ended, cancelled
    -- event.x, event.y 是触摸点当前位置
    -- event.prevX, event.prevY 是触摸点之前的位置
    -- local label = string.format("PlayDirector: %s x,y: %0.2f, %0.2f", event.name, event.x, event.y)
    -- print(label)
    if event.name == "began" then

    elseif event.name == "moved" then
        local posX = self.bigImg:getPositionX()
        posX = posX - (event.prevX - event.x)
        posX = math.min(posX, self.imgMaxX)
        posX = math.max(posX, self.imgMinX)

        local posY = self.bigImg:getPositionY()
        posY = posY - (event.prevY - event.y)
        posY = math.min(posY, self.imgMaxY)
        posY = math.max(posY, self.imgMinY)

        self.bigImg:setPosition(posX, posY)

    else

    end

    -- 返回 true 表示要响应该触摸事件，并继续接收该触摸事件的状态变化
    return true
end

function MainScene:test()

end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
