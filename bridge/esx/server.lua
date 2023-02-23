if GetResourceState('es_extended') ~= 'started' then return end

ESX = exports.es_extended:getSharedObject()

AddEventHandler('esx:playerLoaded', function(playerId, player)
	AddPlayer(player)
end)

AddEventHandler('esx:setJob', function(playerId, job, lastJob)
	UpdatePlayerJob(playerId, job)
end)

AddEventHandler('esx:playerLogout', function(playerId)
    RemovePlayer(playerId)
end)

function GetSource(player)
    return player.source
end

function GetPlayerJob(player)
    return player.job
end

function GetPlayerFromId(source)
    return ESX.GetPlayerFromId(source)
end

function GetServerPlayers()
    return ESX.GetExtendedPlayers()
end