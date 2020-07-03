local ADDON_NAME, RAW = ...

RAW_EventHandler = {}

----------------------------------------------
-- COMMS HANDLERS
----------------------------------------------

-- Default Comm handler
function RAW_EventHandler:OnCommReceived(prefix, message, distribution, sender)
end

-- Handles Comm Message Recieved Containing Warlock Spec
function RAW_EventHandler:Comm_WarlockSpec(Prefix, Message, Distribution, Sender)

	-- Try to Deserialize the Spec info, if success update the Entry and refresh the UI
	local Success, SpecInfo = RAW_Core:Deserialize(Message)
	if (Success) then

		-- Look through the list of Warlocks, if they match set thier Spec String
		for k, Warlock in ipairs(RAW_Core.WarlockList) do
			if Warlock.Name == Sender then
				
				RAW_Core:DebugPrint("Recieved Warlock Spec for "..Warlock.Name)
				Warlock.Spec = SpecInfo.SpecString
			end
		end
	end

	-- Refresh the UI
	RAW_WarlockList:UpdateWarlockListViewItems()
end

-- Handles Comm Message Recieved Containing All Warlock Info Dump
function RAW_EventHandler:Comm_WarlockConfigsDump(Prefix, Message, Distribution, Sender)

	-- Try to Deserialize the Warlock info, if success update the Entry and refresh the UI
	local Success, UpdatedWarlocks = RAW_Core:Deserialize(Message)
	if (Success) then
	
		RAW_Core:DebugPrint("Recieved Bulk Warlock Info From: "..Sender)
		RAW_Core.WarlockList = UpdatedWarlocks
		
		RAW_Core.HasValidData = true
	end

	RAW_WarlockList:UpdateWarlockListViewItems()
end

-- Handles the Event when a new users joins
function RAW_EventHandler:Comm_AddonUserAnnounced(Prefix, Message, Distribution, Sender)
	RAW_Core.AddonUserList[Sender] = Sender -- Keep Track of Other Addon Users
end

-- Handles Comm Message Recieved Indicating a New Summon Session has Started
function RAW_EventHandler:Comm_NewSession(Prefix, Message, Distribution, Sender)

	-- TODO: Move this to a function in SummonsFrame.lua
	-- Clear the local list of summons
	for k, Entry in ipairs(RAW_Core.SummonList) do
		RAW_Core.SummonList[k] = nil
	end
	
	RAW_Summons:UpdateSummonListView()
end

-- Handles Comm Message Recieved Indicating a New Summon Session has Started
function RAW_EventHandler:Comm_RequestInfo(Prefix, Message, Distribution, Sender)

 	-- Send your apec out to others
	RAW_Core:SendSpec()

	if (RAW_Core.HasValidData) then
		RAW_Core:SendAllWarlockData()
	end

end

------------------------------------------------
-- EVENT HANDLERS
------------------------------------------------

-- Hook for GROUP_ROSTER_UPDATE
function RAW_EventHandler:Event_RaidRosterUpdate()
 
 	-- When the group changes, send a message so others see who has the addon
	local MessageString = "Hello" -- Todo: Send Usefull Information, Or Remove Entirely
	RAW_Core:SendCommMessage("raw-Announce", MessageString, "RAID", nil, "NORMAL")
end

-- Hook to GROUP_JOINED, PLAYER_LOGIN, PLAYER_ENTERING_WORLD
function RAW_EventHandler:Event_GroupJoined()
	--Clear out any list of addon users we have
	for k, AddonUser in ipairs(RAW_Core.AddonUserList) do
		RAW_Core.AddonUserList[k] = nil
	end

	-- When Joining a Group Send Your Spec To the Others
	RAW_Core:SendSpec()

	-- When I join a new group announce myself
	local MessageString = "Joined"
	RAW_Core:SendCommMessage("raw-Request", MessageString, "RAID", nil, "NORMAL")
end


----------------------------------------------------------
-- CHAT MESSAGE HANDLERS
----------------------------------------------------------

-- Message Handler that parses RAID messages for Key Text and Performs Actions
function RAW_EventHandler:Message_Raid(Channel, Message, Sender, arg11, arg12)	

	-- Iterator seperated by spaces
	local MessageIterator  = string.gmatch(Message, "%S+")

	-- Grab the first word
	local KeyWord = MessageIterator()

	-- Look for an Indicator in Chat. If so Add to Summon Queue
	if (KeyWord == "X" or KeyWord =="x" or KeyWord == "Summ" or KeyWord == "123" or KeyWord =="1") then

		-- Sender is in format Name-Server, parses the name portion
		local NameIterator  = string.gmatch(Sender, "([^%-]+)")
		local SummonName = NameIterator()

		-- Check through the list of Currently Queued Raiders, if they already exist dont add them again
		local Exists = false
		for k, Target in ipairs(RAW_Core.SummonList) do
			if Target.Name == SummonName then
				Target.Status = "Queued" -- Reset their status to Queued if it was set to Summoned
				Exists = true
				break
			end
		end

		-- If they dont exist create a new Entry for them
		if (Exists ~= true) then
			local SummonInfo = {}
			SummonInfo.Name = SummonName
			SummonInfo.Status = "Queued"

			--Todo: Find away to avoid Iterating over the Raid every time
			for Index = 1, GetNumGroupMembers(), 1 do
				--Grab the raider info from the WOWAPI
				local RaiderName, RaiderRank, RaiderSubgroup, RaiderLevel, RaiderClass, RaiderFileName, RaiderZone, RaiderOnline, RaiderIsDead, RaiderRole, RaidersIsML = GetRaidRosterInfo(Index);
				if RaiderName == SummonName then
					SummonInfo.Class = RaiderClass
					SummonInfo.Zone = RaiderZone
					SummonInfo.Online = RaiderOnline
					SummonInfo.Dead = RaiderIsDead
					break
				end
			end

			RAW_Core.SummonList[#RAW_Core.SummonList +1] = SummonInfo
		end

		--Redraw the Summon Interface with the Updated 
		RAW_Summons:UpdateSummonListView()
	end

	--Messages sent to Raid(Not Via SendAddonMessage) will prefix with RAW so we can pick them up here
	if (KeyWord == "RAW")
	then
		local Action = MessageIterator()
		if (Action == "Summoning") then
		
			local TargetName = MessageIterator()
			for k, Target in ipairs(RAW_Core.SummonList) do
				if (Target.Name == TargetName) then
					Target.Status = "Summoned"
					break
				end
			end

			--Refresh the view
			RAW_Summons:UpdateSummonListView()
		end
	end
end

------------------------------------------
-- HELPER FUNCTIONS
------------------------------------------

--Function Used to Register Events With Ace
function RAW_EventHandler:RegisterEvent(eventName, callback)
	if not callback then 
		callback = eventName 
	end

	RAW_Core:RegisterEvent(eventName, function(...) self[callback](self, ...) end)
end

--Function Used to Register Comms With Ace
function RAW_EventHandler:RegisterComm(prefix, callback)
	RAW_Core:RegisterComm(prefix, function(...) self[callback](self, ...) end)
end