blockData={}

--[[所有的方块数据]]--
-- 记录的各方向的方块形状(从下往上)：1-原位(0) 2-顺时针位(R) 3-180度位(2) 4-逆时针位(L)
local blocks={
	-- I
	{
		{{0,0,0,0},{0,0,0,0},{1,1,1,1},{0,0,0,0}},		--I1
		{{0,0,1,0},{0,0,0,0},{0,0,0,0},{0,0,1,0}},		--I2
		{{0,0,0,0},{1,1,0,1},{0,0,0,0},{0,0,0,0}},		--I3
		{{0,1,0,0},{0,0,0,0},{0,0,0,0},{0,1,0,0}}		--I4
	},	
	-- J
	{
		{{0,0,0},{1,1,1},{1,0,0}},						--J1
		{{0,1,0},{0,0,0},{0,1,1}},						--J2
		{{0,0,1},{1,1,0},{0,0,0}},						--J3
		{{1,1,0},{0,0,0},{0,1,0}}						--J4
	},		
	-- L
	{
		{{0,0,0},{1,1,1},{0,0,1}},						--L1
		{{0,1,1},{0,0,0},{0,1,0}},						--L2
		{{1,0,0},{0,1,1},{0,0,0}},						--L3
		{{0,1,0},{0,1,0},{1,0,0}}						--L4
	},
	-- O	
	{
		{{1,1},{1,1}},									--O1
		{{1,0},{1,1}},									--O2
		{{1,0},{0,1}},									--O3
		{{0,1},{1,1}}									--O4
	},
	-- S
	{
		{{0,0,0},{1,1,0},{0,1,1}},						--S1
		{{0,0,1},{0,1,0},{0,1,0}},						--S2
		{{1,0,0},{0,1,1},{0,0,0}},						--S3
		{{0,1,0},{0,1,0},{1,0,0}}						--S4
	},		
	-- Z
	{
		{{0,0,0},{0,1,1},{1,1,0}},						--Z1
		{{0,1,0},{0,0,1},{0,0,1}},						--Z2
		{{0,1,1},{1,0,0},{0,0,0}},						--Z3
		{{1,0,0},{1,0,0},{0,1,0}}						--Z4
	},
	-- T
	{
		{{0,0,0},{1,1,1},{0,1,0}},						--T1
		{{0,1,0},{0,0,1},{0,1,0}},						--T2
		{{0,1,0},{1,0,1},{0,0,0}},						--T3
		{{0,1,0},{1,0,0},{0,1,0}}						--T4
	}
}
-- 记录各方向方块在相应行列是否有小 mino,可以由 blocks 推出
local blockRowsFlag={}
local blockColsFlag={} 
local function calRowColFlag()
	for id=1,#blocks do	-- 每种方块
		blockRowsFlag[id]={}
		local blockSize=#blocks[id][1]
		for dir=1,4 do	-- 每个方向
			blockRowsFlag[id][dir]={}
			for i=1,blockSize do -- 每行
				blockRowsFlag[id][dir][i]=0
				for j=1,blockSize do
					if blocks[id][dir][i][j]>0 then
						blockRowsFlag[id][dir][i]=1
						break
					end
				end
			end
		end
	end
	for i=1,#blockRowsFlag do
		blockColsFlag[i]={}
		blockColsFlag[i][1]=blockRowsFlag[i][4]
		blockColsFlag[i][2]=blockRowsFlag[i][1]
		blockColsFlag[i][3]=blockRowsFlag[i][2]
		blockColsFlag[i][4]=blockRowsFlag[i][3]
	end
end
calRowColFlag()

-- 踢墙表(JLSTZ相同一套，单独一套,O无踢墙)
local kickWallTable={
	-- I
	{
		{{0,0},{-2,0},{ 1,0},{-2,-1},{ 1, 2}},		-- 0->R
		{{0,0},{ 2,0},{-1,0},{ 2, 1},{-1,-2}},		-- R->0
		{{0,0},{-1,0},{ 2,0},{-1, 2},{ 2,-1}},		-- R->2
		{{0,0},{ 1,0},{-2,0},{ 1,-2},{-2, 1}},		-- 2->R
		{{0,0},{ 2,0},{-1,0},{ 2, 1},{-1,-2}},		-- 2->L
		{{0,0},{-2,0},{ 1,0},{-2,-1},{ 1, 2}},		-- L->2
		{{0,0},{ 1,0},{-2,0},{ 1,-2},{-2, 1}},		-- L->0
		{{0,0},{-1,0},{ 2,0},{-1, 2},{ 2,-1}}		-- 0->L
	},	
	-- J
	{
		{{0,0},{-1,0},{-1, 1},{0,-2},{-1,-2}},		-- 0->R
		{{0,0},{ 1,0},{ 1,-1},{0, 2},{ 1, 2}},		-- R->0
		{{0,0},{ 1,0},{ 1,-1},{0, 2},{ 1, 2}},		-- R->2
		{{0,0},{-1,0},{-1, 1},{0,-2},{-1,-2}},		-- 2->R
		{{0,0},{ 1,0},{ 1, 1},{0,-2},{ 1,-2}},		-- 2->L
		{{0,0},{-1,0},{-1,-1},{0, 2},{-1, 2}},		-- L->2
		{{0,0},{-1,0},{-1,-1},{0, 2},{-1, 2}},		-- L->0
		{{0,0},{ 1,0},{ 1, 1},{0,-2},{ 1,-2}}		-- 0->L
	},		
	-- L
	{
		{{0,0},{-1,0},{-1, 1},{0,-2},{-1,-2}},		-- 0->R
		{{0,0},{ 1,0},{ 1,-1},{0, 2},{ 1, 2}},		-- R->0
		{{0,0},{ 1,0},{ 1,-1},{0, 2},{ 1, 2}},		-- R->2
		{{0,0},{-1,0},{-1, 1},{0,-2},{-1,-2}},		-- 2->R
		{{0,0},{ 1,0},{ 1, 1},{0,-2},{ 1,-2}},		-- 2->L
		{{0,0},{-1,0},{-1,-1},{0, 2},{-1, 2}},		-- L->2
		{{0,0},{-1,0},{-1,-1},{0, 2},{-1, 2}},		-- L->0
		{{0,0},{ 1,0},{ 1, 1},{0,-2},{ 1,-2}}		-- 0->L
	},
	-- O	
	{
		{{0,0}},		-- 0->R
		{{0,0}},		-- R->0
		{{0,0}},		-- R->2
		{{0,0}},		-- 2->R
		{{0,0}},		-- 2->L
		{{0,0}},		-- L->2
		{{0,0}},		-- L->0
		{{0,0}}			-- 0->L
	},
	-- S
	{
		{{0,0},{-1,0},{-1, 1},{0,-2},{-1,-2}},		-- 0->R
		{{0,0},{ 1,0},{ 1,-1},{0, 2},{ 1, 2}},		-- R->0
		{{0,0},{ 1,0},{ 1,-1},{0, 2},{ 1, 2}},		-- R->2
		{{0,0},{-1,0},{-1, 1},{0,-2},{-1,-2}},		-- 2->R
		{{0,0},{ 1,0},{ 1, 1},{0,-2},{ 1,-2}},		-- 2->L
		{{0,0},{-1,0},{-1,-1},{0, 2},{-1, 2}},		-- L->2
		{{0,0},{-1,0},{-1,-1},{0, 2},{-1, 2}},		-- L->0
		{{0,0},{ 1,0},{ 1, 1},{0,-2},{ 1,-2}}		-- 0->L
	},		
	-- Z
	{
		{{0,0},{-1,0},{-1, 1},{0,-2},{-1,-2}},		-- 0->R
		{{0,0},{ 1,0},{ 1,-1},{0, 2},{ 1, 2}},		-- R->0
		{{0,0},{ 1,0},{ 1,-1},{0, 2},{ 1, 2}},		-- R->2
		{{0,0},{-1,0},{-1, 1},{0,-2},{-1,-2}},		-- 2->R
		{{0,0},{ 1,0},{ 1, 1},{0,-2},{ 1,-2}},		-- 2->L
		{{0,0},{-1,0},{-1,-1},{0, 2},{-1, 2}},		-- L->2
		{{0,0},{-1,0},{-1,-1},{0, 2},{-1, 2}},		-- L->0
		{{0,0},{ 1,0},{ 1, 1},{0,-2},{ 1,-2}}		-- 0->L
	},
	-- T
	{
		{{0,0},{-1,0},{-1, 1},{0,-2},{-1,-2}},		-- 0->R
		{{0,0},{ 1,0},{ 1,-1},{0, 2},{ 1, 2}},		-- R->0
		{{0,0},{ 1,0},{ 1,-1},{0, 2},{ 1, 2}},		-- R->2
		{{0,0},{-1,0},{-1, 1},{0,-2},{-1,-2}},		-- 2->R
		{{0,0},{ 1,0},{ 1, 1},{0,-2},{ 1,-2}},		-- 2->L
		{{0,0},{-1,0},{-1,-1},{0, 2},{-1, 2}},		-- L->2
		{{0,0},{-1,0},{-1,-1},{0, 2},{-1, 2}},		-- L->0
		{{0,0},{ 1,0},{ 1, 1},{0,-2},{ 1,-2}}		-- 0->L
	}
}
-- 踢墙表映射，由起止的方向获得索引 [a][b]=>index,index=0 意为没有映射
local kickWallTableMap={
	{0,1,0,8},
	{2,0,3,0},
	{0,4,0,5},
	{7,0,6,0},
}
-- 方块活动框左上角坐标 (x,y)
local initPos={
	{4,22},		-- I
	{4,22},		-- J
	{4,22},		-- L
	{5,22},		-- O
	{4,22},		-- S
	{4,22},		-- Z
	{4,22}		-- T
}
-- 方块颜色
local blockColor={
	{0,255,255},		-- I
	{0,0,255},			-- J
	{255,170,0},		-- L
	{255,255,0},		-- O
	{0,255,0},			-- S
	{255,0,0},			-- Z
	{153,0,255}			-- T
}
for i=1,#blockColor do
	for j=1,3 do
		blockColor[i][j]=blockColor[i][j]/255
	end
end

--[[
整合模块
	blocks：			记录的各方向的方块形状(从下往上)：1-原位(0) 2-顺时针位(R) 3-180度位(2) 4-逆时针位(L)
	blockRowsFlag：		记录各方向方块在相应行是否有小 mino,可以由 blocks 推出
	blockColsFlag：		记录各方向方块在相应列是否有小 mino,可以由 blocks 推出
	
	kickWallTable：		踢墙表(JLSTZ相同一套，单独一套,O无踢墙)		
	kickWallTableMap：	踢墙表映射，由起止的方向获得索引 [a][b]=>index,index=0 意为没有映射
	
	initPos：			方块活动框左上角坐标 (x,y)
	blockColor：		方块颜色
]]--
blockData.blocks=blocks
blockData.blockRowsFlag=blockRowsFlag
blockData.blockColsFlag=blockColsFlag

blockData.kickWallTable=kickWallTable
blockData.kickWallTableMap=kickWallTableMap

blockData.initPos=initPos
blockData.blockColor=blockColor

return blockData