--// VARIABLES
-- Links
local IV2 = itemslibV2;

local IV2C = IV2.Core;
local IV2CT = IV2C.Terminal;
local IV2E = IV2.Environment;
local IV2ET = IV2E.Textures;
local IV2I = IV2.Inputs;
local IV2M = IV2.Menu;

--// LIBRARIES
-- MATH --
--[[
	function IV2E.DoProperTeleportMove
		arguments:
			mobj_t *mobj;
			fixed_t *x;
			fixed_t *y;
			fixed_t *z;
			boolean *moveorigin;

		description:
			Grabs the Proper P_TeleportMove Function To Use, Depending on the SRB2 Version, or TSoURDt3rd.
				As an Extra Parameter, You Can Choose to Do the P_MoveOrigin Instead, if the Version is Correct.
			
		possible returns:
			boolean *true/false;
			mobj_t *mobj;
]]--
function IV2E.DoProperTeleportMove(mobj, x, y, z, moveorigin)
	local VERSION2211 = (((VERSION == 202 and SUBVERSION >= 11) or (tsourdt3rd)) and true or false);

	-- P_MoveOrigin
	if (moveorigin)
		if not (VERSION2211)
			if (IV2C.DebugMode.value and server)
				print("You aren't using version 2.2.11 or above! P_MoveOrigin defaulting to P_Move");
			end
		else
			return P_MoveOrigin(mobj, x, y, z);
		end
	end
	
	-- P_TeleportMove/P_SetOrigin
	if not (VERSION2211) return P_TeleportMove(mobj, x, y, z); else return P_SetOrigin(mobj, x, y, z); end
end

-- ENVIRONMENT --
--[[
	function IV2E.IsObjectOnSolidGround
		arguments:
			mobj_t *mobj;
		
		description:
			Checks if the Object Given is on Solid Ground.
			
		possible returns:
			true;
			false;
]]--
function IV2E.IsObjectOnSolidGround(mobj)
	return (P_IsObjectOnGround(mobj) and mobj.eflags & MFE_ONGROUND);
end

-- ENVIRONMENT --
--[[
	function IV2E.IsObjectWithinWater
		arguments:
			mobj_t *mobj;
		
		description:
			Checks if the Object Given is Within Water.
			
		possible returns:
			0;
			1;
			2;
]]--
function IV2E.IsObjectWithinWater(mobj)
	return (((mobj.eflags & MFE_UNDERWATER) and 1)
			or ((mobj.eflags & MFE_TOUCHWATER) and 2)
			or (0));
end

-- SECTORS/FOFS --
--[[
	function IV2ET.GrabSectorTexture
		arguments:
			mobj_t *mobj;
		
		description:
			Grabs the Texture of the Floor that The Player is Standing On.
			
		possible returns:
			nil;
			ffloors_t *toppic;
			subsector_t *floorpic;
]]--
function IV2ET.GrabSectorTexture(mobj)
	if (mobj and mobj.valid)
		-- FOF Floors
		if (mobj.floorrover and mobj.floorrover.valid)
			if (IV2C.DebugMode.value)
				CONS_Printf("Standing on FOF, Currently on "..(IV2T.photosynthesis[mobj.floorrover.toppic] and "Supported" or "Unsupported")
					.."Texture"..mobj.floorrover.toppic);
			end

			return mobj.floorrover.toppic;
		end
		
		-- Sector Floors
		if ((mobj.subsector and mobj.subsector.valid)
			and (mobj.subsector.sector and mobj.subsector.sector.valid))

			if (IV2C.DebugMode.value)
				CONS_Printf("Standing on FOF, Currently on "..(IV2T.photosynthesis[mobj.floorrover.floorpic] and "Supported" or "Unsupported")
					.."Texture"..mobj.floorrover.floorpic);
			end

			return mobj.subsector.sector.floorpic;
		end
		
		-- No Floors Found!
		if (IV2C.DebugMode.value) CONS_Printf("Mobj is Not Standing on Floor"); end
	else
		error("You Need a Valid Mobj!", 2);
	end

	return;
end

--[[
	function IV2ET.GrabFloorType
		arguments:
			mobj_t *mobj;
		
		description:
			Grabs the Type of Floor that The Player is Standing On.
			
		possible returns:
			nil;
			1, ffloors_t *fof;
			2, subsector_t *sector;
]]--
function IV2ET.GrabFloorType(mobj)
	if (mobj and mobj.valid)
		-- FOF Floors
		if (mobj.floorrover and mobj.floorrover.valid) return 1, mobj.floorrover; end
		
		-- Sector Floors
		if ((mobj.subsector and mobj.subsector.valid)
			and (mobj.subsector.sector and mobj.subsector.sector.valid))

			return 2, mobj.subsector.sector;
		end
		
		-- No Floors Found!
		return;
	else
		error("You Need a Valid Mobj!", 2);
	end
end

-- RENDERING --
--[[
	function IV2M.initMenuSound
		arguments:
			none
		
		description:
			Grabs a Menu Sound to Play Depending on the Player's Inputs and the Options Avaliable.
			
		possible returns:
			sound_t *sound
]]--
function IV2M.initMenuSound()	
	-- Are We Breathing? --
	if (IV2M.active)
		-- Moving
		if (IV2I[GC_FORWARDS].press or IV2I[GC_BACKWARD].press
			or IV2I[GC_STRAFELEFT].press or IV2I[GC_STRAFERIGHT].press)

			return sfx_menu1;
		end
		
		-- Closing
		if (IV2I[GC_SPIN].press) return sfx_skid; end
		
		-- Selecting
		if (IV2I[GC_JUMP].press and CPTNS) return sfx_strpst; end
		
		-- *error sound effect*
		return sfx_lose;
	end

	-- Are We Leaving? --
	if ((IV2I[GC_CUSTOM1].press)
		or (IV2I[GC_SPIN].press and not (CP > 1)))

		return sfx_kc65;
	end
	
	-- We Are Literally Lazy --
	return sfx_none;
end