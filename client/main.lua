local Scoreboard = {
    displaying = false,

    obj = nil,
    players = {}
}
RegisterNetEvent('kossek-scoreboard:playerLoaded', function(players)
    table.wipe(Scoreboard.players)
    
    for i, data in pairs(players) do
        Scoreboard.players[#Scoreboard.players + 1] = data
    end
end)

RegisterNetEvent('kossek-scoreboard:addPlayer', function(playerData)
    Scoreboard.players[#Scoreboard.players + 1] = playerData
end)

RegisterNetEvent('kossek-scoreboard:removePlayer', function(playerData)
    for i = 1, #Scoreboard.players do
        local player = Scoreboard.players[i]

        if player.identifier == playerData.identifier then
            table.remove(Scoreboard.players, i)
            break
        end
    end
end)

local function DrawText3D(x, y, z, text, color)
    local onScreen, _x, _y = World3dToScreen2d(x,y,z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    local scale = (1 / GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov
    
    if onScreen then
        SetTextScale(1.0 * scale, 1.55 * scale)
        SetTextFont(0)
        SetTextColour(color[1], color[2], color[3], 255)
        SetTextDropshadow(0, 0, 5, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
		SetTextCentre(1)

        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

local function DrawId()
    while Scoreboard.displaying do
        Wait(3)
        local playerId = PlayerId()
        local playerPed = PlayerPedId()
        for _, player in ipairs(GetActivePlayers()) do
            if player ~= playerId then
                local targetPed = Citizen.InvokeNative(0x43A66C31C68491C0, player)

                if IsEntityVisible(targetPed) then
                    local coords1 = GetPedBoneCoords(playerPed, 31086, -0.4, 0.0, 0.0)
                    local coords2 = GetPedBoneCoords(targetPed, 31086, -0.4, 0.0, 0.0)
                    local dst = 40.0
                    if #(coords1 - coords2) < dst then
                        DrawText3D(coords2.x, coords2.y, coords2.z + 1.2, GetPlayerServerId(player), (NetworkIsPlayerTalking(player) and {0, 0, 255} or {255, 255, 255}))
                    end
                end
            end
        end
    end
end

local function OpenScoreboard()
    SendNUIMessage({
        action      = 'openScoreboard',
        myId        = GetPlayerServerId(PlayerId()),
        players     = Scoreboard.players,
        counter     = GlobalState['scoreboard_counter'],
        serverName  = Config.ServerName,
        slots       = GetConvarInt('sv_maxclients', 1024)
    })
end

local function CloseScoreboard()
    SendNUIMessage({ action = 'closeScoreboard' })
end

local function LoadDict(dict)
    while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Citizen.Wait(0)
	end
end

CreateThread(function()
    while true do
        Wait(0)
        if Scoreboard.displaying then
            if IsControlPressed(0, 188) then
                SendNUIMessage({ action = 'scrollUp' })
            elseif IsControlPressed(0, 173) then
                SendNUIMessage({ action = 'scrollDown' })
            end
        else
            Wait(500)
        end
    end
end)

RegisterCommand('+scoreboard', function()
    Scoreboard.displaying = true

    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)

    if not IsPedInAnyVehicle(playerPed) and not IsPedFalling(playerPed) and not IsPedCuffed(playerPed) and not IsPedDiving(playerPed) and not IsPedInCover(playerPed, false) and not IsPedInParachuteFreeFall(playerPed) and GetPedParachuteState(playerPed) < 1 then
        LoadDict('amb@world_human_clipboard@male@idle_a')
        TaskPlayAnim(playerPed, 'amb@world_human_clipboard@male@idle_a', 'idle_a', 8.0, -8.0, -1, 1, 0.0, false, false, false)

        Scoreboard.obj = CreateObject(`p_cs_clipboard`, playerPos.x, playerPos.y, playerPos.z, true, false, false)
        AttachEntityToEntity(Scoreboard.obj, playerPed, GetPedBoneIndex(playerPed, 36029), 0.1, 0.015, 0.12, 45.0, -130.0, 180.0, true, false, false, false, 0, true)
    end

    OpenScoreboard()
    if Config.IdOverHead then
        DrawId()
    end
end)

RegisterCommand('-scoreboard', function()
    local playerPed = PlayerPedId()

    if Scoreboard.displaying then
        Scoreboard.displaying = false
        StopAnimTask(playerPed, 'amb@world_human_clipboard@male@idle_a', 'idle_a', 1.0)

		DeleteObject(Scoreboard.obj)
        Scoreboard.obj = nil
    end

    CloseScoreboard()
end)

RegisterKeyMapping('+scoreboard', 'Show scoreboard', 'keyboard', Config.Key)