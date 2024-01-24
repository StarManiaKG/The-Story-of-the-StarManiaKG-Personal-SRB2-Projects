--// COSMIC CLONES //--
--// MADE BY MY BEST FRIEND, NARBLUEBEAR (lol) //--
--// (and slightly touched up by starmaniakg (lol)) //--

-- Freeslot Stuff
freeslot(
"MT_COSMICCLONE", 
"MT_CCLONEMARKER"
)

-- Declarations
mobjinfo[MT_COSMICCLONE] = { // Player's mobjinfo courtesy of the srb2 wiki
    doomednum = -1,
    spawnstate = S_PLAY_STND,
    spawnhealth = 99,
    seestate = S_PLAY_RUN,
    seesound = sfx_None,
    reactiontime = 0,
    attacksound = sfx_thok,
    painstate = S_PLAY_PAIN,
    painchance = MT_THOK,
    painsound = sfx_None,
    meleestate = S_NULL,
    missilestate = S_PLAY_JUMP,
    deathstate = S_PLAY_DEAD,
    xdeathstate = S_NULL,
    deathsound = sfx_None,
    speed = 1,
    radius = 16*FRACUNIT,
    height = 48*FRACUNIT,
    dispoffset = 0,
    mass = 1000,
    damage = MT_THOK,
    activesound = sfx_None,
    flags = MF_PAIN,
    raisestate = MT_THOK
}
mobjinfo[MT_CCLONEMARKER] = { // Cosmic Clone's "chaseitem", which spawns on the player.
	doomednum = -1,
	spawnstate = S_INVISIBLE,
	flags = MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_SCENERY
}

-- Commands
COM_AddCommand("showtrail", function(player, arg1)
	if arg1 == "true" or arg1 == "1" or arg1 == "on" then
		CONS_Printf(player, "Ghost trails are now shown.")
		player.trail = "on"
	elseif arg1 == "false" or arg1 == "0" or arg1 == "off" then
		CONS_Printf(player, "Ghost trails are now hidden.")
		player.trail = "off"
	else
		CONS_Printf(player, "Toggles the ability to show ghost trails, in case you want to see where the Cosmic Clone will go. Default: off, currently " + player.trail + ".")
	end
end)

-- Main
addHook("PlayerSpawn", function(player)
    if player.mo and player.mo.valid then
        player.clonespawned = false
    end
end)
addHook("PlayerThink", function(player)
	if player.mo then
        // Spawns.a clone
        if (player.cmd.buttons & BT_CUSTOM2) and player.clonespawned == false then
            player.clonespawned = true
            P_SpawnMobj(player.mo.x - 32*FRACUNIT, player.mo.y - 32*FRACUNIT, player.mo.z, MT_COSMICCLONE)
        end
        // Spawns the markers
		local marker = P_SpawnMobj(player.mo.x, player.mo.y, player.mo.z, MT_CCLONEMARKER)
		marker.state = player.mo.state
		marker.angle = player.drawangle
		marker.storedname = player.name
		marker.skin = player.mo.skin
		marker.color = player.mo.color
		if not player.trail or player.trail == "off" then
			marker.flags2 = MF2_DONTDRAW
		elseif player.trail == "on" then
			marker.flags2 = MF2_SHADOW
		end
		marker.fuse = 1*TICRATE
	end
end)
addHook("MobjSpawn", function(mobj)
	mobj.tracer = A_FindTracer(mobj, MT_PLAYER, 0)
	if mobj.tracer then
		mobj.skin = mobj.tracer.skin
		mobj.color = SKINCOLOR_PURPLE
		mobj.colorized = true
		mobj.state = mobj.tracer.state
	end
end, MT_COSMICCLONE)
addHook("MobjThinker", function(mobj)
	A_FindTarget(mobj, MT_CCLONEMARKER, 0)
	if not mobj.storedname then
		mobj.storedname = mobj.target.storedname
	end
	if mobj.target.storedname == mobj.storedname then
		P_TeleportMove(mobj, mobj.target.x, mobj.target.y, mobj.target.z)
		mobj.skin = mobj.target.skin
		mobj.angle = mobj.target.angle
		mobj.state = mobj.target.state
		P_RemoveMobj(mobj.target)
	end
	mobj.color = SKINCOLOR_PURPLE
	mobj.colorized = true
end, MT_COSMICCLONE)