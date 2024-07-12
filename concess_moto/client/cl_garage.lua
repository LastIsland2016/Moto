ESX = exports['es_extended']:getSharedObject()
local Garage = Config.Garage
list_vehicles = {}
function GetVehicleSociety()
    lib.callback("Moto:concessmoto_VehiculeSociety",false, function(result)
        list_vehicles = result 
    end)
end

list_vehicles_dispo = {}

Citizen.CreateThread(function()
    pedHash = GetHashKey(Garage.Ped.model)

    RequestModel(pedHash)
    while not HasModelLoaded(pedHash) do Wait(1) end

    local ped = CreatePed(4,pedHash, Garage.Ped.position, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    exports.ox_target:addBoxZone({
        coords = Garage.Ped.position,
        icon = "fa-solid fa-warehouse",
        options = {
            {
            label = 'Ouvrir le Garage',
            event = 'OuvertureGarage'
            }
        }
    })
end)

AddEventHandler('OuvertureGarage', function()
   
    MenuGarage()
end)

function GetVehicleDispo()
    lib.callback('Moto:concessmoto_garage', false, function(result)
        list_vehicles_dispo = result
    end)
end 

--{"modTrimB":-1,"modFrame":-1,"modCustomTiresR":false,"paintType2":0,"modLightbar":-1,"modStruts":-1,"oilLevel":8,"plateIndex":1,"modHydraulics":false,"modTransmission":-1,"doors":[],"model":1179302752,"modSmokeEnabled":false,"modAirFilter":-1,"modRearBumper":-1,"modSideSkirt":-1,"modSteeringWheel":-1,"paintType1":0,"modFrontWheels":-1,"modGrille":-1,"wheelSize":0.0,"modTrunk":-1,"modOrnaments":-1,"modTank":-1,"modSubwoofer":-1,"neonEnabled":[false,false,false,false],"modSeats":-1,"wheelWidth":0.0,"modAPlate":-1,"modDoorSpeaker":-1,"modFrontBumper":-1,"modRoof":-1,"modVanityPlate":-1,"modArmor":-1,"modTrimA":-1,"modFender":-1,"dashboardColor":0,"modHorns":-1,"xenonColor":255,"bodyHealth":1000,"pearlescentColor":27,"modSpoilers":-1,"modExhaust":-1,"color2":34,"modArchCover":-1,"modDoorR":-1,"windows":[4,5],"modHood":-1,"modPlateHolder":-1,"modSuspension":-1,"modShifterLeavers":-1,"modTurbo":false,"windowTint":-1,"extras":[],"modSpeakers":-1,"interiorColor":0,"color1":[5,174,252],"modBackWheels":-1,"plate":"PQU 345 ","modBrakes":-1,"neonColor":[255,0,255],"modDashboard":-1,"tyreSmokeColor":[255,255,255],"dirtLevel":4,"modCustomTiresF":false,"wheels":1,"modHydrolic":-1,"fuelLevel":80,"driftTyres":false,"engineHealth":1000,"modAerials":-1,"modRoofLivery":-1,"tyres":[],"modEngineBlock":-1,"wheelColor":2,"tankHealth":1000,"modXenon":false,"bulletProofTyres":true,"modWindows":-1,"modDial":-1,"modNitrous":-1,"modEngine":-1,"modLivery":-1,"modRightFender":-1}

function MenuGarage()
    local option = {}    
    GetVehicleDispo()
    Wait(100)
        if #list_vehicles_dispo > 0 then 
            for k, v in pairs(list_vehicles_dispo) do
               -- print(json.decode(v.vehicle).bodyHealth/10)
                    print(v.label)
                    table.insert(option, {
                    title = v.label,
                    arrow = true,
                    description = 'Plaque : ' ..v.plate,
                    colorScheme = '#3BC9DB',
                    icon = "fa-solid fa-car-on",
                    iconColor = '#63EFFF',
                    metadata = {
                        {label = 'Etat du  véhicule ', value =  tonumber(json.decode(v.vehicle).bodyHealth/10).. '%', progress = tonumber(json.decode(v.vehicle).bodyHealth/10)},
                        {label = 'Essence ', value =   tonumber(json.decode(v.vehicle).fuelLevel).. '%', progress = tonumber(json.decode(v.vehicle).fuelLevel)},
                        {label = 'Etat moteur ', value =   tonumber(json.decode(v.vehicle).engineHealth/10).. '%', progress = tonumber(json.decode(v.vehicle).engineHealth/10)},
                    },
                    onSelect = function()
                        properties = v.vehicle
                        plate = v.plate
                        stored = v.stored
                        label = v.label
                        SpawnVehicle(properties, plate, stored, label)
                    end
            
                })
                lib.registerContext({
                    id = 'MenuGarage',
                    title = 'Garage Concessionnaire',
                    options = option
                })
                
                
            end 
            lib.showContext('MenuGarage')
    
        else 
            lib.notify({
                title = 'Garage',
                description = 'Vous n\'avez pas de véhicule dans le garage',
                type = 'error'
            })

            print('pas de veh')
        end 
        
       
    
end

function SpawnVehicle(properties, plate, stored, label)
    local SpawnVehiculeZone = Garage.VerifZoneSpawn
    if stored == 1 then
        if ESX.Game.IsSpawnPointClear(SpawnVehiculeZone, 5.0) then 
            ESX.Game.SpawnVehicle(json.decode(properties).model, Garage.SpawnVehicle.coords, Garage.SpawnVehicle.heading,function(vehicle)
                SetVehicleNumberPlateText(vehicle, plate)
                TriggerServerEvent('Moto:concessmoto_SaveSortie', plate)
                ESX.Game.SetVehicleProperties(vehicle, json.decode(properties))
                Wait(300)
                SetPedIntoVehicle(PlayerPedId(), vehicle, -1)

            end)
            lib.notify({
                title = 'Garage',
                description = 'Vous avez sorti votre vehicule : ' ..label,
                type = 'success'
            })
        else 
            lib.notify({
                title = 'Garage',
                description = 'Vous ne pouvez pas sortir votre véhicule car la sortie est bloquée.',
                type = 'error'
            })
        end 
    else 
        lib.notify({
            title = 'Garage',
            description = 'Ce véhicule est déjà sorti !',
            type = 'error'
        })
    end 
end 

function onEnterG(self)
    lib.showTextUI('Appuyez sur [E]', {
        borderRadius = 100,
        position = "center",

    })
end

function onExitG(self)
    lib.hideTextUI()
end 

function insideG(self)
    if IsControlJustReleased(1,51) then
        if IsPedInAnyVehicle(PlayerPedId()) then
            local VehUse = GetVehiclePedIsIn(PlayerPedId(), true)
            local Plate = GetVehicleNumberPlateText(VehUse)
           
            local PlateVeh = nil
            lib.callback("Moto:concessmoto_VehiculeSociety",false, function(result)
                
                    Wait(100)
                
                    if result == true then 
                        PlateVeh = Plate
                        print(PlateVeh)
                    else 
                        lib.notify({
                            title = 'Garage',
                            description = 'Ce véhicule n\'appartient pas à la société !',
                            type = 'error'
                        })
                        return
                    end 
                
            
                if PlateVeh == Plate then
                    local Pos = GetEntityCoords(VehUse)
                    local HeadingPos = GetEntityHeading(VehUse)
                    VehPos = vector4(Pos.x, Pos.y, Pos.z, HeadingPos)
                    TriggerServerEvent("Moto:concessmoto_SaveStatsEntrer", PlateVeh, 1, ESX.Game.GetVehicleProperties(VehUse))            
                    DeleteEntity(VehUse)
                    lib.notify({
                        id = 'notif_rentrer',
                        title = 'Garage Concessionnaire',
                        description = 'Vous venez de ranger votre véhicule !',
                        duration = 2500,
                        position = 'center-left',
                        type = 'success'
                    })

                else 
                    lib.notify({
                        id = 'notif_notsociety',
                        title = 'Garage Concessionnaire',
                        description = 'Ce véhicule n\'appartient pas à la société !',
                        duration = 2500,
                        position = 'center-left',
                        type = 'error',
                        icon = 'fa-solid fa-car',
                        iconColor = '#FFFFFF'
                    })
                end
            end, Plate)
        else 
            lib.notify({
                title = 'Livraison',
                description = 'Vous devez être dans un véhicule !',
                type = 'error',
                position = 'center-left'
            })
        end
    end
end 

Citizen.CreateThread(function()
    lib.zones.sphere({
        coords =  Config.Garage.StoredPosition,
        radius = 3, 
        onEnter = onEnterG,
        onExit = onExitG, 
        inside = insideG
    })
end)


