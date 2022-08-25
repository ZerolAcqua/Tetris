--[[数据&初始化]]--，
require("blockData")

local blocks=blockData.blocks
local blockRowsFlag=blockData.blockRowsFlag
local blockColsFlag=blockData.blockColsFlag

local kickWallTable=blockData.kickWallTable
local kickWallTableMap=blockData.kickWallTableMap

local initPos=blockData.initPos
local blockColor=blockData.blockColor


-- 场地：40 格高，但是有效区域为 20 格，field 从底下往上
local field= {}
for i=1,40 do 
	field[i]={0,0,0,0,0,0,0,0,0,0}
end


-- 当前的方块的参数(位置形状颜色)
math.randomseed(os.time())
local curBlockId = math.random(7)
local curBlockDir = 1;

local curBlockColor = blockColor[curBlockId]
local curBlockShp = blocks[curBlockId][curBlockDir]
local curblockRowsFlag,curblockColsFlag = blockRowsFlag[curBlockId][curBlockDir],blockColsFlag[curBlockId][curBlockDir]
local coorX ,coorY = initPos[curBlockId][1],initPos[curBlockId][2] 
local blockSize = #curBlockShp
-- 当前的方块的状态参数(是否在地面、是否锁定)
local isGrounded=false
local islocked=false
-- 锁延开始时间
local lagStart=love.timer.getTime()
-- 锁延操作计数
local moveCount=15



-- 修改当前方块参数的函数
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
local function regenerateBlock()
	newId=math.random(7)
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

-- 检测方块是否落地的函数
local function ifOnGround()
	return ifOverlap(curBlockId,curBlockDir,coorX,coorY-1)
end

--下落函数
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

-- 重置锁延
local function resetLockLag()
	if isGrounded then
		if moveCount>0 then
			lagStart=love.timer.getTime()
			moveCount=moveCount-1
			print(moveCount)
		end
	else
		lagStart=love.timer.getTime()
	end
end

-- 锁定函数
local function lockBlock()
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