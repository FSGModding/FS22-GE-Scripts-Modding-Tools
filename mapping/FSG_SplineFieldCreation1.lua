-- Author: DaVaR
-- Name: FSG Spline to Field Creation Script v1
-- Description: Convert splines to field dimensions for map creation.
-- Icon:
-- Hide: no

-- Credits
-- This script was made possible by utilizeing existing features from scripts made by the following creators
-- LS-Modcompany/kevink98
-- modelleicher
-- TracMax, W_R
-- FSG Modding
-- Ola Haldor

-- How to use
-- Create a transform group in GE.  Place your splines within that transform group.
-- Ensure that your splines are complete and connect.  Select each and press "o" if not to close them.
-- Select the tranform group that you placed all of the splines in, and run the script.
-- Issues will be listed in the console with instructions if available.
-- 

-- Script Steps
-- Convert splines to field dimensions
-- Create a transformgroup and paste field splines in it
-- Loop through each spline and convert to a field in the order they are listed

-- Custom Settings
local objectDistance = 4                -- distance between objects in metres -- Abstand der Objekte --
local useDistanceTable = false          --'true' sets a fixed distance between objects using the settings in the distanceTable variable -- 'false' uses the objectDistance settings
local distanceTable = {2,0}             -- distanceTable, distance has to be set for each object -- Tabelle mit den Abstaenden fuer jedes Objekt, zu viele Eintraege schaden nicht , zu wenig fuehren zu Fehlern
local stayUpright = false               -- 'true' item remains upright --- 'false' reverts to spline 'X'rotation and original object rotation at the placement point
local randomYrotation = false           -- 'true' random rotation of 'Y'axis-- 'false' Y axis rotation as original object
local randomObjectDistance = false      -- 'true' allows for random distance between objects along the spline -- false distance as set by objectDistance
local randomObjectDistanceV = 5         -- Variation of the randomObjectDistance distance by percentage -- Variation des Abstands in Prozent der objectDistance --
local fixedDistance = false		          -- Allows a set distance for objects to be placed either to the left or right of the spline depending on valuue set indistanceFixed
local distanceFixed = -15			          -- Distance for objects to be placed to the left or right of the spline in metres (+/- depending on which side you want to place the objects) .			

-- Default stuffs
local worldRootNode = getRootNode()
local Map = getChildAt(worldRootNode,0)
local Terrain = getChild(Map,"terrain")
local selectedGroup = getSelection(0)

-- Check if anything is selected
if selectedGroup == 0 then 
  print('Error: Please select the transformgroup that contains splines.')
  return nil
end

-- Do stuff
function crossProduct(ax, ay, az, bx, by, bz)	
    return ay*bz - az*by, az*bx - ax*bz, ax*by - ay*bx;
end

-- Format Number with 00 at start if under 9 | add 0 if under 100
local function FormatNumber(idx)
    if idx < 10 then
        return string.format("00%s", idx)
    elseif idx < 100 then
        return string.format("0%s", idx)
    else
        return idx
    end
end

-- Function to convert spline to transformgroups
local function convertSpline(spline,newGroup)
  --print(string.format('Spline id: %d',spline))
  -- Get spline lengeth and make sure it is long enough for what we need to do
  local splineLength = getSplineLength(spline);
  --print(string.format('Spline Length: %s',splineLength))
  if splineLength < 3 then
    print(string.format('Skipped Short Spline: %s | nodeId: %d',getName(spline), spline))
    return nil
  end
  -- Set translations
  local xParent, yParent, zParent = getWorldTranslation(selectedGroup)

  local iObject = 0   -- Number of the object in objectsToPlace
  local numObjectsToPlace = 0

  -- Set start of spline position
  local splinePos = 0
  if splinePos < 0 then 
    splinePos = 0 
  end
  if splinePos > 1 then 
    print("Error: splinePos > 1 at start!")
    return 
  end

  -- Position of last location in spline
  local xlast, ylast, zlast = getSplinePosition(spline, 0);

  -- Initialize variables for center calculation
  local totalX, totalY, totalZ = 0, 0, 0
  local pointCount = 0

  -- Run through the spline and create transform groups to create an outer edge for field creation
  while splinePos <= 1 do

    local placeId = true
    local x, y, z = getSplinePosition(spline, splinePos);	

    if startX == 0 then
      startX = x
    end

    y = getTerrainHeightAtWorldPos(Terrain, x, y, z);
    if y == 0 then -- remove object, probably outside the map - delete object, is probably outside the map -
      placeId = false
    end
      
    local rx, ry, rz = getSplineOrientation(spline, splinePos, 0, -1, 0);  

    local yyy = 0

    if placeId then -- place object 
      local newPoint = createTransformGroup("sp-" .. splinePos)
      link(newGroup,newPoint)
      local mDirX, mDirY,   mDirZ = worldDirectionToLocal( spline, getSplineDirection (spline, splinePos) );
      local mVecDx, mVecDy, mVecDz = crossProduct( mDirX, mDirY, mDirZ, 0, 1, 0);
      if fixedDistance then					
        local fixPosX = x +distanceFixed * mVecDx;
        local fixPosY = y +distanceFixed * mVecDy;
        local fixPosZ = z +distanceFixed * mVecDz;
        
        fixPosY = getTerrainHeightAtWorldPos(Terrain, fixPosX, fixPosY, fixPosZ );
        if fixPosY ~= 0 then 
          setTranslation(newPoint, fixPosX-xParent, getTerrainHeightAtWorldPos(Terrain, fixPosX-xParent, 0, fixPosZ-zParent), fixPosZ-zParent);
        else
          -- do noting I guess
        end
      else
        setTranslation(newPoint, x-xParent, getTerrainHeightAtWorldPos(Terrain, x-xParent, 0, z-zParent), z-zParent);		
      end	--fixDst
      
      if stayUpright then 
        rx = 0
        rz = 0
      end

      if randomYrotation then   
        ry = math.random()*math.pi*2
      end

      setRotation(newPoint, rx, ry, rz);
      yyy =  y-ylast	
        
      -- Calculate center
      totalX = totalX + x
      totalY = totalY + y
      totalZ = totalZ + z

      pointCount = pointCount + 1

    end -- if placeId

    xlast = x -- update last position
    ylast = y
    zlast = z
    yyy = objectDistance/splineLength
    
    if useDistanceTable then 
      yyy = distanceTable[iObject+1]/splineLength -- Increase splinePos by 1 unit
      
      if iObject >= numObjectsToPlace then 
        iObject = 0
      end
    end
    if randomObjectDistance then 
        yyy = yyy*(1+(math.random()-0.5)*randomObjectDistanceV/100)
    end
    splinePos = splinePos + yyy -- Increase splinePos by 1 unit
    if splinePos < 0 then -- can be made negative by randomObjectDistance
      splinePos = 0 
    end
    
    iObject = iObject + 1 -- take next object
    if iObject >= numObjectsToPlace then 
      iObject = 0
    end

  end -- while

  -- Calculate the center coordinates
  local centerX = totalX / pointCount
  local centerZ = totalZ / pointCount

  
  return newGroup, centerX, centerZ;

end

-- create mid point between vector a and b 
function getMidPoint(a, b)
    local returnValue = {}
    returnValue[1], returnValue[2], returnValue[3] = (a[1] + b[1]) / 2, (a[2] + b[2]) / 2, (a[3] + b[3]) / 2 
    return returnValue
end


-- create field definition corner 
function createCorner(fieldDimensions, a, b, c, prefixIndex, prefixLetter)
    local corner1_1 = createTransformGroup(string.format("corner%s_%s_A_1",FormatNumber(prefixIndex),prefixLetter))
    local corner1_2 = createTransformGroup(string.format("corner%s_%s_A_2",FormatNumber(prefixIndex),prefixLetter))
    local corner1_3 = createTransformGroup(string.format("corner%s_%s_A_3",FormatNumber(prefixIndex),prefixLetter))
      
    link(fieldDimensions, corner1_1)   
    link(corner1_1, corner1_2) 
    link(corner1_1, corner1_3) 

    setTranslation(corner1_1, worldToLocal(fieldDimensions, unpack(a)))
    setTranslation(corner1_2, worldToLocal(corner1_1, unpack(b)))  
    setTranslation(corner1_3, worldToLocal(corner1_1, unpack(c)))
end

-- Start the field creation
function RDM_createField(curField, fieldsTG, centerX, centerZ)

    local nodes = getNumOfChildren(curField)
    local field
    local fieldDimensions

    -- get the center point vector  
    local centerP = {}
    centerP[1], centerP[2] , centerP[3] = centerX, 0, centerZ


    -- get number of fields already existing 
    local numberOfFields = getNumOfChildren(fieldsTG)

    -- create fieldX TG
    local number = numberOfFields

    -- clone the third selection, TemplateTG
    field = createTransformGroup(string.format("field%s", FormatNumber(number)))
    --if grassField == "grass" then
    --    setUserAttribute(field, "fieldGrassMission", "boolean", true)
    --end
    --  
    setUserAttribute(field, "fieldAngle", "Integer", 90);
    setUserAttribute(field, "fieldDimensionIndex", "Integer", 0);
    setUserAttribute(field, "nameIndicatorIndex", "Integer", 1);
    link(fieldsTG, field)
    --RDM edit
    setTranslation(field, unpack(centerP))

    fieldDimensions = createTransformGroup("fieldDimensions")       
    link(field, fieldDimensions) 
    -- create fieldMapIndicator
    local fieldMapIndicator = createTransformGroup("fieldMapIndicator")
    link(field, fieldMapIndicator)  
    setTranslation(fieldMapIndicator, worldToLocal(field, unpack(centerP)))
    

    -- cycle through all the outside points
    for i = 0, nodes-1 do   
        
        -- get the current outside node
        local node = getChildAt(curField, i)
        local currentP = {}
        currentP[1], currentP[2], currentP[3] = getWorldTranslation(node)

        -- get the next outside node, if we are at the last one, its the first
        local nextIndex = i+1 
        if nextIndex == nodes then
            nextIndex = 0
        end
        local nodeNext = getChildAt(curField, nextIndex)
        local nextP = {}
        nextP[1], nextP[2], nextP[3] = getWorldTranslation(nodeNext)

        -- calculate the mid point between current and center
        local curCenterMidP = getMidPoint(currentP, centerP)

        -- calculate mid point between current and next
        local curNextMidP = getMidPoint(nextP, currentP)

        -- calculate mid point between next and center
        local nextCenterMidP = getMidPoint(nextP, centerP)

        -- create first parallelogram between current, curCenterMid and curNextMid
        local par1A = curCenterMidP
        local par1B = currentP
        local par1C = curNextMidP

        -- create the second parallelogram between next, nextMid and nextCenterMid
        local par2A = curNextMidP
        local par2B = nextP
        local par2C = nextCenterMidP

        -- create the third parallelogram between nextCenterMid, center and currentCenterMid
        local par3A = nextCenterMidP
        local par3B = centerP
        local par3C = curCenterMidP

        -- create corners
        createCorner(fieldDimensions, par1A, par1B, par1C, i, "A")
        createCorner(fieldDimensions, par2A, par2B, par2C, i, "B")
        createCorner(fieldDimensions, par3A, par3B, par3C, i, "C")

    end
        
    print("Created Field Dimensions and Field 'field"..tostring(number).."'")
end

--------End of functions - start doing stuff with them---------

print('========================================')
print('========= FSG Spline Field Creation Script ==========')
print('========================================')

-- Get fields group and see if it is empty, if empty add to it, if not then request user to empty it
local fields = nil
local gameplay = getChild(Map,"gameplay")
if gameplay ~= nil then
  fields = getChild(gameplay,"fields")
end
-- Check if fields exist, if not create them and let user know to add attributes 
if fields == nil or fields == 0 then
  -- Fields Group is missing, create one
  fields = createTransformGroup("fields")
  -- setUserAttribute(fields, "onCreate", "scriptCallback", "FieldUtil.onCreate");
  link(gameplay, fields)
  print('Info: fields transportgroup has been added to the gameplay transport group.')
  print('Please add user atribute type "script callback" with name "onCreate" to the fields transportgroup.')
  print('Once the script callback is added, add "FieldUtil.onCreate" to the onCreate field.')
  print('========================================')
  return
end
-- Check if fields group has on create attribute
if getUserAttribute(fields, "onCreate") ~= "FieldUtil.onCreate" then
  print('Error: fields transportgroup is missing a required user attribute to continue.')
  print('Please add user atribute type "script callback" with name "onCreate" to the fields transportgroup.')
  print('Once the script callback is added, add "FieldUtil.onCreate" to the onCreate field.')
  print('========================================')
  return
end

-- Get splines in selected transform group
local numOfChildren = getNumOfChildren(selectedGroup)
print('Number of itmes in selected transformgroup: ' .. numOfChildren)
-- Create transform group to store data in
local parentGroup = getParent(getSelection(0))
local newGroup = createTransformGroup("new-fields-data")
link(parentGroup, newGroup)
local fieldNum = 0;
-- loop though all children and check if they are splines
for g=0, getNumOfChildren(selectedGroup)-1 do
  -- Get all groups within selected group
  local spline = getChildAt(selectedGroup, g)
  local splineLength = getSplineLength(spline);
  -- Run function to convert spline to transformgroups
  if spline ~= nil and splineLength > 2 then
    -- Create transformgroup for field data
    fieldNum = fieldNum + 1
    local newFieldGroup = createTransformGroup(string.format("fieldData%s", FormatNumber(fieldNum)));
    link(newGroup, newFieldGroup)
    local fieldSpline, centerX, centerZ = convertSpline(spline,newFieldGroup)
    if fieldSpline ~= nil and centerX ~= nil and centerZ ~= nil then
      -- print('====')
      -- print('Field Spline Data')
      -- print(fieldSpline)
      -- print(centerX)
      -- print(centerZ)
      -- print('====')

      -- Get the number of fields to create
      local numberOfShapes = getNumOfChildren(fieldSpline)

      -- Make sure we have fields to work with
      if numberOfShapes == nil or numberOfShapes == 0 then
        print(string.format('Info: No fileds were able to be created for field spline: %s - Skipping',fieldSpline))
        return
      end

      RDM_createField(fieldSpline, fields, centerX, centerZ)

    end
  end
end

-- Remove the transport group used to generate the data
delete(newGroup)

print('========================================')



