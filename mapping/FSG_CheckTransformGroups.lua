-- Author: FSG Modding
-- Name: FSG Check Transform Groups Tool
-- Description: This tool loops through transform groups to check if more than one item in groups that have LOD checked.  Provides Node IDs.
-- Icon:
-- Hide: no

local TransformGroupToCheck = "Trees";

local groupCount = 0
local totalCount = 0
local worldRootNode = getRootNode()
local Map = getChildAt(worldRootNode,0)
local Terrain = getChild(Map,"terrain")
local Groups = getChild(Map, TransformGroupToCheck)

print("FSG Modding Check Transform Groups Script Running...  This may take some time...")

local function transportGroupCheck(parentNodeId)
    if parentNodeId ~= nil then
        print("Checking Transport Groups in: " .. parentNodeId)
        local numOfChildren = getNumOfChildren(parentNodeId)
        print("Total number of groups within " .. parentNodeId .. ": " .. numOfChildren)
    end
end

transportGroupCheck(Groups)