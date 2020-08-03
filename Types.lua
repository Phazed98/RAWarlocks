local ADDON_NAME, RAW = ...

RAW.addon_name = "RA Warlocks"

RAW.Types = {}

RAW.Debug = true

-- Curses Sorted by Priority
RAW.Types.Curses =
{
	{ Id = 1, Text =  "Curse of Recklessness"},
	{ Id = 2, Text =  "Curse of Elements"},
	{ Id = 3, Text =  "Curse of Shadow"},
	{ Id = 4, Text =  "Curse of Agony"},
	{ Id = 5, Text =  "Curse of Weakness"},
	{ Id = 6, Text =  "Curse of Doom"},
	{ Id = 7, Text =  "Curse of Tongues"},
	{ Id = 8, Text =  "Curse of Exhaustion"},
	{ Id = 9, Text =  "No Curse"},
}

-- Spell Icon IDs used to show various Icons in the UI
RAW.Types.SpellIcons =
{
	["Corruption"]				= 136118,
	["Curse of Recklessness"]	= 136225,
	["Curse of Elements"]		= 136130,
	["Curse of Shadow"]			= 136137,
	["Curse of Agony"]			= 136139,
	["Curse of Weakness"]		= 136138,
	["Curse of Doom"]			= 136122,
	["Curse of Tongues"]		= 136140,
	["Curse of Exhaustion"]		= 136162,
	["No Curse"] = 0,
}

-- Class colours, used to Append to the start of a string to change the colour
RAW.Types.ClassColours =
{
	["DRUID"]	= "|cffFF7D0A",
	["HUNTER"]	= "|cffABD473",
	["MAGE"]	= "|cff40C7EB",
	["PALADIN"]	= "|cffF58CBA",
	["PRIEST"]	= "|cffFFFFFF",
	["ROGUE"]	= "|cffFFF569",
	["SHAMAN"]	= "|cff0070DE",
	["WARLOCK"]	= "|cff8787ED",
	["WARRIOR"]	= "|cffC79C6E",
}

-- Class Icons, not actual class icons because there number doesnt appear to work in game
RAW.Types.ClassIcons = 
{
	["DRUID"]		= 136085,
	["WARLOCK"]		= 136197,
	["PALADIN"]		= 135963,
	["MAGE"]		= 135846,
	["SHAMAN"]		= 136048,
	["WARRIOR"]		= 132355,
	["ROGUE"]		= 132320,
	["HUNTER"]		= 132222,
	["PRIEST"]		= 135940,
	["Unknown"]		= 132311,
}