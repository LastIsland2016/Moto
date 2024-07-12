ESX = exports['es_extended']:getSharedObject()

local ox_inventory = exports.ox_inventory

local Automatisation = "Non-automatique"

local Id = nil

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
end)

Citizen.CreateThread(function()
    blip = AddBlipForCoord(Config.Blips.Position)
    SetBlipSprite(blip, Config.Blips.Type)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.Blips.Size)
    SetBlipColour(blip, Config.Blips.Color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(Config.Blips.Title)
    EndTextCommandSetBlipName(blip) 
end)

Citizen.CreateThread(function() 
    
    while true do 
        if IsControlJustPressed(1,167) and (ESX.PlayerData.job and ESX.PlayerData.job.name == "concessmotomoto") then
            lib.showContext('MenuF6')
        end
        Citizen.Wait(1)  
    end
end)

lib.registerContext({
	id = 'MenuF6',
	title = 'Menu Gestion',
	options = {
		-- {
		-- 	title = 'Annonces',
		-- 	icon = 'fa-solid fa-share-nodes',
		-- 	iconColor = '#FFFFFF',
        --     arrow = true,
        --     menu = 'MenuAnnonces',
		-- },
		-- {
		-- 	title = 'Réparer',
		-- 	icon = 'fa-solid fa-hammer',
		-- 	iconColor = '#FFFFFF',
        --     arrow = true,
        --     event = 'MenuRepair',
		-- },
        {
			title = 'Automatisation',
			icon = "fa-solid fa-robot",
			iconColor = '#FFFFFF',
            arrow = true,
            event = 'MenuAutomat',
		},
        {
            title = 'Historique',
            icon = "fa-solid fa-clock-rotate-left",
            arrow = '#FFFFFF',
            arrow = true,
            event = 'MenuHistoriqueMoto'
        }
	
	}
})

lib.registerContext({
	id = 'MenuAnnonces',
	title = 'Annonces',
	menu = 'MenuF6',
	options = {
		{
            title  = 'Ouverture',
            icon = 'fa-solid fa-lock-open',
            iconColor = '#FFFFFF',
            arrow = true,
            onSelect = function()
                TriggerServerEvent('Moto_concessmoto:AnnonceOuverture')
            end
        },
        {
            title  = 'Fermeture',
            icon = 'fa-solid fa-lock',
            iconColor = '#FFFFFF',
            arrow = true,
            onSelect = function()
                TriggerServerEvent('Moto_concessmoto:AnnonceFermeture')  
            end
        },
        {
            title  = 'Recrutement',
            icon = 'fa-solid fa-user-pen',
            iconColor = '#FFFFFF',
            arrow = true,
            onSelect = function()
                TriggerServerEvent('Moto_concessmoto:AnnonceRecrutement')  
            end
        },
		{
            title  = 'Personnalisé',
            icon = 'fa-solid fa-user-pen',
            iconColor = '#FFFFFF',
            arrow = true,
			onSelect = function()
				local input = lib.inputDialog('Annonce Personnalisée', {
					{type = 'input', label = 'Message', description = 'Choisis ton message.', required = true, min = 4, max = 75}
				})
				if input then 
					TriggerServerEvent('Moto_concessmoto:AnnoncePerso', input[1])  
				else 
					return
				end
			end
           
        }
	}
})

AddEventHandler('MenuAutomat', function()
    MenuAutomatiqueMoto()
end)

AddEventHandler('MenuHistoriqueMoto', function()
    MenuHistoriqueMoto()
end)

AddEventHandler('MenuRepair', function()
    MenuRepair()
end)

function MenuHistoriqueMoto()
    local option = {}
    lib.callback('Moto:concessmoto_historique', false, function(result)
        if result then
            for k, v in pairs(result) do
                table.insert(option, {
                    title = v.date.. ' - ' ..v.type,
                    icon = "fa-solid fa-clock-rotate-left",
                    iconColor = 'FFF68F',
                    description = "Gain pour l'entreprise : "..v.gain.. '\n Coût pour l\'entreprise : ' ..v.cost.. '\n Objet affecté : ' ..v.vehicle.. '\n Utilisateur :' ..v.identifier,
                    onSelect = function()
                        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'concessmoto' and ESX.PlayerData.job.grade == 4 then
                            local input = lib.inputDialog('Gestion historique',{
                                {type = 'checkbox', label = 'Supprimer cette information', required = true}

                            })
                            if input then 
                                TriggerServerEvent('Moto:concessmoto_delete_historique', v.id)
                            end 
                        else 
                            lib.notify({
                                title = 'Gestion Historique',
                                description = 'Seul le patron à accès à cette fonction.',
                                type = 'error'
                            })
                            lib.showContext('MenuHistoriqueMoto')
                        end 
                    end 
                })
                lib.registerContext({
                    id = 'MenuHistoriqueMoto',
                    title = "Historique",
                    options = option,
                    menu = 'MenuF6'
                })
            end 
        end  
        lib.showContext('MenuHistoriqueMoto')
    end)
end 

function MenuAutomatiqueMoto()
    
    lib.callback('Moto:concessmoto_auto_verif', false,function(result)
        if result then 
            for k, v in pairs(result) do 
                lib.registerContext({
                    id = 'MenuAutomatiqueMoto',
                    title = "Gestion Automatisation",
                    menu = "MenuF6",
                    options = {
                        {
                            title = "Statut de l'automatisation : " ..v.statut
                        },
                        {
                            title = "Changer le mode",
                            arrow = true,
                            icon = "fa-solid fa-robot",
                            onSelect = function()
                                local input = lib.inputDialog('Mode d\'automatisation', {
                                    {type = 'select', label = 'Choisissez le mode de fonctionnement', description = "Le mode Automatique permet aux clients d'acheter les véhicules en stock sans qu'un vendeur soit nécessairement présent.",  options = {{value = 'Automatique', label = 'Automatique'}, {value = 'Non-automatique', label = 'Non-automatique'}}, default = 'Non-automatique', icon = "fa-solid fa-hand-pointer"}
                                })
                                if input then 
                                    TriggerServerEvent('Moto:concessmoto_update_automatisation', input[1])
                                end 
                            end
                        }
                        
                    }
                })
            end
        end
        lib.showContext('MenuAutomatiqueMoto')
    end)
end

function MenuRepair()
    print("ok")
    local targetVehicle = ESX.Game.GetVehicleInDirection()
    local model = GetEntityModel(targetVehicle)
    local coords = GetEntityCoords(targetVehicle)
    local playerPos = GetEntityCoords(PlayerPedId())
    local distance = #(playerPos - vector3(coords.x, coords.y , coords.z ))
    print(targetVehicle)
    if targetVehicle ~= 0 and distance <= 2 then 
        lib.progressCircle({
            duration = 7000,
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            disable = {
                car = true,
                move = true, 
                mouse = true
            },
            anim = {
                dict = 'missmechanic',
                clip = 'work2_base'
            },
            prop = {
                model = `prop_tool_wrench`,
                pos = vec3(0.0, 0.03, -0.10),
                rot = vec3(0.5, 0.0, -1.5)
            },
            
        })
        SetVehicleEngineHealth(targetVehicle, 1000.0)
        SetVehicleBodyHealth(targetVehicle, 1000.0)
        SetVehicleDirtLevel(targetVehicle, 1000.0)
        SetVehicleFixed(targetVehicle)
        lib.notify({
            title = 'Réparation',
            description = 'La réparatrion du véhicule a bien été réalisée.',
            icon = Config.MenuF6.Repair.Icon,
            iconColor = Config.MenuF6.Repair.IconColor,
            position = Config.MenuF6.Repair.Position,
            style = {
                backgroundColor = Config.MenuF6.Repair.BackgroundColor,
                ['.description'] = {
                    color = Config.MenuF6.Repair.ColorDesc
                }, 
                ['.title'] = {
                    color = Config.MenuF6.Repair.ColorTitle
                }
            }
        })
    else 
        lib.showContext('MenuF6')
        lib.notify({
            title = 'Réparation',
            description = 'Pas de véhicule à proximité.',
            type = 'error'
        })
    end
end 