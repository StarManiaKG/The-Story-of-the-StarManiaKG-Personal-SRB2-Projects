--// BASIC SCREEN FADING SCRIPT //--
--// BY STARMANIAKG //--

addHook("HUD", function(v, player)
    if not (player and player.valid) then return; end
    v.fadeScreen(0xFF00, 16);
end)