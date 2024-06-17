-- Author: Myrithis (Catalyzer Industries) - DaVaR Edit to add random rotation
-- Name: Tree Random Rotation v3.2
-- Description: Auto Fix Y values of all trees to match terrain height.
-- Icon:
-- Hide: no

-- New in version 3.2: The tree structure no longer an issue.
-- Just keep the trees under the top level transform group.
-- Make sure all tree parent tranlate XYZ values are 0,0,0 before running this script.
-- If the parents have something other than 0,0,0 then the script will be looking in the wrong place for the terrain height.

-- Changable Variables
local TopLevelParentName = "Trees";

-- DO NOT CHANGE ANYTHING BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING.

local treeCount = 0
local totalCount = 0
local worldRootNode = getRootNode()
local Map = getChildAt(worldRootNode,0)
local Terrain = getChild(Map,"terrain")
local Trees = getChild(Map, TopLevelParentName)

print("Processing, this may take a while...")

local function ranRot(parentTreeNodeId)
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
                    setRotation(childNodeId, 0, math.rad(math.random(1, 360)), 0)
                    treeCount = treeCount+1
                else
                    ranRot(childNodeId);
                end
            else
                ranRot(childNodeId);
            end
        end
    end
end

ranRot(Trees)

print("Trees Rotated Count:" .. treeCount)
