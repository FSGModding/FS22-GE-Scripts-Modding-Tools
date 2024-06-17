-- Author: Myrithis (Catalyzer Industries) - DaVaR Edit to add random rotation
-- Name: Tree Float Fix v3.2 RAN ROT
-- Description: Auto Fix Y values of all trees to match terrain height.
-- Icon:
-- Hide: no

-- New in version 3.2: The tree structure no longer an issue.
-- Just keep the trees under the top level transform group.
-- Make sure all tree parent tranlate XYZ values are 0,0,0 before running this script.
-- If the parents have something other than 0,0,0 then the script will be looking in the wrong place for the terrain height.

-- Changable Variables
local TopLevelParentName = "treesNorthEast";

-- DO NOT CHANGE ANYTHING BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING.

local treeCount = 0
local totalCount = 0
local worldRootNode = getRootNode()
local Map = getChildAt(worldRootNode,0)
local Terrain = getChild(Map,"terrain")
local Trees = getChild(Map, TopLevelParentName)

print("Processing, this may take a while...")

local function floatFix(parentTreeNodeId)
    if parentTreeNodeId ~= nil then
        local numOfChildren = getNumOfChildren(parentTreeNodeId)
        for p=0,numOfChildren-1 do
            local childNodeId = getChildAt(parentTreeNodeId,p)
            local numOfChildrenCheck = getNumOfChildren(childNodeId)
            if(numOfChildrenCheck > 0) then
                local childCheckId = getChildAt(childNodeId,0)
                if getName(childCheckId) == "LOD0" then
                    local x,y,z = getTranslation(childNodeId)
                    local rx,ry,rz = getRotation(childNodeId)
                    local terrainHeight = getTerrainHeightAtWorldPos(Terrain, x, y, z)
                    local increaseHeightForRotation = 0
                    rx = math.deg(rx)
                    ry = math.deg(ry)
                    rz = math.deg(rz)
                    local sideWaysRotationAdjustment = 0
                    if rx > 50 and rx < 175 or rx > -175 and rx < -50 then
                        sideWaysRotationAdjustment = -0.15 -- this is for sideways trees
                    end
                    if y ~= terrainHeight+sideWaysRotationAdjustment then
                        setTranslation(childNodeId, x, terrainHeight+sideWaysRotationAdjustment, z)
                        setRotation(childNodeId, 0, math.rad(math.random(1, 360)), 0)
                        treeCount = treeCount+1
                    end
                    totalCount = totalCount+1
                else
                    floatFix(childNodeId);
                end
            else
                floatFix(childNodeId);
            end
        end
    end
end

floatFix(Trees)

print("Fixed Tree Count:" .. treeCount)
print("Total Tree Count:" .. totalCount)
