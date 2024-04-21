// SONIC ROBO BLAST 2
// STAR Library
//-----------------------------------------------------------------------------
// Made by Star "Guy Who Names Scripts After Him" ManiaKG.
//-----------------------------------------------------------------------------
/// \file  STAR_INIT_C.lua
/// \brief Initializes the proper C emulation of the STAR library.

// ------------------------ //
//        Variables
// ------------------------ //

--
-- function VA() = function string.format()
-- string.format is basically just the 'va' function but in lua.
--
rawset(_G, "va", string.format);

--
-- function strlwr() = function string.format()
-- string.lower is literally just the 'strlwr' function but in lua.
--
rawset(_G, "strlwr", string.lower);

--
-- function strupr() = function string.format()
-- string.upper is literally just the 'strupr' function but in lua.
--
rawset(_G, "strupr", string.upper);