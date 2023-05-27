-- Animals


itemlib.addItem({
	name = "bird",
	tip = "A tiny blue bird desperately trying to get away from your inventory",

	mobjsprite = SPR_FL01,
	mobjframe = 0,
	mobjtype = MT_FLICKY_01,
	cookable = "cooked bird",

	action1 = {
		name = "eat",
		action = function(p)
			CONS_Printf(p, "Eating a RAW bird?! No way lol")
			return true
		end
	}
})

itemlib.addItem({
	name = "rabbit",
	tip = "A cute rabbit desperately trying to get away from your inventory",

	mobjsprite = SPR_FL02,
	mobjframe = 0,
	mobjtype = MT_FLICKY_02,
	cookable = "cooked rabbit",

	action1 = {
		name = "eat",
		action = function(p)
			CONS_Printf(p, "Trying to eat a raw rabbit? You weirdo.")
			return true
		end
	}
})

itemlib.addItem({
	name = "rat",
	tip = "A white rat desperately trying to get away from your inventory",

	mobjsprite = SPR_FL12,
	mobjframe = 0,
	mobjtype = MT_FLICKY_12,
	cookable = "cooked rat",

	action1 = {
		name = "eat",
		action = function(p)
			CONS_Printf(p, "You try to eat the rat, but it suddently disappears.")
			return true
		end
	}
})

itemlib.addItem({
	name = "chicken",
	tip = "A raw chicken desperately trying to get away from your inventory",

	mobjsprite = SPR_FL03,
	mobjframe = F,
	mobjtype = MT_FLICKY_03,
	cookable = "cooked chicken",

	action1 = {
		name = "eat",
		action = function(p)
			CONS_Printf(p, "Chicken... RAW...")
			return true
		end
	}
})

/*itemlib.addItem({
	name = "cow",
	tip = "An apple-sized cow desperately trying to get away from your inventory",

	mobjsprite = SPR_COWZ,
	mobjframe = 0,
	mobjtype = MT_COW,
	cookable = "cooked cow",

	action1 = {
		name = "eat",
		action = function(p)
			CONS_Printf(p, "Ever heard of mad cow disease?!")
			return true
		end
	}
})

itemlib.addItem({
	name = "red bird",
	tip = "Like a tiny blue bird, but red",

	mobjsprite = SPR_RBRD,
	mobjframe = 0,
	mobjtype = MT_REDBIRD,
	cookable = "cooked bird",

	action1 = {
		name = "eat",
		action = function(p)
			CONS_Printf(p, "You look at the tiny red raw bird. It's tiny, red and RAW.")
			return true
		end
	}
})*/

itemlib.addItem({
	name = "cooked chicken",
	tip = "A cooked chicken. Yep.",
	stack = 1,

	mobjstate = "S_COOKEDCHICKEN",
	mobjsprite = SPR_ITEM,
	mobjframe = F,
	mobjtype = MT_ITEMS_GROUNDITEM,

	action1 = {
		name = "eat",
		tip = "Eat the chicken",
		action = function(p, it)
			if itemlib.eat(p, itemlib.cfg.hunger) return true end
			CONS_Printf(p, "You eat the children. Truly delicious.")
		end
	}
})

itemlib.addItem({
	name = "cooked bird",
	tip = "A tiny blue bird that will never fly again",
	stack = 2,

	mobjstate = "S_COOKEDBIRD",
	mobjsprite = SPR_ITEM,
	mobjframe = F,
	mobjtype = MT_ITEMS_GROUNDITEM,

	action1 = {
		name = "eat",
		tip = "Eat the blue bird",
		action = function(p)
			if itemlib.eat(p, itemlib.cfg.hunger / 2) return true end
			CONS_Printf(p, "You eat the tiny blue bird.\nIt's even tinier now.")
			/*if itemlib.countItems(p, "cooked bird")
				itemlib.dropItem(p, "cooked bird")
				return true
			end*/
		end
	}
})

itemlib.addItem({
	name = "cooked rabbit",
	tip = "A cooked rabbit, as the name implies",
	stack = 1,

	mobjstate = "S_COOKEDRABBIT",
	mobjsprite = SPR_ITEM,
	mobjframe = F,
	mobjtype = MT_ITEMS_GROUNDITEM,

	action1 = {
		name = "eat",
		tip = "Eat the rabbit",
		action = function(p)
			if itemlib.eat(p, itemlib.cfg.hunger) return true end
			CONS_Printf(p, "You make even more sure the rabbit will never jump again.")
		end
	}
})

itemlib.addItem({
	name = "cooked rat",
	tip = "A cooked rat",
	stack = 3,

	mobjstate = "S_COOKEDRAT",
	mobjsprite = SPR_ITEM,
	mobjframe = F,
	mobjtype = MT_ITEMS_GROUNDITEM,

	action1 = {
		name = "eat",
		tip = "Eat the rat",
		action = function(p)
			if itemlib.eat(p, itemlib.cfg.hunger / 3) return true end
			if p.items.hunger == itemlib.cfg.hunger
				CONS_Printf(p, "You eat the rat.\nYou are satiated.")
			else
				CONS_Printf(p, "You eat the rat.\nWhy not.")
			end
		end
	}
})

/*itemlib.addItem({
	name = "cooked cow",
	tip = "A cooked cow",
	stack = 2,

	mobjstate = "S_COOKEDCOW",
	mobjsprite = SPR_ITEM,
	mobjframe = F,
	mobjtype = MT_ITEMS_GROUNDITEM,

	action1 = {
		name = "eat",
		action = function(p)
			if itemlib.eat(p, itemlib.cfg.hunger / 2) return true end
			CONS_Printf(p, "You put the cow in your mouth and swallow it.")
		end
	}
})*/
