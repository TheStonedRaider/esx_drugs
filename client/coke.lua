local spawnedcoke = 0
local cokePlants = {}
local isPickingUp, isProcessing = false, false


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		local coords = GetEntityCoords(PlayerPedId())

		if GetDistanceBetweenCoords(coords, Config.CircleZones.CokeField.coords, true) < 50 then
			SpawnCokePlants()
			Citizen.Wait(500)
		else
			Citizen.Wait(500)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)

		if GetDistanceBetweenCoords(coords, Config.CircleZones.CokeProcessing.coords, true) < 2 then
			if not isProcessing then
				ESX.ShowHelpNotification(_U('coke_processprompt'))
			end

			if IsControlJustReleased(0, Keys['E']) and not isProcessing then

				if Config.LicenseEnable then
					ESX.TriggerServerCallback('esx_license:checkLicense', function(hasProcessingLicense)
						if hasProcessingLicense then
							ProcessCoke()
						else
							OpenBuyLicenseMenu('coke_processing')
						end
					end, GetPlayerServerId(PlayerId()), 'coke_processing')
				else
					ProcessCoke()
				end

			end
		else
			Citizen.Wait(500)
		end
	end
end)

function ProcessCoke()
	isProcessing = true

	ESX.ShowNotification(_U('coke_processingstarted'))
	TriggerServerEvent('esx_drugs:processCoke')
	local timeLeft = Config.Delays.CokeProcessing / 1000
	local playerPed = PlayerPedId()

	while timeLeft > 0 do
		Citizen.Wait(1000)
		timeLeft = timeLeft - 1

		if GetDistanceBetweenCoords(GetEntityCoords(playerPed), Config.CircleZones.CokeProcessing.coords, false) > 4 then
			ESX.ShowNotification(_U('coke_processingtoofar'))
			TriggerServerEvent('esx_drugs:cancelProcessing')
			break
		end
	end

	isProcessing = false
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)
		local nearbyObject, nearbyID

		for i=1, #cokePlants, 1 do
			if GetDistanceBetweenCoords(coords, GetEntityCoords(cokePlants[i]), false) < 1 then
				nearbyObject, nearbyID = cokePlants[i], i
			end
		end

		if nearbyObject and IsPedOnFoot(playerPed) then

			if not isPickingUp then
				ESX.ShowHelpNotification(_U('coke_pickupprompt'))
			end

			if IsControlJustReleased(0, Keys['E']) and not isPickingUp then
				isPickingUp = true

				ESX.TriggerServerCallback('esx_drugs:canPickUp', function(canPickUp)

					if canPickUp then
						TaskStartScenarioInPlace(playerPed, 'world_human_gardener_plant', 0, false)

						Citizen.Wait(2000)
						ClearPedTasks(playerPed)
						Citizen.Wait(1500)
		
						ESX.Game.DeleteObject(nearbyObject)
		
						table.remove(cokePlants, nearbyID)
						spawnedcoke = spawnedcoke - 1
		
						TriggerServerEvent('esx_drugs:pickedUpCoke')
					else
						ESX.ShowNotification(_U('coke_inventoryfull'))
					end

					isPickingUp = false

				end, 'cannabis')
			end

		else
			Citizen.Wait(500)
		end

	end

end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for k, v in pairs(cokePlants) do
			ESX.Game.DeleteObject(v)
		end
	end
end)

function SpawnCokePlants()
	while spawnedcoke < 25 do
		Citizen.Wait(0)
		local cokeCoords = GenerateCokeCoords()

		ESX.Game.SpawnLocalObject('prop_bush_med_03', cokeCoords, function(obj)
--			PlaceObjectOnGroundProperly(obj)
			FreezeEntityPosition(obj, true)

			table.insert(cokePlants, obj)
			spawnedcoke = spawnedcoke + 1
		end)
	end
end

function ValidateCokeCoord(plantCoord)
	if spawnedcoke > 0 then
		local validate = true

		for k, v in pairs(cokePlants) do
			if GetDistanceBetweenCoords(plantCoord, GetEntityCoords(v), true) < 5 then
				validate = false
			end
		end

		if GetDistanceBetweenCoords(plantCoord, Config.CircleZones.CokeField.coords, false) > 50 then
			validate = false
		end

		return validate
	else
		return true
	end
end

function GenerateCokeCoords()
	while true do
		Citizen.Wait(1)

		local cokeCoordX, cokeCoordY

		math.randomseed(GetGameTimer())
		local modX = math.random(-90, 90)

		Citizen.Wait(100)

		math.randomseed(GetGameTimer())
		local modY = math.random(-90, 90)

		cokeCoordX = Config.CircleZones.CokeField.coords.x + modX
		cokeCoordY = Config.CircleZones.CokeField.coords.y + modY

		local coordZ = GetCoordZ(cokeCoordX, cokeCoordY) - 1
		local coord = vector3(cokeCoordX, cokeCoordY, coordZ) 

		if ValidateCokeCoord(coord) then
			return coord
		end
	end
end

function GetCoordZ(x, y)
	local groundCheckHeights = { 40.0, 41.0, 42.0, 43.0, 44.0, 45.0, 46.0, 47.0, 48.0, 49.0, 50.0 }

	for i, height in ipairs(groundCheckHeights) do
		local foundGround, z = GetGroundZFor_3dCoord(x, y, height)

		if foundGround then
			return z -1 
		end
	end

	return 43.0
end
