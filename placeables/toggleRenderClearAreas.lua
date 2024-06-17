-- Author:Stefan Geiger
-- Name:toggleRenderClearAreas
-- Description:Toggles the visualization of the clear areas
-- Icon:
-- Hide: no

function toggleRenderClearAreas_drawCallback()
    local rootNode = g_renderClearAreasDrawDefinition
    local clearAreasNode = getChild(rootNode, "clearAreas")
    if clearAreasNode == 0 then
      print("Make sure to select the root node at the stop of the scenegraph")
      removeDrawListener(g_renderClearAreasDrawCallback)
      g_renderClearAreasDrawCallback = nil
      g_renderClearAreasDrawDefinition = nil
      return
    end
    if clearAreasNode ~= nil then
        local nums = getNumOfChildren(clearAreasNode)
        for i=0, nums-1 do
            local r, g, b, a = 1, 1, 0, 0.1

            if clearAreasNode ~= 0 then
                local numDimensions = getNumOfChildren(clearAreasNode)
                for d=0, numDimensions-1 do
                    local dimNode = getChildAt(clearAreasNode, d)
                    if getNumOfChildren(dimNode) >= 2 then
                        local dimNode1 = getChildAt(dimNode, 0)
                        local dimNode2 = getChildAt(dimNode, 1)
                        local x,y,z = getWorldTranslation(dimNode2)
                        local x1,y1,z1 = getWorldTranslation(dimNode)
                        local x2,y2,z2 = getWorldTranslation(dimNode1)
                        local x3,y3,z3 = x+x2-x1, y, z+z2-z1

                        drawDebugTriangle(x,y,z, x1,y1,z1, x2,y2,z2, r,g,b,a, false)
                        drawDebugTriangle(x,y,z, x2,y2,z2, x3,y3,z3, r,g,b,a, false)

                        drawDebugTriangle(x,y,z, x2,y2,z2, x1,y1,z1, r,g,b,a, false)
                        drawDebugTriangle(x,y,z, x3,y3,z3, x2,y2,z2, r,g,b,a, false)
                    end
                end
            end
        end
    end
end

if g_renderClearAreasDrawCallback ~= nil then
    removeDrawListener(g_renderClearAreasDrawCallback)
    g_renderClearAreasDrawCallback = nil
    g_renderClearAreasDrawDefinition = nil
else
    print("FSG Draw Clear Area")
    local node = getSelection(0)
    if node == 0 then
        print("Error: Please select the root transport group of the placeable that contains clearClearAreas!")
        return
    end
    g_renderClearAreasDrawDefinition = node
    g_renderClearAreasDrawCallback = addDrawListener("toggleRenderClearAreas_drawCallback")
end
