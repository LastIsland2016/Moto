ESX = exports["es_extended"]:getSharedObject()

local info = {
    identifier = nil,
    grade = nil,
    label = nil 
}

Citizen.CreateThread(function()
    exports.ox_target:addBoxZone({
        coords = Config.BossMenu.Coords,
        size = vec(1, 1.5, 1.5),
        rotation = 60, 
        debug = false,
        options = {
            {
                groups = {['concess'] = 4},
                name = 'Ordinateur',
                icon = 'fa-solid fa-users',
                label = 'Gérer les employés',
                event = 'GestionEmployed'
            },
            {
                groups = {['concess'] = 4},
                name = 'Ordinateur',
                icon = 'fa-solid fa-money-bill-transfer',
                label = 'Gérer les Salaires',
                event = 'GestionSalary'
            },
            {
                groups = {['concess'] = 4},
                name = 'Ordinateur',
                label = 'Gérer les finances',
                event = 'GestionFinance',
                icon = "fa-solid fa-chart-line"
            },
            {
                groups = {['concess'] = 4},
                name = 'Ordinateur',
                label = 'Gérer les véhicules',
                event = 'GestionVeh',
                icon = "fa-solid fa-warehouse"
            },
        }

    })
end)


AddEventHandler('GestionEmployed', function()
    GestionEmployed()
end)

AddEventHandler('GestionSalary', function()
    GestionSalaire()
end)

AddEventHandler('GestionFinance', function()
    GestionFinance()
end)

AddEventHandler('Modify_employed', function()
    ModifyEmployed()
end)

AddEventHandler('GestionVeh', function()
    GestionVeh()
end)

function GestionEmployed()
    option = {}
    local xPlayer = PlayerPedId()
    local option_player = {}
    lib.callback('Moto:concess_employed', false, function(result)
       
        if #result > 0 then
            for k, v in pairs(result) do 
                lib.registerContext({
                    id = 'gestion',
                    title = 'Gestion',
                    options = {
                        {
                            title = 'Recrutement',
                            icon = "fa-solid fa-user-plus",
                            onSelect = function()
                                local closestPlayer = lib.getClosestPlayer(GetEntityCoords(xPlayer), 10.0, false)
                                table.insert(option_player, {
                                    value = GetPlayerServerId(closestPlayer),
                                    label = "ID : " ..GetPlayerServerId(closestPlayer).. " Pseudo : " ..GetPlayerName(closestPlayer)
                                })
                                    
                                if closestPlayer then     
                                    local input = lib.inputDialog('Recrutement', {
                                        {type = 'select', label= 'Choisissez le joueur', options = option_player},
                                    })
                                    if input then
                                        TriggerServerEvent('Moto:concess_recruit', input[1])
                                        
                                        lib.notify({
                                            title = 'Vous venez de recruter : ' ..GetPlayerName(closestPlayer) ,
                                            type = 'success'
                                        }) 
                                    else
                                        lib.showContext('gestion') 
                                    end   
                                else 
                                    lib.notify({
                                        title = 'Personne à proximité',
                                        description = 'Pas de joueur à proximité.',
                                        type = 'error'

                                    })
                                end

                            end 
                        },
                        {
                            title = 'Gestion des employés',
                            icon = "fa-solid fa-users-gear",
                            onSelect = function()
                                lib.showContext('list_employed')
                            end 
                        }
                    }
                })
                lib.showContext('gestion')
                table.insert(option, { 
                        title = "Prénom : " ..v.firstname.. "\n Nom : " ..v.lastname,
                        description = "ID Grade" ..v.job_grade,
                        icon = 'fa-solid fa-user',
                        arrow = true,
                        metadata = {
                            {label = "Sexe ", value = " " ..v.sex},
                            {label = "Date de naissance ", value = " " ..v.dateofbirth}
                        },
                        onSelect = function()
                            if v.job_grade ~= 4 then 
                                ModifyEmployed()
                            else
                                lib.notify({
                                    title = 'Gestion Employés',
                                    description = 'Vous ne pouvez pas modifier le grade d\'un Patron !',
                                    type = 'error'
                                })
                                lib.showContext('list_employed')
                            end 
                        end                    
                })
                lib.registerContext({
                    id = 'list_employed',
                    title = "Liste des employés ",
                    menu = 'gestion',
                    options = option       
                })
               
                info.identifier = v.identifier
                info.grade = v.job_grade
            end     
        
    end
    end)
end


function ModifyEmployed()
    local option = {}
    lib.callback('Moto:concess_salaire_table', false, function(result)
        for k, v in pairs(result) do 
            lib.registerContext({
                id = 'modify_employed',
                title = 'Gestion de l\'employé',
                menu = 'list_employed',
                table.insert(option, {
                    
                    value = v.grade, 
                    label = v.label.. " - Grade : " ..v.grade 
                    
                }),
                options = {
                    {
                        title = "Changer le grade",
                        icon = "fa-solid fa-user-gear", 
                        onSelect = function()
                            local input = lib.inputDialog("Choisir le nouveau grade", {
                                {type = 'select', label = "Grade", default = "Grade actuel : " ..info.grade, options = option}
                            })
                            if input then 
                                TriggerServerEvent("Moto:concess_modify_grade", input[1], info.identifier)
                                lib.showContext('list_employed')
                            else 
                                lib.showContext('list_employed')
                            end 
                        end 
                    },
                    {
                        title = "Virer l'employé",
                        icon = "fa-solid fa-user-minus",
                        onSelect = function()
                            TriggerServerEvent('Moto:concess_delete_grade', info.identifier)
                        end 
                    },
                }
            })
        end 
        lib.showContext('modify_employed')
    end)
    
end 

function GestionSalaire()
    local option = {}
    lib.callback('Moto:concess_salaire_table', false, function(result)
        if result then
            for k, v in pairs(result) do 
                table.insert(option, {
                    title = "Grade : " ..v.grade.. "\n Salaire : " ..v.salary,
                    description = nil,
                    icon = 'fa-solid fa-user',
                    arrow = true,      
                    onSelect = function()
                        local input = lib.inputDialog('Modification Salaire', {
                            {type = 'number', label = 'Salaire', description = 'Définissez le salaire pour le grade : ' ..v.label, default = v.salary ,required = true}
                        })
                        if input then
                           
                            if v.grade == 4 and input[1] > Config.BossMenu.MaxSalaryBoss then
                                lib.notify({
                                    title = 'Dépot', 
                                    type = 'error',
                                    description = 'Vous ne pouvez pas dépasser le montant de : ' ..Config.BossMenu.MaxSalaryBoss
                                })
                            else 
                                somme = input[1]
                                TriggerServerEvent('Moto:concess_change_salaire', somme, v.grade)
                            end 
                        end
                    end   
                })
                lib.registerContext({
                    id = 'list_salary',
                    title = "Liste des Salaires",
                    options = option
                        
                })
                
            end     
        end
        lib.showContext('list_salary')
    end)
end

function GestionFinance()
  
    lib.callback('Moto:concess_money', false, function(result)
        if result then
            for k, v in pairs(result) do
                lib.registerContext({
                    id = 'list_finance',
                    title = 'Finances de l\'Entreprise',
                    options = {
                        {
                            title = "Compte de l'entreprise : \n" ..v.money,
                            icon = "fa-solid fa-chart-line"
                        },
                        {
                            title = "Ajouter au compte",
                            arrow = true,
                            onSelect = function()
                                local input = lib.inputDialog('Ajouter au compté',{
                                    {type = 'number', label = 'Somme à ajouter', description = 'Définissez la somme à ajouter au compte de l\'entreprise.',required = true}
                                })
                                if input then
                                    somme = input[1]
                                    TriggerServerEvent('Moto:add_money_society', v.money, somme)
                                end
                            end
                        },
                        {
                            title = "Retirer du compte",
                            arrow = true,
                            onSelect = function()
                                local input = lib.inputDialog('Retirer du compte',{
                                    {type = 'number', label = 'Somme à retirer', description = 'Définissez la somme à retirer du compte de l\'entreprise.',required = true}
                                })
                                if input then
                                    somme = input[1]
                                    TriggerServerEvent('Moto:remove_money_society', v.money, somme)
                                end
                            end
                        }
                    }
                })
            end
        end
        lib.showContext('list_finance')
    end)
end



function GestionVeh()
    local option = {}
    local statut = nil
    local iconColor = nil
    lib.callback("Moto:concess_GetVehicleSociety",false, function(result)
        if #result > 0 then 
            for k, v in pairs(result) do
                if v.stored == 0 then 
                    statut = 'Sortie'
                    iconColor = 'FF2D2D'
                else 
                    statut = 'Dans le garage'
                    iconColor = 'B0FE9A'
                end
                table.insert(option, {
                    title = v.plate,
                    description = 'Statut du véhicule : ' ..statut,
                    arrow = true,
                    icon = "fa-solid fa-square-parking",
                    iconColor = iconColor,
                    onSelect = function()
                        ActionVehicleSociety(v.plate, v.vehicle, v.stored, v.society)
                    end,

                })
                lib.registerContext({
                    id = 'GestionVehicle',
                    title = 'Gestion des Véhicules',
                    options = option 
                })
                
            end 
        else
            table.insert(option, {
                title = 'Vous n\'avez pas de véhicule'
            })
            lib.registerContext({
                id = 'GestionVehicle',
                title = 'Gestion des Véhicules',
                options = option 
            }) 
        end 
        lib.showContext('GestionVehicle')
    end)
  
end

function ActionVehicleSociety(plate, vehicle, stored, society)
    local option = {} 
    if stored == 1 then 
        lib.registerContext({
            id = 'OptionsVehicle', 
            title = 'Gestion : ' ..plate,
            menu = 'GestionVehicle',
            options = {
                {
                    title = 'Vendre ce véhicule',
                    icon = "fa-solid fa-hand-holding-dollar",
                    onSelect = function()
                        local name = GetDisplayNameFromVehicleModel(json.decode(vehicle).model)
                        TriggerServerEvent('Moto:concess_SellVehicleSociety', plate, name, society)
                    end
                },

            }
        })
    else
        lib.registerContext({
            id = 'OptionsVehicle', 
            title = 'Gestion : ' ..plate,
            menu = 'GestionVehicle',
            options = {
                {
                    title = 'Vendre ce véhicule',
                    onSelect = function()
                        local name = GetDisplayNameFromVehicleModel(json.decode(vehicle).model)
                        TriggerServerEvent('Moto:concess_SellVehicleSociety', plate, name, society)
                    end
                }, 
                {
                    title = 'Ramener le véhicule au Garage',
                    icon = "fa-solid fa-arrow-rotate-left",
                    onSelect = function()
                       
                        local VehMaps = ESX.Game.GetVehicles()

                        for k , v in pairs(VehMaps) do
                            if string.upper(trim(GetVehicleNumberPlateText(v))) == string.upper(trim(plate)) then 
                                print('Véhicule trouvé ! - Suppression en cours')
                                properties = ESX.Game.GetVehicleProperties(v)
                                ESX.Game.DeleteVehicle(v)
                            else 
                                print('Pas de véhicule trouvé')
                            end 
                            
                        end 
                        TriggerServerEvent('Moto:concess_CautionVehicleSociety', plate)
                            lib.notify({
                                title = 'Garage',
                                description = 'Véhicule ramené au garage !',
                                type = 'success'
                            })
                            
                    end
                
                }

            }
        })
    end 
    lib.showContext('OptionsVehicle')
end 

function trim(s)
    return s:match'^%s*(.*%S)' or ''
end