// SONIC ROBO BLAST 2
// STAR Library
//-----------------------------------------------------------------------------
// Made by Star "Guy Who Names Scripts After Him" ManiaKG.
//-----------------------------------------------------------------------------
/// \file  init.lua
/// \brief Initializes basic mod data.

// ------------------------ //
//        Variables
// ------------------------ //

local starfiles = {};
local fold;

// ------------------------ //
//		  Functions
// ------------------------ //

--
-- local function S_AddFile(string *file)
-- Stores a file string inside 'starfiles', for easy and neat script loading.
--
-- 'fold' should already be provided before running the function.
--
local function S_AddFile(file)
	table.insert(starfiles, string.format("%s%s", fold, file));
end

// ------------------------ //
//		 Load Scripts
// ------------------------ //

fold = "1 - Init/";
	S_AddFile("STAR_INITD.lua");
	S_AddFile("STAR_INITD_C.lua");

fold = "2 - Library/";
	S_AddFile("STAR_LIB_C.lua");

for _, file in ipairs(starfiles) do
	dofile(file);
end