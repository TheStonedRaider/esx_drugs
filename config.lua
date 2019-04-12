Config 						= {} 
Config.Locale 				= 'en'

Config.RequiredCopsProcess 	= 2
Config.RequiredCopsSell 	= 2

Config.LicenseEnable 		= false -- enable processing licenses? Requires esx_license
Config.GiveBlack 			= true -- give black money? if disabled it'll give regular cash.
Config.ShowBlips 			= false

Config.Delays = { 
	-- in seconds
	WeedPickUp 		= 2, 
	WeedProcessing 	= 10,
	CokePickUp 		= 2,
	CokeProcessing 	= 10
}

Config.LicensePrices = {
	weed_processing = {label = _U('license_weed'), price = 10000},
	coke_processing = {label = _U('license_coke'), price = 15000},
}

Config.DrugDealers = {

	WeedDealer = {
		items = {
			marijuana = 2000,
		},
		coords = vector3(-1172.02, -1571.98, 4.66),
		name = 'Weed Dealer'
	},

	--[[CokeDealer = {
		items = {
			cokebag = 4000,
		},
		coords = vector3(-1172.02, -1571.98, 4.66),
		name = 'Coke Dealer'
	}]]
}

Config.CircleZones = {
	WeedField = {
		coords = vector3(310.91, 4290.87, 45.15), 
		name = _U('blip_weedfield'), 
		color = 25, 
		sprite = 496, 
		radius = 100.0
	},
	WeedProcessing = {
		coords = vector3(2329.02, 2571.29, 46.68), 
		name = _U('blip_weedprocessing'), 
		color = 25, 
		sprite = 496, 
		radius = 100.0
	},
	CokeField = {
		coords = vector3(3345.95, 5505.87, 29.15), 
		name = _U('blip_cokefield'), 
		color = 4, 
		sprite = 501, 
		radius = 100.0
	},
	CokeProcessing = {
		coords = vector3(-618.02, -1628.29, 32.18), 
		name = _U('blip_cokeprocessing'), 
		color = 4, 
		sprite = 501, 
		radius = 100.0
	},
}

