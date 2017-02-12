function startSkn()
	engineImportTXD(engineLoadTXD("model/fam1.txd", 35), 35)
	engineReplaceModel(engineLoadDFF("model/fam1.dff", 35), 35)
end                                          
addEventHandler("onClientResourceStart", resourceRoot, startSkn)

local bones = {
	{1},
	{2},
	{3},
	{4},
	{5},
	{6},
	{7},
	{8},
	{21},
	{22},
	{23},
	{24},
	{25},
	{26},
	{31},
	{32},
	{33},
	{34},
	{35},
	{36},
	{41},
	{42},
	{43},
	{44},
	{51},
	{52},
	{53},
	{54}
}


local lights = {}
local v_ObstaclesDetect = {}
local sounds = {}
local timers = { ['control'] = {}, ['normal'] = {}, ['render'] = {} }
local c_Colshapes = {}
local playList = 
{ 
	['spawn'] = { 'chargerbacteria.wav', 'chargerbacterias.wav'}, 
	['charge'] = {'charger_charge_01.wav', 'charger_charge_02.wav'}, 
	['punch'] = {'charger_punch1.wav', 'charger_punch2.wav', 'charger_punch3.wav', 'charger_punch4.wav'},
	['ambient'] = {'charger_spotprey_01.wav', 'charger_spotprey_02.wav', 'charger_spotprey_03.wav'},
	['pummel'] = {'charger_pummel01.wav', 'charger_pummel02.wav', 'charger_pummel04.wav'},
	['die'] = {'charger_die_01.wav', 'charger_die_02.wav', 'charger_die_03.wav'},
	['theme'] = {}
}

addEvent("CHARGER", true)
addEventHandler("CHARGER", root, 
	function(p, tabl)
		element = p
		tablek = tabl
		
		v_ObstaclesDetect[element] = setTimer(chargerJumpInObstacle, 1000, 0, element)
		if not getElementData(localPlayer, "seguido") then
			timers['control'][element] = setTimer(pedControls, 50, 0, element)
			setPedControlState( element, "forwards", true )
		end
		timers['normal'][element] = setTimer(charger_normalsounds, 15000, 0, element)
		local x, y, z = getElementPosition(element)
		playList['spawn'][element] = playSound3D("sounds/spawn/"..playList['spawn'][math.random(1, #playList['spawn'])], x, y, z, false)
		setSoundMaxDistance(playList['spawn'][element], 50)
	end 
)



addEvent("recreate", true)
addEventHandler("recreate", root, 
	function(ped)
		deps(element)
		playList['theme'][localPlayer] = playSound("sounds/theme.mp3", true)
	end 
)

addEvent("pedRot", true)
addEventHandler("pedRot", root, 
	function(player)
		pl = player
	end 
)



function pedControls(ped)
	if isElement(ped) then 
		if isElement(getElementData(ped, "ta")) and getElementData(ped, "charging") == "off" and getElementData(ped, "punchs") == "off"  then
			local x, y, z = getElementPosition(getElementData(ped, "ta"))
			local x1, y1, z1 = getElementPosition(ped)
			angle = ( 360 - math.deg ( math.atan2 ( ( x - x1 ), ( y - y1 ) ) ) ) % 360
			setElementRotation( ped, 0, 0, angle, "default", true)
			if getDistanceBetweenPoints3D(x1, y1, z1, x, y, z) > 85 then
				setPedControlState( ped, "forwards", false )
			elseif getDistanceBetweenPoints3D(x1, y1, z1, x ,y , z) < 80 then 
				setPedControlState( ped, "forwards", true )
			end
			if getDistanceBetweenPoints3D(x1, y1, z1, x, y, z) < 4 then 
				if getPedControlState(ped, "fire") then 
					setTimer(setPedControlState, 570, 1, ped, "fire", false)
				else 
					setTimer(setPedControlState, 570, 1, ped, "fire", true)
				end
			end	
		end
	end
end

addEvent("Chaaarrrr", true)
addEventHandler("Chaaarrrr", root, 
	function(elem)
		local x, y, z = getElementPosition(elem)
		playList['charge'][elem] = playSound3D("sounds/charge/"..playList['charge'][math.random(1, #playList['charge'])], x, y, z, false)
		setSoundMaxDistance(playList['charge'][elem], 80)
	end 
)

addEvent("Punch!", true)
addEventHandler("Punch!", root, 
	function(source)
		local x, y, z = getElementPosition(source)
		playList['punch'][source] = playSound3D("sounds/punch/"..playList['punch'][math.random(1, #playList['punch'])], x, y, z, false)
		setSoundMaxDistance(playList['punch'][source], 12)
	end 
)

function charger_normalsounds(ped)
	if isElement(ped) and getElementData(ped, "charging") == "off" or getElementData(ped, "punchs") == "off" then 
		local x, y, z = getElementPosition(ped)
		playList['ambient'][ped] = playSound3D("sounds/ambient/"..playList['ambient'][math.random(1, #playList['ambient'])], x, y, z, false)
		setSoundMaxDistance(playList['ambient'][ped], 50)
	end
end

local sx, sy = guiGetScreenSize()
local sourceX, sourceY = 1336, 768


function dxDrawLinedRectangle( x, y, width, height, color, _width, postGUI )
	local _width = _width or 1
	dxDrawLine ( x, y, x+width, y, color, _width, postGUI ) -- Top
	dxDrawLine ( x, y, x, y+height, color, _width, postGUI ) -- Left
	dxDrawLine ( x, y+height, x+width, y+height, color, _width, postGUI ) -- Bottom
	return dxDrawLine ( x+width, y, x+width, y+height, color, _width, postGUI ) -- Right
end



local B_player = 185
local B_charger = 185
local posX = 640
local posxd = 410
a = 220
posXx = 690


local Poss = {660, 630, 662, 570, 600, 640}
local gui_Elements = {}

addEventHandler("onClientResourceStart", resourceRoot, 
	function()
		gui_Elements[1] = guiCreateLabel ( sx*(560/sourceX), sy*(Poss[2]/sourceY), sx*(350/sourceX), sy*(30/sourceY), "¡Preciona B para escapar!", false)
		gui_Elements[2] = guiCreateStaticImage ( sx*(posXx/sourceX), sy*(Poss[3]/sourceY), sx*(B_charger/sourceX), sy*(28/sourceY), "images/gde.png", false)
		guiSetProperty(gui_Elements[2], "ImageColours", "tl:FF2D2C2C tr:FF2D2C2C bl:FF2D2C2C br:FF2D2C2C")  
		gui_Elements[3] = guiCreateStaticImage ( sx*(500/sourceX), sy*(Poss[3]/sourceY), sx*(B_player/sourceX), sy*(28/sourceY), "images/yde.png", false)
		guiSetProperty(gui_Elements[3], "ImageColours", "tl:FFFFDC00 tr:FFFFDC00 bl:FFFFDC00 br:FFFFDC00")  
		gui_Elements[4] =  guiCreateStaticImage ( sx*(posX/sourceX), sy*(Poss[6]/sourceY), sx*(73/sourceX), sy*(73/sourceY), "images/004gw.png", false)
		gui_Elements[5] = guiCreateStaticImage ( sx*(850/sourceX), sy*(Poss[5]/sourceY), sx*(130/sourceX), sy*(130/sourceY), "images/chager.png", false)
		gui_Elements[6] = guiCreateStaticImage ( sx*(357/sourceX), sy*(Poss[4]/sourceY), sx*(200/sourceX), sy*(200/sourceY), "images/b_press.png", false)
		for i = 1, #gui_Elements do 
			guiSetVisible(gui_Elements[i], false)
			destroyElement(gui_Elements[i])
		end
	end 
)


function chargerJumpInObstacle (ped) 
    
	if isElement(ped) then
		local t_PedPos = {getElementPosition(ped)}
		local bPathClear = true 
		local t_Matrix = getElementMatrix (ped) 
	  
		-- Calculate a position 1m ahead of ped 
		local int_RayX = t_Matrix[2][1] + t_Matrix[4][1] 
		local int_RayY = t_Matrix[2][2] + t_Matrix[4][2] 
		local int_RayZ = t_Matrix[2][3] + t_Matrix[4][3] 
	  
		-- We cast 10 rays 1m ahead of the ped 

			local intSourceX, intSourceY, intSourceZ = t_PedPos[1], t_PedPos[2], t_PedPos[3] 
	  
			-- The target position height is identical to the center of the ped (1m m above ground)  
			-- We lower this value by 0.5m to detect short obstacles 
			local intTargetX, intTargetY, intTargetZ = int_RayX, int_RayY, int_RayZ - 0.5 + 1*0.2
	  
			bPathClear = isLineOfSightClear (intSourceX, intSourceY, intSourceZ, intTargetX, intTargetY, intTargetZ, true, true, false, true) 
			dxDrawLine3D (intSourceX, intSourceY, intSourceZ, intTargetX, intTargetY, intTargetZ, bPathClear and tocolor(255,255,255,255) or tocolor(255,0,0,0)) 

	  
		if (not bPathClear) then 
			if (getElementData(ped, "charging") == "off") then
			   setPedControlState (ped, 'jump', true) 
			   setPedControlState (ped, 'jump', false) 
			   setPedControlState (ped, 'jump', true) 
			elseif (getElementData(ped, "charging") == "on") then 
				triggerServerEvent("pedChockingWithObstacle", getLocalPlayer(), ped)
				for i, v in ipairs(bones) do
					local bX, bY, bZ = getPedBonePosition(ped, unpack(v))
					fxAddPunchImpact( bX, bY, bZ, 0, 0, 0)
					fxAddPunchImpact( bX, bY+0.2, bZ, 0, 0, 0)
					fxAddPunchImpact( bX+0.2, bY, bZ, 0, 0, 0)
					fxAddPunchImpact( bX-0.2, bY, bZ, 0, 0, 0)
					fxAddPunchImpact( bX, bY+0.4, bZ, 0, 0, 0)
					fxAddPunchImpact( bX, bY-0.4, bZ, 0, 0, 0)
					fxAddPunchImpact( bX, bY-0.2, bZ, 0, 0, 0)
				end
			end
		else 
			setPedControlState (ped, 'jump', false) 
			
		end 
	end
end 

addEventHandler("onClientPedDamage", root, 	
	function(_, w, _, l)
		for i, v in ipairs(tablek) do
			if source == v then 
				if w == 54 then 
					cancelEvent()
					if isElementAttached(getElementData(source, "ta")) then 
						triggerServerEvent("chargerFall", getLocalPlayer(), l)
					end
				end
			end
		end
	end 
)
  



function deps(ped)
	if isElement(ped) and getElementData(ped, "punchs") == "on" then	
		gui_Elements[1] = guiCreateLabel ( sx*(560/sourceX), sy*(Poss[2]/sourceY), sx*(350/sourceX), sy*(30/sourceY), "¡Preciona B para escapar!", false)
		gui_Elements[2] = guiCreateStaticImage ( sx*(posXx/sourceX), sy*(Poss[3]/sourceY), sx*(B_charger/sourceX), sy*(28/sourceY), "images/gde.png", false)
		guiSetProperty(gui_Elements[2], "ImageColours", "tl:FF2D2C2C tr:FF2D2C2C bl:FF2D2C2C br:FF2D2C2C")  
		gui_Elements[3] = guiCreateStaticImage ( sx*(500/sourceX), sy*(Poss[3]/sourceY), sx*(B_player/sourceX), sy*(28/sourceY), "images/yde.png", false)
		guiSetProperty(gui_Elements[3], "ImageColours", "tl:FFFFDC00 tr:FFFFDC00 bl:FFFFDC00 br:FFFFDC00")  
		gui_Elements[4] =  guiCreateStaticImage ( sx*(posX/sourceX), sy*(Poss[6]/sourceY), sx*(73/sourceX), sy*(73/sourceY), "images/004gw.png", false)
		gui_Elements[5] = guiCreateStaticImage ( sx*(850/sourceX), sy*(Poss[5]/sourceY), sx*(130/sourceX), sy*(130/sourceY), "images/chager.png", false)
		gui_Elements[6] = guiCreateStaticImage ( sx*(357/sourceX), sy*(Poss[4]/sourceY), sx*(200/sourceX), sy*(200/sourceY), "images/b_press.png", false)
	
		
		for i, v in ipairs(bones) do
			local bX, bY, bZ = getPedBonePosition(ped, unpack(v))
			fxAddPunchImpact( bX, bY, bZ, 0, 0, 0)
			fxAddPunchImpact( bX, bY+0.2, bZ, 0, 0, 0)
			fxAddPunchImpact( bX+0.2, bY, bZ, 0, 0, 0)
			fxAddPunchImpact( bX-0.2, bY, bZ, 0, 0, 0)
			fxAddPunchImpact( bX, bY+0.4, bZ, 0, 0, 0)
			fxAddPunchImpact( bX, bY-0.4, bZ, 0, 0, 0)
			fxAddPunchImpact( bX, bY-0.2, bZ, 0, 0, 0)
		end
		setTimer(function()
		local x, y,z = getElementPosition(ped)
		local rx, ry, rz = getElementRotation(ped)
		local matrix = Matrix.create(x,y,z+1.8,rx,ry,rz-50)
		local ford = Matrix.getForward(matrix) * 3 
		pos = Matrix.getPosition(matrix) - ford
		setCameraMatrix( pos, x, y, z )
		timers['render'][ped] = setTimer(startcount, 450, 0, ped)
		end, 300, 1)
	end
end 









addEvent("createRedLight", true)
addEventHandler("createRedLight", root, 
	function()
		createRedLight(element)
	end 
)

function createRedLight(ped)
	if isElement(ped) then 
		local x, y, z = getElementPosition(ped)
		lights[ped] = exports.dynamic_lighting:createPointLight(x, y, z+0.2,255,0,0,1,3,true)
	end
end

addEvent("onChargerDeath", true)
addEventHandler("onChargerDeath", root,
	function(source, x, y, z)
		if isElement(lights[source]) then 
			exports.dynamic_lighting:destroyLight(lights[source]) 
		end
		if isTimer(timers['control'][source]) then killTimer(timers['control'][source]) end
		if isTimer(timers['normal'][source]) then killTimer(timers['normal'][source]) end
		if isTimer(v_ObstaclesDetect[source]) then killTimer(v_ObstaclesDetect[source]) end
		playList['die'][source] = playSound3D("sounds/die/"..playList['die'][math.random(1, #playList['die'])], x, y, z, false)
		setSoundMaxDistance(playList['die'][source], 35)
		stopSound(playList['theme'][localPlayer])
			for i = 1, #gui_Elements do 
				if isElement(gui_Elements[i]) then
					destroyElement(gui_Elements[i])
					if isTimer(timers['render'][source]) then killTimer(timers['render'][source]) end
				end
			end
	end 
)

addEvent("onPlayerKillerByCharger", true)
addEventHandler("onPlayerKillerByCharger", root, 
	function(ki)
		stopSound(playList['theme'][localPlayer])
		for i = 1, #gui_Elements do 
			destroyElement(gui_Elements[i])
			if isTimer(timers['render'][ki]) then killTimer(timers['render'][ki]) end
		end
	end 
)

addEvent("pummelSound", true)
addEventHandler("pummelSound", root, 
	function(ped, x, y, z)
		playList['pummel'][source] = playSound3D("sounds/pummel/"..playList['pummel'][math.random(1, #playList['pummel'])], x, y, z, false)
	end 
)



vel =.8

function sPeedUp()
	if tablek then 
		for i, val in ipairs(tablek) do
			if isElement(val) then
				if getElementData(val, "charging") == "on" then
					
					local x, y, z = getElementPosition(val)
					local prot = getPedRotation(val)
					local nx, ny = getPointFromDistanceRotation(x, y, vel, (prot)*-1)
					local clear = isLineOfSightClear( x, y, z, nx, ny, z, true, true, true, true, true, true, true)
					if clear == true then
						local lx, ly = getPointFromDistanceRotation(x, y, 1, (prot-8)*-1)
						local rx, ry = getPointFromDistanceRotation(x, y, 1, (prot+8)*-1)
						local clearl = isLineOfSightClear( x, y, z, lx, ly, z, true, true, true, true, true, true, true)
						local clearr = isLineOfSightClear( x, y, z, rx, ry, z, true, true, true, true, true, true, true)
						if clearl == true and clearr == true then


							local nz = getGroundPosition ( nx, ny, z+1 )
							if  getDistanceBetweenPoints3D( x, y, z, nx, ny, nz) < 2 then
								setElementPosition(val, nx, ny, nz+1, false)
							end
							
						end
					end
				end
			end
		end
	end
end
addEventHandler("onClientRender", root, sPeedUp)


function startcount(ped)
	if getElementData(ped, "punchs") == "on" then
		local x, y = guiGetPosition( gui_Elements[4], false )
		local x2, y2 = guiGetPosition( gui_Elements[2], false )
		local x3, y3 = guiGetPosition( gui_Elements[5], false )
		local w, h = guiGetSize( gui_Elements[3], false )
		local w2, h2 = guiGetSize( gui_Elements[2], false )
		guiSetPosition ( gui_Elements[4], x-7, y, false) 
		guiSetSize ( gui_Elements[3], w-7, h, false) 
		guiSetPosition( gui_Elements[2], x2-7, y2, false)
		guiSetSize ( gui_Elements[2], w2+7, h2, false)
		if x >= sx*(850/sourceX) then 
			triggerServerEvent("playerWinBalance", getLocalPlayer(), ped)
			stopSound(playList['theme'][localPlayer])
			
			for i = 1, #gui_Elements do 
				destroyElement(gui_Elements[i])
				if isTimer(timers['render'][ped]) then killTimer(timers['render'][ped]) end
			end
		end
	end
end

bindKey("B", "down", function()
	if isElement(element) and getElementData(element, "punchs") == "on" and isElement(gui_Elements[4]) == true and 
		isElement(gui_Elements[2]) and isElement(gui_Elements[3]) then
		local x, y = guiGetPosition( gui_Elements[4], false )
		local x2, y2 = guiGetPosition( gui_Elements[2], false )
		local w, h = guiGetSize( gui_Elements[3], false )
		local w2, h2 = guiGetSize( gui_Elements[2], false )
		guiSetPosition ( gui_Elements[4], x+6, y, false) 
		guiSetSize ( gui_Elements[3], w+6, h, false) 
		guiSetPosition( gui_Elements[2], x2+6, y2, false)
		guiSetSize ( gui_Elements[2], w2-6, h2, false) 
	end
end)

function getPointFromDistanceRotation(x, y, dist, angle)

    local a = math.rad(90 - angle);
 
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
 
    return x+dx, y+dy;
 
end
  
