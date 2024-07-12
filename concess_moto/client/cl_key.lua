CreateThread(function()
    while GetResourceState('ox_inventory') ~= 'started' do
        Wait(200)
    end
    local Inventory = exports.ox_inventory
    Inventory:displayMetadata('plate', 'Plaque')
    Inventory:displayMetadata('model', 'Model')
    Citizen.Wait(500)
end)

CreateThread(function()
    while true do
        Wait(200)
		local ped = PlayerPedId()
		local vehicle = GetVehiclePedIsIn(ped, false)
		local engineStatus
		
		if IsPedGettingIntoAVehicle(ped) then
			engineStatus = (GetIsVehicleEngineRunning(vehicle))
			if not (engineStatus) then 
				SetVehicleEngineOn(vehicle, false, true, true)
				DisableControlAction(2, 71, true)
			end
		end
		
		if IsPedInAnyVehicle(ped, false) and not IsEntityDead(ped) and (not GetIsVehicleEngineRunning(vehicle)) then
			DisableControlAction(2, 71, true)
		end
		
		if IsPedInAnyVehicle(ped, false) and IsControlPressed(2, 75) and not IsEntityDead(ped) then
			if (GetIsVehicleEngineRunning(vehicle)) then
				Wait(150)
				SetVehicleEngineOn(vehicle, true, true, false)
				TaskLeaveVehicle(ped, vehicle, 0)
			else
				TaskLeaveVehicle(ped, vehicle, 0)
			end
		end
    end
end)


CreateThread(function()
    while GetResourceState('ox_target') ~= 'started' do
        Wait(100)
    end

    local pedHash = GetHashKey(Config.KeyShop.Ped.Model)

    RequestModel(pedHash)                      
    while not HasModelLoaded(pedHash) do Wait(1) end

    local ped = CreatePed(4, pedHash, Config.KeyShop.Ped.Position, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    exports.ox_target:addModel(Config.KeyShop.Ped.Model, {
        {
            icon = 'fas fa-key',
            label = 'Ouvrir le magasin de clés',
            onSelect = function()
				OpenKeyShop()
			end,
        }
    })
end)

CreateThread(function()
    local blip = AddBlipForCoord(Config.KeyShop.Ped.Position)
    SetBlipSprite(blip, 187)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Magasin de clés')
    EndTextCommandSetBlipName(blip)
end)

AddEventHandler('carkeys:client:useKey', function(data)
    local plate = data.metadata.plate
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped)
    local engineStatus = GetIsVehicleEngineRunning(veh)

    while #plate < 8 do
        plate = plate .. ' '
    end

    local vehicle = GetVehicleInDistanceByPlate(plate, Config.LockingRange)
    if vehicle and not IsPedInAnyVehicle(ped, false) then
        inVehicle = false
        ToggleVehicleLock(vehicle)
    elseif vehicle and IsPedInAnyVehicle(ped, false) and not engineStatus then
        SetVehicleEngineOn(vehicle, true, false, true)
        Notification('Moteur allumé')
    elseif vehicle and IsPedInAnyVehicle(ped, false) and engineStatus then
        SetVehicleEngineOn(vehicle, false, false, true)
        Notification('Moteur éteint')
    else
        Notification('Ce n\'est pas votre véhicule')
    end
end)

AddEventHandler('carkeys:context:Moto', function(data)
    lib.hideContext(false)
    lib.registerContext({
        id = 'carkeys_Moto_menu',
        title = 'Vous souhaitez acheter une clé pour votre véhicule?',
        options = {
            {
                title = "Oui",
                description = 'Prix de la clef : ' ..Config.KeyPrice,
                 arrow = true,
                icon = "fa-solid fa-circle-check",
                iconColor = 'A2FF62',
                event = 'carkeys:client:buyKey',
                args = {
                    plate = data.plate,
                    model = data.model
                }
            },
            {
                title = "Non",
                arrow = true,
                icon = "fa-solid fa-circle-xmark",
                iconColor = 'FF6F62',
                menu = 'carkeys_context_shop'
            }
        }
    })
    lib.showContext('carkeys_Moto_menu')
end)

AddEventHandler('carkeys:client:buyKey', function(data)
    TriggerServerEvent('carkeys:server:buyKey', data.plate, data.model)
end)

local function IsVehicleLocked(vehicle)
    local status = GetVehicleDoorLockStatus(vehicle)
    if status == 2 then 
        return true
    end
    return false 
end

local function LockStartAnim(ped, animDict, animLib, vehicle)
    TaskPlayAnim(ped, animDict, animLib, 15.0, -10.0, 1500, 49, 0, false, false, false)
    PlaySoundFromEntity(-1, "Remote_Control_Fob", ped, "PI_Menu_Sounds", 1, 0)
    
    SetVehicleLights(vehicle,2)
    Wait(200)

    SetVehicleLights(vehicle,1)
    Wait(200)

    SetVehicleLights(vehicle,2)        
    Wait(200)
end

local function LockEndAnim(vehicle)
    Wait(200)
    SetVehicleLights(vehicle,1)
    SetVehicleLights(vehicle,0)
    Wait(200)
end

local function GetVehiclesInArea(maxDistance)
    local vehicles = GetGamePool('CVehicle')

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    
    local nearbyVehicles = {}
    
    for k, entity in pairs(vehicles) do
        local distance = #(coords - GetEntityCoords(entity))

        if distance <= maxDistance then
            nearbyVehicles[#nearbyVehicles + 1] = entity
        end
    end

    return nearbyVehicles
end

function OpenKeyShop()
    local vehicles = lib.callback('carkeys:callback:getPlayerVehicles', nil)

    local options = {}

    for k, v in pairs(vehicles) do
        local model = GetLabelText(GetDisplayNameFromVehicleModel(v.model))
        options[v.plate] = {
            description = model,
            arrow = true,
            icon = "fa-solid fa-key",
            event = 'carkeys:context:Moto',
            args = {
                plate = v.plate,
                model = model
            },
            arrow = true
        }
    end

    lib.registerContext({
        id = 'carkeys_context_shop',
        filter = Config.FilterUse,
        title = 'Vous souhaitez acheter une clé pour votre véhicule?',
        options = options
    })
    lib.showContext('carkeys_context_shop')
    
end

function GetVehicleInDistanceByPlate(plate, maxDistance)
    local vehicles = GetVehiclesInArea(maxDistance)

    for k, vehicle in pairs(vehicles) do
        local vehiclePlate = GetVehicleNumberPlateText(vehicle)
        if vehiclePlate == plate then
            return vehicle
        end
    end

    return false
end

function ToggleVehicleLock(vehicle)
	local ped = PlayerPedId()
    local isCycle = GetVehicleClass(vehicle) == Config.CycleVehicleClass
    local locked = IsVehicleLocked(vehicle)
    local keyFob = nil

    if not isCycle then 
        local prop = GetHashKey('p_car_keys_01')
        local animDict = 'anim@mp_player_intmenu@key_fob@'
        local animLib = 'fob_click'
    
        RequestModel(prop)
        while not HasModelLoaded(prop) do Wait(1) end

        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do Wait(1) end
        
        keyFob = CreateObject(prop, 1.0, 1.0, 1.0, 1, 1, 0)
        AttachEntityToEntity(keyFob, ped, GetPedBoneIndex(ped, 57005), 0.09, 0.04, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
        
        LockStartAnim(ped, animDict, animLib, vehicle)
    end
        
	if locked then
		SetVehicleDoorsLocked(vehicle, 1)
        if not isCycle then
            PlayVehicleDoorOpenSound(vehicle, 0)
            PlaySoundFromEntity(-1, "Remote_Control_Open", car, "PI_Menu_Sounds", 1, 0)
        end
		Notification('Véhicule déverrouillé')
	elseif not locked then
		SetVehicleDoorsLocked(vehicle, 2)
        if not isCycle then
            PlayVehicleDoorCloseSound(vehicle, 0)
            PlaySoundFromEntity(-1, "Remote_Control_Close", car, "PI_Menu_Sounds", 1, 0)
        end
		Notification("Véhicule verrouillé")
	end

    if not isCycle then	
        LockEndAnim(vehicle)
        DeleteEntity(keyFob)
    end
end

Notification = function(message)
    ESX.ShowNotification(message)
end
