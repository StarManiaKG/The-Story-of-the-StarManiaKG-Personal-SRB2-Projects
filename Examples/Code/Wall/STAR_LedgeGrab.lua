--// HOW TO PLAY AS ME, SPECCY //--
--// BY STARMANIAKG //--

--// FUN STAR FACT: //--
--// This Ironically Has Better Wall Checking Than Hexhog Lol //--
--// ...but not for long >:)

--// First, Check Our Wall Properties
addHook("MobjMoveBlocked", function(mobj, thing, line)
	if ((mobj and mobj.valid) and (mobj.player and mobj.player.valid) and (line and line.valid))
		if (P_IsObjectOnGround(mobj)) return; end

		local player = mobj.player;
		if not (player.STAR) return; end

		local side = P_PointOnLineSide(mobj.x, mobj.y, line);
		local sector = (side == 1 and "frontsector" or "backsector");

		local pointX, pointY = P_ClosestPointOnLine(mobj.x, mobj.y, line)
		local pointAngle = R_PointToAngle2(mobj.x, mobj.y, pointX, pointY)

		if (line[sector] and line[sector].valid)
			-- FOFs
			for rover in line[sector].ffloors() do
				if not (mobj.z+mobj.height <= rover.topheight and mobj.z+mobj.height >= rover.topheight-20*FRACUNIT) continue; end
				if (rover.toppic == "F_SKY1") continue; end

				player.STAR.AtWall = true;
				player.STAR.AtWallAngle = pointAngle;

				return true;
			end

			-- Sectors
			if ((mobj.z+mobj.height <= line[sector].floorheight and mobj.z+mobj.height >= line[sector].floorheight-20*FRACUNIT) and line[sector].floorpic ~= "F_SKY1")
				if (line[sector].floorheight == line[sector].ceilingheight) return; end -- thok barrier prevention system

				player.STAR.AtWall = true;
				player.STAR.AtWallAngle = pointAngle;

				return true;
			end
		end
	end
end, MT_PLAYER)

--// Now, Run Our Wall Functions, Make Sure we Reset Everything at the End, and We're Done :)
addHook("PlayerThink", function(player)
	if (player.mo and player.mo.valid)
		player.STAR = ($ or { AtWall = false, AtWallAngle = 0 });

		if (player.STAR.AtWall)
			if (player.cmd.buttons & BT_JUMP)
				player.mo.state = S_PLAY_JUMP;
				
				P_SetObjectMomZ(player.mo, 12*FRACUNIT, false);
				S_StartSound(player.mo, sfx_jump);

				player.STAR.AtWall = false;
				return;
			end

			if (player.mo.state ~= S_PLAY_RIDE) S_StartSound(mobj, sfx_s3k4a); end
			player.mo.state = S_PLAY_RIDE;

			player.mo.momz = 0;
			player.drawangle = player.STAR.AtWallAngle;
		end
		
		player.STAR.AtWall = false;
	end
end)