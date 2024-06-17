-- Author: MyrithisCatalyst / Catalyzer Gaming / FSG DaVaR
-- Name: FSG Tree Radius Fix v3.0.2
-- Description: Delete the first tree it finds that is too close. Default is 2 meters. This script goes 3 transport groups deep instead of the default 2.
-- Icon:
-- Hide: no

-- Changable Variables
local treeDistance = 4

-- DO NOT CHANGE ANYTHING BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING.

function in_array(tbl, item)
    if tbl then
        for key, value in pairs(tbl) do
            if value == item then
                return key
            end
        end
    end
    return false
end

local treeCount = 0
local totalCount = 0

local worldRootNode = getRootNode()
local Map = getChildAt(worldRootNode,0)
local Terrain = getChild(Map,"terrain")
local selectedTree = getChildAt(getRootNode(), 0);
local removeTrees = {}
local checkedTrees = {}
print("Processing, this may take a while...")
print("worldRootNode: " .. worldRootNode)
print("Map: " .. Map)
print("Terrain: " .. Terrain)
print("Selected: " .. selectedTree)

for g=0, getNumOfChildren(selectedTree)-1 do
  local Group = getChildAt(selectedTree, g)
  if Group ~= nil then
    for n=0, getNumOfChildren(Group)-1 do
  
      local GroupA = getChildAt(Group, n)
      for h=0, getNumOfChildren(GroupA)-1 do
    
        local Tree = getChildAt(GroupA, h)
        local x,y,z = getTranslation(Tree)
        for ig=0, getNumOfChildren(Tree)-1 do
          local iGroup = getChildAt(Tree, ig)
          for tna=0, getNumOfChildren(iGroup)-1 do
          
            local iGroupA = getChildAt(iGroup, tna)
            for tn=0, getNumOfChildren(iGroupA)-1 do
          
              local iTree = getChildAt(iGroupA, tn)
              local tx,ty,tz = getTranslation(iTree)
              if Tree ~= iTree and tx >= x-treeDistance and tx <= x+treeDistance and tz >= z-treeDistance and tz <= z+treeDistance then
                if in_array(removeTrees, iTree) == false and in_array(checkedTrees, iTree) == false then
                  removeTrees[treeCount+1] = iTree
                  treeCount = treeCount+1
                end
                if checkedTrees then
                  checkedTrees[table.getn(checkedTrees)+1] = Tree
                else
                  checkedTrees[1] = Tree
                end
              end
            
            end
            
          end
        end
        totalCount = totalCount+1
      
      end
    
    end
  end
end
if removeTrees then
    for key, value in pairs(removeTrees) do
        delete(value)
    end
end
print("   Removed Tree Count:" .. treeCount)
print("Total Trees Remaining:" .. totalCount-treeCount)
