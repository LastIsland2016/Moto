ESX = exports['es_extended']:getSharedObject()

Citizen.CreateThread(function()
    
    local xPlayer = PlayerPedId()
    ClearPedTasks(xPlayer)
    FreezeEntityPosition(PlayerPedId(), false)

        exports.ox_target:addBoxZone({
        coords = Config.Catalogue.Coords,
        rotation = 60, 
        debug = false,
        id = 'catalogue',
        options = {
                {
                    name = 'Ordinateur',
                    icon = 'fa-solid fa-clipboard-list',
                    label = 'Catalogue',
                    event = 'MenuconcessmotoCatalogue'
                },
            }
    }) 
end)


AddEventHandler('MenuconcessmotoCatalogue', function()
    Catalogue()
end)


function Catalogue()
    local option = {}
    lib.callback('Moto:concessmoto_liste_cat', false, function(result)
        if result then 
            for k, v in pairs(result) do
                table.insert(option, {
                    title = v.label,
                    image = v.image,
                    icon = Config.Icon.Type.Category,
                    iconColor = Config.Icon.Color.Category,
                    onSelect = function()
                       MenuVeh(v.name)
                    end
                })

                lib.registerContext({
                    id = 'Catalogue',
                    title = 'Catalogue Véhicules',
                    icon = "fa-solid fa-car",
                    options = option 
                })
            end 
        end 
        lib.showContext('Catalogue')
    end)
end

function MenuAchat(name, model, price, category, stock, label)
    local xPlayer = PlayerPedId()
    local modelChoice = nil
    lib.callback('Moto:concessmoto_auto_verif', false, function(result)
        if result then 
            for k, v in pairs(result) do
                if v.statut == 'Automatique' then
                    lib.registerContext({
                        id = 'MenuAchatVeh',
                        title = 'Choix du véhicule',
                        menu = 'Catalogue',
                        options = {
                            {
                                title = name, 
                                description = 'Model : ' ..model.. '\n Price : ' ..price.. '\n Catégorie : ' ..category.. "\n Stock : " ..stock,
                                icon = "fa-solid fa-car-side",
                                iconColor = "#364FC7",
                                colorScheme = 'blue',
                                metadata = {
                                    {label = 'Vitesse Maximale ', value =  Floor(GetVehicleModelEstimatedMaxSpeed(model)*3.6).." km/h"},
                                    {label = 'Nombre de Places ', value =  GetVehicleModelNumberOfSeats(model)},
                                    {label  = "Accelération ", value = math.floor(GetVehicleModelAcceleration(model)*100).. "%",progress = GetVehicleModelAcceleration(model)*100, colorScheme = 'blue'},
                                    {label = "Freinage ", value =  math.floor(GetVehicleModelMaxBraking(model)*100).. "%", progress = GetVehicleModelMaxBraking(model)*100, colorScheme = 'blue'}
                                },
                            },
                            {
                                title = "Visualiser le véhicule",
                                arrow = true, 
                                icon = "fa-solid fa-camera-rotate",
                                iconColor = "#FFD43B",
                               
                                onSelect = function()
                                   OpenPreview(model)
                                end
                            },
                            {
                                title = "Acheter ce véhicule",
                                icon = "fa-solid fa-money-check",
                                arrow = true, 
                                iconColor = '#51CF66',
                                description = "Vous entrerez dans le panneau de configuration de votre futur véhicule.",
                                onSelect = function()
                                    if stock >= 1 then 
                                        local input = lib.inputDialog('Panel de Configuration', {
                                        
                                            {type = 'color', label = "Couleur du véhciule", required = true, format = 'rgb', default = '0, 0, 0'},

                                            {type = 'select', label = 'Choisissez le mode de paiement', icon = "fa-solid fa-cash-register", options = {{value = 'bank', label = "Carte Bancaire"}, {value = "money", label = "Espèce"}}, required = true},
                                            {type = 'checkbox', label = "Confirmer l'achat", icon = "fa-regular fa-keyboard", required = true}
                                        })
                                        if input then 
                                            alert = lib.alertDialog({
                                                header = 'Confirmation de paiement',
                                                content = 'En confirmant vous acceptez de payer la somme de : ' ..price.. " au concessionaire",
                                                centered = true,
                                                cancel = true,
                                                size = 'sm'
                                            })
                                            if alert == 'confirm' then
                                                local plate = GeneratePlate()
                                                local r, g, b = extractRGB(input[1])
                                                lib.callback('Moto:concessmoto_verif_money', false, function(cb)
                                                    if cb then 
                                                        ESX.Game.SpawnVehicle(model, Config.Catalogue.SpawnVehicle.coords, Config.Catalogue.SpawnVehicle.heading, function(vehicle)
                                                            SetVehicleNumberPlateText(vehicle, plate)
                                                            SetVehicleCustomPrimaryColour(vehicle, r, g, b)
                                                            local properties = lib.getVehicleProperties(vehicle)
                                                            Wait(300)
                                                            SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
                                                            TriggerServerEvent('Moto:concessmoto_buy_car', name, price, properties, plate,stock, input[1], input[2])
                                                            TriggerServerEvent('Moto:concessmoto_add_historique', "Vente", "/", price, name)
                                                        end)
                                                    else 
                                                        lib.notify({
                                                            title = 'Achat Concessionnaire',
                                                            description = 'Vous n\'avez pas assez d\'argent',
                                                            type = 'error'
                                                        })
                                                        lib.showContext('MenuAchatVeh')
                                                    end
                                                end, price, input[2]) 
                                            else 
                                                
                                                lib.notify({
                                                    title = 'Achat Concessionnaire',
                                                    description = 'L\'achat du véhicule : ' ..name.. ' a été annulé.',
                                                    type = 'error'
                                                })
                                                lib.showContext('MenuAchatVeh')
                                            end 
                                        end
                                    else 
                                        lib.notify({
                                            title = 'Achat Concessionnaire',
                                            description = 'Le véhicule ' ..name.. " est en rupture de stock.",
                                            type = 'error'
                                        })
                                        lib.showContext('MenuAchatVeh')
                                    end 
                                end
                            }

                        }
                    })
                else
                    lib.registerContext({
                        id = 'MenuAchatVeh',
                        title = 'Choix du véhicule',
                        --icon = "fa-solid fa-car",
                        menu = 'Catalogue',
                        options = {
                            {
                                title = name, 
                                description = 'Model : ' ..model.. '\n Price : ' ..price.. '\n Catégorie : ' ..category,
                                icon = "fa-solid fa-car-side",
                                iconColor = "#364FC7",
                                colorScheme = 'blue',
                                metadata = {
                                    {label = 'Vitesse Maximale ', value =  Floor(GetVehicleModelEstimatedMaxSpeed(model)*3.6).." km/h"},
                                    {label = 'Nombre de Places ', value =  GetVehicleModelNumberOfSeats(model)},
                                    {label  = "Accelération ", value = math.floor(GetVehicleModelAcceleration(model)*100).. "%",progress = GetVehicleModelAcceleration(model)*100, colorScheme = 'blue'},
                                    {label = "Freinage ", value =  math.floor(GetVehicleModelMaxBraking(model)*100).. "%", progress = GetVehicleModelMaxBraking(model)*100, colorScheme = 'blue'}
                                },
                            },
                            {
                                title = "Visualisez le véhicule",
                                arrow = true,
                                icon = "fa-solid fa-camera-rotate",
                                iconColor = "#FFD43B",
                               
                                onSelect = function()
                                    OpenPreview(model)
                                 end
                            },
                            {
                                title = "Espace Vendeurs(ses)",
                                arrow = true,
                                icon = "fa-solid fa-id-card-clip",
                                iconColor = '1B62FF',
                                onSelect = function()
                                    if ESX.PlayerData.job and ESX.PlayerData.job.name == 'concessmoto' then
                                        MenuAchatVendeur(name, model, price, category, stock, label)
                                    else 
                                        lib.showContext('MenuAchatVeh')
                                        lib.notify({
                                            title = 'Accès Vendeurs(ses)',
                                            description = 'Vous ne travaillez par au concessionnaire !',
                                            type = 'error'
                                        })
                                    end
                                end

                            }
                        }
                    })
                end 
            end
        end
        lib.showContext('MenuAchatVeh')
    end)
end

function MenuVeh(categories)
    local option = {}
    lib.callback('Moto:concessmoto_liste_veh_from_cat', false, function(result)
        if #result >= 1 then 
            for k, v in pairs(result) do
                    table.insert(option, {   
                        title = v.name,
                        description = 'Model : ' ..v.model.. '\n Price : ' ..v.price.. '\n Catégorie : ' ..v.category.. "\n Stock : " ..v.stock,
                        arrow = true, 
                        icon = "fa-solid fa-car-side",
                        iconColor = "#364FC7",
                        colorScheme = 'blue',
                        metadata = {
                            {label = 'Vitesse Maximale ', value =  Floor(GetVehicleModelEstimatedMaxSpeed(v.model)*3.6).." km/h"},
                            {label = 'Nombre de Places ', value =  GetVehicleModelNumberOfSeats(v.model)},
                            {label  = "Accelération ", value = math.floor(GetVehicleModelAcceleration(v.model)*100).. "%",progress = GetVehicleModelAcceleration(v.model)*100},
                            {label = "Freinage ", value =  math.floor(GetVehicleModelMaxBraking(v.model)*100).. "%", progress = GetVehicleModelMaxBraking(v.model)*100}
                        },
                        onSelect = function()
                            MenuAchat(v.name, v.model, v.price, v.category, v.stock, v.name)
                        end 
                    })
                    lib.registerContext({
                        id = 'CatalogueVeh',
                        title = 'Choix du véhicule',
                        icon = "fa-solid fa-car",
                        filter = Config.FilterUse,
                        menu = 'Catalogue',
                        options = option 
                    })
                
            end 
        else
            lib.registerContext({
                id = 'CatalogueVeh',
                title = 'Choix du véhicule',
                icon = "fa-solid fa-car",
                menu = 'Catalogue',
                options = {
                    {
                        title = "Pas de véhicules dans cette catégorie."
                    }
                }
            })
        end 
        lib.showContext('CatalogueVeh')
    end, categories)
end


function OpenPreview(model)
    local vehicleChoice = nil
    local xPlayer = PlayerPedId()
    

    ESX.Game.SpawnVehicle(model, Config.Preview.SpawnVehicle.coords,  Config.Preview.SpawnVehicle.heading, function(vehicle)
        SetVehicleNumberPlateText(vehicle, "Concessmoto")
        cam()
        vehicleChoice = vehicle
        if Config.Preview.Cam.statut then
            while true do
            
                SetEntityHeading(vehicle, GetEntityHeading(vehicle) + 0.3)
                Citizen.Wait(0)
            end
        end 
    end)
          
    lib.registerContext({
        id = 'MenuPreview',
        title = "Preview",
        canClose = false,
        options = {
            {
                title = "Changer la couleur",
                icon = "fa-solid fa-palette",
                arrow = true,
                onSelect = function()
                    local input = lib.inputDialog('Choisir la couleur du véhicule',{
                        {type = 'color', label = 'Couleur principale du véhicule', format = 'rgb', default = '0, 0, 0'},
                        {type = 'color', label = 'Couleur secondaire du véhicule', format = 'rgb', default = '0, 0, 0'},
                      
                    })
                    
                    if input then

                        local r, g, b = extractRGB(input[1])
                        local r2, g2, b2 = extractRGB(input[2])
                        SetVehicleCustomPrimaryColour(vehicleChoice, r, g, b)
                        SetVehicleCustomSecondaryColour(vehicleChoice, r2, g2, b2)
                      
                            
                    end

                    lib.showContext('MenuPreview')
                end
                
            },
            {
                title = "Retour",
                arrow = true,
                
                onSelect = function()
                
                    DeleteVehicle(vehicleChoice)
                    Camkill()
                    ClearPedTasks(xPlayer)
                    FreezeEntityPosition(PlayerPedId(), false)
                    lib.showContext('MenuAchatVeh')
                end
               
            }

        }
    })
    lib.showContext('MenuPreview')
end


function MenuVendeur()
    local option = {}
    lib.callback('Moto:concessmotomoto_liste_cat', false, function(result)
        if result then 
            for k, v in pairs(result) do
                table.insert(option, {
                    title = v.label,
                    image = v.image,
                    icon = "fa-solid fa-rectangle-list",
                    onSelect = function()
                       MenuVehVendeur(v.name)
                    end
                })

                lib.registerContext({
                    id = 'CatalogueVendeur',
                    title = 'Catalogue Véhicules',
                    icon = "fa-solid fa-car",
                    options = option 
                })
            end 
        end 
        lib.showContext('CatalogueVendeur')
    end)
end 

------------------ ESPACE VENDEUR 

function MenuAchatVendeur(name, model, price, category, stock, label)
    local xPlayer = PlayerPedId()
    local modelChoice = nil
    local option_player = {}
    lib.callback('Moto:concessmoto_auto_verif', false, function(result)
        if result then 
            for k, v in pairs(result) do
                lib.registerContext({
                    id = 'MenuAchatVendeur',
                    title = 'Choix du véhicule',
                    menu = 'Catalogue',
                    options = {
                        {
                            title = name, 
                            description = 'Model : ' ..model.. '\n Price : ' ..price.. '\n Catégorie : ' ..category.. '\n Stock : '..stock,
                            icon = "fa-solid fa-car-side",
                            iconColor = "#364FC7",
                            colorScheme = 'blue',
                            metadata = {
                                {label = 'Vitesse Maximale ', value =  Floor(GetVehicleModelEstimatedMaxSpeed(model)*3.6).." km/h"},
                                {label = 'Nombre de Places ', value =  GetVehicleModelNumberOfSeats(model)},
                                {label  = "Accelération ", value = math.floor(GetVehicleModelAcceleration(model)*100).. "%",progress = GetVehicleModelAcceleration(model)*100, colorScheme = 'blue'},
                                {label = "Freinage ", value =  math.floor(GetVehicleModelMaxBraking(model)*100).. "%", progress = GetVehicleModelMaxBraking(model)*100, colorScheme = 'blue'}
                            },
                        },
                        {
                            title = "Acheter ce véhicule",
                            icon = "fa-solid fa-money-check",
                            arrow = true, 
                            iconColor = '#51CF66',
                            description = "Vous entrerez dans le panneau de configuration de votre futur véhicule.",
                            onSelect = function()
                                if stock >= 1 then 
                                    local closestPlayer = lib.getClosestPlayer(GetEntityCoords(xPlayer), 10.0, false)
                                    local input1 = lib.inputDialog('Pour qui est cet achat ?', {
                                        {type = 'select', label = 'Choisissez la raison de l\'achat', options = {{value = 'particulier', label = 'Pour un particulier'}, {value = 'moi', label = 'Pour moi'}, {value = 'entreprise', label = 'Pour une entreprise'}}}
                                    })
                                    if input1 and input1[1] == 'particulier' and closestPlayer ~= nil then
                                        local input = lib.inputDialog('Achat du véhicule', {
                                            {type = 'color', label = "Couleur du véhciule", required = true, format = 'rgb', default = '0, 0, 0'},
                                            {type = 'select', label = 'Choisissez le mode de paiement', icon = "fa-solid fa-cash-register", options = {{value = 'bank', label = "Carte Bancaire"}, {value = "money", label = "Espèce"}}, required = true},
                                            {type = 'select', label= 'Choisissez le joueur', options = {{value = GetPlayerServerId(closestPlayer), label = "ID : " ..GetPlayerServerId(closestPlayer).. " Pseudo : " ..GetPlayerName(closestPlayer)}}, required = true},
                                            {type = 'checkbox', label = "Confirmer l'achat", icon = "fa-regular fa-keyboard", required = true},
                                        })
                                        if input and input[3] ~= nil then 
                                            alert = lib.alertDialog({
                                                header = 'Confirmation de paiement',
                                                content = 'En confirmant vous acceptez de payer la somme de : ' ..price.. " au concessionaire",
                                                centered = true,
                                                cancel = true,
                                                size = 'sm'
                                            })
                                            if alert == 'confirm' then
                                                local plate = GeneratePlate()
                                                local r, g, b = extractRGB(input[1])
                                                lib.callback('Moto:concessmoto_verif_money_vendeur', false, function(cb)
                                                    if cb then 
                                                        ESX.Game.SpawnVehicle(model,  Config.Catalogue.SpawnVehicle.coords,  Config.Catalogue.SpawnVehicle.heading, function(vehicle)
                                                            SetVehicleNumberPlateText(vehicle, plate)
                                                            SetVehicleCustomPrimaryColour(vehicle, r, g, b)
                                                            local properties = lib.getVehicleProperties(vehicle)
                                                            print(properties)
                                                            Wait(300)
                                                            --SetPedIntoVehicle(GetPlayerServerId(closestPlayer), vehicle, -1)
                                                            TriggerServerEvent('Moto:concessmoto_buy_car_vendeur', name, price, properties, plate, stock, input[1], input[2], input[3])
                                                            TriggerServerEvent('Moto:concessmoto_add_historique', "Vente Automatique", "/", price, name)
                                                        end)
                                                    else 
                                                        lib.notify({
                                                            title = 'Achat Concessionnaire',
                                                            description = 'Le joueur n\'a pas assez d\'argent !',
                                                            type = 'error'
                                                        })
                                                    end
                                                end, price, input[2], input[3]) 
                                            else 
                                                lib.notify(GetPlayerServerId(closestPlayer),{
                                                    title = 'Achat Concessionnaire',
                                                    description = 'L\'achat du véhicule : ' ..name.. ' a été annulé.',
                                                    type = 'error'
                                                })
                                            end 
                                        else 
                                            lib.notify({
                                                title = 'Pas de joueur à proximité', 
                                                description = 'Aucun joueur à proximité',
                                                type = 'error'
                                            })
                                        end
                                    elseif input1[1] == 'moi' then
                                        print(GetPlayerServerId(NetworkGetEntityOwner(GetPlayerPed(-1))))
                                        local input = lib.inputDialog('Achat du véhicule', {
                                            {type = 'color', label = "Couleur du véhciule", required = true, format = 'rgb', default = '0, 0, 0'},
                                            {type = 'select', label = 'Choisissez le mode de paiement', icon = "fa-solid fa-cash-register", options = {{value = 'bank', label = "Carte Bancaire"}, {value = "money", label = "Espèce"}}, required = true},
                                            {type = 'select', label= 'Choisissez le joueur', options = {{value = GetPlayerServerId(NetworkGetEntityOwner(GetPlayerPed(-1))), label = "Moi"}}, required = true},
                                            {type = 'checkbox', label = "Confirmer l'achat", icon = "fa-regular fa-keyboard", required = true},
                                        })
                                        if input and input[3] ~= nil then 
                
                                            alert = lib.alertDialog({
                                                header = 'Confirmation de paiement',
                                                content = 'En confirmant vous acceptez de payer la somme de : ' ..price.. " au concessionaire",
                                                centered = true,
                                                cancel = true,
                                                size = 'sm'
                                            })
                                            if alert == 'confirm' then
                                                local plate = GeneratePlate()
                                                local r, g, b = extractRGB(input[1])
                                                lib.callback('Moto:concessmoto_verif_money_vendeur', false, function(cb)
                                                    if cb then 
                                                        ESX.Game.SpawnVehicle(model, Config.Catalogue.SpawnVehicle.coords, Config.Catalogue.SpawnVehicle.heading,function(vehicle)
                                                            SetVehicleNumberPlateText(vehicle, plate)
                                                            SetVehicleCustomPrimaryColour(vehicle, r, g, b)
                                                            local properties = lib.getVehicleProperties(vehicle)
                                                            print(properties)
                                                            Wait(300)
                                                            SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
                                                            TriggerServerEvent('Moto:concessmoto_buy_car_vendeur', name, price, properties, plate, stock, input[1], input[2], input[3])
                                                            TriggerServerEvent('Moto:concessmoto_add_historique', "Vente Automatique", "/", price, name)
                                                        end)
                                                    else 
                                                        lib.notify({
                                                            title = 'Achat Concessionnaire',
                                                            description = 'Vous n\'avez pas assez d\'argent',
                                                            type = 'error'
                                                        })
                                                    end
                                                end, price, input[2], input[3]) 
                                            else 
                                                lib.notify({
                                                    title = 'Achat Concessionnaire',
                                                    description = 'L\'achat du véhicule : ' ..name.. ' a été annulé.',
                                                    type = 'error'
                                                })
                                            end 
                                        else 
                                            lib.notify({
                                                title = 'Achat annulé', 
                                                type = 'error'
                                            })
                                        end
                                    elseif input1[1] == 'entreprise' then
                                        local input = lib.inputDialog('Achat du véhicule', {
                                            {type = 'color', label = "Couleur du véhciule", required = true, format = 'rgb', default = '0, 0, 0'},
                                            {type = 'input', label = 'Nom de l\'entreprise', required = true},
                                            {type = 'checkbox', label = "Confirmer l'achat", icon = "fa-regular fa-keyboard", required = true},
                                        })
                                        if input then
                                            alert = lib.alertDialog({
                                                header = 'Confirmation de paiement',
                                                content = 'En confirmant vous acceptez de payer la somme de : ' ..price.. " au concessionaire",
                                                centered = true,
                                                cancel = true,
                                                size = 'sm'
                                            })
                                            if alert == 'confirm' then
                                                local plate = GeneratePlate()
                                                local r, g, b = extractRGB(input[1])
                                                lib.callback('Moto:concessmoto_verif_money_entreprise', false, function(cb)
                                                    if cb then 
                                                        ESX.Game.SpawnVehicle(model,  Config.Catalogue.SpawnVehicle.coords,  Config.Catalogue.SpawnVehicle.heading, function(vehicle)
                                                            SetVehicleNumberPlateText(vehicle, plate)
                                                            SetVehicleCustomPrimaryColour(vehicle, r, g, b)
                                                            local properties = lib.getVehicleProperties(vehicle)
                                                            print(properties)
                                                            Wait(300)
                                                            SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
                                                            TriggerServerEvent('Moto:concessmoto_buy_car_entreprise', name, price, properties, plate, stock, label, input[1], input[2])
                                                            TriggerServerEvent('Moto:concessmoto_add_historique', "Vente Automatique", "/", price, name)
                                                        end)
                                                    else 
                                                        lib.notify({
                                                            title = 'Achat Concessionnaire',
                                                            description = 'Vous n\'avez pas assez d\'argent',
                                                            type = 'error'
                                                        })
                                                    end
                                                end, price, input[2]) 
                                            else 
                                                lib.notify({
                                                    title = 'Achat Concessionnaire',
                                                    description = 'L\'achat du véhicule : ' ..name.. ' a été annulé.',
                                                    type = 'error'
                                                })
                                            end 
                                        end 
                                    else
                                        lib.notify({
                                            title = 'Personne à proximité',
                                            description = 'Pas de joueur à proximité.',
                                            type = 'error'

                                        })
                                    end 
                                else 
                                    lib.notify({
                                        title = 'Achat Concessionnaire',
                                        description = 'Le véhicule ' ..name.. " est en rupture de stock.",
                                        type = 'error'
                                    })
                                end                                    
                            end      
                                   
                        }

                    }
                })
            end
        end
        lib.showContext('MenuAchatVendeur')
    end)
end 

---------------



local NumberCharset = {}
local Charset = {}

for i = 48,  57 do table.insert(NumberCharset, string.char(i)) end

for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

function GeneratePlate()
	math.randomseed(GetGameTimer())

	local generatedPlate = string.upper( GetRandomNumber(3) .. GetRandomLetter(2) .. (true and '' or '') .. GetRandomNumber(3))

	local isTaken = IsPlateTaken(generatedPlate)
	if isTaken then 
		return GeneratePlate()
	end

	return generatedPlate
end

-- mixing async with sync tasks
function IsPlateTaken(plate)
	local p = promise.new()
	
	ESX.TriggerServerCallback('Moto:concessmoto_isPlateTaken', function(isPlateTaken)
		p:resolve(isPlateTaken)
	end, plate)

	return Citizen.Await(p)
end

function GetRandomNumber(length)
	Wait(0)
	return length > 0 and GetRandomNumber(length - 1) .. NumberCharset[math.random(1, #NumberCharset)] or ''
end

function GetRandomLetter(length)
	Wait(0)
	return length > 0 and GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)] or ''
end

----------

local Cam = nil
function cam()
    local introcam 
    Cam = introcam
    introcam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamActive(introcam, true)
   -- SetEntityCoords(PlayerPedId(), -56.58957, 6378.409, 31.04843,true, false, false, false)
    SetEntityHeading(PlayerPedId(), Config.Preview.Cam.heading)
    TaskStartScenarioInPlace(PlayerPedId(),'WORLD_HUMAN_CLIPBOARD', 0, true)
    SetCamCoord(introcam, Config.Preview.Cam.coords)
    FreezeEntityPosition(PlayerPedId(), true)
    SetCamRot(introcam, -0, 0, Config.Preview.Cam.heading)
    SetCamActive(introcam, true)
    RenderScriptCams(1, 0, 500, false, false)
end

function Camkill()
    RenderScriptCams(false, false, 0, true, true)
end
function extractRGB(couleur_str)
    local pattern = "rgb%((%d+),%s*(%d+),%s*(%d+)%)"
    local r, g, b = string.match(couleur_str, pattern)
    if r and g and b then
        return tonumber(r), tonumber(g), tonumber(b)
    else
        return nil
    end
end

                                
