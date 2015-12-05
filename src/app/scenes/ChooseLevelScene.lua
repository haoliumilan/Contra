--
-- Author: liuhao
-- Date: 2015-12-03 11:51:21
-- 选择关卡界面

local ChooseLevelScene = class("ChooseLevelScene", function()
    return display.newScene("ChooseLevelScene")
end)

function ChooseLevelScene:ctor()
	app:createGrid(self)

	cc.ui.UILabel.new({
	        UILabelType = 2, text = "关卡选择", size = 50,
	        color = cc.c3b(255, 0, 0)})
	    :align(display.CENTER, display.cx, display.top-100)
	    :addTo(self)

	self:createPageView()

	cc.ui.UIPushButton.new(ImageName.Button01, {scale9 = true})
	    :setButtonSize(200, 80)
	    :setButtonLabel(cc.ui.UILabel.new({text = "BACK"}))
	    :onButtonPressed(function(event)
	        event.target:setScale(1.1)
	    end)
	    :onButtonRelease(function(event)
	        event.target:setScale(1.0)
	    end)
	    :onButtonClicked(function()
	        app:enterScene("MainScene", nil, "flipy")
	    end)
	    :pos(display.left+150, display.bottom+100)
	    :addTo(self)
end

function ChooseLevelScene:createPageView()
    self.pv = cc.ui.UIPageView.new {
        viewRect = cc.rect(70, 200, 610, 1000),
        column = 3, row = 3,
        padding = {left = 20, right = 20, top = 20, bottom = 20},
        columnSpace = 10, rowSpace = 10}
        :onTouch(handler(self, self.touchListener))
        :addTo(self)

    -- add items
    for i=1,9 do
        local item = self.pv:newItem()
        local content = cc.LayerColor:create(
            cc.c4b(math.random(250),
                math.random(250),
                math.random(250),
                250))
        content:setContentSize(160, 270)
        content:setTouchEnabled(false)
        item:addChild(content)
        self.pv:addItem(item)        

        local title = cc.ui.UILabel.new(
            {text = "item"..i,
            size = 36,
            align = cc.ui.TEXT_ALIGN_CENTER,
            color = display.COLOR_BLACK,
            dimensions = cc.size(160, 270),})
        	:addTo(content)
    end
    self.pv:reload()

end

function ChooseLevelScene:touchListener(event)
    dump(event, "TestUIPageViewScene - event:")
    local listView = event.listView
    app:enterScene("PlayLevelScene", nil, "flipy")
end


return ChooseLevelScene