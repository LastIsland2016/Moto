ESX = exports["es_extended"]:getSharedObject() 

----------- ANNONCES

RegisterServerEvent('Moto_concessmoto:AnnonceOuverture')
AddEventHandler('Moto_concessmoto:AnnonceOuverture', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	local namexPlayer = GetPlayerName(_source)
	print(namexPlayer)
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		
		TriggerClientEvent('ox_lib:notify', xPlayers[i], {
			id = 'AO',
			title = 'concessionnaire',
			description = 'Le concessmotoionnaire est maintenant Ouvert !',
			duration = 6000,
			icon = Config.MenuF6.Annonce.Ouverture.Icon,
            iconColor = Config.MenuF6.Annonce.Ouverture.IconColor,
            position = Config.MenuF6.Annonce.Ouverture.Position,
            style = {
                backgroundColor = Config.MenuF6.Annonce.Ouverture.BackgroundColor,
                ['.description'] = {
                    color = Config.MenuF6.Annonce.Ouverture.ColorDesc
                }, 
                ['.title'] = {
                    color = Config.MenuF6.Annonce.Ouverture.ColorTitle
                }
            }
		})
	end
end)

RegisterServerEvent('Moto_concessmoto:AnnonceFermeture')
AddEventHandler('Moto_concessmoto:AnnonceFermeture', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	local namexPlayer = GetPlayerName(_source)
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		
		TriggerClientEvent('ox_lib:notify', xPlayers[i], {
			id = 'AF',
			title = 'Concessionnaire',
			description = 'Le concessionnaire ferme ses portes pour aujourd\'hui !',
			duration = 6000,
			icon = Config.MenuF6.Annonce.Fermeture.Icon,
            iconColor = Config.MenuF6.Annonce.Fermeture.IconColor,
            position = Config.MenuF6.Annonce.Fermeture.Position,
            style = {
                backgroundColor = Config.MenuF6.Annonce.Fermeture.BackgroundColor,
                ['.description'] = {
                    color = Config.MenuF6.Annonce.Fermeture.ColorDesc
                }, 
                ['.title'] = {
                    color = Config.MenuF6.Annonce.Fermeture.ColorTitle
                }
            }
		})
	end
end)

RegisterServerEvent('Moto_concessmoto:AnnonceRecrutement')
AddEventHandler('Moto_concessmoto:AnnonceRecrutement', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	local namexPlayer = GetPlayerName(_source)
	
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		
		TriggerClientEvent('ox_lib:notify', xPlayers[i], {
			id = 'AR',
			title = 'Concessionnaire',
			description = 'Recrutement en cours, rendez-vous au concessionnaire !',
			duration = 6000,
			icon = Config.MenuF6.Annonce.Recrutement.Icon,
            iconColor = Config.MenuF6.Annonce.Recrutement.IconColor,
            position = Config.MenuF6.Annonce.Recrutement.Position,
            style = {
                backgroundColor = Config.MenuF6.Annonce.Recrutement.BackgroundColor,
                ['.description'] = {
                    color = Config.MenuF6.Annonce.Recrutement.ColorDesc
                }, 
                ['.title'] = {
                    color = Config.MenuF6.Annonce.Recrutement.ColorTitle
                }
            }
		})
	end
end)

RegisterServerEvent('Moto_concessmoto:AnnoncePerso')
AddEventHandler('Moto_concessmoto:AnnoncePerso', function(content)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	local namexPlayer = GetPlayerName(_source)
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		
		TriggerClientEvent('ox_lib:notify', xPlayers[i], {
			id = 'AR',
			title = 'Concessionnaire',
			description = content,
			duration = 6000,
			icon = Config.MenuF6.Annonce.Perso.Icon,
            iconColor = Config.MenuF6.Annonce.Perso.IconColor,
            position = Config.MenuF6.Annonce.Perso.Position,
            style = {
                backgroundColor = Config.MenuF6.Annonce.Perso.BackgroundColor,
                ['.description'] = {
                    color = Config.MenuF6.Annonce.Perso.ColorDesc
                }, 
                ['.title'] = {
                    color = Config.MenuF6.Annonce.Perso.ColorTitle
                }
            }
		})
	end
end)

----------------- BOSS

RegisterNetEvent('Moto:concessmoto_change_salaire')
AddEventHandler('Moto:concessmoto_change_salaire', function(input, grade)
	MySQL.update('UPDATE job_grades SET salary = ? WHERE grade = ?',
		{input, grade}, function(affectedRows)		
	end)
	TriggerClientEvent('ox_lib:notify', source,{
		id = 'norif_change_salary',
		title = 'Changement de salaire',
		position = 'center-left',
		type = 'success',
		description = 'Le salaire du grade : ' ..grade.. ' a changé : ' ..input.. "$"
	})
end)

RegisterNetEvent('Moto:concessmoto_recruit')
AddEventHandler('Moto:concessmoto_recruit', function(id)
	local xPlayer = ESX.GetPlayerFromId(id)
	local identifier = xPlayer.getIdentifier()
	MySQL.update('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', {'concessmoto', '0', identifier},function(affectedRows)
	end)
end)

lib.callback.register('Moto:concessmoto_money', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
	local result = MySQL.query.await('SELECT * FROM addon_account_data WHERE account_name = ?', {'society_concessmoto'})
	return result
end)

RegisterNetEvent('Moto:add_money_society')
AddEventHandler('Moto:add_money_society', function(base_money, add_money)
	local xPlayer = ESX.GetPlayerFromId(source)
	local new_money = tonumber(base_money + add_money)
	if xPlayer.getAccount('money').money > add_money then
		MySQL.update('UPDATE addon_account_data SET money = ? WHERE account_name = ?',
			{new_money, 'society_concessmoto'}, function(affectedRows)
		end)
		xPlayer.removeAccountMoney('money', add_money)
		TriggerClientEvent('ox_lib:notify', source,{
			id = 'norif_change_salary',
			title = 'Ajout de fonds',
			position = 'center-left',
			type = 'success',
			description = 'Vous avez effectué un dépôt de : ' ..add_money.. "$ vers l'entreprise."
		})
	else 
		TriggerClientEvent('ox_lib:notify', source,{
			id = 'norif_change_salary',
			title = 'Ajout de fonds',
			position = 'center-left',
			type = 'error',
			description = "Vous n'avez pas assez d'argent pour faire ce dépôt."
		})
	end
end)

RegisterNetEvent('Moto:remove_money_society')
AddEventHandler('Moto:remove_money_society', function(base_money, remove_money)
	local xPlayer = ESX.GetPlayerFromId(source)
	local new_money = tonumber(base_money - remove_money)
	if base_money > remove_money then
		MySQL.update('UPDATE addon_account_data SET money = ? WHERE account_name = ?',
			{new_money, 'society_concessmoto'}, function(affectedRows)
		end)
		xPlayer.addAccountMoney('money', remove_money)
		TriggerClientEvent('ox_lib:notify', source,{
			id = 'norif_change_salary',
			title = 'Ajout de fonds',
			position = 'center-left',
			type = 'success',
			description = 'Vous avez effectué un retrait de : ' ..remove_money.. "$."
		})
	else 
		TriggerClientEvent('ox_lib:notify', source,{
			id = 'norif_change_salary',
			title = 'Retrait de fonds',
			position = 'center-left',
			type = 'error',
			description = "Il n'y a pas assez d'argent pour faire ce retrait."
		})
	end
end)

RegisterNetEvent('Moto:concessmoto_modify_grade')
AddEventHandler('Moto:concessmoto_modify_grade', function(new_grade, identifier)
	MySQL.update('UPDATE users SET job_grade = ? WHERE identifier = ?', {new_grade, identifier})
	TriggerClientEvent('ox_lib:notify', source,{
		title = 'Changement de grade',
		position = 'center-left',
		type = 'success',
		description = "Vous avez changé le grade d'un employé avec succès."
	})
end)

RegisterNetEvent('Moto:concessmoto_delete_grade')
AddEventHandler('Moto:concessmoto_delete_grade', function(identifier)
	MySQL.update('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', {'unemployed', 0, identifier})
	TriggerClientEvent('ox_lib:notify', source,{
		title = 'Employé Viré',
		position = 'center-left',
		type = 'success',
		description = "Vous avez viré un employé avec succès."
	})
end)

----------------- AUTOMATISATION

lib.callback.register('Moto:concessmoto_auto_verif', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
	local result = MySQL.query.await('SELECT * FROM automatisation WHERE society = ?', {'concessmoto'})
	return result
end)

RegisterNetEvent('Moto:concessmoto_update_automatisation')
AddEventHandler('Moto:concessmoto_update_automatisation', function(statut)
	MySQL.update('UPDATE automatisation SET statut = ? WHERE society = ?',
		{statut, 'concessmoto'}, function(affectedRows)
	end)
	TriggerClientEvent('ox_lib:notify', source,{
		id = 'notif_change_statut',
		title = 'Changement de mode',
		icon = Config.MenuF6.ChangementOfMode.Icon,
            iconColor = Config.MenuF6.ChangementOfMode.IconColor,
            position = Config.MenuF6.ChangementOfMode.Position,
            style = {
                backgroundColor = Config.MenuF6.ChangementOfMode.BackgroundColor,
                ['.description'] = {
                    color = Config.MenuF6.ChangementOfMode.ColorDesc
                }, 
                ['.title'] = {
                    color = Config.MenuF6.ChangementOfMode.ColorTitle
                }
            },
		description = "Vous avez défnini le mode sur : " ..statut
	})
end)

----------------- COMPTOIR

RegisterNetEvent('Moto:concessmoto_add_category')
AddEventHandler('Moto:concessmoto_add_category', function(name, label, image)
	print(label)
	print(name)
	local _src = source
	local result = MySQL.query.await('SELECT * FROM moto_categories WHERE name = ?', {name})
	if #result == 0 then
		MySQL.insert.await('INSERT INTO moto_categories (name, label, image) VALUES (?, ?, ?)',
			{name, label, image}, function()
		end)
		TriggerClientEvent('ox_lib:notify', _src ,{
			id = 'notif_add_category_success',
			title = 'Création catégorie',
			position = 'center-left',
			type = 'success',
			description = 'Vous avez créé la catégorie : ' ..label
		})
	else 
		TriggerClientEvent('ox_lib:notify', _src,{
			id = 'notif_add_category_error',
			title = 'Création catégorie',
			position = 'center-left',
			type = 'error',
			description = 'La catégorie ' ..label.. ' existe déjà !'
		})
	end 
end)

RegisterNetEvent('Moto:concessmoto_add_vehicle')
AddEventHandler('Moto:concessmoto_add_vehicle', function(label, model, price, category)

	local _src = source
	local result = MySQL.query.await('SELECT * FROM moto_categories WHERE name = ?', {category})
	local result_check_veh = MySQL.query.await('SELECT * FROM moto WHERE name = ?', {model})
	if #result == 1 then 
		if #result_check_veh == 0 then 
			MySQL.insert.await('INSERT INTO moto (name, model, price, category) VALUES (?, ?, ?, ?)',
				{label, model, price, category}, function()
			end)
			TriggerClientEvent('ox_lib:notify', _src ,{
				id = 'notif_add_category_success',
				title = 'Ajout Véhicule',
				position = 'center-left',
				type = 'success',
				description = 'Vous avez ajouté au catalogue : ' ..label
			})
		else 
			TriggerClientEvent('ox_lib:notify', _src,{
				id = 'notif_add_category_error',
				title = 'Ajout Véhicule',
				position = 'center-left',
				type = 'error',
				description = 'Le véhicule ' ..label.. ' existe déjà !'
			})
		end
	else 
		TriggerClientEvent('ox_lib:notify', _src,{
			id = 'notif_add_category_error',
			title = 'Ajout Véhicule',
			position = 'center-left',
			type = 'error',
			description = 'La catégorie ' ..category.. ' n\'existe pas !'
		})
	end

end)

lib.callback.register('Moto:concessmoto_liste_cat', function(source)
	local result = MySQL.query.await('SELECT * FROM moto_categories', function()end)
	return result
end)

RegisterNetEvent('Moto:concessmoto_update_category')
AddEventHandler('Moto:concessmoto_update_category', function(name, newname, newcat)
	local _src = source
	local result = MySQL.query.await('SELECT * FROM moto_categories WHERE name = ?', {newname}, function()end)
	if #result == 0 then
		MySQL.update.await('UPDATE moto_categories SET name = ?, label = ? WHERE name = ?', {newname, newcat, name},function()end)
		TriggerClientEvent('ox_lib:notify', _src ,{
			id = 'notif_add_category_success',
			title = 'Modification Catégorie',
			position = 'center-left',
			type = 'success',
			description = 'Vous avez modifié la catégorie : ' ..newcat
		})
	else 
		TriggerClientEvent('ox_lib:notify', _src,{
			id = 'notif_add_category_error',
			title = 'Modification Catégorie',
			position = 'center-left',
			type = 'error',
			description = 'La catégorie ' ..newname.. ' existe déjà !'
		})
	end
end) 

lib.callback.register('Moto:concessmoto_liste_veh', function(source)
	local result = MySQL.query.await('SELECT * FROM moto', function()end)
	return result
end)

lib.callback.register('Moto:concessmoto_liste_veh_from_cat', function(source, cat)
	local result = MySQL.query.await('SELECT * FROM moto WHERE category = ?', {cat},function()end)
	return result
end)

RegisterNetEvent('Moto:concessmoto_update_vehicle')
AddEventHandler('Moto:concessmoto_update_vehicle', function(model, newlabel, newmodel, newprice, newcat)
	local _src = source
	local result = MySQL.query.await('SELECT * FROM moto WHERE model = ?', {newmodel}, function()end)
	local result_check_cat = MySQL.query.await('SELECT * FROM moto_categories WHERE name = ?', {newcat}, function()end)
	
		if #result_check_cat == 1 then
			MySQL.update.await('UPDATE vehicles SET name = ?, model = ?, price = ?, category = ? WHERE model = ?', {newlabel, newmodel, newprice, newcat, model},function()end)
			TriggerClientEvent('ox_lib:notify', _src ,{
				id = 'notif_update_vehicle_success',
				title = 'Modification Véhicules',
				position = 'center-left',
				type = 'success',
				description = 'Vous avez modifié le véhicule : ' ..newlabel
			})
		else 
			TriggerClientEvent('ox_lib:notify', _src,{
				id = 'notif_update_vehicle_error',
				title = 'Ajout Véhicule',
				position = 'center-left',
				type = 'error',
				description = 'La catégorie ' ..newcat.. ' n\'existe pas !'
			})
		end 
	
end)

RegisterNetEvent('Moto:concessmoto_remove_vehicle')
AddEventHandler('Moto:concessmoto_remove_vehicle', function(name)
	local _src = source
	MySQL.update('DELETE FROM moto WHERE model = ?', {name}, function()end)
	TriggerClientEvent('ox_lib:notify', _src,{
		id = 'notif_remove_vehicle_success',
		title = 'Suppression Véhicule',
		position = 'center-left',
		type = 'success',
		description = 'Le Véhicule ' ..name.. ' a été supprimé !'
	})
end)

RegisterNetEvent('Moto:concessmoto_remove_cat')
AddEventHandler('Moto:concessmoto_remove_cat', function(name)
	local _src = source
	MySQL.update('DELETE FROM moto_categories WHERE name = ?', {name}, function()end)
	TriggerClientEvent('ox_lib:notify', _src,{
		id = 'notif_remove_vehicle_success',
		title = 'Suppression Véhicule',
		position = 'center-left',
		type = 'success',
		description = 'La catégorie ' ..name.. ' a été supprimé !'
	})
end)


lib.callback.register('Moto:concessmoto_verif_money', function(source, price, paiement) 
	print(price)
	print(paiement)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	
    local identifier = xPlayer.getIdentifier()
	local countMoney = xPlayer.getAccount(paiement).money 

	if countMoney > price then
		return true
	else 
		return false
	end 
end)

lib.callback.register('Moto:concessmoto_verif_money_vendeur', function(source, price, paiement, xPlayer) 
	
	local xPlayerX = ESX.GetPlayerFromId(xPlayer)
	local countMoney = xPlayerX.getAccount(paiement).money 

	if countMoney > price then
		return true
	else 
		return false
	end 
end)

lib.callback.register('Moto:concessmoto_verif_money_entreprise', function(source, price, entreprise) 

	local countMoney = MySQL.query.await('SELECT * FROM addon_account_data WHERE account_name = ?', {entreprise}, function()end)
	print(countMoney[1].money)
	if countMoney[1].money >= price then 
		return true
	else 
		return false
	end 
end)

RegisterNetEvent('Moto:concessmoto_buy_car')
AddEventHandler('Moto:concessmoto_buy_car', function(name, price, model, plate, stock, color, paiement)
	local xPlayer = ESX.GetPlayerFromId(source)
	print(source)
    local identifier = xPlayer.getIdentifier()
	local countMoney = xPlayer.getAccount(paiement).money 
	local _src = source
	
		MySQL.insert.await('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (?, ?, ?)',
			{identifier, plate, json.encode(model)}, function()
		end)
		
		MySQL.update.await('UPDATE moto SET stock = ? WHERE name = ?', {tonumber(stock-1), name})
		TriggerClientEvent('ox_lib:notify', _src ,{
			id = 'notif_add_category_success',
			title = 'Achat',
			position = 'center-left',
			type = 'success',
			description = 'Bravo ! Vous êtes le nouvel heureux propriétaire d\'un(e) : ' ..name
		})
		local result = MySQL.query.await('SELECT * FROM addon_account_data WHERE account_name = ?', {'society_concessmoto'})
		local base_money = result[1].money
		--print(money)
		local new_money = tonumber(base_money + price)
		xPlayer.removeAccountMoney(paiement, price)
		MySQL.update.await('UPDATE addon_account_data SET money = ? WHERE account_name = ?',
		{new_money, 'society_concessmoto'})

	 
end)

RegisterNetEvent('Moto:concessmoto_buy_car_vendeur')
AddEventHandler('Moto:concessmoto_buy_car_vendeur', function(name, price, model, plate, stock, color, paiement, xPlayer)
	local source = source
	local _src = xPlayer
	local xPlayerX = ESX.GetPlayerFromId(_src)
	local identifier = xPlayerX.getIdentifier()
	local countMoney = xPlayerX.getAccount(paiement).money 
		MySQL.insert.await('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (?, ?, ?)',
			{identifier, plate, json.encode(model)}, function()
		end)
		TriggerClientEvent('ox_lib:notify', _src,{
			id = 'notif_add_category_success',
			title = 'Achat',
			position = 'center-left',
			type = 'success',
			description = 'Bravo ! Vous êtes l\'heureux propriétaire d\'un(e) : ' ..name
		})
		local result = MySQL.query.await('SELECT * FROM addon_account_data WHERE account_name = ?', {'society_concessmoto'})
		local base_money = result[1].money
		--print(money)
		xPlayerX.removeAccountMoney(paiement, price)
		local new_money = tonumber(base_money + price)
		MySQL.update.await('UPDATE addon_account_data SET money = ? WHERE account_name = ?',
		{new_money, 'society_concessmoto'})
		MySQL.update.await('UPDATE moto SET stock = ? WHERE name = ?', {tonumber(stock-1), name})
		TriggerClientEvent('ox_lib:notify', source,{
			title = 'Vente',
			position = 'center-left',
			type = 'success',
			description = 'Bravo ! Vous avez vendu : ' ..name.. " pour : " ..price.. "$"
		})
	
	 
end)

RegisterNetEvent('Moto:concessmoto_buy_car_entreprise')
AddEventHandler('Moto:concessmoto_buy_car_entreprise', function(name, price, model, plate, stock, label, color, entreprise)
	local _src = source
	MySQL.insert.await('INSERT INTO society_vehicles (society, plate, vehicle, label) VALUES (?, ?, ?, ?)', {entreprise, plate, json.encode(model), label}, function()end)
	local result = MySQL.query.await('SELECT * FROM addon_account_data WHERE account_name = ?', {'society_concessmoto'})
		local base_money = result[1].money
		--print(money)
		
		local result = MySQL.query.await('SELECT * FROM addon_account_data WHERE account_name = ?', {'society_concessmoto'})
		local base_money = result[1].money
		local new_money = tonumber(base_money - price)
		local add_money = tonumber(base_money + price)
		MySQL.update.await('UPDATE addon_account_data SET money = ? WHERE account_name = ?',
		{new_money, entreprise})

		MySQL.update.await('UPDATE moto SET stock = ? WHERE name = ?', {tonumber(stock-1), name})
		TriggerClientEvent('ox_lib:notify', _src,{
			title = 'Vente',
			position = 'center-left',
			type = 'success',
			description = 'Bravo ! Vous avez vendu : ' ..name.. " pour : " ..price.. "$"
		})
		if entreprise ~= 'society_concessmoto' then 
			MySQL.update.await('UPDATE addon_account_data SET money = ? WHERE account_name = ?',
			{add_money, 'society_concessmoto'})
		else 
			print('c est ta propre entreprise')
		end 

end)

ESX.RegisterServerCallback('Moto:concessmoto_isPlateTaken', function(source, cb, plate)
	MySQL.scalar('SELECT plate FROM owned_vehicles WHERE plate = ?', {plate},
	function(result)
		cb(result ~= nil)
	end)
end)

RegisterNetEvent('Moto:concessmoto_restock')
AddEventHandler('Moto:concessmoto_restock', function(stock, model, price)
	local _src = source
	local money = 0
	local result = MySQL.query.await('SELECT * FROM addon_account_data WHERE account_name = ?', {'society_concessmoto'})
		local base_money = result[1].money
		local new_money = tonumber(base_money - price)
		MySQL.update.await('UPDATE addon_account_data SET money = ? WHERE account_name = ?',
		{new_money, 'society_concessmoto'})
		MySQL.update.await('UPDATE moto SET stock = ? WHERE model = ?', {tonumber(stock+1), model})
			TriggerClientEvent('ox_lib:notify', _src ,{
				title = 'Achat',
				position = 'center-left',
				description = 'Vous avez acheté une unité de stock supplémentaire pour : '..model,
				icon = Config.Livraison.Delivred.Icon,
				iconColor = Config.Livraison.Delivred.IconColor,
				position = Config.Livraison.Delivred.Position,
				style = {
					backgroundColor = Config.Livraison.Delivred.BackgroundColor,
					['.description'] = {
						color = Config.Livraison.Delivred.ColorDesc
					}, 
					['.title'] = {
						color = Config.Livraison.Delivred.ColorTitle
					}
				}
			})
		
end)


RegisterServerEvent('Moto:concessmoto_add_historique')
AddEventHandler('Moto:concessmoto_add_historique', function(typee, cost, gain, vehicle)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
    local identifier = GetPlayerName(_src)
	local date = os.date("*t", os.time()).day.. "/" .. os.date("*t", os.time()).month .. "/" .. os.date("*t", os.time()).year .. " à " .. os.date("*t", os.time()).hour+1 .. "h" .. os.date("*t", os.time()).min
	MySQL.insert.await('INSERT INTO historique_concessionnaire_moto (type, gain, cost, vehicle, identifier, date) VALUES (?, ?, ?, ?, ?, ?)', {typee, gain, cost, vehicle, identifier, date})
end)

lib.callback.register('Moto:concess_historique', function(source)
	local result = MySQL.query.await('SELECT * FROM historique_concessionnaire_moto')
	return result
end)

RegisterNetEvent('Moto:concessmoto_delete_historique')
AddEventHandler('Moto:concessmoto_delete_historique', function(id)
	local _src = source
	MySQL.update('DELETE FROM historique_concessionnaire_moto WHERE id = ?', {id}, function()
		TriggerClientEvent('ox_lib:notify', _src ,{
			title = 'Achat',
			position = 'center-left',
			type = 'success',
			description = 'Vous avez supprimé une page de l\'historique'
		})
	end)
end)


----------------- CALLBACK


lib.callback.register('Moto:concessmoto_employed', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
	local result = MySQL.query.await('SELECT * FROM users WHERE job = ?', {'concessmoto'})
	return result
end)


lib.callback.register('Moto:concessmoto_salaire_table', function(source)

	local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
	local result = MySQL.query.await('SELECT * FROM job_grades WHERE job_name = ?', {'concessmoto'})
	
	return result
end)

-----------------


local function AddCarkey(source, plate, model)
    exports.ox_inventory:AddItem(source, Config.Keyitem, 1, { plate = plate, model = model })
end

lib.callback.register('carkeys:callback:getPlayerVehicles', function(source, target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local vehicles = {}
    local result = MySQL.query.await('SELECT * FROM owned_vehicles WHERE owner = ?', { xPlayer.identifier })
    if result then
        for k, v in pairs(result) do
            local vehicle = json.decode(v.vehicle)
            vehicles[#vehicles + 1] = {
                plate = vehicle.plate,
                model = vehicle.model
            }
        end
        return vehicles
    end
    return false        
end)

RegisterNetEvent('carkeys:server:buyKey', function(plate, model)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    MySQL.single('SELECT owner FROM owned_vehicles WHERE plate = ?', { plate }, function(result)
        if result then
            if xPlayer.getMoney() >= Config.KeyPrice then
                xPlayer.removeMoney(Config.KeyPrice)
                AddCarkey(_source, plate, model)
                xPlayer.showNotification('Vous avez acheté une clé pour votre véhicule')
            else
                xPlayer.showNotification('Vous n\'avez pas assez d\'argent')
            end
        else
            xPlayer.showNotification('Ce n\'est pas votre véhicule !')
        end
    end)
end)

------------ GARAGE
 
lib.callback.register('Moto:concessmoto_garage', function(source)
	local result = MySQL.query.await('SELECT * FROM society_vehicles WHERE society = @society and stored = @stored', {
		['@society'] = 'society_concessmoto',
		['@stored'] = 1
	})
	return result
end)

lib.callback.register("Moto:concessmoto_VehiculeSociety", function(source, plate)
	local result = MySQL.query.await('SELECT * FROM society_vehicles WHERE society = ? and plate = ?', {'society_concessmoto', plate})
	print(#result)
	if #result == 1 then 
		return true
	end
end)

lib.callback.register('Moto:concessmoto_GetVehicleSociety', function(source)
	local result = MySQL.query.await('SELECT * FROM society_vehicles WHERE society = ?', {'society_concessmoto'})
	return result
end)

RegisterNetEvent("Moto:concessmoto_SaveStatsEntrer")
AddEventHandler("Moto:concessmoto_SaveStatsEntrer", function(plate, stored, properties)
	print(plate)
    MySQL.update('UPDATE society_vehicles SET stored = ?, vehicle = ? WHERE plate = ?', {
		stored,
		json.encode(properties),
		plate,
	}, function() end)
end)

RegisterNetEvent('Moto:concessmoto_SellVehicleSociety')
AddEventHandler('Moto:concessmoto_SellVehicleSociety', function(plate, displayname, society)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	local add_money = nil
	print(society)

	local result2 = MySQL.query.await('SELECT * FROM  moto WHERE model = ?', {displayname})
	local result3 = MySQL.query.await('SELECT * FROM addon_account_data WHERE account_name = ?', {society})
	local base_money = result3[1].money
	print(base_money)
	for k, v in pairs(result2) do 
		add_money = tonumber(v.price*(1-25/100))
		local new_money = tonumber(base_money + add_money)

		if result2 and result3 then 
			local result1 = MySQL.update.await('DELETE FROM society_vehicles WHERE plate = ? and society = ?', {plate, society})
			MySQL.update('UPDATE addon_account_data SET money = ? WHERE account_name = ?',
					{new_money, 'society_concessmoto'}, function(affectedRows)
						TriggerClientEvent('ox_lib:notify', _src ,{
							title = 'Revente',
							position = 'center-left',
							type = 'success',
							description = 'Vous avez vendu un véhicule de l\'entreprise: ' ..displayname.. '\n Votre entreprise a reçu : ' ..add_money 
						})
			end)
		end 
	
	end 
end)

RegisterNetEvent("Moto:concessmoto_SaveSortie")
AddEventHandler("Moto:concessmoto_SaveSortie", function(plate)
	MySQL.update.await('UPDATE society_vehicles SET stored = ? WHERE plate = ?', {0, plate})
end)

RegisterNetEvent('Moto:concessmoto_CautionVehicleSociety')
AddEventHandler('Moto:concessmoto_CautionVehicleSociety', function(plate)
	MySQL.update.await('UPDATE society_vehicles SET stored = ? WHERE plate = ?', {1, plate})
end)


---------- Coffre

local ox_inventory = exports.ox_inventory

AddEventHandler('onServerResourceStart', function(resourceName)

	 
	if resourceName == 'ox_inventory' or resourceName == GetCurrentResourceName() then

		
			exports.ox_inventory:RegisterStash(Config.Coffre.id, Config.Coffre.label, Config.Coffre.slots, Config.Coffre.weight)
		
	end
end)