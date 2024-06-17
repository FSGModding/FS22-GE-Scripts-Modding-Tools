-- Author: Myrithis (Catalyzer Industries) - DaVaR Edit Random Rotation
-- Name: FSG Auto Trees Replicator Rotation v3-6
-- Description: Replicate the selected tree(s) in a square radius around it.
--              Place all template trees close to the same x,y,z location to have a mixed forest.
-- Icon:
-- Hide: no

-- Select a group of trees that you want randomly placed, and put the fisrt tree on the texture you want them placed on, then run the script. Easy

-- Warning: Trees will place inside objects.
-- v3.6
--    Ability to select a group of trees and auto place trees anywehre on the map that has matching texture that first tree selected is located on.
-- New in version 3.5:
--    Renamed variable allowTreesInWater to allowTreesAnywhere.
--    Renamed variable wy to minHeightLevel.
--    Added maxHeightLevel.
--    Adjusted descriptions of renamed variable to make more sense.

-- Changable Variables
local minHeightLevel = 1              -- Do not place trees below this Y level.
local maxHeightLevel = 9999           -- Do not place trees above this Y level.
local allowTreesAnywhere = false      -- This will override the minHeightLevel and maxHeightLevel variables and place the trees at any Y level.
local treeRadiusSize = 4096           -- The radius distance to place the trees. The selected tree will act as the center.
local treeDistance = 5                -- The radius restriction for how far apart the trees should be placed.
local restrictPaint = true            -- Only plant on the ground type that first selected tree is located on.

-- DO NOT CHANGE ANYTHING BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING.
local worldRootNode = getRootNode()
local Map = getChildAt(worldRootNode,0)
local Terrain = getChild(Map,"terrain")
local TreeExists = false
local topLevelTransformId = -1

-- Auto get color of texture that the first tree selected is currently on.
print("Running Tree Replication Script.  This process may take a moment to complete.")
treeNodeId = getSelection(0)
local tx,ty,tz = getTranslation(treeNodeId)
local CurLocColorR, CurLocColorG, CurLocColorB, CurLocColorW, CurLocColorU = getTerrainAttributesAtWorldPos(Terrain, tx, ty, tz, true, true, true, true, true)
-- print("Selected Tree Color Codes: R: "..CurLocColorR.."G: "..CurLocColorG.."B: "..CurLocColorB.."W: "..CurLocColorW.."U: "..CurLocColorU)
CurLocColorR = string.format("%.12f",CurLocColorR)
CurLocColorG = string.format("%.12f",CurLocColorG)
CurLocColorB = string.format("%.12f",CurLocColorB)
CurLocColorW = string.format("%f",CurLocColorW)

-- Get parent group name and stuff
local topLevelTransformName = getName(getParent(getSelection(0)))

-- Function to walk up the tree and make sure the selection us under the top level parent specified on the top.
local function walkParents(treeNodeId)
    parentId = getParent(treeNodeId)
    if getName(parentId) == topLevelTransformName then
        topLevelTransformId = parentId
        return true
    elseif parentId < 2 then
        return false
    else
        return walkParents(parentId)
    end
end

for selectCount = 0, getNumSelected()-1 do
    treeNodeId = getSelection(selectCount)
    local numOfChildren = getNumOfChildren(treeNodeId)
    if numOfChildren > 0 then
        childName = getName(getChildAt(treeNodeId,0))
    else
        childName = nil
    end
    if childName ~= "LOD0" then
        TreeExists = false
        break
    else
        TreeExists = walkParents(treeNodeId)
    end
    if TreeExists == false then
        break
    end
end

if TreeExists == true then
    -- Walk down the tree to find all children within the tree radius
    local function buildExistingTreeNodesInRadius(existingTreeNodesInRadius, parentTreeNodeId, origX, origZ)
        if parentTreeNodeId ~= nil then
            local numOfChildren = getNumOfChildren(parentTreeNodeId)
            if numOfChildren > 0 then
                for p=0,numOfChildren-1 do
                    local childNodeId = getChildAt(parentTreeNodeId,p)
                    local tx,ty,tz = getTranslation(childNodeId)
                    local childCheckId = getChildAt(childNodeId,0)
                    if getName(childCheckId) == "LOD0" then
                        if tx >= origX-(treeRadiusSize+(treeDistance*2)) and tx <= origX+(treeRadiusSize+(treeDistance*2)) and tz >= origZ-(treeRadiusSize+(treeDistance*2)) and tz <= origZ+(treeRadiusSize+(treeDistance*2)) then
                            table.insert(existingTreeNodesInRadius, childNodeId)
                        end
                    else
                        existingTreeNodesInRadius = buildExistingTreeNodesInRadius(existingTreeNodesInRadius, childNodeId, origX, origZ);
                    end
                end
            end
        end
        return existingTreeNodesInRadius
    end

    -- Function to see if a tree is too close to another before it plants a new one.
    local function checkForNoTreeConflict(x, y, z, treeDistance, existingTreeNodesInRadius, allowTreesAnywhere, minHeightLevel, maxHeightLevel)
        local placeTree = true
        for key,value in ipairs(existingTreeNodesInRadius) do
            local tx,ty,tz = getTranslation(value)
            if tx >= x-treeDistance and tx <= x+treeDistance and tz >= z-treeDistance and tz <= z+treeDistance then
                placeTree = false
                break
            elseif not allowTreesAnywhere and y < minHeightLevel then -- do not plant below minHeightLevel
                placeTree = false
                break
            elseif not allowTreesAnywhere and y > maxHeightLevel then -- do not plant above maxHeightLevel
                placeTree = false
                break
            elseif restrictPaint == true then
                -- Only plant trees on allowed terrain paint.
                local cR, cG, cB, cW, _ = getTerrainAttributesAtWorldPos(Terrain, x, y, z, false, false, false, false, false)
                cR = string.format("%.12f",cR)
                cG = string.format("%.12f",cG)
                cB = string.format("%.12f",cB)
                cW = string.format("%f",cW)
                if cR == CurLocColorR and cG == CurLocColorG and cB == CurLocColorB and cW == CurLocColorW then
                    -- Matched color to current top tree location
                    placeTree = true
                else
                    placeTree = false
                    break
                end
            else
                placeTree = true
            end
        end
        return placeTree
    end

    -- These are the main variables to process everything.
    local origX = 0
    local origZ = 0
    local x = 0
    local y = 0
    local z = 0
    local treesPlaced = 0
    local treeConflicts = 0
    local treeTracker = 1000 * treeRadiusSize
    local existingTreeNodesInRadius = {}
    local newTreesTable = {}
    print("Num Selected Trees to Randomly place: " .. getNumSelected())
    treeNodeId = getSelection(0)
    x,y,z = getTranslation(treeNodeId)
    -- print("Selected Tree Location: " .. x .. " " .. y .. " " .. z)
    existingTreeNodesInRadius = buildExistingTreeNodesInRadius(existingTreeNodesInRadius, topLevelTransformId, x, z)
    while(treeTracker > 0) do
        treeNodeId = getSelection(0)
        x,y,z = getTranslation(treeNodeId)
        origX = x
        origZ = z
        local treePlacedCheck = false
        for c=0, 1, 1 do
            local randomX = math.random(-treeRadiusSize,treeRadiusSize)
            local randomZ = math.random(-treeRadiusSize,treeRadiusSize)
            x = origX+randomX
            z = origZ+randomZ

            local terrainHeight = getTerrainHeightAtWorldPos(Terrain, x, y, z)
            if checkForNoTreeConflict(x, terrainHeight, z, treeDistance, existingTreeNodesInRadius, allowTreesAnywhere, minHeightLevel, maxHeightLevel) == true and terrainHeight > 0 then
                treeNodeId = getSelection(math.random(0,getNumSelected()-1))
                local tree = clone(treeNodeId, true)
                setTranslation(tree, x, terrainHeight, z)
                setRotation(tree, 0, math.rad(math.random(1, 360)), 0)
                treesPlaced = treesPlaced + 1
                treeTracker = treeTracker + 1
                treePlacedCheck = true
                if tree then
                    table.insert(existingTreeNodesInRadius, tree)
                    table.insert(newTreesTable, tree)
                end
                break
            end
        end
        if treePlacedCheck == false then
            treeTracker = treeTracker - 1
        end
    end
    -- Create a new transform group to put the new trees in
    local parentGroup = getParent(getSelection(0));
    local newTreeGroup = createTransformGroup(topLevelTransformName .. "-new");
    link(parentGroup, newTreeGroup)
    -- Loop through all the new trees and put them into their own transport group    
    if newTreesTable ~= nil and #newTreesTable > 0 then
      print("Putting New Trees in their own transport group.")
      for _,newTree in pairs(newTreesTable) do
        link(newTreeGroup,newTree)
      end
    end
    print("Number of Trees Placed: " .. treesPlaced)
    if(treesPlaced == 0 and treeTracker == 0) then
        print("Could not place additional trees.")
    end
elseif getNumSelected() > 0 then
    print("Not all selections were detected as compatible trees.\nSelected trees need to have LOD0 as the first child node and "..topLevelTransformName.." as the highest parent.")
else
    print("Please select a tree to replicate.")
end
