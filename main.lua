--[[数据&初始化]]--，
require("blockData")

-- local blocks=blockData.blocks
-- local blockRowsFlag=blockData.blockRowsFlag
-- local blockColsFlag=blockData.blockColsFlag

-- local kickWallTable=blockData.kickWallTable
-- local kickWallTableMap=blockData.kickWallTableMap

-- local initPos=blockData.initPos
-- local blockColor=blockData.blockColor


-- -- 场地：40 格高，但是有效区域为 20 格，field 从底下往上
-- local field= {}
-- for i=1,40 do 
-- 	field[i]={0,0,0,0,0,0,0,0,0,0}
-- end


-- -- 当前的方块的参数(位置形状颜色)
-- math.randomseed(os.time())
-- local curBlockId = math.random(7)
-- local curBlockDir = 1;

-- local curBlockColor = blockColor[curBlockId]
-- local curBlockShp = blocks[curBlockId][curBlockDir]
-- local curblockRowsFlag,curblockColsFlag = blockRowsFlag[curBlockId][curBlockDir],blockColsFlag[curBlockId][curBlockDir]
-- local coorX ,coorY = initPos[curBlockId][1],initPos[curBlockId][2] 
-- local blockSize = #curBlockShp
-- -- 当前的方块的状态参数(是否在地面、是否锁定)
-- local isGrounded=false
-- local islocked=false
-- -- 锁延开始时间
-- local lagStart=love.timer.getTime()
-- -- 锁延操作计数
-- local moveCount=15



-- -- 修改当前方块参数的函数
-- local function changeCurBlock(id,dir,pos)
-- 	-- 修改方块的类型方向与位置
-- 	curBlockId=id
-- 	curBlockDir=dir
-- 	curBlockColor = blockColor[curBlockId]
-- 	curBlockShp = blocks[curBlockId][curBlockDir]
-- 	curblockRowsFlag,curblockColsFlag = blockRowsFlag[curBlockId][curBlockDir],blockColsFlag[curBlockId][curBlockDir]
-- 	blockSize = #curBlockShp
-- 	if type(pos)=='table' then
-- 		coorX ,coorY =pos[1],pos[2]
-- 	end
-- end

-- -- 生成新方块 
-- local function regenerateBlock()
-- 	newId=math.random(7)
-- 	changeCurBlock(newId,1,{initPos[newId][1],initPos[newId][2]})
-- 	isGrounded = false
-- 	islocked = false
-- 	lagStart=love.timer.getTime()
-- 	moveCount=15
-- end

-- -- 检测当前方块，在左上角坐标为(x,y)时是否超出场地或与地面有重叠
-- local function ifOverlap(id,dir,x,y)
-- 	local tmpBlockShp = blocks[id][dir]
-- 	local tmpBlockRowsFlag,tmpBlockColsFlag = blockRowsFlag[id][dir],blockColsFlag[id][dir]
-- 	local tmpBlockSize = #tmpBlockShp
-- 	-- 是否超出场地左边界
-- 	for i=1,tmpBlockSize do 
-- 		if tmpBlockColsFlag[i]>0 then
-- 			if x+i-1<1 then 
-- 				return true
-- 			else
-- 				break
-- 			end
-- 		end
-- 	end
-- 	-- 是否超出场地右边界
-- 	for i=tmpBlockSize,1,-1 do 
-- 		if tmpBlockColsFlag[i]>0 then
-- 			if x+i-1>10 then 
-- 				return true
-- 			else
-- 				break
-- 			end
-- 		end
-- 	end
-- 	-- 是否超出场地底部
-- 	for i=1,tmpBlockSize do 
-- 		if tmpBlockRowsFlag[i]>0 then
-- 			if y-tmpBlockSize+i<=0 then
-- 				return true	-- 超出场地底部
-- 			end
-- 			for j=1,tmpBlockSize do
-- 				if tmpBlockShp[i][j]>0 and field[y-tmpBlockSize+i][x+j-1]>0 then
-- 					return true
-- 				end
-- 			end
-- 		end 
-- 	end
-- 	return false
-- end

-- -- 检测方块是否落地的函数
-- local function ifOnGround()
-- 	return ifOverlap(curBlockId,curBlockDir,coorX,coorY-1)
-- end

-- --下落函数
-- local function drop()
-- 	isGrounded=ifOnGround()
-- 	if isGrounded==false then
-- 		coorY=coorY-1
-- 	end
-- end

-- -- 踢墙函数
-- local function kickWall(newDir)
-- 	local index=kickWallTableMap[curBlockDir][newDir]

-- 	if index==0 then	-- 无对应踢墙表
-- 		if not ifOverlap(curBlockId,newDir,coorX,coorY) then
-- 			changeCurBlock(curBlockId,newDir)
-- 			return true
-- 		end
-- 	else
-- 		local kickWallSeq = kickWallTable[curBlockId][index]
-- 		local dX,dY
-- 		if moveCount>0 then
-- 			for i=1,#kickWallSeq do
-- 				dX,dY=kickWallSeq[i][1],kickWallSeq[i][2]
-- 				if not ifOverlap(curBlockId,newDir,coorX+dX,coorY+dY) then
-- 					changeCurBlock(curBlockId,newDir,{coorX+dX,coorY+dY})
-- 					return true
-- 				end
-- 			end
-- 		else
-- 			for i=1,#kickWallSeq do
-- 				dX,dY=kickWallSeq[i][1],kickWallSeq[i][2]
-- 				if not ifOverlap(curBlockId,newDir,coorX+kickWallSeq[i][1],coorY+kickWallSeq[i][2]) and dY<=0 then
-- 					changeCurBlock(curBlockId,newDir,{coorX+kickWallSeq[i][1],coorY+kickWallSeq[i][2]})
-- 					return true
-- 				end
-- 			end
-- 		end
-- 	end
-- 	return false
-- end

-- -- 重置锁延
-- local function resetLockLag()
-- 	if isGrounded then
-- 		if moveCount>0 then
-- 			lagStart=love.timer.getTime()
-- 			moveCount=moveCount-1
-- 			print(moveCount)
-- 		end
-- 	else
-- 		lagStart=love.timer.getTime()
-- 	end
-- end

-- -- 锁定函数
-- local function lockBlock()
-- 	for i=1,blockSize do 
-- 		for j=1,blockSize do 
-- 			if curBlockShp[i][j]>0 then
-- 				field[coorY-blockSize+i][coorX+j-1]=curBlockId
-- 			end 
-- 		end 
-- 	end
-- end

-- -- 消行函数
-- local function eraseLines()
-- 	-- 检测消行
-- 	for i=blockSize,1,-1 do
-- 		local ct=0
-- 		if curblockRowsFlag[i]>0 then
-- 			for j=1,10 do
-- 				if field[coorY-blockSize+i][j]>0
-- 				then ct=ct+1
-- 				end
-- 			end
-- 			if ct==10 then
-- 				table.remove(field,coorY-blockSize+i)
-- 				table.insert(field,{0,0,0,0,0,0,0,0,0,0})
-- 			end
-- 		end
-- 	end
-- end

--引擎工作函数
function love.run()
	--初始化计时
	local tm=0

	--引擎工作循环
	return function()
		--引擎事件系统
		love.event.pump()
		for name,k in love.event.poll()do
			if name=="quit"then
				--程序退出
				return true
			elseif name=="keypressed"then--玩家按键
				if k=="left"then--左移
					if not ifOverlap(curBlockId,curBlockDir,coorX-1,coorY)then
						-- TODO:移动旋转计数，如果在地面上进行移动旋转，计数减少
						resetLockLag()

						-- 移动
						coorX=coorX-1
						isGrounded=ifOnGround()
					end
				elseif k=="right"then--右移
					if not ifOverlap(curBlockId,curBlockDir,coorX+1,coorY)then
						-- TODO:移动旋转计数，如果在地面上进行移动旋转，计数减少
						resetLockLag()

						-- 移动						
						coorX=coorX+1
						isGrounded=ifOnGround()					
					end
				elseif k=="z"then--逆时针旋转
					local newDir = (curBlockDir-1 -1)%4+1
					if kickWall(newDir)then -- 在这里完成旋转
						-- TODO:移动旋转计数，如果在地面上进行移动旋转，计数减少
						resetLockLag()

						isGrounded=ifOnGround()
					end

				elseif k=="x"then--顺时针旋转
					local newDir = (curBlockDir+1 -1)%4+1
					if kickWall(newDir)then -- 在这里完成旋转
						-- TODO:移动旋转计数，如果在地面上进行移动旋转，计数减少
						resetLockLag()

						isGrounded=ifOnGround()
					end
				elseif k=="a"then--180度旋转
					local newDir = (curBlockDir+2 -1)%4+1
					if kickWall(newDir)then -- 在这里完成旋转
						-- TODO:移动旋转计数，如果在地面上进行移动旋转，计数减少
						resetLockLag()

						isGrounded=ifOnGround()
					end		
				
				elseif k=="down"then--软降到底
					repeat drop()until isGrounded==true
					-- 重置锁延时间
					resetLockLag()
				elseif k=="space"then--硬降
					repeat drop()until isGrounded==true
					islocked =true
				end
			end
		end

		--刷新下落计时器，每0.6秒执行一次drop
		if love.timer.getTime()-tm>.6 then
			drop()
			tm=love.timer.getTime()
		end

		-- 锁延后锁定
		if isGrounded==true and love.timer.getTime()-lagStart>1 or islocked then
			lockBlock()
			eraseLines()
			regenerateBlock()

		end

		--绘制场地
		love.graphics.clear(1,1,1)
		for y=1,20 do for x=1,10 do if field[y][x]>0 then
			local tempColor=blockColor[field[y][x]]
			love.graphics.setColor(tempColor[1],tempColor[2],tempColor[3])
			love.graphics.rectangle("fill",40*x-39,801-40*y,38,38)
		end end end

		--绘制方块
		love.graphics.setColor(curBlockColor[1],curBlockColor[2],curBlockColor[3])
		for y=1,#curBlockShp do for x=1,#curBlockShp[1]do if curBlockShp[y][x]==1 then
			love.graphics.rectangle("fill",40*(x+coorX-1)-39,801-40*(y+coorY-blockSize),38,38)
		end end end

		--将绘制内容输出到屏幕
		love.graphics.present()
	end
end