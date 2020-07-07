local ADDON_NAME, RAW = ...

RAW.addon_name = "RA Warlocks"

-- Initialize with Ace
RAW_Core = LibStub("AceAddon-3.0"):NewAddon(RAW.addon_name, "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")
RAW_Core.Name = ADDON_NAME

-- List of Warlocks in the raid
RAW_Core.WarlockList = {}

-- List of Raid Members Seeking Summons
RAW_Core.SummonList = {}

-- List of Raid Members with the Soulstone Buff
RAW_Core.SoulstonedList = {}

-- List of Warlocks in the raid
RAW_Core.AddonUserList = {}

-- If the Warlock data we have is valid
RAW_Core.HasValidData = false

--Debug Print That Doesnt Print In Public Builds
function RAW_Core:DebugPrint(Value)
	if (RAW.Debug) then
		RAW_Core:Print(Value)
	end
end

-- Code that you want to run when the addon is first loaded goes here.   
function RAW_Core:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("RAWarlocksDB", 
	{
		global = 
		{
			minimap = 
			{
				hide = false,
			},
			AutoSendCharacterData = true,
		},
	})

	RAW.UI.MinimapIcon:Register(RAW.addon_name, RAW.UI.MinimapButton, self.db.global.minimap)
end

-- Called when the addon is enabled
function RAW_Core:OnEnable()
	-- Build the Views
	RAW.UI.BuildWarlockListView()
	RAW.UI.BuildSummonListView()
	RAW.UI.BuildSoulstoneListView()

	RAW_Core.HasValidData = false

	-- Addon Comms
	RAW_EventHandler:RegisterComm("raw-Spec", "Comm_WarlockSpec")
	RAW_EventHandler:RegisterComm("raw-Warlocks", "Comm_WarlockConfigsDump")
	RAW_EventHandler:RegisterComm("raw-Announce", "Comm_AddonUserAnnounced")
	RAW_EventHandler:RegisterComm("raw-NewSession", "Comm_NewSession")
	RAW_EventHandler:RegisterComm("raw-UserList", "Comm_UserList")
	RAW_EventHandler:RegisterComm("raw-Request", "Comm_RequestInfo")

	-- Events
	RAW_EventHandler:RegisterEvent("GROUP_ROSTER_UPDATE", "Event_RaidRosterUpdate")
	RAW_EventHandler:RegisterEvent("GROUP_JOINED", "Event_GroupJoined")
	RAW_EventHandler:RegisterEvent("PLAYER_LOGIN", "Event_GroupJoined")
	RAW_EventHandler:RegisterEvent("PLAYER_ENTERING_WORLD", "Event_GroupJoined")
	RAW_EventHandler:RegisterEvent("PLAYER_REGEN_DISABLED", "Event_EnteredCombat")

	-- Channel Messages
	RAW_EventHandler:RegisterEvent("CHAT_MSG_RAID", "Message_Raid")
	RAW_EventHandler:RegisterEvent("CHAT_MSG_RAID_LEADER", "Message_Raid") 

	-- Send the Spec Via Addon Message (Probably Just Local Update)
	RAW_Core:SendSpec()
end

-- Called when the addon is disabled
function RAW_Core:OnDisable()
end

-- Called Whenever the Panel is opened, Will add any new Warlocks, and Refresh the UI
function RAW_Core:FindAllWarlocks()	

	local WarlockIndex = 1

	-- Loop over the group members, grab any warlocks and add them to RAW_Core.WarlockList
	for Index = 1, GetNumGroupMembers(), 1  do
		-- Grab the raider info from the WOWAPI
		local RaiderName, RaiderRank, RaiderSubgroup, RaiderLevel, RaiderClass, RaiderFileName, RaiderZone, RaiderOnline, RaiderIsDead, RaiderRole, RaidersIsML = GetRaidRosterInfo(Index);

		if (RaiderClass == "Warlock") then

			local bExists = false;

			-- Iterate the Warlock list and match via name
			for k, ExistingWarlock in ipairs(RAW_Core.WarlockList) do
				if ExistingWarlock.Name == RaiderName then
					ExistingWarlock.bDirty = false
					bExists = true
				end
			end
			
			-- Add a new Warlock to the list
			if not bExists then
				local Warlock = {}
				Warlock.Name = RaiderName
				Warlock.bDirty = false

				-- Assign Basic Curses, These may get overriden if someone sends data
				if RAW_Core.HasValidData ~= true and #RAW_Core.WarlockList+1 <= 3 then
					Warlock.Curse = RAW.Types.Curses[#RAW_Core.WarlockList+1].Text
				else
					Warlock.Curse = RAW.Types.Curses[9].Text
				end
				Warlock.Spec = "(0/0/0)"
				Warlock.CanCorruption = false
			
				RAW_Core.WarlockList[#RAW_Core.WarlockList + 1] = Warlock
			end
		end
	end

	-- Remove Any Warlocks that may have left the raid
	RAW_Core:RemoveDirtyWarlocks()

	--If we have only local unedited data we should draw it at least once
	if (RAW_Core.HasValidData == false) then
		-- Refreshes the UI to Match the Data
		RAW_WarlockList:UpdateWarlockListViewItems()
	end

end

-- Called Whenever the Panel is opened, Iterates through Each Raid member and checks for a soulstone, refreshes UI View
function RAW_Core:FindAllSoulstones()	
	
	-- Clear out all entries
	for k, Entry in ipairs(RAW_Core.SoulstonedList) do
		RAW_Core.SoulstonedList[k] = nil
	end

	-- Iterate over raiders
	for Index = 1, GetNumGroupMembers(), 1  do

		-- Grab the raider info from the WOWAPI
		local RaiderName, RaiderRank, RaiderSubgroup, RaiderLevel, RaiderClass, RaiderFileName, RaiderZone, RaiderOnline, RaiderIsDead, RaiderRole, RaidersIsML = GetRaidRosterInfo(Index);

		if (RaiderClass ~= nil) then
			for BuffIndex = 1, 40, 1 do

				local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId = UnitBuff(RaiderName,BuffIndex)

				if name == "Soulstone Resurrection" then
					local SoulstonedInfo = {}
					-- Whos SSd
					SoulstonedInfo.Name = RaiderName

					SourceString = "Unknown"
					if (source ~= nil) then
						SourceName, SourceRealm = UnitFullName(source)
						SourceString = SourceName
					end

					-- Who SSd Them (May Be Missing)
					SoulstonedInfo.Source = SourceString

					-- ExperationTime, Might Not Be Valid TODO
					--SoulstonedInfo.ExperationTime = expirationTime

					-- Class that was SSd
					SoulstonedInfo.Class = RaiderClass

					-- Assign the updated info
					RAW_Core.SoulstonedList[#RAW_Core.SoulstonedList+1] = SoulstonedInfo
					break
				end
			end
		end
	end

	--Refreshes the UI to Match the Data
	RAW_Soulstones:UpdateSoulStoneViewItems()
end

function RAW_RosterFrameOnShow()
	-- Send the Spec Via Addon Message
	RAW_Core:SendSpec()

	RAW_Core:FindAllWarlocks()
end

function RAW_SoulstoneFrameOnShow()

	RAW_Core:FindAllSoulstones()
end

function RAW_SummonsFrameOnShow()
end

function RAW_OptionsFrameOnShow()
end

-- Whispers the Warlock thier specific assignment
function RAW_Core:WhisperWarlockCurse(Warlock)
	if Warlock ~= nil and Warlock.Name ~= nil then
		local TextString = "Your Curse is: "..Warlock.Curse
		
		if (Warlock.CanCorruption) then
			TextString = TextString..", You May Cast Corruption!"
		end
		
		local Target = Warlock.Name
		SendChatMessage(TextString, "WHISPER", nil, Target)
	end
end

-- Clears warlocks marked dirty from the WarlocList
function RAW_Core:RemoveDirtyWarlocks()

	-- Iterate Backwords through list and remove all Dirty Entries
	for Index = #RAW_Core.WarlockList, 1, -1 do
		if (RAW_Core.WarlockList[Index].bDirty) then
			table.remove(RAW_Core.WarlockList, Index)
		end
	end
end

-- Sends the Warlocks Spec Info to the Raid
function RAW_Core:SendSpec()

	-- Todo: Make this a bit more usefull
	local AfflicNum = 0
	local DemoNum = 0
	local DestroNum = 0
	
	-- Afflic Talents
	for i = 1, GetNumTalents(1)  do
		local name, texture, tier, column, rank, maxRank, isExceptional, available = GetTalentInfo(1,i)
		AfflicNum = AfflicNum + rank
	end

	-- Demo Talents
	for i = 1, GetNumTalents(2) do
		local name, texture, tier, column, rank, maxRank, isExceptional, available = GetTalentInfo(2,i)
		DemoNum = DemoNum + rank
	end

	-- Destro Talents
	for i = 1, GetNumTalents(3) do
		local name, texture, tier, column, rank, maxRank, isExceptional, available = GetTalentInfo(3,i)
		DestroNum = DestroNum + rank
	end

	-- Build a human readable string
	local SpecString = "("..AfflicNum.."/"..DemoNum.."/"..DestroNum..")"

	local WarlockSpecInfo = {}
	WarlockSpecInfo.AfflicNum = AfflicNum
	WarlockSpecInfo.DemoNum = DemoNum
	WarlockSpecInfo.DestroNum = DestroNum
	WarlockSpecInfo.SpecString = SpecString
	
	local MessageString = RAW_Core:Serialize(WarlockSpecInfo)
	RAW_Core:SendCommMessage("raw-Spec", MessageString, "RAID", nil, "NORMAL")
end

-- Sends the Warlock Data Out
function RAW_Core:SendAllWarlockData()

	local MessageString = RAW_Core:Serialize(RAW_Core.WarlockList)
	RAW_Core:SendCommMessage("raw-Warlocks", MessageString, "RAID", nil, "NORMAL")
end