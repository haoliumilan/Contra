
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
	app:createGrid(self)

    cc.ui.UILabel.new({
            UILabelType = 2, text = "Contra", size = 64,
            color = cc.c3b(255, 0, 0)})
        :align(display.CENTER, display.cx, display.cy+200)
        :addTo(self)

    cc.ui.UILabel.new({
            UILabelType = 2, text = "魂斗罗", size = 64,
            color = cc.c3b(255, 0, 0)})
        :align(display.CENTER, display.cx, display.cy+100)
        :addTo(self)

    cc.ui.UIPushButton.new(ImageName.Button01, {scale9 = true})
        :setButtonSize(200, 80)
        :setButtonLabel(cc.ui.UILabel.new({text = "START"}))
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
        :addTo(self)

    self:test()
end

function MainScene:test()
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
