-- Hide: no
-- Author: FSG Modding - DaVaR
-- Name: FSG Set Spline Speed Limit 55mph
-- Description: Adds speedlimit user atributes to spline
-- Icon:

-- Speed limit in kph
local setSpeed = 88 -- 88 = 55mph
local setSpeedScale = 1 -- 1 Default

-- Get selection
local sceneNodeID = getChildAt(getRootNode(), 0);
local terrainNodeID = getChild(sceneNodeID, "terrain")
local numItemsSelected = getNumSelected()
local currentNode = nil

-- Check if anything is selected
if numItemsSelected ~= nil and numItemsSelected > 0 then
  for selectCount = 0, numItemsSelected-1 do
    currentNode = getSelection(selectCount)
    print("INFO: Adding Speed Atribute to selected item.")
    setUserAttribute(currentNode, "maxSpeedScale", "Integer", setSpeedScale)
    setUserAttribute(currentNode, "speedLimit", "Integer", setSpeed)
  end
else
  print("ERROR: You must select a spline first, no node was selected!")
  return
end