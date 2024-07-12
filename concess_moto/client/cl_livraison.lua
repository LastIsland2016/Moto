
ESX = exports["es_extended"]:getSharedObject()
local TargetVehicle = nil
CanStartLivraisonMoto = true 
local model = nil
local modelToDelivery =nil

local info = {
    stockVeh = nil,
    modelVeh = nil, 
    priceVeh = nil
}

AddEventHandler('StartLivraisonMoto', function(stock, modela, price)
    info.stockVeh = stock
    info.modelVeh = modela
    info.priceVeh = price
    StartLivraisonMoto()
end)

function StartLivraisonMoto()
    if CanStartLivraisonMoto then 
        SpawnPedLivraison()
    else 
        lib.notify({
            title = 'Livraison',
            description = 'Livraison déjà en cours !',
            type = 'error',
            position = 'center-left'
        })
    end 
end 

function SpawnPedLivraison()
    StatutLivraison = 0
    CanStartLivraisonMoto = false
    local VehicleHash = GetHashKey("flatbed3")  
    local CarLivraison = GetHashKey(info.modelVeh)    

	RequestModel(VehicleHash)
	while not HasModelLoaded(VehicleHash) do
		Wait(1)
	end
    RequestModel(CarLivraison)
	while not HasModelLoaded(CarLivraison) do
		Wait(1)
	end
	RequestModel('s_m_m_highsec_01')
	while not HasModelLoaded('s_m_m_highsec_01') do
		Wait(1)
	end 
    
    VehiculeLivraison = CreateVehicle(VehicleHash, Config.Livraison.SpawnTruck, true, false)                    
    ClearAreaOfVehicles(GetEntityCoords(VehiculeLivraison), 5000, false, false, false, false, false);  
    SetVehicleOnGroundProperly(VehiculeLivraison)
	SetVehicleNumberPlateText(VehiculeLivraison, "Moto")
	SetEntityAsMissionEntity(VehiculeLivraison, true, true)
	SetVehicleEngineOn(VehiculeLivraison, true, true, false)
    SetVehicleDoorsLockedForAllPlayers(VehiculeLivraison, true)
    Wait(500)
    VehiculeToDelivery = CreateVehicle(CarLivraison, 0,0,0,0, true, false)   
    Wait(500) 
    SetVehicleNumberPlateText(VehiculeToDelivery, Config.Livraison.Plaque)
    AttachEntityToEntity(VehiculeToDelivery, VehiculeLivraison, 20, -1.2, -0.4, -0.7, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
    ------

    PedInVehicle = CreatePedInsideVehicle(VehiculeLivraison, 26, GetHashKey('s_m_m_highsec_01'), -1, true, false)    
    SetEntityInvincible(PedInVehicle, true)
    SetBlockingOfNonTemporaryEvents(PedInVehicle, 1)
    
    -------

    BlipVehiculeLivraison = AddBlipForEntity(VehiculeLivraison)     
    SetBlipSprite(BlipVehiculeLivraison, 477)                                                   	
    SetBlipFlashes(BlipVehiculeLivraison, true)  
    SetBlipColour(BlipVehiculeLivraison, 5)

    --------

    TaskVehicleDriveToCoord(PedInVehicle, VehiculeLivraison, Config.Livraison.LocationToDelivery, 0, GetEntityModel(VehiculeLivraison), 63, 2.0)	
    Wait(1000)
    lib.notify({
        id = 'LEC',
        title = 'Concessionnaire Moto',
        description = 'Le camion de livraison arrive bientôt !',
        duration = 6000,
        icon = Config.Livraison.EnCours.Icon,
        iconColor = Config.Livraison.EnCours.IconColor,
        position = Config.Livraison.EnCours.Position,
        style = {
            backgroundColor = Config.Livraison.EnCours.BackgroundColor,
            ['.description'] = {
                color = Config.Livraison.EnCours.ColorDesc
            }, 
            ['.title'] = {
                color = Config.Livraison.EnCours.ColorTitle
            }
        }
        
    }) 
    StatutLivraison = 1
    model = GetEntityModel(VehiculeLivraison)
    modelToDelivery = GetEntityModel(VehiculeToDelivery)
    TargetVehicle = exports.ox_target:addModel(model, {
        {
            label = 'Récupérer le véhicule',
            icon = "fa-solid fa-truck-ramp-box",
            name = 'Recup',
            event = 'RecupVehicleMoto'
        }
    })
   
    


end 

AddEventHandler('RecupVehicle', function()
    exports.ox_target:removeModel(model)
    TriggerServerEvent('Moto:LogsSendMoto', 'Concessionnaire Moto', 'Livraison', 'Le véhicule a été livré', Config.Webhook)
    lib.notify({
        title = 'Livraison éffectuée',
        description = 'Votre véhicule est livré ! Récupérez le et mettez le en stock !',
        icon = Config.Livraison.Finish.Icon,
        iconColor = Config.Livraison.Finish.IconColor,
        position = Config.Livraison.Finish.Position,
        style = {
            backgroundColor = Config.Livraison.Finish.BackgroundColor,
            ['.description'] = {
                color = Config.Livraison.Finish.ColorDesc
            }, 
            ['.title'] = {
                color = Config.Livraison.Finish.ColorTitle
            }
        }
    })
    RecupVehicleMoto()
end)

function RecupVehicleMoto()
        AttachEntityToEntity(VehiculeToDelivery, VehiculeLivraison, 20, -0.5, -12.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
        Wait(10)
        DetachEntity(VehiculeToDelivery, true, true)
        SetVehicleOnGroundProperly(VehiculeToDelivery)
        while not CanStartLivraisonMoto do
            local CoordsPed = GetEntityCoords(PedInVehicle)
            local plCoords = GetEntityCoords(PlayerPedId())
        
            --DistanceToDestination = Vdist( CoordsPed.x, CoordsPed.y, CoordsPed.z, )
            DistanceToPlayer = Vdist(plCoords.x, plCoords.y, plCoords.z, CoordsPed.x, CoordsPed.y, CoordsPed.z)
            Citizen.Wait(200)
            if IsPedInVehicle(PlayerPedId(), VehiculeToDelivery, false) then 

           
                TaskVehicleDriveToCoord(PedInVehicle, VehiculeLivraison, Config.Livraison.LocationToDestination, 0, GetEntityModel(VehiculeLivraison))
                StatutLivraison = 2
            
                if StatutLivraison == 2 and DistanceToPlayer >= 100  then
                    
                    RemovePedElegantly(PedInVehicle)
                    DeleteEntity(VehiculeLivraison)
                    Wait(1500)
                    StatutLivraison = 0
                    CanStartLivraisonMoto = true
                end 
            end
        end
end

function onEnter(self)
    lib.showTextUI('Appuyez sur [E]', {
        borderRadius = 100,
        position = "center",

    })
end

function onExit(self)
    lib.hideTextUI()
end 

function inside(self)
    if IsControlJustReleased(1,51) then
        local VehUse = GetVehiclePedIsIn(PlayerPedId(), true)
        local Plate = GetVehicleNumberPlateText(VehUse)
        local ModelUse = GetEntityModel(VehUse)      
        if IsPedInAnyVehicle(PlayerPedId()) then           
            if VehUse == VehiculeToDelivery then
                TriggerServerEvent('Moto:concessmoto_restock', info.stockVeh, info.modelVeh, info.priceVeh) 
                TriggerServerEvent('Moto:LogsSendMoto', 'Concessionnaire Moto', 'Livraison', 'Le véhicule livré a été ajouté au stock !', Config.Webhook)
                TriggerServerEvent('Moto:concessmoto_add_historique', "Restock véhicule", info.priceVeh, "/", info.modelVeh)
                DeleteEntity(VehiculeToDelivery)
                info.stockVeh = nil
                info.modelVeh = nil
                info.priceVeh = nil
            else 
                lib.notify({
                    title = 'Livraison',
                    description = 'Ce véhicule ne correspond pas à celui qui a été livré !',
                    type = 'error',
                    position = 'center-left'
                })
            end 
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
        coords =  Config.Livraison.LocationStock,
        radius = 3, 
        onEnter = onEnter,
        onExit = onExit, 
        inside = inside
    })
end)
