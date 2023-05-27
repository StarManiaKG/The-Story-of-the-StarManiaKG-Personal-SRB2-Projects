-- Keep Stuff support
-- Restores the inventory and carried item
-- Works even if Keep Stuff is not added first


local function addKeepStuffSupport()
	keepstuff.addSaver("game", function(s, p)
		local it = p.items
		if not it return end

		s.itemid = it.itemid
		s.itemquantity = it.itemquantity

		if it.carrieditem and it.carrieditem.valid
			s.carrieditemid = it.carrieditem.itemid
			s.carrieditemdata = it.carrieditem.itemdata
		end

		s.hunger = p.hunger
		s.thirst = p.thirst
	end)

	keepstuff.addLoader("game", function(s, p)
		local it = p.items
		if not it return end

		it.itemid = s.itemid
		it.itemquantity = s.itemquantity

		if s.carrieditemid
			itemlib.carryItem(p, s.carrieditemid, s.carrieditemdata)
		end

		p.hunger = s.hunger
		p.thirst = s.thirst
	end)
end

if keepstuff
	addKeepStuffSupport()
else
	rawset(_G, "keepstuff_onadded", keepstuff_onadded or {})
	table.insert(keepstuff_onadded, addKeepStuffSupport)
end