--// SPEEDING UP MUSIC //--
--// BY STARMANIAKG //--

--// STAR NOTE: needs to be used with TSoURDt3rd for obvious reasons
if not (tsourdt3rd) then error("You need to load this with TSoURDt3rd!"); end

addHook("PlayerThink", function(player)
    if not (player and player.valid) then return; end
    S_SpeedMusic(player, player.speed);
end)