ESX = nil
local adminMode = false
local fixedAdminID = "UNKNOWN"
local otherAdmins = {}

-- Lade die Konfiguration
Config = Config or {}
if not Config.AdminModeCommand then
    local configFile = LoadResourceFile(GetCurrentResourceName(), 'config.lua')
    assert(load(configFile))()
end

-- Initialisiere ESX
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

-- Event zum Umschalten des eigenen Admin-Modus
RegisterNetEvent('Quwenji_Adminmode:toggleOwnAdminMode')
AddEventHandler('Quwenji_Adminmode:toggleOwnAdminMode', function(isAdminMode, adminID)
    adminMode = isAdminMode
    fixedAdminID = adminID

    local playerPed = PlayerPedId()

    if adminMode then
        -- Charakter durchsichtig machen
        SetEntityAlpha(playerPed, Config.AdminTransparency, false)
        ESX.ShowNotification('Admin-Modus aktiviert')
    else
        -- Transparenz zurücksetzen
        SetEntityAlpha(playerPed, Config.NormalTransparency, false)
        ESX.ShowNotification('Admin-Modus deaktiviert')
    end
end)

-- Event zum Aktualisieren des Admin-Status anderer Spieler
RegisterNetEvent('Quwenji_Adminmode:updateAdminStatus')
AddEventHandler('Quwenji_Adminmode:updateAdminStatus', function(serverId, isAdmin, adminID)
    if isAdmin then
        otherAdmins[serverId] = adminID
    else
        otherAdmins[serverId] = nil
        -- Transparenz zurücksetzen, wenn Admin deaktiviert wurde
        local clientId = GetPlayerFromServerId(serverId)
        if clientId ~= -1 and clientId ~= PlayerId() then
            local targetPed = GetPlayerPed(clientId)
            if DoesEntityExist(targetPed) then
                SetEntityAlpha(targetPed, Config.NormalTransparency, false)
            end
        end
    end
end)

-- Funktion zur Zeichnung von 3D-Text mit Spieler-ID und Anpassungen
function DrawAdminLabel(x, y, z, adminID, r, g, b)
    local onScreen, screenX, screenY = World3dToScreen2d(x, y, z)
    local camCoords = GetGameplayCamCoords()
    local dist = #(vector3(x, y, z) - camCoords)

    -- Definiere Mindest- und Maximalwerte für die Skalierung
    local minDistance = 10.0 -- Ab dieser Distanz bleibt die Skalierung gleich groß
    local maxDistance = 2.0  -- Bis zu dieser Distanz wird der Text größer
    local minScale = 0.5 -- Mindestskalierung, wenn man sich weit entfernt
    local maxScale = 1.0 -- Maximalskalierung, wenn man nah dran ist

    -- Dynamische Skalierung basierend auf der Entfernung, aber nicht kleiner als minScale und nicht größer als maxScale
    local scale = (1 / dist) * 2 -- Grundlegende Skalierung basierend auf Entfernung
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    -- Begrenze die Skalierung, wenn die Entfernung größer oder kleiner als die Grenzwerte ist
    if dist > minDistance then
        scale = minScale
    elseif dist < maxDistance then
        scale = maxScale
    end

    -- "Admin" und "ID: ..." Text gleich groß und mit derselben Skalierung
    if onScreen then
        -- "Admin"-Text
        SetTextScale(0.0 * scale, 0.5 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextCentre(true)
        SetTextColour(r, g, b, 215)
        SetTextEntry("STRING")
        AddTextComponentString("Admin")
        DrawText(screenX, screenY)

        -- "ID: ..." Text direkt unter dem "Admin"-Text
        SetTextScale(0.0 * scale, 0.5 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextCentre(true)
        SetTextColour(r, g, b, 215)
        SetTextEntry("STRING")
        AddTextComponentString("ID: " .. adminID)
        DrawText(screenX, screenY + 0.025 * scale)
    end
end

-- Thread zur Anzeige des eigenen Admin-Labels
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if adminMode then
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            DrawAdminLabel(coords.x, coords.y, coords.z + 1.0, fixedAdminID, 255, 0, 0)
        end
    end
end)

-- Thread zur Anpassung der Transparenz anderer Admins
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for serverId, adminID in pairs(otherAdmins) do
            local clientId = GetPlayerFromServerId(serverId)
            if clientId ~= -1 and clientId ~= PlayerId() then
                local targetPed = GetPlayerPed(clientId)
                if DoesEntityExist(targetPed) then
                    local targetCoords = GetEntityCoords(targetPed)
                    local distance = #(playerCoords - targetCoords)

                    if distance <= Config.MaxTransparencyRenderDistance then
                        -- Setze Transparenz für andere Admins
                        if GetEntityAlpha(targetPed) ~= Config.AdminTransparency then
                            SetEntityAlpha(targetPed, Config.AdminTransparency, false)
                        end
                    else
                        -- Setze Transparenz zurück, wenn außerhalb der Distanz
                        if GetEntityAlpha(targetPed) ~= Config.NormalTransparency then
                            SetEntityAlpha(targetPed, Config.NormalTransparency, false)
                        end
                    end
                end
            end
        end
    end
end)

-- Thread zur Anzeige der Admin-Labels anderer Spieler
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for serverId, adminID in pairs(otherAdmins) do
            local clientId = GetPlayerFromServerId(serverId)
            if clientId ~= -1 and clientId ~= PlayerId() then
                local targetPed = GetPlayerPed(clientId)
                if DoesEntityExist(targetPed) then
                    local targetCoords = GetEntityCoords(targetPed)
                    local distance = #(playerCoords - targetCoords)

                    if distance <= Config.MaxLabelRenderDistance then
                        -- Zeichne das Admin-Label
                        DrawAdminLabel(targetCoords.x, targetCoords.y, targetCoords.z + 1.0, adminID, 255, 0, 0)
                    end
                end
            end
        end
    end
end)
