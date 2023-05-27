addHook("PlayerThink", function(player)
    if (player.mo and player.mo.valid)
        v.fadeScreen(0xFF00, 16);
    end
end)