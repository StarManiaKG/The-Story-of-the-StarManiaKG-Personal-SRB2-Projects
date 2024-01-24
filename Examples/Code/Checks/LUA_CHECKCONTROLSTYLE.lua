--// CONTROL CHECKING SYSTEM //--
--// BY DEVS LIKE LACH AND OTHERS IN THE SRB2 OFFICIAL DISCORD //--

--// EXAMPLE 1
-- Might be better to use option two if you need to refer back to this function multiple times though
-- To prevent this, maybe set the table below, which is in {}, outside the function :)
local controlstyle = function(player)
    return ({"strafe", "analog", "manual", "automatic"})[((player.pflags & (PF_ANALOGMODE | PF_DIRECTIONCHAR)) >> 1) + 1]
end

--// EXAMPLE 2
local PLAYSTYLE_STRAFE = 0
local PLAYSTYLE_MANUAL = PF_DIRECTIONCHAR
local PLAYSTYLE_AUTOMATIC = PF_ANALOGMODE|PF_DIRECTIONCHAR
local PLAYSTLE_OLDANALOG = PF_ANALOGMODE

local function GetPlayStyle(player)
    return player.pflags & (PF_ANALOGMODE|PF_DIRECTIONCHAR)
end