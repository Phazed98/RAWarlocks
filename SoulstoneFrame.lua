local ADDON_NAME, RAW = ...

RAW_Soulstones = {}

-- Frame for the Soulstone tab
RAW.UI.SoulstoneFrame = CreateFrame("SCROLLFRAME", "RAW_Soulstoneframe", RAWarlocks_SoulstoneFrame)
RAW.UI.SoulstoneFrame:SetPoint("TOPLEFT", 16, -86)
RAW.UI.SoulstoneFrame:SetSize(400, 400)
RAW.UI.SoulstoneFrame:EnableMouseWheel(false)

-- Scroll Bar used to navigate the soulstone list
RAW.UI.SoulstoneScrollBar = CreateFrame("Slider", "RAW_SoulScrollBar", RAW.UI.SoulstoneFrame, "UIPanelScrollBarTemplate")
RAW.UI.SoulstoneScrollBar:SetPoint("TOPLEFT", RAW.UI.SoulstoneFrame, "TOPRIGHT", -16, -22)
RAW.UI.SoulstoneScrollBar:SetPoint("BOTTOMLEFT", RAW.UI.SoulstoneFrame, "BOTTOMRIGHT", -16, 8)
RAW.UI.SoulstoneScrollBar:SetMinMaxValues(1, 10)
RAW.UI.SoulstoneScrollBar:SetValueStep(1)
RAW.UI.SoulstoneScrollBar.scrollStep = 1
RAW.UI.SoulstoneScrollBar:SetStepsPerPage(9)
RAW.UI.SoulstoneScrollBar:SetObeyStepOnDrag(true)
RAW.UI.SoulstoneScrollBar:SetValue(1)
RAW.UI.SoulstoneScrollBar:SetWidth(16)
RAW.UI.SoulstoneScrollBar:SetScript("OnValueChanged", function(self, delta)
-- Probably not required
end)

RAW.UI.SoulstonedListViewItems = {}
function RAW.UI.BuildSoulstoneListView()
	for i = 1, 10 do
		-- Base frame holds the rest
		local SoulstoneFrameEntry = CreateFrame("FRAME", tostring("RAW_SoulstonedListViewItems"..i), RAW.UI.SoulstoneFrame)
		SoulstoneFrameEntry:SetPoint("TOPLEFT", 12, ((40 * (i - 1)) * -1) - 2)
		SoulstoneFrameEntry:SetSize(370,40)
		SoulstoneFrameEntry:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background", insets = { left = 1, right = 1, top = 1, bottom = 1 } })
		SoulstoneFrameEntry:SetBackdropColor(0, 0, 0, 1.0)
		SoulstoneFrameEntry:EnableMouse(true)

		-- Name of the person Soulstoned
		SoulstoneFrameEntry.Name = SoulstoneFrameEntry:CreateFontString(tostring("RAW_SoulstonedListViewItems"..i.."_NameText"), "OVERLAY", "GameFontNormalLarge")
		SoulstoneFrameEntry.Name:SetPoint("TOPLEFT", 40, -2)
		SoulstoneFrameEntry.Name:SetText("Unknown")

		-- Source of the Soulstone (Warlock)
		SoulstoneFrameEntry.Source = SoulstoneFrameEntry:CreateFontString(tostring("RAW_SoulstonedListViewItems"..i.."_SourceText"), "OVERLAY", "GameFontNormalSmall")
		SoulstoneFrameEntry.Source:SetPoint("TOPLEFT", 40, -18)
		SoulstoneFrameEntry.Source:SetText("(Unknown)")

		-- Icon that shows the current Soulstoned class
		SoulstoneFrameEntry.ClassIcon = CreateFrame("FRAME", tostring("RAW_SoulstonedListViewItems"..i.."_ClassIcon"), SoulstoneFrameEntry)
		SoulstoneFrameEntry.ClassIcon:SetPoint("TOPLEFT", 5, -5)
		SoulstoneFrameEntry.ClassIcon:SetSize(30, 30)
		SoulstoneFrameEntry.ClassIcon.Texture = SoulstoneFrameEntry.ClassIcon:CreateTexture("$parent_Background", "BACKGROUND")
		SoulstoneFrameEntry.ClassIcon.Texture:SetAllPoints(SoulstoneFrameEntry.ClassIcon)	
		ClassIconValue = RAW.Types.ClassIcons["Unknown"]
		SoulstoneFrameEntry.ClassIcon.Texture:SetTexture(ClassIconValue)

		-- Duration Remaining on the Soulstone
		--SoulstoneFrameEntry.DurationText = SoulstoneFrameEntry.ClassIcon:CreateFontString(tostring("RAW_SoulstonedListViewItems"..i.."_DurationText"), "OVERLAY", "GameFontNormalLarge")
		--SoulstoneFrameEntry.DurationText:SetPoint("TOPLEFT", 5, -5)
		--SoulstoneFrameEntry.DurationText:SetText("30")

		-- Hide by default
		SoulstoneFrameEntry:Hide()

		RAW.UI.SoulstonedListViewItems[i] = SoulstoneFrameEntry
	end
end

-- Takes the values in RAW_Core.SoulstonedList and applies them to the RAW.UI.SoulstonedListViewItems
function RAW_Soulstones:UpdateSoulStoneViewItems()

	-- Hide all current entries, if theres a matching warlock they will be shown
	for k, Entry in ipairs(RAW.UI.SoulstonedListViewItems)  do
		Entry:Hide()
	end

	-- Iterate over the Warlocks and set their data in the UI, and unhide them
	for k, SoulstonedRaider in ipairs(RAW_Core.SoulstonedList) do

		-- Grab a local reference
		local Entry = RAW.UI.SoulstonedListViewItems[k]

		if (Entry ~= nil) then

			NameText = RAW.Types.ClassColours[SoulstonedRaider.Class]..SoulstonedRaider.Name

			Entry.Name:SetText(NameText)

			Entry.Source:SetText("("..SoulstonedRaider.Source..")")

			--Entry.DurationText:SetText(format("%.0f", (SoulstonedRaider.ExperationTime - GetTime()) / 60))

			Entry.ClassIcon.Texture:SetTexture(RAW.Types.ClassIcons[SoulstonedRaider.Class])

			Entry:Show()
		end
	end
end