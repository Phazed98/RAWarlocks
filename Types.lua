local ADDON_NAME, RAW = ...

RAW.addon_name = "RA Warlocks"

RAW.Types = {}

RAW.Debug = false

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
	{ Id = 9, Text =  "Curse of Santa"},
	{ Id = 10, Text =  "No Curse"},
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
	["Curse of Santa"]			= 133169,
	["No Curse"] = 0,
}

-- Class colours, used to Append to the start of a string to change the colour
RAW.Types.ClassColours =
{
	["Druid"]	= "|cffFF7D0A",
	["Hunter"]	= "|cffABD473",
	["Mage"]	= "|cff40C7EB",
	["Paladin"]	= "|cffF58CBA",
	["Priest"]	= "|cffFFFFFF",
	["Rogue"]	= "|cffFFF569",
	["Shaman"]	= "|cff0070DE",
	["Warlock"]	= "|cff8787ED",
	["Warrior"]	= "|cffC79C6E",
}

-- Class Icons, not actual class icons because there number doesnt appear to work in game
RAW.Types.ClassIcons = 
{
	["Druid"]		= 136085,
	["Warlock"]		= 136197,
	["Paladin"]		= 135963,
	["Mage"]		= 135846,
	["Shaman"]		= 136048,
	["Warrior"]		= 132355,
	["Rogue"]		= 132320,
	["Hunter"]		= 132222,
	["Priest"]		= 135940,
	["Unknown"]		= 132311,
}