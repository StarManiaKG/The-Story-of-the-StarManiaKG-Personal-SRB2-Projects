local SPEED_INCREMENT = 10*FRACUNIT;

addHook("PlayerThink", function(player)
	if not (player.mo and player.mo.valid) return; end

	local curspeed = player.speed;
	local speed = 6;

	while (curspeed >= SPEED_INCREMENT and speed > 1) do
		speed = $1 - 1;
		curspeed = $1 - SPEED_INCREMENT;
	end

	S_SpeedMusic(1*FRACUNIT/speed);
	S_PitchMusic(1*FRACUNIT/speed);
end)