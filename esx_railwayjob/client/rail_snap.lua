-- rail_snap.lua
-- Utilitaires pour positionner un véhicule sur la voie la plus proche

-- Retourne la position (x,y,z,heading) d'un point proche des rails
function GetNearestRailPos(x, y, z)
    -- On utilise CreateMissionTrain spawn pour forcer snap, puis on récupère coords.
    -- Comme alternative, on fait une petite recherche Z via trace verticale.
    local ztest = z
    for dz = 0, 5, 1 do
        local _, groundZ = GetGroundZFor_3dCoord(x, y, ztest + dz, 0)
        if groundZ and groundZ > 0 then
            ztest = groundZ
            break
        end
    end

    -- Retour simple: on maintient heading du joueur et Z ajusté
    local heading = GetEntityHeading(PlayerPedId())
    return vector3(x, y, ztest), heading
end
