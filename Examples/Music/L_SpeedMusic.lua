addHook("PlayerThink", function(player)
    if (player.mo and player.mo.valid) then
        S_SpeedMusic(2*FRACUNIT, player)
    end
end)