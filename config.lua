Config = {}

Config.Locale = 'fr'

-- Blips et Markers pour les points d'intérêt
Config.Zones = {
    -- Station principale
    MainStation = {
        Pos = vector3(246.0, -1197.0, 38.0), -- Station Metro Central (ajustez si nécessaire)
        Size = {x = 1.5, y = 1.5, z = 1.0},
        Color = {r = 50, g = 50, b = 204},
        Type = 1,
        BlipSprite = 513, -- Sprite pour train
        BlipColor = 0, -- Bleu
        BlipName = "Dépôt Ferroviaire"
    },
    
    -- Points de prise de service
    Cloakroom = {
        Pos = vector3(249.0, -1200.0, 38.0),
        Size = {x = 1.5, y = 1.5, z = 1.0},
        Color = {r = 0, g = 255, b = 0},
        Type = 20
    },
    
    -- Points de spawn des trains
    VehicleSpawner = {
        Pos = vector3(252.0, -1204.0, 38.0),
        Size = {x = 3.0, y = 3.0, z = 1.0},
        Color = {r = 0, g = 255, b = 0},
        Type = 36
    }
}

-- Points d'arrêt des trains/métros
Config.Stops = {
    Metro = {
        {pos = vector3(246.0, -1197.0, 38.0), name = "Central Station"},
        {pos = vector3(-297.0, -333.0, 10.0), name = "Downtown Station"},
        {pos = vector3(-547.0, -1286.0, 27.0), name = "South Station"}
    },
    Freight = {
        {pos = vector3(1239.0, -1289.0, 35.0), name = "Freight Terminal"},
        {pos = vector3(2808.0, 4312.0, 46.0), name = "Industrial Zone"},
        {pos = vector3(-1042.0, 4920.0, 205.0), name = "Mountain Depot"}
    }
}

-- Véhicules disponibles
Config.Vehicles = {
    {
        label = "Metro Train",
        name = "metrotrain",
        type = "metrotrain"
    },
    {
        label = "Freight Train",
        name = "freight",
        type = "freight"
    }
}

-- Contrôles du train
Config.Controls = {
    START_STOP = 71, -- INPUT_VEH_ACCELERATE (W par défaut)
    SPEED_UP = 72,   -- INPUT_VEH_BRAKE (S par défaut)
    HORN = 86,       -- INPUT_VEH_HORN (H par défaut)
    LIGHTS = 74      -- INPUT_VEH_HEADLIGHT (H par défaut)
}

-- Paramètres réalistes
Config.Realism = {
    -- accélération m/s², freinage m/s²
    Acceleration = 0.8,
    Brake = 1.2,
    EmergencyBrake = 4.0,
    -- offsets pour attacher les wagons (en mètres)
    WagonSpacing = 11.5,
    -- conversion du speed game units à km/h approximatif si besoin
    SpeedUnit = 3.6
}

-- Grades du métier
Config.Grades = {
    {
        grade = 0,
        name = "recruit",
        label = "Stagiaire",
        salary = 200
    },
    {
        grade = 1,
        name = "metro",
        label = "Conducteur Metro",
        salary = 400
    },
    {
        grade = 2,
        name = "freight",
        label = "Conducteur Fret",
        salary = 600
    },
    {
        grade = 3,
        name = "boss",
        label = "Chef de Gare",
        salary = 800
    }
}