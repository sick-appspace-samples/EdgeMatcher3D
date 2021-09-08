
-- Create viewer
local v = View.create('viewer3D1')

local DELAY = 2000 -- ms between each type for demonstration purpose

local red = View.ShapeDecoration.create()
red:setLineColor(255, 0, 0)

local blue = View.ShapeDecoration.create()
blue:setLineColor(0, 0, 255)
blue:setLineWidth(4)

--@handleOnStarted()
local function handleOnStarted()
  -- Load and prepare test images
  local teachImages = Object.load('resources/teachImages.json')
  local matchImages = Object.load('resources/matchImages.json')
  local teachHM = teachImages[1]
  local teachI = teachImages[2]
  local matchHM = matchImages[1]
  local matchI = matchImages[2]

  -- Create matcher and teach area
  local matcher = Image.Matching.EdgeMatcher3D.create()
  local teachBox =
    Shape3D.createBox(60, 80, 50, Transform.createTranslation3D(0, 80, 110))
  local teachRegion = teachBox:toPixelRegion(teachHM)

  -- Teach matcher
  matcher:setFindTiltHeight(true, true)
  matcher:setReferenceHeight(100)
  matcher:setEdgeThreshold(1.0)
  matcher:setBackgroundClutter(true)
  local teachPose = matcher:teach(teachHM, teachRegion)
  local modelContours = matcher:getModelContours()

  -- create fixture and append some shapes to show the functionality of the fixture
  local fixture = Image.Fixture3D.create()
  local inspectionRegion =
    Shape3D.createBox(40, 40, 20, Transform.createTranslation3D(30, 95, 127))
  fixture:appendShape('inspectionRegion', inspectionRegion)
  fixture:setReferencePose(teachPose)

  local teachModelContours = Shape3D.transform(modelContours, teachPose)

  -- Show teach geometry
  v:clear()
  local heightmapID = v:addHeightmap({teachHM, teachI}, {}, {'Reflectance'})
  v:addShape(teachBox, nil, nil, heightmapID)
  for _, contour in ipairs(teachModelContours) do
    v:addShape(contour, red, nil, heightmapID)
  end
  v:addShape(inspectionRegion, blue, nil, heightmapID)
  v:present()
  Script.sleep(DELAY) -- for demonstration purpose only

  -- Match
  local poses,
    _ = matcher:match(matchHM)
  local matchModelContours = Shape3D.transform(modelContours, poses[1])

  -- Display results
  v:clear()
  fixture:transform(poses[1])
  heightmapID = v:addHeightmap({matchHM, matchI}, {}, {'Reflectance'})
  v:addShape(fixture:getShape('inspectionRegion'), blue, nil, heightmapID)
  for _, contour in ipairs(matchModelContours) do
    v:addShape(contour, red, nil, heightmapID)
  end
  v:present()
  print('App finished.')
end
Script.register('Engine.OnStarted', handleOnStarted)
