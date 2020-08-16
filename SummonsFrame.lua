local ADDON_NAME, RAW = ...

RAW_Summons = {}

-- Frame for the summons tab
RAW.UI.SummonsFrame = CreateFrame("SCROLLFRAME", "RAW_SummonsFrame", RAWarlocks_SummonsFrame)
RAW.UI.SummonsFrame:SetPoint("TOPLEFT", 16, -86)
RAW.UI.SummonsFrame:SetSize(400, 400)
RAW.UI.SummonsFrame:EnableMouseWheel(false)

-- Button messages raid indicating summons are available and clears the pending summons list
RAW.UI.SummonsFrame.MessageRaidButton = CreateFrame("BUTTON", "RAW_SummonRaidButton", RAW.UI.SummonsFrame, "UIPanelButtonTemplate")
RAW.UI.SummonsFrame.MessageRaidButton:SetPoint("TOPLEFT", 100, 25)
RAW.UI.SummonsFrame.MessageRaidButton:SetText("Start Summon Session")
RAW.UI.SummonsFrame.MessageRaidButton:SetSize(150, 22)
RAW.UI.SummonsFrame.MessageRaidButton:SetScript("OnClick", function()
	SendChatMessage(RAW_Options.SummonSessionText, "RAID", nil, nil)
	RAW_Core:SendCommMessage("raw-NewSession", "SessionStart", "RAID", nil, "BULK")
end)

-- Scroll Bar used to navigate the summons list
RAW.UI.SummonsScrollBar = CreateFrame("Slider", "RAW_SummonsScrollBar", RAW.UI.SummonsFrame, "UIPanelScrollBarTemplate")
RAW.UI.SummonsScrollBar:SetPoint("TOPLEFT", RAW.UI.SummonsFrame, "TOPRIGHT", -16, -22)
RAW.UI.SummonsScrollBar:SetPoint("BOTTOMLEFT", RAW.UI.SummonsFrame, "BOTTOMRIGHT", -16, 8)
RAW.UI.SummonsScrollBar:SetMinMaxValues(0, 30)
RAW.UI.SummonsScrollBar:SetValueStep(1)
RAW.UI.SummonsScrollBar.scrollStep = 1
RAW.UI.SummonsScrollBar:SetStepsPerPage(9)
RAW.UI.SummonsScrollBar:SetObeyStepOnDrag(true)
RAW.UI.SummonsScrollBar:SetValue(0)
RAW.UI.SummonsScrollBar:SetWidth(16)
RAW.UI.SummonsScrollBar:EnableMouseWheel(false)
RAW.UI.SummonsScrollBar:SetScript("OnValueChanged", function(self, delta)
	RAW_Summons:UpdateSummonListView()
end)

RAW.UI.SummonListViewItems = {}
function RAW.UI.BuildSummonListView()
	for i = 1, 10 do
		-- Base frame holds the rest
		local SummonFrameEntry = CreateFrame("FRAME", tostring("RAW_SummonListViewItems"..i), RAW.UI.SummonsFrame)
		SummonFrameEntry:SetPoint("TOPLEFT", 12, ((40 * (i - 1)) * -1) - 2)
		SummonFrameEntry:SetSize(370, 40)
		SummonFrameEntry:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background", insets = { left = 1, right = 1, top = 1, bottom = 1 } })
		SummonFrameEntry:SetBackdropColor(0, 0, 0, 1.0)
		SummonFrameEntry:EnableMouse(true)

		SummonFrameEntry.PlayerName = "None"

		-- Name of the person requesting a summon
		SummonFrameEntry.Name = SummonFrameEntry:CreateFontString(tostring("RAW_SoulstonedListViewItems"..i.."_NameText"), "OVERLAY", "GameFontNormalLarge")
		SummonFrameEntry.Name:SetPoint("TOPLEFT", 40, -2)
		SummonFrameEntry.Name:SetText("Unknown")

		-- Location of the person requesting a summon
		SummonFrameEntry.Location = SummonFrameEntry:CreateFontString(tostring("RAW_SoulstonedListViewItems"..i.."_SourceText"), "OVERLAY", "GameFontNormalSmall")
		SummonFrameEntry.Location:SetPoint("TOPLEFT", 40, -18)
		SummonFrameEntry.Location:SetText("(Unknown)")

		-- Class Icon of the person requesting a summon
		SummonFrameEntry.ClassIcon = CreateFrame("FRAME", tostring("RAW_SoulstonedListViewItems"..i.."_ClassIcon"), SummonFrameEntry)
		SummonFrameEntry.ClassIcon:SetPoint("TOPLEFT", 5, -5)
		SummonFrameEntry.ClassIcon:SetSize(30, 30)
		SummonFrameEntry.ClassIcon.Texture = SummonFrameEntry.ClassIcon:CreateTexture("$parent_Background", "BACKGROUND")
		SummonFrameEntry.ClassIcon.Texture:SetAllPoints(SummonFrameEntry.ClassIcon)	
		SummonFrameEntry.ClassIcon.Texture:SetTexture( RAW.Types.ClassIcons["Unknown"])

		-- Button used to clear the summon without summoning them
		SummonFrameEntry.ClearButton = CreateFrame("BUTTON", tostring("RAW_ClearButton"), SummonFrameEntry, "UIPanelButtonTemplate")
		SummonFrameEntry.ClearButton:SetPoint("RIGHT", -100, 0)
		SummonFrameEntry.ClearButton:SetText("Remove")
		SummonFrameEntry.ClearButton:SetSize(60, 25)
		SummonFrameEntry.ClearButton:SetScript("OnClick", function()

			for k, Target in ipairs(RAW_Core.SummonList) do
				if SummonFrameEntry.PlayerName == Target.Name then
					Target.Status = "InProgress"
					break
				end
			end

			--Refresh the view
			RAW_Summons:UpdateSummonListView()
		end)

		-- Button used to summon the person
		SummonFrameEntry.SummonButton = CreateFrame("BUTTON", "RAW_SummonButton", SummonFrameEntry, "SecureActionButtonTemplate, UIPanelButtonTemplate");
		SummonFrameEntry.SummonButton:SetPoint("RIGHT", -10, 0)
		SummonFrameEntry.SummonButton:SetText("Summon")
		SummonFrameEntry.SummonButton:SetSize(60, 25)
		SummonFrameEntry.SummonButton:SetAttribute("type", "macro");

		-- Hide by default
		SummonFrameEntry:Hide()

		RAW.UI.SummonListViewItems[i] = SummonFrameEntry
	end
end

-- Refreshes the SummonFrameView Entries
function RAW_Summons:UpdateSummonListView()


	if (InCombatLockdown() == true) then
		-- Player is in fight, we have to wait to be able to change the summon macro
		RAW_Core.UpdateSummons = true
		return
	end


	--Scrollbar Determines which Index to start at
	local SummonListIndex = RAW.UI.SummonsScrollBar:GetValue()

	-- Iterate over all the ListViewItems and try to find a Summon To Show
	for k, Entry in ipairs(RAW.UI.SummonListViewItems) do

		-- Flag set if we find a valid SummonInfo to display
		local ShouldShowEntry = false

		-- Find the Next SummonListItem To Show
		for Index = SummonListIndex +1, #RAW_Core.SummonList, 1 do
			if (RAW_Core.SummonList[Index] ~= nil and RAW_Core.SummonList[Index].Status == "Queued") then
				SummonListIndex = Index
				ShouldShowEntry = true
				break
			end
		end

		-- There is an entry in this summon index that we wish to show
		if (ShouldShowEntry) then
			-- Cache it locally
			local SummonInfo = RAW_Core.SummonList[SummonListIndex]

			Entry.PlayerName = SummonInfo.Name

			local NameText = RAW.Types.ClassColours[SummonInfo.Class]..SummonInfo.Name
			Entry.Name:SetText(NameText)
			Entry.Location:SetText(SummonInfo.Zone)

			local ClassIconValue = RAW.Types.ClassIcons[SummonInfo.Class]
			Entry.ClassIcon.Texture:SetTexture(ClassIconValue)

			SummonSpellName = GetSpellInfo(698) -- get local name of "Ritual of Summoning"

			-- Build the Macro String, Wow API has a limitation of requireing a SecureButtonTemplate to be clicked to perform some actions
			-- One action is UseMacro which lets us Target and Cast Ritual of Summoning, Than Announce in Raid which the EventHandler looks for to remove the item from the list
			local MacroString = "/Tar "..SummonInfo.Name .."\n/cast  "..SummonSpellName
			--local MacroString = "/Tar "..SummonInfo.Name .."\n/cast  Ritual of Summoning" .."\n/Script if IsCurrentSpell(698) then SendChatMessage(\"RAW Summoning "..SummonInfo.Name.."\", \"RAID\") end"
			Entry.SummonButton:SetAttribute("macrotext", MacroString);


			-- Show current entry
			Entry:Show()
		else
			-- Hide current entry
			Entry:Hide()
		end
	end
	self:UpdateSummonMakro()
end


function RAW_Summons:UpdateSummonMakro()
	local MacroString = ""
	EditMacro("RAPort",nil,136223,MacroString)

	for Index, Entry in ipairs(RAW_Core.SummonList) do

		if (RAW_Core.SummonList[Index] ~= nil and RAW_Core.SummonList[Index].Status == "Queued") then

			SummonSpellName = GetSpellInfo(698) -- get local name of "Ritual of Summoning"
			--local MacroString = "/Tar "..Entry.Name .."\n/cast  "..SummonSpellName

			MacroString = "#showtooltip "..SummonSpellName.."\n/Tar [modifier:shift] "..Entry.Name .."\n/cast  "..SummonSpellName
			EditMacro("RAPort",nil,136223,MacroString)
			break
		end
	end
end

