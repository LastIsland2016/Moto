ESX = exports["es_extended"]:getSharedObject()

local ox_inventory = exports.ox_inventory

AddEventHandler('OpenInvSociety', function()
        exports.ox_inventory:openInventory('stash', {id = Config.Coffre.id})
end)

Citizen.CreateThread(function()
    
        exports.ox_target:addBoxZone({
            coords = Config.Coffre.Coords,
            --size = v.size,
            --rotation = Config.Positions.Frigo_ox_target.rotation,
            debug = false,
            distance = 10,
            options = {
                {
                    groups = 'concess',
                    event = 'OpenInvSociety',
                    label = 'Coffre',  
                    icon = "fa-solid fa-boxes-stacked"
                },
            }
        })
   
end)
