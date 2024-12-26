ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Lade die Konfiguration
Config = Config or {}
if not Config.AdminModeCommand then
    local configFile = LoadResourceFile(GetCurrentResourceName(), 'config.lua')
    assert(load(configFile))()
end

-- Tabelle zur Verfolgung von Spielern im Admin-Modus
local adminsInMode = {}

-- Funktion zum Abrufen der LicenseID
local function getLicenseID(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in ipairs(identifiers) do
        if string.find(id, "license:") then
            return id
        end
    end
    return nil
end

-- Funktion zur Überprüfung, ob ein Spieler Admin ist
local function isPlayerAdmin(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local licenseID = getLicenseID(source)
        local userGroup = xPlayer.getGroup()
        local isAdmin = false

        -- Überprüfe Admin durch Gruppe
        for _, group in ipairs(Config.AdminGroups) do
            if userGroup == group then
                isAdmin = true
                break
            end
        end

        -- Überprüfe Admin durch licenseID
        if Config.AdminIDMapping[licenseID] then
            isAdmin = true
        end

        return isAdmin
    end
    return false
end

-- Eventhandler für Chat-Nachrichten
AddEventHandler('chatMessage', function(source, name, message)
    if message:lower() == '/' .. Config.AdminModeCommand then
        CancelEvent() -- Verhindert, dass die Nachricht im Chat angezeigt wird
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            if isPlayerAdmin(source) then
                local licenseID = getLicenseID(source)
                local fixedAdminID = Config.AdminIDMapping[licenseID] or Config.DefaultAdminID

                -- Toggle den Admin-Modus
                local isNowAdminMode = not adminsInMode[source]
                adminsInMode[source] = isNowAdminMode

                -- Benachrichtige den Spieler selbst, um den Modus zu toggeln und die fixierte ID zu senden
                TriggerClientEvent('Quwenji_Adminmode:toggleOwnAdminMode', source, isNowAdminMode, fixedAdminID)

                -- Benachrichtige alle Clients über die Statusänderung und die fixierte ID
                TriggerClientEvent('Quwenji_Adminmode:updateAdminStatus', -1, source, isNowAdminMode, fixedAdminID)
            else
                TriggerClientEvent('esx:showNotification', source, 'Unbekannter Befehl.')
            end
        end
    end
end)

-- Entferne Spieler aus der Admin-Tabelle, wenn sie den Server verlassen
AddEventHandler('playerDropped', function(reason)
    local src = source
    if adminsInMode[src] then
        adminsInMode[src] = nil
        -- Informiere alle Clients, dass dieser Spieler den Admin-Modus verlassen hat
        TriggerClientEvent('Quwenji_Adminmode:updateAdminStatus', -1, src, false, nil)
    end
end)

-- Beim Laden eines Spielers den aktuellen Admin-Status senden
AddEventHandler('esx:playerLoaded', function(source)
    local playerId = source

    for serverId, isAdmin in pairs(adminsInMode) do
        if isAdmin then
            -- Hole die licenseID des Admins
            local licenseID = getLicenseID(serverId)

            -- Hole die fixierte Admin-ID basierend auf der licenseID
            local fixedAdminID = Config.AdminIDMapping[licenseID] or Config.DefaultAdminID

            TriggerClientEvent('Quwenji_Adminmode:updateAdminStatus', playerId, serverId, true, fixedAdminID)
        end
    end
end)
