--// ZAWAURDO PALETTE SCRIPT //--
--// BY STARMANIAKG //--

addHook("PlayerSpawn", function(player)
    if not (player and player.valid) then return; end
    P_FlashPal(player, 5, -1);
end)