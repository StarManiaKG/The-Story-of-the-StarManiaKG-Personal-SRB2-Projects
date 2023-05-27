rawset(_G, "itemlib", {})


for _, filename in ipairs{
	"Core/MenuLibrary.lua",
	"Core/Core.lua",
	"Core/Actions.lua",
	"Core/HungerThirst.lua",
	"Core/DayNightCycle.lua",
	"Core/Crafting.lua",
	"Core/KeepStuff.lua",

	"Items/Items.lua",
	"Items/Campfire.lua",
	"Items/Chest.lua",
	"Items/PlantGrowing.lua",
	"Items/Flowers.lua",
	"Items/Animals.lua",
	"Items/WaterBucket.lua",
	"Items/Actions.lua",

	"Core/Menus.lua",
}
	dofile(filename)
end
