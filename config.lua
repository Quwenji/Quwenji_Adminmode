Config = {}

-- Name des Admin-Modus-Befehls
Config.AdminModeCommand = 'adminmode' -- Du kannst den Befehl hier ändern

-- Admin-Gruppen
Config.AdminGroups = { 'admin', 'superadmin' }

-- Transparenz-Einstellungen
Config.AdminTransparency = 150 -- Transparenzwert, wenn Admin-Modus aktiviert (0-255)
Config.NormalTransparency = 255 -- Normaler Transparenzwert

-- Render-Distanzen
Config.MaxTransparencyRenderDistance = 50.0 -- Maximale Distanz für Transparenzanpassung
Config.MaxLabelRenderDistance = 30.0 -- Maximale Distanz für das Admin-Label

-- Fixierte Admin-IDs basierend auf der Lizenz
Config.AdminIDMapping = {
    ["license:6c525220d89cc2d77b148e68e97289adc76a53f8"] = "ID_01", -- 
    ["license:914c3b2378fe1d1da23ec5fadd6f7460ca0eedd8"] = "ID_02", -- 
    ["license:e89292e0a317f2008c1bbac8c4b614283afec9c5"] = "ID_03", -- 
    -- Füge hier weitere Zuordnungen hinzu
}

-- Standard Admin-ID für Gruppen-basierte Admins
Config.DefaultAdminID = "ADMIN_GROUP"
