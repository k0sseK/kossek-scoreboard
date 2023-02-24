local Scoreboard = {
    players = {},
    counter = {}
}

local function GetAvatar(playerId)
    local steamHex = GetPlayerIdentifier(playerId, 0)

    local p = promise.new()
    if steamHex and steamHex ~= '' then
        local steamId = tonumber(string.gsub(steamHex, 'steam:', ''), 16)

        if steamId then
            PerformHttpRequest('http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=' .. GetConvar('steam_webApiKey') .. '&steamids=' .. steamId, function(e, data, h)
                local data = json.decode(data) or {}
                if data and data.response and data.response.players[1] then
                    local avatar = data.response.players[1].avatarfull
                    p:resolve(avatar or nil)
                end
            end)
        end
    end

    return Citizen.Await(p)
end

local function UpdateCounter()
    Wait(1000)
    Scoreboard.counter = { players = 0, police = 0, ambulance = 0, mechanic = 0 }

    for i, data in pairs(Scoreboard.players) do
        Scoreboard.counter.players += 1
        
        if data.job == 'police' then
            Scoreboard.counter.police += 1
        elseif data.job == 'ambulance' then
            Scoreboard.counter.ambulance += 1
        elseif data.job == 'mechanic' then
            Scoreboard.counter.mechanic += 1
        end 
    end

    GlobalState['scoreboard_counter'] = Scoreboard.counter
end

function AddPlayer(player)
    local playerId = GetSource(player)
    
    Scoreboard.players[playerId] = {
        id = playerId,
        identifier = GetPlayerIdentifier(playerId, 0),
        name = GetPlayerName(playerId),
        avatar = GetAvatar(playerId),
        job = GetPlayerJob(player).name
    }

    TriggerClientEvent('kossek-scoreboard:addPlayer', -1, Scoreboard.players[playerId])
end

function RemovePlayer(playerId)
    TriggerClientEvent('kossek-scoreboard:removePlayer', -1, Scoreboard.players[playerId])
    Scoreboard.players[playerId] = nil

    UpdateCounter()
end

function UpdatePlayerJob(playerId, job)
    Scoreboard.players[playerId].job = job.name

    UpdateCounter()
end

AddEventHandler('playerDropped', function()
    RemovePlayer(source)
end)

AddEventHandler('onResourceStart', function(name)
	if name == GetCurrentResourceName() then
		local players = GetServerPlayers()

		if #players > 0 then
			for i=1, #players do
				local player = GetPlayerFromId(GetSource(players[i]))

				if player then
					AddPlayer(player)
				end
			end

            UpdateCounter()
		end
	end
end)