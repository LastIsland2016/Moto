ESX = exports["es_extended"]:getSharedObject()

Citizen.CreateThread(function()
    exports.ox_target:addBoxZone({
        coords = Config.Comptoir.Coords,
        size = vec(1, 1.5, 1.5),
        rotation = 60, 
        debug = false,
        id = 'bureau',
        options = {
            {
                groups = {['concessmoto'] = 0},
                name = 'Ordinateur',
                icon = 'fa-solid fa-clipboard-list',
                label = 'Gérer les véhicules',
                onSelect = function() lib.showContext('GestionVéhicules') end
            },
        }

    })
end)

lib.registerContext({
    id = 'GestionVéhicules',
    title = 'Gestion des Véhicules',
    options = {
        {
            title = "Créer une catégorie",
            arrow = true,
            icon = "fa-solid fa-file-import",
            onSelect = function()
                local input = lib.inputDialog('Ajout de catégorie',{
                    {type = 'input', label = "Nom de la catégorie", icon = "fa-regular fa-keyboard", required = true},
                    {type = 'input', label = "Label de la catégorie (visible dans le menu)",icon = "fa-regular fa-keyboard", required = true},
                    {type = 'input', label = "image",icon = "fa-regular fa-keyboard", required = false}
                })
                if input then 
                    TriggerServerEvent('Moto:concessmoto_add_category', input[1], input[2], input[3])
                    TriggerServerEvent('Moto:concessmoto_add_historique', "Catégorie ajoutée", "/", "/", input[2])
                end

            end
        }, 
        {
            title = "Ajouter véhicules",
            arrow = true,
            icon = "fa-solid fa-car-side",
            onSelect = function()
                
                local input = lib.inputDialog('Ajout de catégorie',{
                    {type = 'input', label = "Label véhicule (visible dans le menu)", icon = "fa-regular fa-keyboard", required = true},
                    {type = 'input', label = "Nom de Spawn",icon = "fa-regular fa-keyboard", required = true},
                    {type = 'input', label = "Prix (visible dans le menu)",icon = "fa-regular fa-keyboard", required = true},
                    {type = 'input', label = "Catégorie (visible dans le menu)",icon = "fa-regular fa-keyboard", required = true},
                })
                if input then 
                    TriggerServerEvent('Moto:concessmoto_add_vehicle', input[1], input[2], input[3], input[4])
                    TriggerServerEvent('Moto:concessmoto_add_historique', "Véhicule ajouté", "/", "/", input[1])
                end

            end
        },
        {
            title = 'Listes',
            description = 'Consultez, gérez les catégories et le catalogue.',
            menu = 'MenuLists',
            icon = "fa-solid fa-list"
        }
    }
})

lib.registerContext({
    id = 'MenuLists', 
    title = 'Listes Gestion',
    menu = 'GestionVéhicules',
    options = {
        {
            title = 'Liste catégories',
            event = 'MenuListeCatMoto',
            icon = "fa-solid fa-layer-group",
            arrow = true
        },
        {
            title = 'Liste véhicules',
            event = 'MenuListVehMoto',
            icon = "fa-solid fa-car-rear",
            arrow = true
        }
    }
})


AddEventHandler('MenuListeCatMoto', function()
    MenuListeCatMoto()
    print('ok')
end)

AddEventHandler('MenuListVehMoto', function()
    MenuListeVehMoto()
    print('ok!!!!!!')
end)

function MenuListeCatMoto()
    local option = {}
    lib.callback('Moto:concessmoto_liste_cat', false, function(result) 
        if #result > 0 then
            
            for k, v in pairs(result) do
                table.insert(option,{   
                    title = v.label,
                    description = 'Nom : ' ..v.name,
                    arrow = true, 
                    image = v.image,
                    icon = "fa-solid fa-arrows-spin",
                    iconColor = "#FF922B",
                    onSelect = function()
                        local input = lib.inputDialog('Modifier la catégorie',{
                            {type = 'input', label = "Nom de la catégorie", icon = "fa-regular fa-keyboard", default = v.name,required = true},
                            {type = 'input', label = "Label de la catégorie (visible dans le menu)",icon = "fa-regular fa-keyboard", default = v.label, required = true},
                            {type = 'checkbox', label = "Supprimer ce véhicule du catalogue.", checked = false},
                            print('yes')
                            
                        })
                        if input then
                            if input[3]then
                                TriggerServerEvent('Moto:concessmoto_remove_cat', v.name)
                                TriggerServerEvent('Moto:concessmoto_add_historique', "Catégorie supprimée", "/", "/", v.name)
                                print('ok!!!!!')
                            else 
                                TriggerServerEvent('Moto:concessmoto_update_category', v.name, input[1], input[2])
                                TriggerServerEvent('Moto:concessmoto_add_historique', "Catégorie modifié", "/", "/", v.name)
                                print('ok')
                            end

                        end
                    end
                })
                lib.registerContext({
                    id = 'list_cat',
                    title = "Liste des catégories",
                    menu = 'MenuLists',
                    filter = Config.FilterUse,
                    options = option
                       
                })
            end 
            lib.showContext('list_cat')
        end
        
    end)
end

function MenuListeVehMoto()
    local option = {}
    lib.callback('Moto:concessmoto_liste_veh', false, function(result) 
        if #result > 0 then
            
            for k, v in pairs(result) do
                table.insert(option,{   
                    title = v.name,
                    description = 'Model : ' ..v.model.. '\n Price : ' ..v.price.. '\n Catégorie : ' ..v.category.. "\n Stock : " ..v.stock,
                    arrow = true, 
                    icon = "fa-solid fa-arrows-spin",
                    iconColor = "#FF922B",
                    colorScheme = 'orange',
                    metadata = {
                        {label = 'Vitesse Maximale ', value =  Floor(GetVehicleModelEstimatedMaxSpeed(v.model)*3.6).." km/h"},
                        {label = 'Nombre de Places ', value =  GetVehicleModelNumberOfSeats(v.model)},
                        {label  = "Accelération ", value = math.floor(GetVehicleModelAcceleration(v.model)*100).. "%",progress = GetVehicleModelAcceleration(v.model)*100},
                    },
                    onSelect = function()
                        local price_restock = tonumber(v.price*0.70)
                        lib.registerContext({
                            title = "Options",
                            id = 'gestion_véhicule-choice',
                            menu = 'list_veh',
                            options = {
                                {
                                    title = v.name,
                                    description = 'Model : ' ..v.model.. '\n Price : ' ..v.price.. '\n Catégorie : ' ..v.category.. "\n Stock : " ..v.stock,
                                    icon = "fa-solid fa-arrows-spin",
                                    iconColor = "#FF922B",
                                }, 
                                {
                                    title = "Modifier le véhicule",
                                    arrow = true,
                                    icon = "fa-regular fa-pen-to-square",
                                    iconColor = 'orange',
                                    onSelect = function()
                                        local input = lib.inputDialog('Modifier le véhicule',{
                                            {type = 'input', label = "Label véhicule (visible dans le menu)", icon = "fa-regular fa-keyboard", default = v.name,required = true},
                                            {type = 'input', label = "Nom de Spawn",icon = "fa-regular fa-keyboard", default = v.model, required = true},
                                            {type = 'number', label = "Prix (visible dans le menu)",icon = "fa-regular fa-keyboard", default = v.price, required = true},
                                            {type = 'input', label = "Catégorie (visible dans le menu)",icon = "fa-regular fa-keyboard", default = v.category, required = true},
                                            {type = 'checkbox', label = "Supprimer ce véhicule du catalogue.", checked = false}
                                        })
                                        print(input[5])
                                        if input[5] == false then
                                            TriggerServerEvent('Moto:concessmoto_update_vehicle', v.model, input[1], input[2], input[3], input[4])
                                            TriggerServerEvent('Moto:concessmoto_add_historique', "Véhicule modifié", "/", "/", v.name)
                                        else 
                                            TriggerServerEvent('Moto:concessmoto_remove_vehicle', v.model)
                                            TriggerServerEvent('Moto:concessmoto_add_historique', "Véhicule supprimé", "/", "/", v.name)
                                        end
                                    end 
                                }, 
                                {
                                    title = "Restock le véhicule",
                                    arrow = true, 
                                    description = "Acheter directement du stock au fournisseur, cela vous coutera : " ..price_restock.. "\n Votre marge est donc de : " ..tonumber(v.price-v.price*0.70), 
                                    progress = tonumber(price_restock/v.price),
                                    colorScheme = '#3BC9DB',
                                    icon = "fa-solid fa-arrows-down-to-line",
                                    iconColor = '#3BC9DB',
                                    onSelect = function()
                                        lib.callback('Moto:concessmoto_verif_money_entreprise', false, function(result)
                                            if result then
                                                TriggerEvent('StartLivraisonMoto',v.stock, v.model, v.price )
                                            else
                                                lib.notify({
                                                    title = 'Livraison',
                                                    description = 'L\'entreprise n\'a plus assez d\'argent !',
                                                    type = 'error'
                                                })
                                            end
                                        end, v.price, 'society_concessmoto')    
                                        
                                    end 


                                }
                            } 
                        })
                        lib.showContext('gestion_véhicule-choice')
                        
                    end
                })
                lib.registerContext({
                    id = 'list_veh',
                    title = "Liste des véhicules",
                    menu = 'MenuLists',
                    filter = Config.FilterUse,
                    options = option
                       
                })
            end 
            lib.showContext('list_veh')
        else 
            lib.registerContext({
                id = 'list_veh',
                title = "Liste des véhicules",
                menu = 'MenuLists',
                options = {
                    {
                        title = 'Aucun véhicule dans le catalogue',
                        icon = "fa-solid fa-triangle-exclamation"
                    }
                }
                   
            })
            lib.showContext('list_veh')
        end
        
    end)
end