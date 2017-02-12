local chargers = {}
local timers = { ['recharge'] = {}, ['kombo'] = { ['up'] = {}, ['down'] = {} } }
local recharging = { ['step'] = { ['step2'] = {}, ['step3'] = {}, ['step4'] = {} } }
local dCold = { ['hitter'] = {}, ['range'] = {} }
local waterDeath = {}
local checkers = {}


function spawnCharger(player)
	if isElement(player) and getElementType(player) == "player" then 
		local accountName = getAccountName(getPlayerAccount(player))
		if (accountName) then 
			if isObjectInACLGroup("user."..accountName, aclGetGroup("Admin")) then 
				local x, y, z = getElementPosition(player)
				
				charger = createPed(35, x + 8, y + 1, z)
				table.insert(chargers, charger)
				exports['extra_health']:setElementExtraHealth(charger, 220)
				local cx, cy, _ = getElementPosition(charger)
				timers[charger] = setTimer(findEnemy, 100, 0, charger)
				setElementData(charger, "charging", "off")
				setElementData(charger, "punchs", "off")
				setElementData(charger, "type", "Charger")
				setPedWalkingStyle(charger, 60)
				dCold[charger] = createColCircle(cx, cy, 3)
				waterDeath[charger] = false
				attachElements(dCold[charger], charger)
				recharging[charger] = "Ready"
				triggerClientEvent("CHARGER", root, charger,  chargers)
				setPedGravity ( charger, 2 )
			end
		end
	end
end
addCommandHandler("ch", spawnCharger)

function getPointFromDistanceRotation(x, y, dist, angle) 
    angle = math.rad(90 - angle); 
    local dx = math.cos(angle) * dist; 
    local dy = math.sin(angle) * dist; 
    return x+dx, y+dy; 
end 
  
-- dist = distance 

addEventHandler("onResourceStop", root, 
	function()
		for i, v in ipairs(getElementsByType("player")) do
			setElementData(v, "seguido", false)
		end
	end 
)


function findEnemy(ped)
	if isElement(ped) then 	
		
		local x, y, z = getElementPosition(ped)
		local player = NearPlatyer(x, y, z)
		if player then 
			local px, py, pz = getElementPosition(player)
			if getDistanceBetweenPoints3D(px, py, pz, x, y, z) > 60 or isPedDead(player) then 
				if getTarget(ped) then 
					setElementData(ped, "ta", false)
					checkers[player] = "libre"
					setElementData(player, "seguido", false)
				end
			end
			if getDistanceBetweenPoints3D(x, y, z, px, py, pz) < 20  and checkers[player] ~= "seguido" and not getElementData(ped, "ta") and not isPedDead(player)  then
				setElementData(ped, "ta", player)
				checkers[player] = "seguido"
				setElementData(player, "seguido", true)
				triggerClientEvent("pedRot", ped)
			end
			if getDistanceBetweenPoints2D(x, y, px, py) > 20 and isElement(ped) and recharging[ped] == "Ready" and getTarget(ped) and getElementData(ped, "charging") == "off" and not isElementInWater(ped) then 
				local x, y, z = getElementPosition(ped)
				dCold['range'][ped] = createColSphere(x,y,z, 1.2)
				attachElements(dCold['range'][ped], ped,0,0.7,0)
				setElementData(ped, "charging", "on")
				recharging[ped] = "Pause"
				setTimer(function() recharging[ped] = "Ready" end, 15000, 1)
					recharging['step']['step4'][ped] = setTimer( 
						function()
							if isPedOnGround(ped) and isPedOnGround(player) then
								if not isElementAttached(getTarget(ped)) then 
									setElementData(ped, "charging", "off")
								else 
									stepping(ped)
									triggerClientEvent(getTarget(ped), "recreate", getTarget(ped), ped)
									
								end
								if isElement(dCold['range'][ped]) then destroyElement(dCold['range'][ped]) end
							end
						end, 2800, 1
					)
				triggerClientEvent("Chaaarrrr", ped, ped)
				
			end
			if isElementInWater(ped) then 
				
				setElementData(ped, "charging", "off")
				if isElementAttached(getTarget(ped)) then 
					if isElement(dCold['range'][ped]) then destroyElement(dCold['range'][ped]) end
					if not waterDeath[ped] then 
						detachElements(getTarget(ped), ped)
						local model = getElementModel(getTarget(ped))
						setElementModel(getTarget(ped), 0)
						setElementModel(getTarget(ped), model)
						waterDeath[ped] = true 
					end
					killPed(ped)
				end
			end
		end
	end
end

addCommandHandler("kile", function(p)
	killPed(charger, p)
end)

addEventHandler("onColShapeHit", root, 
	function(hit)
		if getElementType(hit) == "player" then 
			for i, val in ipairs(chargers) do 
				if source == dCold[val] and exports.bone_attach:isElementAttachedToBone(getTarget(val)) then 
					if not dCold['hitter'][hit] then
						local aPosX, aPosY, aPosZ = getElementPosition(val) 
						local sPosX, sPosY, sPosZ = getElementPosition(hit) 
						local angle = math.atan2(aPosX - sPosX, aPosY - sPosY) - math.rad(90) 
						local vx, vy, vz = getElementVelocity(hit)
						setElementVelocity(hit, vx, vy, vz + 0.5)
						setTimer(setElementVelocity, 50, 1,hit, vx + 0.3*-math.cos(angle),vy +0.3*math.sin(angle), vz+0.1)
					
						outputChatBox("holap")
						dCold['hitter'][hit] = true 
						setTimer(function() dCold['hitter'][hit] = false end, 3000, 1)
					end
				elseif source == dCold['range'][val] and getElementData(val, "charging") == "on" then 
					if not recharging['step'][val] then
						setElementCollisionsEnabled(hit, false)
						attachElements(hit, val, 0, 0.5, 0, 0, 180, 0)
						setPedAnimation(hit, "ped", "FALL_fall", 1)
						recharging['step'][val] = true
						setElementData(hit, "trap", "on")
						recharging['step']['step3'][val] = true
					end
				end
			end
		end
	end 
)
		
addEvent("pedChockingWithObstacle", true)
addEventHandler("pedChockingWithObstacle", root, 
	function(pd)
		if isElementAttached(getTarget(pd))  then
			stepping(pd)
			triggerClientEvent(getTarget(pd), "recreate", getTarget(pd), pd, getTarget(pd))
		end
		setElementData(pd, "charging", "off")
		setPedAnimation(pd, "ped", "HIT_Front")
		setTimer(setPedAnimation, 600, 1, pd)
		if isElement(dCold['range'][ped]) then destroyElement(dCold['range'][ped]) end
	end
)

addCommandHandler("tc", function(p)
	local x, y, z = getElementPosition(p)
	local sp = createColSphere(x,y,z, 0.9)
	attachElements(sp, p,0,0.7,0)
end)

addCommandHandler("cped", function(p)
local rx, ry, rz = getElementPosition(p)
createPed(1, rx, ry, rz)
end)

function stepping(ped)
	if not recharging['step']['step2'][ped] and isElement(ped) then
		if isElementAttached(getTarget(ped)) and getElementData(ped, "punchs") == "off" and getElementData(getTarget(ped), "trap") == "on"  then 
			if isTimer(recharging['step']['step3'][ped]) then killTimer(recharging['step']['step3'][ped] ) end
			setTimer(function()
				local x, y, z = getElementPosition(getTarget(ped))
				triggerClientEvent("createRedLight", ped)
			end, 1500, 1)
			
			setElementData(ped, "punchs", "on")
			
			setElementData(ped, "charging", "off")
			setPedAnimation(getTarget(ped), "ped", "KO_skid_front", 1, false, false)
			setPedAnimation(ped, "ped", "HIT_Front", 1, false, false)
			
			timers['kombo']['up'][getTarget(ped)] = setTimer( function() 
				setPedAnimation( ped, "BSKTBALL", "BBALL_react_miss", 1, false, true)
				exports.bone_attach:attachElementToBone(getTarget(ped), ped, 12, 0, 0, 0)
			end, 1200,0)
			timers['kombo']['down'][getTarget(ped)] = setTimer(
				function()
					exports.bone_attach:detachElementFromBone(getTarget(ped)) 
					setPedAnimation(getTarget(ped), "ped", "KO_skid_front", 1, false, false)
					setElementHealth(getTarget(ped), getElementHealth(getTarget(ped)) - 10)
					local x, y, z = getElementPosition(ped)
					triggerClientEvent("pummelSound", getRootElement(), ped, x, y, z)
					if getElementHealth(getTarget(ped)) < 15 then 
						killPed(getTarget(ped), ped)
						if isTimer(timers['kombo']['up'][getTarget(ped)]) then killTimer(timers['kombo']['up'][getTarget(ped)]) end
						if isTimer(timers['kombo']['down'][getTarget(ped)]) then killTimer(timers['kombo']['down'][getTarget(ped)]) end

					end
				end, 1300,0
			)
			recharging['step']['step2'][ped] = true
			setElementData(ped, "balancing", true)
			setTimer( function() if recharging['step']['step2'][ped] == true then recharging['step']['step2'][ped] = false end end, 20000, 1)
		else 
			setElementData(ped, "charging", "off")
			setElementData(ped, "punchs", "off")
		end
	end
end

addEvent("playerWinBalance", true)
addEventHandler("playerWinBalance", root, 
	function(element)	
		
		recharging['step'][element] = false 
		setElementData(getTarget(element), "trap", "off")
		setElementPosition(getTarget(element), getElementPosition(element))
		detach(element)
	end
)

addEvent("chargerFall", true)
addEventHandler("chargerFall", root,
function(l)
	reflectDamage(charger, l) 
	
end)

function reflectDamage(ped, damage)
	local model = getElementModel(getElementData(ped, "ta"))
	
	setPedAnimation(getElementData(ped, "ta"), "ped", "KO_skid_back")
	setTimer(setPedAnimation, 600, 1, getElementData(ped, "ta"))
	detachElements(getElementData(ped, "ta"), ped)
	setElementModel(getElementData(ped, "ta"), 0)
	setElementModel(getElementData(ped, "ta"), model)
end 


addEventHandler("onPlayerDamage", getRootElement(), 
	function(attacker, wep) 
		for a, b in ipairs(chargers) do
			if attacker and attacker == b and wep == 0 then
				setElementHealth(source, getElementHealth(source) - 10)
				
				triggerClientEvent("Punch!", attacker, source)
			end
		end
	end
) 

addCommandHandler("at", function(p)
	if isElementAttached(p) then 
		outputChatBox("lol")
	else 
		outputChatBox("bno")
	end
end)

addEventHandler("onPlayerWasted", root, 
	function( _, killer ) 
		for i, v in ipairs(chargers) do 
			if killer == v then 
				if getElementData(killer, "ta") == source then 
					setElementData(killer, "ta", false)
					setElementData(source, "seguido", false)
					checkers[source] = "libre"
				end 
				if getElementData(source, "trap") == "on" then
					setElementData(source, "trap", "off")
					triggerClientEvent(source, "onPlayerKillerByCharger", source, killer)
					if exports.bone_attach:isElementAttachedToBone(source) then exports.bone_attach:detachElementFromBone(source) end 
					if isElementAttached(source) then detachElements(source, killer) end
					if isTimer(timers['kombo']['up'][source]) then killTimer(timers['kombo']['up'][source]) end
					if isTimer(timers['kombo']['down'][source]) then killTimer(timers['kombo']['down'][source]) end
					if isTimer(timers['recharge'][killer]) then killTimer(timers['recharge'][killer]) end
					setElementData(killer, "punchs", "off")
					setElementData(killer, "charging", "off")
					setTimer(setPedAnimation, 1000, 1, killer)
					recharging['step'][killer] = false
				end
			end
		end
	end 
)

addCommandHandler("k", function(p)
	outputChatBox(getElementData(charger, "charging"))
	outputChatBox(getElementData(charger, "punchs"))
end)

addEventHandler("onPedWasted", root, 
	function(_, killer)
		if isElement(source) and getElementData(source, "type") == "Charger" then 
			if getElementData(source, "punchs") == "on" and not isElementInWater(source) then
				detach(source)
			end
			checkers[getTarget(source)] = "libre"
			setElementData(getTarget(source), "seguido", false)
			setElementData(source, "ta", false)
			
			local x, y, z = getElementPosition(source)
			triggerClientEvent("onChargerDeath", getRootElement(), source, x, y, z)
			if (getElementType(killer) == "player") then 
				local x, y, z = getElementPosition(source)
				exports['killmessages']:outputMessage( {getPlayerName(killer),{"padding",width=3},{"icon",id = getPedWeapon(killer) or 0},{"padding",width=3},{"color",r=255,g=220,b=30},"Charger"},getRootElement(),wr,wg,wb )
				exports['Level_System[CaoZ]']:givePlayerExp(killer, 250)
				exports['newammos']:dropBox(x, y, z)
			end
			for i, v in ipairs(chargers) do 
				if source == v then 
					table.remove(chargers, i)
				end
				setTimer(destroyElement, 10000, 1, source )
			end
			if isTimer(timers[source]) then killTimer(timers[source]) end
			destroyElement(dCold[source])
			timers[source] = nil
			waterDeath[source] = nil
		end
	end 
)

function detach(ped)
	if exports.bone_attach:isElementAttachedToBone(getTarget(ped)) then exports.bone_attach:detachElementFromBone(getTarget(ped)) end 
	if isElementAttached(getTarget(ped)) then detachElements(getTarget(ped), ped) end
	if isTimer(timers['kombo']['up'][getTarget(ped)]) then killTimer(timers['kombo']['up'][getTarget(ped)]) end
	if isTimer(timers['kombo']['down'][getTarget(ped)]) then killTimer(timers['kombo']['down'][getTarget(ped)]) end
	if isTimer(timers['recharge'][ped]) then killTimer(timers['recharge'][ped]) end
	if not isElementInWater(getTarget(ped)) then
		setPedAnimation(getTarget(ped), "ped", "getup", -1, false, true)
		setTimer(setPedAnimation, 2000, 1, getTarget(ped))
	end
	if getElementData(ped, "punchs") == "on" then setElementData(ped, "punchs", "off") end
	if getElementData(ped, "charging") == "on" then setElementData(ped, "charging", "off") end
	setCameraTarget(getTarget(ped))
end

function getTarget(ped)
	if isElement(ped) then 
		return getElementData(ped, "ta")
	end
end

function destroyPed(ped)
	if isTimer(timers[ped]) then 
		killTimer(timers[ped])
	end
	timers[ped] = nil 
	for i, v in ipairs(chargers) do 
		if ped == v then 
			table.remove(chargers, i)
		end
		killPed(ped)
	end
end

function NearPlatyer(x, y, z)
    local Nplayer = nil
    local Ndistance = nil
    for i, players in ipairs(getElementsByType("player")) do
        local px, py, pz = getElementPosition(players)
        local distance = getDistanceBetweenPoints3D(px, py, pz, x, y, z)
        if Nplayer == nil then
            Nplayer = players
            Ndistance = distance
        elseif distance < Ndistance then
            Ndistance = distance
            Nplayer = players
        end
    end
    if Nplayer == nil then
        return false
    else
        return Nplayer
    end
end