-- Author: FSG Modding DaVaR
-- Name: FSG Tree Distance Height and Rotation Fix v1.0.1
-- Description: Loops through trees within a main transport group and checks to see if any trees are too close together, if so deletes them.
-- Icon: 
-- Hide: no

-- Distance you would like trees to have between them.  (meters)
local treeSpacingDistance = 3

-- Transportgroup names fore each tree.  Use the main group for each tree name.
local treeNamesArray = {
  "pine_stage01",
  "pine_stage02",
  "pine_stage03",
  "pine_stage04",
  "spruce_stage5_1500",
  "pineOld_stage5_1500",
  "spruce_stage5_1500",
  "spruceVar02_stage03_1500",
  "spruceVar01_stage02",
  "pine_stage06"
}

-- DO NOT EDIT ANYTHING BELOW THIS LINE OR THINGS COULD GO BAD.  USE AT YOUR OWN RISK.  MAKE BACKUPS FIRST.  

local debug = false

local selectedGroup = getSelection(0);

local worldRootNode = getRootNode()
local Map = getChildAt(worldRootNode,0)
local Terrain = getChild(Map,"terrain")

if selectedGroup == nil or selectedGroup == 0 then
  print("ERROR: You must select a transport group before running this script!")
  return
end

print("FSG Tree Distance Fix v1.0.1 Starting... This make take some time.")

-- Function to check if value is in an array
function in_array(tbl, item)
  if tbl then
    for key, value in pairs(tbl) do
      if value == item then
          return true
      end
    end
  end
  return false
end

-- Print function to make it neater
local function printf(formatText, ...)
    print(string.format(formatText, ...))
end

-- Tree float fix with auto rotation
local function floatFixWithRotation(treeNode)
  if treeNode ~= nil then
    local x,y,z = getTranslation(treeNode)
    local rx,ry,rz = getRotation(treeNode)
    local terrainHeight = getTerrainHeightAtWorldPos(Terrain, x, y, z)
    rx = math.deg(rx)
    ry = math.deg(ry)
    rz = math.deg(rz)
    -- Randomly set some trees slightly angled
    local randomIndex = math.random(1, 30)
    local sideWaysRotationAdjustment = 0
    if randomIndex == 10 or randomIndex == 20 then
      local ranAngle = {0.03,0.05,0.07,0.09}
      local randomAngle1 = math.random(1,4)
      local randomAngle2 = math.random(1,4)
      rx = 0 + ranAngle[randomAngle1]
      rz = 0 + ranAngle[randomAngle2]
      sideWaysRotationAdjustment = -0.15
    else
      rx = 0
      rz = 0
    end
    -- update tree rotation and angle
    setTranslation(treeNode, x, terrainHeight+sideWaysRotationAdjustment, z)
    setRotation(treeNode, rx, math.rad(math.random(1, 360)), rz)
  end
end

-- Array for all found trees
local foundTrees = {}
local treeCount = 0

-- Loop through the selcted transport group and get all trees
for g=0, getNumOfChildren(selectedGroup)-1 do
  -- Get all groups within selected group
  local groupOne = getChildAt(selectedGroup, g)
  if groupOne ~= nil then
    if debug == true then print(groupOne) end 
    local groupOneName = getName(groupOne)
    if debug == true then print(groupOneName) end
    -- Check if group is a Tree
    if in_array(treeNamesArray, groupOneName) == true then 
      if debug == true then printf("Found Tree : %s : %d", groupOneName, groupOne) end
      foundTrees[treeCount] = groupOne
      floatFixWithRotation(groupOne)
      treeCount = treeCount+1
    else
      -- go one more level in
      for g=0, getNumOfChildren(groupOne)-1 do
        -- Get all groups within selected group
        local groupTwo = getChildAt(groupOne, g)
        if groupTwo ~= nil then
          if debug == true then print(groupTwo) end
          local groupTwoName = getName(groupTwo)
          if debug == true then print(groupTwoName) end
          -- Check if group is a Tree
          if in_array(treeNamesArray, groupTwoName) == true then 
            if debug == true then printf("Found Tree : %s : %d", groupTwoName, groupTwo) end
            foundTrees[treeCount] = groupTwo
            floatFixWithRotation(groupTwo)
            treeCount = treeCount+1
          else
            -- go one more level in
            for g=0, getNumOfChildren(groupTwo)-1 do
              -- Get all groups within selected group
              local groupThree = getChildAt(groupTwo, g)
              if groupThree ~= nil then
                if debug == true then print(groupThree) end
                local groupThreeName = getName(groupThree)
                if debug == true then print(groupThreeName) end
                -- Check if group is a Tree
                if in_array(treeNamesArray, groupThreeName) == true then 
                  if debug == true then printf("Found Tree : %s : %d", groupThreeName, groupThree) end
                  foundTrees[treeCount] = groupThree
                  floatFixWithRotation(groupThree)
                  treeCount = treeCount+1
                else
                  -- go one more level in
                  for g=0, getNumOfChildren(groupThree)-1 do
                    -- Get all groups within selected group
                    local groupFour = getChildAt(groupThree, g)
                    if groupFour ~= nil then
                      if debug == true then print(groupFour) end
                      local groupFourName = getName(groupFour)
                      if debug == true then print(groupFourName) end
                      -- Check if group is a Tree
                      if in_array(treeNamesArray, groupFourName) == true then 
                        if debug == true then printf("Found Tree : %s : %d", groupFourName, groupFour) end
                        foundTrees[treeCount] = groupFour
                        floatFixWithRotation(groupFour)
                        treeCount = treeCount+1
                      else
                        -- go one more level in
                        for g=0, getNumOfChildren(groupFour)-1 do
                          -- Get all groups within selected group
                          local groupFive = getChildAt(groupFour, g)
                          if groupFive ~= nil then
                            if debug == true then print(groupFive) end
                            local groupFiveName = getName(groupFive)
                            if debug == true then print(groupFiveName) end
                            -- Check if group is a Tree
                            if in_array(treeNamesArray, groupFiveName) == true then 
                              if debug == true then printf("Found Tree : %s : %d", groupFiveName, groupFive) end
                              foundTrees[treeCount] = groupFive
                              floatFixWithRotation(groupFive)
                              treeCount = treeCount+1
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end


printf("Total Trees Found: %d",treeCount)

-- Loop through all of the found trees and do stuff with them
print("Looping through all the found trees and checking their distance.")
local removeTrees = {}
local checkedTrees = {}
local foundTreecount = treeCount 

for _, ft1 in pairs(foundTrees) do
  for _, ft2 in pairs(foundTrees) do
    if ft1 ~= ft2 then
      -- Get coordinates of both trees
      local fx1, fy1, fz1 = getTranslation(ft1)
      local fx2, fy2, fz2 = getTranslation(ft2)

      -- Calculate the distance between the two trees
      local distance = math.sqrt((fx1 - fx2)^2 + (fy1 - fy2)^2 + (fz1 - fz2)^2)

      if distance <= treeSpacingDistance then
        if not in_array(removeTrees, ft1) and not in_array(checkedTrees, ft1) then
          table.insert(removeTrees, ft1)
        end
        if not in_array(removeTrees, ft2) and not in_array(checkedTrees, ft2) then
          table.insert(removeTrees, ft2)
        end
        if not in_array(checkedTrees, ft1) then
          table.insert(checkedTrees, ft1)
        end
        if not in_array(checkedTrees, ft2) then
          table.insert(checkedTrees, ft2)
        end
      end
    end
  end
end



-- loop through all trees that are marked for removal and delte them.
print("Removing the following trees: ")
local removeTreesCount = 0
if removeTrees then
    for key, value in pairs(removeTrees) do
        if debug == true then print(value) end
        delete(value)
        removeTreesCount = removeTreesCount+1
    end
end

print("Removed Tree Count: " .. removeTreesCount)
print("Total Trees Remaining: " .. foundTreecount-removeTreesCount)