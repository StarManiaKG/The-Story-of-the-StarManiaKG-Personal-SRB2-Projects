// SONIC ROBO BLAST 2
// STAR Library
//-----------------------------------------------------------------------------
// Made by Star "Guy Who Names Scripts After Him" ManiaKG.
//-----------------------------------------------------------------------------
/// \file  STAR_LIB_C.lua
/// \brief Initializes the C library of the STAR library, for proper C emulation.

// ------------------------ //
//        Functions
// ------------------------ //

--
-- function STAR.RemoveFreeSpace(string *gstring)
-- Removes spaces from the given string.
--
function STAR.RemoveFreeSpace(gstring)
	return string.gsub(gstring, " ", "");
end