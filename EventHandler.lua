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
				break
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

		--We recieved Valid Data from a raid member
		RAW_Core.HasValidData = true
	end

	RAW_WarlockList:UpdateWarlockListViewItems()
end

-- Handles the Event when a new users joins
function RAW_EventHandler:Comm_AddonUserAnnounced(Prefix, Message, Distribution, Sender)
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

	-- Update the list so we dont send dirty info
	RAW_Core:FindAllWarlocks()	

	if (RAW_Core.HasValidData) then
		RAW_Core:SendAllWarlockData()
	end

end

-- Handles Comm Message Recieved Indicating a New Summon Session has Started
function RAW_EventHandler:Comm_SummonStarted(Prefix, Message, Distribution, Sender)

	local TargetName = Message
	for k, Target in ipairs(RAW_Core.SummonList) do
		if (Target.Name == TargetName) then
			Target.Status = "InProgress"
			break
		end
	end
	
	--Refresh the view
	RAW_Summons:UpdateSummonListView()
end

------------------------------------------------
-- EVENT HANDLERS
------------------------------------------------

-- Hook for GROUP_ROSTER_UPDATE
function RAW_EventHandler:Event_RaidRosterUpdate()
 
 	-- When the group changes, send a message so others see who has the addon
	local MessageString = "Hello" -- Todo: Send Usefull Information, Or Remove Entirely
	RAW_Core:SendCommMessage("raw-Announce", MessageString, "RAID", nil, "NORMAL")

	-- Send the Spec Via Addon Message
	RAW_Core:SendSpec()

	RAW_Core:FindAllWarlocks()
end

-- Hook to GROUP_JOINED, PLAYER_LOGIN, PLAYER_ENTERING_WORLD
function RAW_EventHandler:Event_GroupJoined()
	
	RAW.UI.OptionsFrame.DebugCheckBox:SetChecked(RAW_Options.Debug)

	if (RAW_Options.Debug) then
		RAW.UI.RosterScrollFrame.TestFeatureButton:Show()
	else
		RAW.UI.RosterScrollFrame.TestFeatureButton:Hide()
	end

	--If we Just joined the group, we dont have valid data
	RAW_Core.HasValidData = false

	-- When Joining a Group Send Your Spec To the Others
	RAW_Core:SendSpec()

	-- When I join a new group announce myself
	local MessageString = "Joined"
	RAW_Core:SendCommMessage("raw-Request", MessageString, "RAID", nil, "NORMAL")
end

-- Hook to GROUP_JOINED, PLAYER_LOGIN, PLAYER_ENTERING_WORLD
function RAW_EventHandler:Event_Login()
	--Fill out the Custom Summon text Boxes
	RAW.UI.OptionsFrame.SummonSessionTextBox:SetText(RAW_Options.SummonSessionText)
	RAW.UI.OptionsFrame.SummonChatTextBox:SetText(RAW_Options.SummonChatText)

	--Update the UI Checkbox to match the stored options
	RAW.UI.OptionsFrame.DebugCheckBox:SetChecked(RAW_Options.Debug)
	
	--Fires on reload, so if were in a group we should pretend like we jsut joined to refresh all our data
	RAW_EventHandler:Event_GroupJoined()
end

-- Hook to GROUP_JOINED, PLAYER_LOGIN, PLAYER_ENTERING_WORLD
function RAW_EventHandler:Event_EnteredCombat()
	RAWarlocks:Hide()
end


-- Hook to GROUP_JOINED, PLAYER_LOGIN, PLAYER_ENTERING_WORLD
function RAW_EventHandler:Event_SpellCastStarted(IDString, Source, CastGUID, SpellID)
	name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(SpellID)

	if Source == "player" and SpellID == 698 then
		RAW_Core:DebugPrint("IDString "..IDString.." Source "..Source.." CastGUID "..CastGUID.." SpellID "..SpellID .." SpellName "..name)
		SendChatMessage(RAW_Options.SummonChatText, "RAID", nil, nil)
	
		local MessageString = UnitName("playerTarget")
		RAW_Core:SendCommMessage("raw-SummonStart", MessageString, "RAID", nil, "NORMAL")
	end
end

-- Hook to GROUP_JOINED, PLAYER_LOGIN, PLAYER_ENTERING_WORLD
function RAW_EventHandler:Event_SpellCastSucceded(IDString, Source, CastGUID, SpellID)
	name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(SpellID)
	if Source == "player" and SpellID == 698 then
		RAW_Core:DebugPrint("IDString "..IDString.."\nSource "..Source.."\nCastGUID "..CastGUID.."\nSpellID "..SpellID .."\nSpellName "..name)
	end
end

-- Hook to GROUP_JOINED, PLAYER_LOGIN, PLAYER_ENTERING_WORLD
function RAW_EventHandler:Event_SpellCastFailed(IDString, Source, CastGUID, SpellID)
	name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(SpellID)
	if Source == "player" and SpellID == 698 then
		RAW_Core:DebugPrint("IDString "..IDString.."\nSource "..Source.."\nCastGUID "..CastGUID.."\nSpellID "..SpellID .."\nSpellName "..name)
	end
end

-- Hook to GROUP_JOINED, PLAYER_LOGIN, PLAYER_ENTERING_WORLD
function RAW_EventHandler:Event_SpellCastSent(UnitTarget, CastGUID, spellID)
	--RAW_Core:DebugPrint("SpellCast Sent")
	--RAW_Core:DebugPrint("\nUnitTarget "..UnitTarget.."\nCastGUID "..CastGUID.."\nSpellID "..spellID)
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
					SummonInfo.Class = RaiderFileName
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
	--if (KeyWord == "RAW")
	--then
	--	local Action = MessageIterator()
	--	if (Action == "Summoning") then
	--	
	--		local TargetName = MessageIterator()
	--		for k, Target in ipairs(RAW_Core.SummonList) do
	--			if (Target.Name == TargetName) then
	--				Target.Status = "Summoned"
	--				break
	--			end
	--		end
	--
	--		--Refresh the view
	--		RAW_Summons:UpdateSummonListView()
	--	end
	--end
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