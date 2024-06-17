-- Hide: no-- Author:LS-Modcompany/kevink98
-- Name: FSG CL - FieldDimensions with bitmap
-- Description:You can draw the filed on a bitmap (*.grle). The script create automaticly fielddimensions.
-- Icon:
-- Hide: no

-- Set filename to a bitmap file (*.grle)
local filename = "C:/Users/davar/OneDriveEw/Documents/My Games/FarmingSimulator2022/mods/courtrightLineMap/FS22_Courtright_Line_150x/map/data/grleGDM/infoLayer_fieldDimensions.grle";
--Set bits of bitmap (normaly 8 bits)
local bits = 8;
--Set size of map (normaly 1024)
local size = 2048;
--Set factor for bigger grle's
local factor = 4;

--HELPS

--szie:
--1x Map : 1024
--4x Map : 2048

-- factor:
-- use 1x Map and grle size 1024x1024 : 1
-- use 1x Map and grle size 2048x2048 : 2
-- use 4x Map and grle size 2048x2048 : 1
-- use 4x Map and grle size 4096x4096 : 2


-- NO CHANGES HERE --
local map = createBitVectorMap("FieldDefs");
local success = loadBitVectorMapFromFile(map, filename, bits);
if not success then
    print("Can't load file!");
    return;
end;
local localMapWidth, localMapHeight = getBitVectorMapSize(map);

local foundFields = {};
local sceneRoot = getChildAt(getRootNode(), 0);
local terrainNode = getChild(sceneRoot, "terrain");
for y = localMapHeight-1, 0, -1 do
    local lastValue = -1;
    for x = 0, localMapWidth - 1 do
        local value = getBitVectorMapPoint(map, x, y, 0, bits);
        if value > 0 then
            if foundFields[value] == nil then
                foundFields[value] = {};
                foundFields[value].lines = {};
            end;
            
            if foundFields[value].lines[y] == nil then
                foundFields[value].lines[y] = {};
            end;
                            
            if lastValue == -1 then
                local newLine = {};
                newLine.y = y / factor;
                newLine.start_x = x / factor;
                newLine.end_x = -1;
                table.insert(foundFields[value].lines[y], newLine);
                lastValue = value;
            end;
        elseif lastValue > -1 then
            local lastlineIndex = nil;
            for k,line in pairs(foundFields[lastValue].lines[y]) do
                if line.end_x == -1 then
                    lastlineIndex = k;
                    break;
                end;
            end;
            
            if lastlineIndex ~= nil then    
                foundFields[lastValue].lines[y][lastlineIndex].end_x = (x / factor) - 1 ;
                lastValue = -1;
            end;       
        end;
    end;
end ;

local node = getSelection(0);
if node == 0 or getUserAttribute(node, "onCreate") ~= "FieldUtil.onCreate" then
    print("Error: Please select FieldDefinition defintions root!");
    return;
end;

local function FormatNumber(idx)
    if idx < 10 then
        return string.format("00%s", idx);
    elseif idx < 100 then
        return string.format("0%s", idx);
    else
        return idx;
    end;
end;

for v, data in pairs(foundFields) do
    local fieldTg = createTransformGroup(string.format("field%s", FormatNumber(v)));
    local fieldDimensions = createTransformGroup("fieldDimensions");
    local fieldMapIndicator = createTransformGroup("fieldMapIndicator");
    link(fieldTg, fieldDimensions);
    link(fieldTg, fieldMapIndicator);
    local cornerIdx = 1;
    
    local s = size + 1;
    local min_x = s;
    local max_x = -s;
    local min_y = s;
    local max_y = -s;

    for y = 0, localMapHeight-1 do
        if data.lines[y] ~= nil then
            for _,line in pairs(data.lines[y]) do

                local c1 = createTransformGroup(string.format("corner%s_1", FormatNumber(cornerIdx)));
                local c2 = createTransformGroup(string.format("corner%s_2", FormatNumber(cornerIdx)));
                local c3 = createTransformGroup(string.format("corner%s_3", FormatNumber(cornerIdx)));
                link(c1, c2);
                link(c1, c3);

                local s_x = line.start_x*2 - size;
                local s_z = line.y*2 - size;
                local w = (line.end_x - line.start_x) * 2 + 2;

                if s_x < min_x then
                    min_x = s_x;
                end;
                if s_x + w > max_x then
                    max_x = s_x + w;
                end;
                if s_z < min_y then
                    min_y = s_z;
                end;
                if s_z > max_y then
                    max_y = s_z;
                end;
                
                setTranslation(c1, s_x, getTerrainHeightAtWorldPos(terrainNode, s_x, 0, s_z),s_z);
                setTranslation(c2, 0,0,2);
                setTranslation(c3, w, 0,2);
                
                link(fieldDimensions, c1);
                cornerIdx = cornerIdx + 1;
            end;
        end;
    end;
    local ind_x = min_x + (max_x - min_x) / 2;
    local ind_y = min_y + (max_y - min_y) / 2;
    setTranslation(fieldMapIndicator, ind_x, getTerrainHeightAtWorldPos(terrainNode, ind_x, 0, ind_y), ind_y);
    
    setUserAttribute(fieldTg, "fieldAngle", "Integer", 90);
    setUserAttribute(fieldTg, "fieldDimensionIndex", "Integer", 0);
    setUserAttribute(fieldTg, "nameIndicatorIndex", "Integer", 1);
    link(node, fieldTg);
end;