--[[数据&初始化]]--，
require("gameModule")
require("drawModule")

--引擎工作函数
function love.run()
	local field=gameModule.getField()
	local blockColor=gameModule.blockColor

	--引擎工作循环
	return function()
		--引擎事件系统
		love.event.pump()
		for name,k in love.event.poll()do
			if name=="quit"then
				--程序退出
				return true
			elseif name=="keypressed"then--玩家按键
				if  k=="escape"then
					return true
				elseif k=="left"then--左移
					gameModule.moveLeft()
				elseif k=="right"then--右移
					gameModule.moveRight()
				elseif k=="z"then--逆时针旋转
					gameModule.rotateLCCW()
				elseif k=="x"then--顺时针旋转
					gameModule.rotateRCW()
				elseif k=="a"then--180度旋转
					gameModule.rotate180()			
				elseif k=="down"then--软降到底
					gameModule.softDrop()
				elseif k=="space"then--硬降
					gameModule.hardDrop()
				end
			end
		end

		-- 方块计时下落
		gameModule.dropByTimer()

		-- 锁延后锁定
		gameModule.lockEraseRespawn()

		-- 绘制
		drawModule.drawField(field)
		drawModule.drawBlock(gameModule.getCurBlockShp(),gameModule.getCurPos(),gameModule.getCurBlockColor())
		love.graphics.present()	-- 输出到屏幕
	end
end

