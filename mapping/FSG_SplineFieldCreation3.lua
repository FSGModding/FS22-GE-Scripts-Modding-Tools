-- Author: DaVaR
-- Name: FSG Spline to Field Creation Script v1-0-2
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

-- Load editor utils
source("editorUtils.lua");

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
local paintFieldDirt = false            -- Paint dirt where field is
local mLayerId   = 40                   -- should be int  -- 80 is asphalt, 71 is grass, 82 is gravel
local mSideCount = 0                    -- distance in meters the dirt should go inward to the field
local mSideCount2 = 0                    -- distance in meters the dirt should go inward to the field

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

-- function to set paint type
local function setLayerId(value)
    mLayerId = value
end

-- function to set paint type
local function setSideCount(value)
    mSideCount = value
end

-- function to set paint type
local function setSideCount2(value)
    mSideCount2 = value
end

-- function to change the object distance
local function setObjectDistance(value)
  objectDistance = value
end

-- function to change the paint field dirt option
local function setPaintFieldDirt(value)
  paintFieldDirt = value
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
        createCorner(fieldDimensions, par1A, par1B, par1C, i, "A", paintDirt)
        createCorner(fieldDimensions, par2A, par2B, par2C, i, "B", paintDirt)
        createCorner(fieldDimensions, par3A, par3B, par3C, i, "C", paintDirt)

    end
        
    print("Created Field Dimensions and Field 'field"..tostring(number).."'")
end


-- Function that paints field dirt within spline area
local function runPaintFieldDirt(mSplineID)

  print('Start of dirt paint thingy')

    if mLayerId == nil then 
      mLayerId = 40
    end

    local mSceneID = getChildAt(getRootNode(), 0)
    local mTerrainID = 0

    for i = 0, getNumOfChildren(mSceneID) - 1 do
        local mID = getChildAt(mSceneID, i)
        if (getName(mID) == "terrain") then
            mTerrainID = mID
            break
        end
    end

    if (mTerrainID == 0) then
        print("Error: Terrain node not found. Node needs to be named 'terrain'.")
        return nil
    end

    local terrainSize = getTerrainSize(mTerrainID)
    print('terrainSize : ' .. terrainSize)

    local mSplineLength = getSplineLength( mSplineID ) 
    local mSplinePiece = 0.5 -- real size 0.5 meter
    local mSplinePiecePoint = mSplinePiece / mSplineLength  -- relative size [0..1]

    local mSplinePos = 0.0
    while mSplinePos <= 1.0 do
        -- get XYZ at position on spline
        local mPosX, mPosY, mPosZ = getSplinePosition( mSplineID, mSplinePos )
        -- directional vector at the point
        local mDirX, mDirY,   mDirZ   = getSplineDirection ( mSplineID, mSplinePos)
        local mVecDx, mVecDy, mVecDz = EditorUtils.crossProduct( mDirX, mDirY, mDirZ, 0, 1, 0)
        -- paint at the center
        setTerrainLayerAtWorldPos(mTerrainID, mLayerId, mPosX, mPosY, mPosZ, 128.0 )
        -- define side to side shift in meters
        for i = 1, mSideCount, 1 do
            local mNewPosX1 = mPosX + i * mVecDx
            local mNewPosZ1 = mPosZ + i * mVecDz
            -- paint at the center
            setTerrainLayerAtWorldPos(mTerrainID, mLayerId, mNewPosX1, mPosY, mNewPosZ1, 128.0 )
        end
        -- define side to side shift in meters
        for i = 1, mSideCount2, 1 do
            local mNewPosX2 = mPosX  - i * mVecDx
            local mNewPosZ2 = mPosZ  - i * mVecDz
            -- paint at the center
            setTerrainLayerAtWorldPos(mTerrainID, mLayerId, mNewPosX2, mPosY, mNewPosZ2, 128.0 )
        end
        -- goto next point
        mSplinePos = mSplinePos + mSplinePiecePoint
    end


end

local function runSplineFieldCreation ()
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
  local newGroup = createTransformGroup("delete-new-fields-data")
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
        -- Check if user wants to paint dirt or not and change from 1,2 to true,false
        if paintFieldDirt == 1 then
          -- Run the paint dirt within spline function
          runPaintFieldDirt(spline)
        end
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

        RDM_createField(fieldSpline, fields, centerX, centerZ, paintFieldDirt)

      end
    end
  end

  -- Remove the transport group used to generate the data
  delete(newGroup)

  print('========================================')

end

-- UI
local labelWidth = 240.0

local boolean = {"true","false"}

local frameSizer = UIRowLayoutSizer.new()
local myFrame = UIWindow.new(frameSizer, "FSG Spline to Field Creation")

local borderSizer = UIRowLayoutSizer.new()
UIPanel.new(frameSizer, borderSizer)

local rowSizer = UIRowLayoutSizer.new()
UIPanel.new(borderSizer, rowSizer, -1, -1, -1, -1, BorderDirection.ALL, 10, 1)

local objectDistanceSliderSizer = UIColumnLayoutSizer.new()
UIPanel.new(rowSizer, objectDistanceSliderSizer, -1, -1, -1, -1, BorderDirection.BOTTOM, 10)
UILabel.new(objectDistanceSliderSizer, "Spline Point Sepeartion - Meters", TextAlignment.LEFT, -1, -1, labelWidth);
local objectDistanceSlider = UIIntSlider.new(objectDistanceSliderSizer, objectDistance, 0, 255 );
objectDistanceSlider:setOnChangeCallback(setObjectDistance)

local horizontalChoicePanelSizer = UIColumnLayoutSizer.new()
local horizontalChoicePanel      = UIPanel.new(rowSizer, horizontalChoicePanelSizer, -1, -1, -1, -1, BorderDirection.BOTTOM, 10)
local horizontalChoiceLabel      = UILabel.new(horizontalChoicePanelSizer, "Paint Dirt on Field:", TextAlignment.LEFT, -1, -1, 240, -1)
-- load item number 2 from 'boolean' array // which is false
local horizontalChoice           = UIChoice.new(horizontalChoicePanelSizer, boolean, 1, -1, 100, -1)
horizontalChoice:setOnChangeCallback(setPaintFieldDirt)

local mLayerIdSliderSizer = UIColumnLayoutSizer.new()
UIPanel.new(rowSizer, mLayerIdSliderSizer, -1, -1, -1, -1, BorderDirection.BOTTOM, 10)
UILabel.new(mLayerIdSliderSizer, "Paint Field Layer Id", TextAlignment.LEFT, -1, -1, labelWidth);
local mLayerIdSlider = UIIntSlider.new(mLayerIdSliderSizer, mLayerId, 0, 255 );
mLayerIdSlider:setOnChangeCallback(setLayerId)

local mSideCountSliderSizer = UIColumnLayoutSizer.new()
UIPanel.new(rowSizer, mSideCountSliderSizer, -1, -1, -1, -1, BorderDirection.BOTTOM, 10)
UILabel.new(mSideCountSliderSizer, "Paint Width in Meters 1", TextAlignment.LEFT, -1, -1, labelWidth);
local mSideCountSlider = UIIntSlider.new(mSideCountSliderSizer, mSideCount, 0, 255 );
mSideCountSlider:setOnChangeCallback(setSideCount)

local mSideCount2SliderSizer = UIColumnLayoutSizer.new()
UIPanel.new(rowSizer, mSideCount2SliderSizer, -1, -1, -1, -1, BorderDirection.BOTTOM, 10)
UILabel.new(mSideCount2SliderSizer, "Paint Width in Meters 2", TextAlignment.LEFT, -1, -1, labelWidth);
local mSideCount2Slider = UIIntSlider.new(mSideCount2SliderSizer, mSideCount2, 0, 255 );
mSideCount2Slider:setOnChangeCallback(setSideCount2)

UIButton.new(rowSizer, "Create Fields", runSplineFieldCreation)

myFrame:showWindow()