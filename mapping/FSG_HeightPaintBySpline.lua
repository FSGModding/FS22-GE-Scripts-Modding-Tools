-- Author:FSG Modding - Giants Edit
-- Name:Paint and Set Height for Terrain By Spline
-- Description: First parameter is the detail layer id. Combined layers are in the range [numLayers, numLayers+numCombinedLayers). Second parameter is half the width in meters
-- Icon:iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAAA3NCSVQICAjb4U/gAAAACXBIWXMAAArwAAAK8AFCrDSYAAAAGUlEQVQokWNsrP/PQApgIkn1qIZRDUNKAwBM3gIfYwhd6QAAAABJRU5ErkJgggAAPll81QUDAoAAAAAATgAAAEQAOgBcAGMAbwBkAGUAXABsAHMAaQBtADIAMAAyADEAXABiAGkAbgBcAGQAYQB0AGEAXABtAGEAcABzAFwAdABlAHgAdAB1AHIAZQBzAAAAZQB1AHIAbwBwAGUAYQBuAAAAAACgEAAAAAAAAAAAAAAmWXTVNQQCgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANDKTaZpAQAAYP5Dw2kBAAAAAAAAAAAAAAAAAIAAAAAAAAAAAAAAAAACAAQAAAAAANAGmjz6fwAAAAAAAAAAAAAgAAAACIAAANDKTaZpAQAAAAAAAAAAAAABAAAAAAAAAC5ZbNW2BQKAbAAxAAAAAAAAAAAAEABPbmVEcml2ZQAAVAAJAAQA774AAAAAAAAAAC4AAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAE8AbgBlAEQAcgBpAHYAZQAAAE8AbgBlAEQAcgBpAHYAZQAAABgAAAB0AAAAAAAAAAAAFllk1S0GAoBDADoAXABVAHMAZQByAHMAXABmAGIAdQBzAHMAZQBcAEEAcABwAEQAYQB0AGEAXABSAG8AYQBtAGkAbgBnAFwATQBpAGMAcgBvAHMAbwBmAHQAXABXAGkAbgBkAG8AdwBzAFwAUgBlAGMAZQBuAHQAAAAAAAAAAAAeWRzVwgcCgGwAMQAAAAAAAAAAABAAT25lRHJpdmUAAFQACQAEAO++AAAAAAAAAAAuAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAABPAG4AZQBEAHIAaQB2AGUAAABPAG4AZQBEAHIAaQB2AGUAAAAYAAAAAAAEAAAAAAAAAAZZFNXyCAKA
-- Hide:no
source("editorUtils.lua");

 -- 80 is asphalt, 71 is grass, 82 is gravel
local mLayerId   = 40 -- should be int
local mSideCount = 4  -- should be int
local width = 4.0
local falloff = 20.0

local function setLayerId(value)
    mLayerId = value
end

local function setSideCount(value)
    mSideCount = value
end

local function setWidth(value)
    width = value
end

local function setFalloff(value)
    falloff = value
end

local function runTerrainBySpline()
    EditorUtils.paintTerrainBySpline(mLayerId, mSideCount);
    EditorUtils.setTerrainHeight( -0.1, width, falloff );
end

-- UI
local labelWidth = 120.0

local frameSizer = UIRowLayoutSizer.new()
local myFrame = UIWindow.new(frameSizer, "Paint and Set Height for Terrain By Spline")

local borderSizer = UIRowLayoutSizer.new()
UIPanel.new(frameSizer, borderSizer)

local rowSizer = UIRowLayoutSizer.new()
UIPanel.new(borderSizer, rowSizer, -1, -1, -1, -1, BorderDirection.ALL, 10, 1)

local mLayerIdSliderSizer = UIColumnLayoutSizer.new()
UIPanel.new(rowSizer, mLayerIdSliderSizer, -1, -1, -1, -1, BorderDirection.BOTTOM, 10)
UILabel.new(mLayerIdSliderSizer, "Layer Id", TextAlignment.LEFT, -1, -1, labelWidth);
local mLayerIdSlider = UIIntSlider.new(mLayerIdSliderSizer, mLayerId, 0, 255 );
mLayerIdSlider:setOnChangeCallback(setLayerId)

local mSideCountSliderSizer = UIColumnLayoutSizer.new()
UIPanel.new(rowSizer, mSideCountSliderSizer, -1, -1, -1, -1, BorderDirection.BOTTOM, 10)
UILabel.new(mSideCountSliderSizer, "Side Count", TextAlignment.LEFT, -1, -1, labelWidth)
local mSideCountSlider = UIIntSlider.new(mSideCountSliderSizer, mSideCount, 1, 10)
mSideCountSlider:setOnChangeCallback(setSideCount)

local widthSliderSizer = UIColumnLayoutSizer.new()
UIPanel.new(rowSizer, widthSliderSizer, -1, -1, -1, -1, BorderDirection.BOTTOM, 10)
UILabel.new(widthSliderSizer, "Width", TextAlignment.LEFT, -1, -1, labelWidth);
local widthSlider = UIFloatSlider.new(widthSliderSizer, width, 0.0, 10.0, 0.0, 10.0);
widthSlider:setOnChangeCallback(setWidth)

local falloffSliderSizer = UIColumnLayoutSizer.new()
UIPanel.new(rowSizer, falloffSliderSizer, -1, -1, -1, -1, BorderDirection.BOTTOM, 10)
UILabel.new(falloffSliderSizer, "Smoothing Distance", TextAlignment.LEFT, -1, -1, labelWidth)
local falloffSlider = UIFloatSlider.new(falloffSliderSizer, falloff, 0.0, 100.0, 0.0, 100.0)
falloffSlider:setOnChangeCallback(setFalloff)

UIButton.new(rowSizer, "Run Script", runTerrainBySpline)

myFrame:showWindow()


