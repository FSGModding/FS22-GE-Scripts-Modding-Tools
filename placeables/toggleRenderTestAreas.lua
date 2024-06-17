-- Author:Stefan Geiger
-- Name:toggleRenderTestAreas
-- Description:Toggles the visualization of the level areas
-- Icon:
-- Hide: no

function toggleRenderTestAreas_drawCallback()
    local rootNode = g_renderTestAreasDrawDefinition
    local testAreasNode = getChild(rootNode, "testAreas")
    if testAreasNode == 0 then
      print("Make sure to select the root node at the stop of the scenegraph")
      removeDrawListener(g_renderTestAreasDrawCallback)
      g_renderTestAreasDrawCallback = nil
      g_renderTestAreasDrawDefinition = nil
      return
    end
    if testAreasNode ~= nil then
        local nums = getNumOfChildren(testAreasNode)
 
        for i=0, nums-1 do
            local r, g, b, a = 1, 0, 0, 0.1

            if testAreasNode ~= 0 then
                local numDimensions = getNumOfChildren(testAreasNode)
                for d=0, numDimensions-1 do
                    local dimNode = getChildAt(testAreasNode, d)
                    if getNumOfChildren(dimNode) >= 1 then
                        local dimNode1 = getChildAt(dimNode, 0)
                        local xb,yb,zb = getWorldTranslation(dimNode1)
                        local x1,y1,z1 = getWorldTranslation(dimNode) -- first
                        local x,y,z = xb, y1, z1 -- second x
                        local x2,y2,z2 = x1, y1, zb -- third z
                        local x3,y3,z3 = xb,y1,zb

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

if g_renderTestAreasDrawCallback ~= nil then
    removeDrawListener(g_renderTestAreasDrawCallback)
    g_renderTestAreasDrawCallback = nil
    g_renderTestAreasDrawDefinition = nil
else
    print("FSG Draw Test Area")
    local node = getSelection(0)
    if node == 0 then
        print("Error: Please select the root transport group of the placeable that contains testAreas!")
        return
    end
    g_renderTestAreasDrawDefinition = node
    g_renderTestAreasDrawCallback = addDrawListener("toggleRenderTestAreas_drawCallback")
end
