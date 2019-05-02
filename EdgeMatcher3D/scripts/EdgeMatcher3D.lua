--[[----------------------------------------------------------------------------

  Application Name:
  EdgeMatcher3D

  Summary:
  Teaching shape of a ”template part” in heightmap and match identical objects
  with full rotation

  Description:
  This sample is using an edge-based shape locator for recognition of edge points
  above an edge strength threshold.

  How to Run:
  Starting this sample is possible either by running the app (F5) or
  debugging (F7+F10). Setting a breakpoint on the first row inside the 'main'
  function allows debugging step-by-step after the 'Engine.OnStarted' event.
  Results can be seen in the viewer on the DevicePage.
  Select Reflectance in the View: box at the top of the GUI and zoom in on the
  data for best experience.
  Restarting the Sample may be necessary to show results after loading the webpage.
  To run this Sample a device with SICK Algorithm API and AppEngine >= V2.5.0 is
  required. For example SIM4000 with latest firmware. Alternatively the Emulator
  in AppStudio 2.3 or higher can be used.

  More Information:
  Tutorial "Algorithms - Matching".

------------------------------------------------------------------------------]]

-- Create viewer
local v = View.create()
v:setID('viewer3D')

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
  Script.sleep(2000) -- for demonstration purpose only

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
