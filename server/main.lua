ESX = nil
local playersProcessing = {}
local copsConnected = 0

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_drugs:sellDrug')
AddEventHandler('esx_drugs:sellDrug', function(dealer, itemName, amount)

	CountCops()

	if copsConnected < Config.RequiredCopsSell then
		TriggerClientEvent('esx:showNotification', source, _U('act_imp_police') .. copsConnected .. '/' .. Config.RequiredCopsSell)
		return
	end

	local xPlayer = ESX.GetPlayerFromId(source)
	local price = Config.DrugDealers[dealer].items[itemName]
	local xItem = xPlayer.getInventoryItem(itemName)

	if not price then
		print(('esx_drugs: %s attempted to sell an invalid drug!'):format(xPlayer.identifier))
		return
	end

	if xItem.count < amount then
		TriggerClientEvent('esx:showNotification', source, _U('dealer_notenough'))
		return
	end

	price = ESX.Math.Round(price * amount)

	if Config.GiveBlack then
		xPlayer.addAccountMoney('black_money', price)
	else
		xPlayer.addMoney(price)
	end

	xPlayer.removeInventoryItem(xItem.name, amount)

	TriggerClientEvent('esx:showNotification', source, _U('dealer_sold', amount, xItem.label, ESX.Math.GroupDigits(price)))
end)

ESX.RegisterServerCallback('esx_drugs:buyLicense', function(source, cb, licenseName)
	local xPlayer = ESX.GetPlayerFromId(source)
	local license = Config.LicensePrices[licenseName]

	if license == nil then
		print(('esx_drugs: %s attempted to buy an invalid license!'):format(xPlayer.identifier))
		cb(false)
	end

	if xPlayer.getMoney() >= license.price then
		xPlayer.removeMoney(license.price)

		TriggerEvent('esx_license:addLicense', source, licenseName, function()
			cb(true)
		end)
	else
		cb(false)
	end
end)

RegisterServerEvent('esx_drugs:pickedUp')
AddEventHandler('esx_drugs:pickedUp', function(item)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xItem = xPlayer.getInventoryItem(item)
	xPlayer.addInventoryItem(xItem.name, 1)
end)

ESX.RegisterServerCallback('esx_drugs:canPickUp', function(source, cb, item)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xItem = xPlayer.getInventoryItem(item)

	if xItem.limit ~= -1 and xItem.count >= xItem.limit then
		cb(false)
	else
		cb(true)
	end
end)

RegisterServerEvent('esx_drugs:processDrug')
AddEventHandler('esx_drugs:processDrug', function(fromItem, toItem, delay)

	CountCops()

	if copsConnected < Config.RequiredCopsProcess then
		TriggerClientEvent('esx:showNotification', source, _U('act_imp_police') .. copsConnected .. '/' .. Config.RequiredCopsProcess)
		return
	end

	if not playersProcessing[source] then
		local _source = source

		playersProcessing[_source] = ESX.SetTimeout(delay, function()
			local xPlayer = ESX.GetPlayerFromId(_source)
			local xFromItem, xToItem = xPlayer.getInventoryItem(fromItem), xPlayer.getInventoryItem(toItem)

			if xToItem.limit ~= -1 and (xToItem.count + 1) >= xToItem.limit then
				TriggerClientEvent('esx:showNotification', _source, _U('weed_processingfull'))
			elseif xFromItem.count < 3 then
				TriggerClientEvent('esx:showNotification', _source, _U('weed_processingenough'))
			else
				xPlayer.removeInventoryItem(fromItem, 3)
				xPlayer.addInventoryItem(toItem, 1)

				TriggerClientEvent('esx:showNotification', _source, _U('weed_processed'))
			end

			playersProcessing[_source] = nil
		end)
	else
		print(('esx_drugs: %s attempted to exploit drug processing!'):format(GetPlayerIdentifiers(source)[1]))
	end
end)

function CancelProcessing(playerID)
	if playersProcessing[playerID] then
		ESX.ClearTimeout(playersProcessing[playerID])
		playersProcessing[playerID] = nil
	end
end

function CountCops()
	local xPlayers = ESX.GetPlayers()
	copsConnected = 0
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			copsConnected = copsConnected + 1
		end
	end
end

RegisterServerEvent('esx_drugs:cancelProcessing')
AddEventHandler('esx_drugs:cancelProcessing', function()
	CancelProcessing(source)
end)

AddEventHandler('esx:playerDropped', function(playerID, reason)
	CancelProcessing(playerID)
end)

RegisterServerEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(data)
	CancelProcessing(source)
end)
