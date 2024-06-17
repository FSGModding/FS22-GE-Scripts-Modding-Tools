-- Author:Stefan Geiger
-- Name:toggleRenderLevelAreas
-- Description:Toggles the visualization of the level areas
-- Icon:
-- Hide: no

function toggleRenderLevelAreas_drawCallback()
    local rootNode = g_renderLevelAreasDrawDefinition
    local levelAreasNode = getChild(rootNode, "levelAreas")
    if levelAreasNode == 0 then
      print("Make sure to select the root node at the stop of the scenegraph")
      removeDrawListener(g_renderLevelAreasDrawCallback)
      g_renderLevelAreasDrawCallback = nil
      g_renderLevelAreasDrawDefinition = nil
      return
    end
    if levelAreasNode ~= nil then
        local nums = getNumOfChildren(levelAreasNode)
        for i=0, nums-1 do
            local r, g, b, a = 1, 0, 0, 0.1

            if levelAreasNode ~= 0 then
                local numDimensions = getNumOfChildren(levelAreasNode)
                for d=0, numDimensions-1 do
                    local dimNode = getChildAt(levelAreasNode, d)
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

if g_renderLevelAreasDrawCallback ~= nil then
    removeDrawListener(g_renderLevelAreasDrawCallback)
    g_renderLevelAreasDrawCallback = nil
    g_renderLevelAreasDrawDefinition = nil
else
    print("FSG Draw Level Area")
    local node = getSelection(0)
    if node == 0 then
        print("Error: Please select the root transport group of the placeable that contains levelAreas!")
        return
    end
    g_renderLevelAreasDrawDefinition = node
    g_renderLevelAreasDrawCallback = addDrawListener("toggleRenderLevelAreas_drawCallback")
end
