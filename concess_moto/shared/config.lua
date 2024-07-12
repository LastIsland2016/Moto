Config = {
    
    FilterUse = true, -- Si true, alors vous aurez l'option du filtre en haut du catalogue, du menu d'achat des clefs... 
    --ATTENTION CETTE OPTION NECESSITE L'INSTALLATION DU OX_LIB PRESENT SUR LE DISCORD
    
    Blips = {
        Position = vector3(-37.5991, -1101.5325, 26.4223),
        Type = 661, 
        Size = 0.8,
        Color = 48,
        Title = 'Concessionnaire Moto'
    },
    -------------------
    --------- ICON ET COULEUR POUR LE MENU DES CATEGORIES DANS LE CATALOGUE
    -------------------
    Icon = {
        Type = {
            Category = "fa-solid fa-layer-group"
        },
        Color = {
            Category = '9272FF'
        }
    },
    -------------------
    --------- MENU F6
    -------------------
    MenuF6 = {
        --Repair = {
        --    BackgroundColor = '#4A4A4A',
        --    ColorDesc = '#909296',
        --    ColorTitle = '909296',
        --    Icon = "fa-solid fa-circle-check",
        --    IconColor = '#1BFB03',
        --    Position = 'center-left'

        --},
        --Annonce = {
        --    Ouverture = {
        --        BackgroundColor = '#4A4A4A',
        --        ColorDesc = '#909296',
        --        ColorTitle = '909296',
        --        Icon = "fa-solid fa-circle-check",
        --        IconColor = '#1BFB03',
        --        Position = 'center-left'
        --    },
        --    Fermeture = {
        --        BackgroundColor = '#4A4A4A',
        --        ColorDesc = '#909296',
        --        ColorTitle = '909296',
        --        Icon = "fa-solid fa-circle-check",
        --        IconColor = '#1BFB03',
        --       Position = 'center-left'
        --    },
        --    Recrutement = {
        --        BackgroundColor = '#4A4A4A',
        --        ColorDesc = '#909296',
        --        ColorTitle = '909296',
        --        Icon = "fa-solid fa-circle-check",
        --        IconColor = '#1BFB03',
        --        Position = 'center-left'
        --    },
        --    Perso = {
        --        BackgroundColor = '#4A4A4A',
        --        ColorDesc = '#909296',
        --        ColorTitle = '909296',
        --        Icon = "fa-solid fa-circle-check",
        --        IconColor = '#1BFB03',
        --        Position = 'center-left'
        --    }
        --}, 
        ChangementOfMode = {
            BackgroundColor = '#4A4A4A',
            ColorDesc = '#909296',
            ColorTitle = '909296',
            Icon = "fa-solid fa-circle-check",
            IconColor = '#1BFB03',
            Position = 'center-left'
        },
        
    },
    -------------------
    --------- OPTIONS LIVRAISON
    -------------------
    Livraison = {
        Plaque = "LASTISLAND",
        SpawnTruck = vector4(179.3941, -1128.2960, 29.4088, 92.7810),
        LocationToDelivery = vector4(-30.8328, -1080.6410, 26.6380, 70.2152),
        LocationToDestination = vector4(-158.7626, -890.1107, 29.1911, 69.0232),
        LocationStock = vector4(-30.8039, -1089.3693, 26.4209, 160.0112),
        EnCours = {
            BackgroundColor = '#4A4A4A',
            ColorDesc = '#909296',
            ColorTitle = 'FF7E43',
            Icon = "fa-solid fa-truck-ramp-box",
            IconColor = 'FF7E43',
            Position = 'center-left'
        },
        Finish = {
            BackgroundColor = '#4A4A4A',
            ColorDesc = '#909296',
            ColorTitle = '#909296',
            Icon = "fa-solid fa-circle-check",
            IconColor = '#1BFB03',
            Position = 'center-left'
        },
        Delivred = {
            BackgroundColor = '#4A4A4A',
            ColorDesc = '#909296',
            ColorTitle = '#909296',
            Icon = "fa-solid fa-circle-check",
            IconColor = '#1BFB03',
            Position = 'center-left'
        }
    },
    -------------------
    --------- MENU CLEFS
    -------------------
    -- LockingRange = 5.0, -- distance pour fermer un véhicule
    -- CycleVehicleClass = 13, -- interdire l'utilisation de clefs pour les vélos
    -- Keyitem = "carkeys", --nom de l'item que vous avre enregistré dans ox_inventory, dans notre cas c'est carkeys
    -- KeyPrice = 10, -- prix de la clef
    -- KeyShop = {
    --     Ped = {
    --         Model = 'a_m_m_genfat_01',
    --         Position = vector4(-31.0006, -1106.5168, 26.4224, 339.3292)
    --     }
    -- },
    -------------------
    --------- COFFRE
    -------------------
    Coffre = {
		id = 'society_concessmoto',
		label = 'Concessionnaire Moto',
		slots = 50,
		weight = 100000,
        Coords = vector4(0, 0, 0, 0)
	},
    -------------------
    --------- GARAGE
    -------------------
    Garage = {
        Ped = {
            model = 'cs_chengsr',
            position = vector4(0, 0, 0, 0)
        },
        SpawnVehicle = {
            coords = vector3(0, 0, 0),
            heading = 229.7664
        },
        VerifZoneSpawn = vector4(0, 0, 0, 0),
        StoredPosition = vector3(0, 0, 0)
    },
    -------------------
    --------- COMPTOIR
    -------------------
    Comptoir = {
        Coords = vector4(-55.1081, -1096.8512, 26.4419, 139.4661)
    },
    -------------------
    --------- CATALOGUE
    -------------------
    Catalogue = {
        Coords = vector4(-53.8786, -1097.4427, 26.4223, 39.5591),
        SpawnVehicle = {
            coords = vector3(-36.0606, -1099.7711, 26.4223),
            heading = 338.6482
        }
    },
    -------------------
    --------- MENU BOSS
    -------------------
    BossMenu = {
        Coords = vector4(0, 0, 0,0),
        MaxSalaryBoss = 100
    },
    -------------------
    --------- PREVIEW
    -------------------
    Preview = {
        SpawnVehicle = {
            coords = vector3(-43.3120, -1094.4469, 26.4223),
            heading = 154.1900, 
        },
        Cam = {
            statut = true,
            coords = vector3(-44.8789, -1099.2220, 26.4223),
            heading = 337.8977
        }
    }
}




