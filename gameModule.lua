gameModule={}

--[[数据&初始化]]--
-- 读取方块数据
require("blockData")
require("sequenceModule")
local blocks=blockData.blocks
local blockRowsFlag=blockData.blockRowsFlag
local blockColsFlag=blockData.blockColsFlag
local kickWallTable=blockData.kickWallTable
local kickWallTableMap=blockData.kickWallTableMap
local initPos=blockData.initPos
local blockColor=blockData.blockColor
math.randomseed(os.time())
-- 场地为 40 格高，但是有效区域为 20 格，field 从底下往上
local field= {}
for i=1,40 do 
	field[i]={0,0,0,0,0,0,0,0,0,0}
end

-- 当前方块的基本参数(位置朝向形状颜色)
local curBlockId = sequenceModule.popFront()
local curBlockDir = 1;
local curBlockColor = blockColor[curBlockId]
local curBlockShp = blocks[curBlockId][curBlockDir]
local curblockRowsFlag,curblockColsFlag = blockRowsFlag[curBlockId][curBlockDir],blockColsFlag[curBlockId][curBlockDir]
local coorX ,coorY = initPos[curBlockId][1],initPos[curBlockId][2] 
local blockSize = #curBlockShp
-- 当前方块的状态参数(是否在地面、是否锁定)
local isGrounded=false
local islocked=false

-- 初始化计时
local tm=0
-- 锁延开始时间
local lagStart=love.timer.getTime()
-- 锁延操作计数
local moveCount=15	-- TODO：这个变量应当是可用一个常量设置的，而不是用数字设置

-- 暂存操作计数
local holdCount=1	-- TODO：这个变量应当是可用一个常量设置的，而不是用数字设置
-- 暂存的方块类型
local holdType=-1

--[[函数]]--
-- 修改当前方块参数
local function changeCurBlock(id,dir,pos)
	-- 修改方块的类型方向与位置
	curBlockId=id
	curBlockDir=dir
	curBlockColor = blockColor[curBlockId]
	curBlockShp = blocks[curBlockId][curBlockDir]
	curblockRowsFlag,curblockColsFlag = blockRowsFlag[curBlockId][curBlockDir],blockColsFlag[curBlockId][curBlockDir]
	blockSize = #curBlockShp
	if type(pos)=='table' then
		coorX ,coorY =pos[1],pos[2]
	end
end

-- 生成新方块 
local function respawnBlock(newId)
	if newId==nil then
		newId=sequenceModule.popFront()
	end
	changeCurBlock(newId,1,{initPos[newId][1],initPos[newId][2]})
	isGrounded = false
	islocked = false
	lagStart=love.timer.getTime()
	moveCount=15
end

-- 检测当前方块，在左上角坐标为(x,y)时是否超出场地或与地面有重叠
local function ifOverlap(id,dir,x,y)
	local tmpBlockShp = blocks[id][dir]
	local tmpBlockRowsFlag,tmpBlockColsFlag = blockRowsFlag[id][dir],blockColsFlag[id][dir]
	local tmpBlockSize = #tmpBlockShp
	-- 是否超出场地左边界
	for i=1,tmpBlockSize do 
		if tmpBlockColsFlag[i]>0 then
			if x+i-1<1 then 
				return true
			else
				break
			end
		end
	end
	-- 是否超出场地右边界
	for i=tmpBlockSize,1,-1 do 
		if tmpBlockColsFlag[i]>0 then
			if x+i-1>10 then 
				return true
			else
				break
			end
		end
	end
	-- 是否超出场地底部
	for i=1,tmpBlockSize do 
		if tmpBlockRowsFlag[i]>0 then
			if y-tmpBlockSize+i<=0 then
				return true	-- 超出场地底部
			end
			for j=1,tmpBlockSize do
				if tmpBlockShp[i][j]>0 and field[y-tmpBlockSize+i][x+j-1]>0 then
					return true
				end
			end
		end 
	end
	return false
end

-- 检测方块是否落地
local function ifOnGround()
	return ifOverlap(curBlockId,curBlockDir,coorX,coorY-1)
end

--方块下落
local function drop()
	isGrounded=ifOnGround()
	if isGrounded==false then
		coorY=coorY-1
	end
end

-- 踢墙函数
local function kickWall(newDir)
	local index=kickWallTableMap[curBlockDir][newDir]

	if index==0 then	-- 无对应踢墙表
		if not ifOverlap(curBlockId,newDir,coorX,coorY) then
			changeCurBlock(curBlockId,newDir)
			return true
		end
	else
		local kickWallSeq = kickWallTable[curBlockId][index]
		local dX,dY
		if moveCount>0 then
			for i=1,#kickWallSeq do
				dX,dY=kickWallSeq[i][1],kickWallSeq[i][2]
				if not ifOverlap(curBlockId,newDir,coorX+dX,coorY+dY) then
					changeCurBlock(curBlockId,newDir,{coorX+dX,coorY+dY})
					return true
				end
			end
		else
			for i=1,#kickWallSeq do
				dX,dY=kickWallSeq[i][1],kickWallSeq[i][2]
				if not ifOverlap(curBlockId,newDir,coorX+kickWallSeq[i][1],coorY+kickWallSeq[i][2]) and dY<=0 then
					changeCurBlock(curBlockId,newDir,{coorX+kickWallSeq[i][1],coorY+kickWallSeq[i][2]})
					return true
				end
			end
		end
	end
	return false
end

-- 因操作造成的重置锁延
local function resetLockLag()
	if isGrounded then
		if moveCount>0 then
			lagStart=love.timer.getTime()
			-- 计数减少
			moveCount=moveCount-1
		end
	else
		lagStart=love.timer.getTime()
	end
end

-- 锁定函数
local function lockBlock()
	holdCount=1
	for i=1,blockSize do 
		for j=1,blockSize do 
			if curBlockShp[i][j]>0 then
				field[coorY-blockSize+i][coorX+j-1]=curBlockId
			end 
		end 
	end
end

-- 消行函数
local function eraseLines()
	-- 检测消行
	for i=blockSize,1,-1 do
		local ct=0
		if curblockRowsFlag[i]>0 then
			for j=1,10 do
				if field[coorY-blockSize+i][j]>0
				then ct=ct+1
				end
			end
			if ct==10 then
				table.remove(field,coorY-blockSize+i)
				table.insert(field,{0,0,0,0,0,0,0,0,0,0})
			end
		end
	end
end

-- 方块左移
function moveLeft()
	if not ifOverlap(curBlockId,curBlockDir,coorX-1,coorY)then
		resetLockLag()

		-- 移动
		coorX=coorX-1
		isGrounded=ifOnGround()
	end	
end
-- 方块右移
function moveRight()
	if not ifOverlap(curBlockId,curBlockDir,coorX+1,coorY)then
		resetLockLag()
		-- 移动						
		coorX=coorX+1
		isGrounded=ifOnGround()					
	end
end
-- 方块左旋逆时针
function rotateLCCW()
	local newDir = (curBlockDir-1 -1)%4+1
	if kickWall(newDir)then -- 在这里完成旋转
		resetLockLag()
		isGrounded=ifOnGround()
	end
end
-- 方块右旋顺时针
function rotateRCW()
	local newDir = (curBlockDir+1 -1)%4+1
	if kickWall(newDir)then -- 在这里完成旋转
		resetLockLag()
		isGrounded=ifOnGround()
	end
end
-- 方块180度旋转
function rotate180()
	local newDir = (curBlockDir+2 -1)%4+1
	if kickWall(newDir)then -- 在这里完成旋转
		resetLockLag()
		isGrounded=ifOnGround()
	end		
end
-- 方块软降
function softDrop()
	repeat drop()until isGrounded==true
	resetLockLag()
end
-- 方块硬降
function hardDrop()
	repeat drop()until isGrounded==true
	islocked =true
end
-- 方块暂存
function hold()
	if holdCount>0 then
		if holdType==-1 then
			holdType=curBlockId
			respawnBlock()
		else
			local tmp=curBlockId
			respawnBlock(holdType)
			holdType=tmp
		end
		holdCount=holdCount-1
	end
end

-- 方块按时间下降
function dropByTimer()
	--刷新下落计时器，每0.6秒执行一次drop
	-- TODO：这个时长应当是可用一个常量设置的，而不是用数字设置
	if love.timer.getTime()-tm>.6 then
		drop()
		tm=love.timer.getTime()
	end
end
-- 方块锁定完成消行与重新生成
function lockEraseRespawn()
	-- TODO：这个锁延时长应当是可用一个常量设置的，而不是用数字设置
	if isGrounded==true and love.timer.getTime()-lagStart>1 or islocked then
		lockBlock()
		eraseLines()
		respawnBlock()
	end
end

-- 获取场地数据
function getField()
	return field
end
-- 获取当前方块形状
function getCurBlockShp()
	return curBlockShp
end
-- 获取当前方块颜色
function getCurBlockColor()
	return curBlockColor
end
-- 获取当前方块位置
function getCurPos()
	return {coorX,coorY}
end
-- 获取 Hold 的方块类型
function getHoldType()
	return holdType	
end

--[[
整合模块
	blockColor：			颜色对应表
	----
	moveLeft()：			当前方块向左移动
	moveRight()：			当前方块向右移动
	rotateLCCW()：			当前方块左旋
	rotateRCW()：			当前方块右旋
	rotate180()：			当前方块180旋
	softDrop()：			当前方块软降
	hardDrop()：			当前方块硬降
	hold():					当前方块暂存
	--
	dropByTimer():			方块按时间下降
	lockEraseRespawn():		方块锁定完成消行与重新生成
	--
	getField：				获取场地数据
	getCurBlockShp：		获取当前方块形状
	getCurBlockColor：		获取当前方块颜色
	getCurPos：				获取当前方块位置
	getHoldType				获取 Hold 的方块类型

	
]]--

gameModule.blockColor=blockColor
----
gameModule.moveLeft=moveLeft
gameModule.moveRight=moveRight
gameModule.rotateLCCW=rotateLCCW
gameModule.rotateRCW=rotateRCW
gameModule.rotate180=rotate180
gameModule.softDrop=softDrop
gameModule.hardDrop=hardDrop
gameModule.hold=hold
--
gameModule.dropByTimer=dropByTimer
gameModule.lockEraseRespawn=lockEraseRespawn
--
gameModule.getField=getField
gameModule.getCurBlockShp=getCurBlockShp
gameModule.getCurBlockColor=getCurBlockColor
gameModule.getCurPos=getCurPos
gameModule.getHoldType=getHoldType

return gameModule