function itemlib.eat(p, n)
	if p.items.hunger > itemlib.cfg.hunger * 15 / 16 return true end
	p.items.hunger = min($ + n, itemlib.cfg.hunger)
	if p.mo and p.mo.valid
		S_StartSound(p.mo, sfx_iteat)
	end
end

function itemlib.drink(p, n)
	if p.items.thirst > itemlib.cfg.thirst * 15 / 16 return true end
	p.items.thirst = min($ + n, itemlib.cfg.thirst)
	if p.mo and p.mo.valid
		S_StartSound(p.mo, P_RandomRange(sfx_bubbl1, sfx_bubbl5))
	end
end

function itemlib.handleHungerAndThirst(p)
	local it = p.items

	local pmo = p.mo
	if pmo and not pmo.valid
		pmo = nil
	end

	if not pmo or pmo.health <= 0 or p.exiting return end

	local maxhunger = itemlib.cfg.hunger
	local maxthirst = itemlib.cfg.thirst

	local freq
	if it.hunger > maxhunger / 10
		freq = 1
	elseif it.hunger > maxhunger / 20
		freq = 2
	else
		freq = 5
	end

	if leveltime % freq == 0
		it.hunger = $ - 1

		if it.hunger == 0
			P_DamageMobj(pmo, nil, nil, nil, DMG_INSTAKILL)
			print(p.name.." starved to death.")
		elseif it.hunger == maxhunger / 4
			CONS_Printf(p, "\x82You are hungry.")
			S_StartSound(nil, sfx_ptally, p)
		elseif it.hunger == maxhunger / 10
			CONS_Printf(p, "\x85You are starving.")
			S_StartSound(nil, sfx_lose, p)
		end
	end

	local freq
	if it.thirst > maxthirst / 10
		freq = 1
	elseif it.thirst > maxthirst / 20
		freq = 2
	else
		freq = 5
	end

	if leveltime % freq == 0
		it.thirst = $ - 1

		if it.thirst == 0
			P_DamageMobj(pmo, nil, nil, nil, DMG_INSTAKILL)
			print(p.name.." died of thirst.")
		elseif it.thirst == itemlib.cfg.thirst / 4
			CONS_Printf(p, "\x82You are thirsty.")
			S_StartSound(nil, sfx_ptally, p)
		elseif it.thirst == itemlib.cfg.thirst / 10
			CONS_Printf(p, "\x85You need to drink. Now.")
			S_StartSound(nil, sfx_lose, p)
		end
	end

	-- Energy stuff
	-- ...
	--it.energy = $ - 1
	--if it.energy == 0
	--end

	local weakness
	if it.hunger <= maxhunger / 20
	or it.thirst <= maxthirst / 20
		weakness = 3
	elseif it.hunger <= maxhunger / 10
	or it.thirst <= maxthirst / 10
		weakness = 2
	elseif it.hunger <= maxhunger / 4
	or it.thirst <= maxthirst / 4
		weakness = 1
	end

	local skin = skins[p.mo.skin]

	if weakness == 1
		p.normalspeed = skin.normalspeed * 3 / 4
		p.actionspd = skin.actionspd * 3 / 4
		p.jumpfactor = skin.jumpfactor

		if p.powers[pw_tailsfly] > 1
			p.powers[pw_tailsfly] = $ - 1
		end
	elseif weakness == 2
		p.normalspeed = skin.normalspeed / 2
		p.actionspd = skin.actionspd / 2
		p.jumpfactor = skin.jumpfactor

		if p.powers[pw_tailsfly] > 2
			p.powers[pw_tailsfly] = $ - 2
		end
	elseif weakness == 3
		p.normalspeed = skin.normalspeed / 3
		p.actionspd = skin.actionspd / 3

		if P_RandomChance(FRACUNIT / 3)
			p.jumpfactor = skin.jumpfactor
		else
			p.jumpfactor = skin.jumpfactor * P_RandomRange(0, 256) / 256
		end

		if p.pflags & PF_JUMPED
			p.pflags = $ | PF_THOKKED
		end
	elseif it.weakness
		p.normalspeed = skin.normalspeed
		p.actionspd = skin.actionspd
		p.jumpfactor = skin.jumpfactor
	end

	it.weakness = weakness
end

function itemlib.drawHungerAndThirstHud(v, p)
end


COM_AddCommand("t", function(p)
	itemlib.cfg.hunger = 2 * 60 * TICRATE
	p.items.hunger = itemlib.cfg.hunger / 4 + 2 * TICRATE
end, COM_ADMIN)
