-- /dump select(4, GetBuildInfo()) use to get updated toc interface version number
if not ClickerDB then
    ClickerDB = {
        settingsKeys = {},
        clickerEnabled = true,
        toastEnabled = true,
        muted = false,
        useClick = "clicker",
        useChannel = "Master",
        numClicks = 0,
    }
end

print ("Clicker Loaded Successfully")
local debugFrame = CreateFrame("Frame", "ClickerMainFrame", UIParent, "BasicFrameTemplateWithInset")
debugFrame:SetSize(350, 350)
debugFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
debugFrame.TitleBg:SetHeight(30)
debugFrame.title = debugFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
debugFrame.title:SetPoint("TOPLEFT", debugFrame.TitleBg, "TOPLEFT", 5, -3)
debugFrame.title:SetText("Clicker Debug Info")

debugFrame.muted = debugFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
debugFrame.muted:SetPoint("TOPLEFT", debugFrame, "TOPLEFT", 10, -40)
debugFrame.muted:SetText("Muted: " .. tostring(ClickerDB.muted))
debugFrame.channel = debugFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
debugFrame.channel:SetPoint("TOPLEFT", debugFrame, "TOPLEFT", 10, -70)
debugFrame.channel:SetText("Channel: " .. ClickerDB.useChannel)  
debugFrame.volume = debugFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
debugFrame.volume:SetPoint("TOPLEFT", debugFrame, "TOPLEFT", 10, -100)
debugFrame.volume:SetText("Volume: " .. ClickerDB.useClick .. ".ogg")
debugFrame.numClicks = debugFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
debugFrame.numClicks:SetPoint("TOPLEFT", debugFrame, "TOPLEFT", 10, -130)
debugFrame.numClicks:SetText("Total Clicks: " .. ClickerDB.numClicks)

debugFrame:Hide()
debugFrame:EnableMouse(true)
debugFrame:SetMovable(true)
debugFrame:RegisterForDrag("LeftButton")
debugFrame:SetScript("OnDragStart", function(self) debugFrame.StartMoving(self) end)
debugFrame:SetScript("OnDragStop", function(self) debugFrame.StopMovingOrSizing(self) end)

debugFrame:SetScript("OnShow", function(self)
    debugFrame.muted:SetText("Muted: " .. tostring(ClickerDB.muted))
    debugFrame.channel:SetText("Channel: " .. ClickerDB.useChannel)
    debugFrame.volume:SetText("Volume: " .. ClickerDB.useClick .. ".ogg")
    debugFrame.numClicks:SetText("Total Clicks: " .. ClickerDB.numClicks)
    print("Clicker Main Frame Shown")
end)

--Clicker Settings Frame and Config
local settingsFrame = CreateFrame("Frame", "ClickerSettingsFrame", UIParent, "BasicFrameTemplateWithInset")
settingsFrame:SetSize(400, 400)
settingsFrame:SetPoint("CENTER")
settingsFrame.TitleBg:SetHeight(30)
settingsFrame.title = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
settingsFrame.title:SetPoint("CENTER", settingsFrame.TitleBg, "CENTER", 0, -3)
settingsFrame.title:SetText("Clicker Settings")
settingsFrame:Hide()
settingsFrame:EnableMouse(true)
settingsFrame:SetMovable(true)
settingsFrame:RegisterForDrag("LeftButton")
settingsFrame:SetScript("OnDragStart", function(self)
	self:StartMoving()
end)

settingsFrame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)

local checkboxes = 0
local function CreateCheckbox(checkboxText, key, checkboxTooltip)
    local checkbox = CreateFrame("CheckButton", "ClickerCheckboxID" .. checkboxes, settingsFrame, "ChatConfigCheckButtonTemplate")
    checkbox.Text:SetText(checkboxText)
    checkbox:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 10, -30 - (checkboxes * -30))
    
    if ClickerDB.settingsKeys[key] == nil then
        ClickerDB.settingsKeys[key] = true
    end
    checkbox:SetChecked(ClickerDB.settingsKeys[key.var])
    
    checkbox.SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(checkboxTooltip, nil, nil, nil, nil, true)
    end)
    
    checkbox:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    checkbox.tooltip = key.tooltip
    
    checkbox:SetScript("OnClick", function(self)
        ClickerDB.settingsKeys[key.var] = self:GetChecked()
    end)

    checkboxes = checkboxes + 1
    return checkbox
end



local settings = {
    {
        label = "Toggle Clicker",
        description = "Turn the Clicker addon functions on or off.",
        tooltip = "Toggle Clicker Addon",
        var = "clickerEnabled",
    },
    {
        label = "Toggle Greeting Toast",
        description = "Enable to see a greeting toast on clicker events!",
        tooltip = "Toggle Greeting Toast On/Off",
        var = "toastEnabled",
    },
    { 
        label = "Toggle Clicker Sound",
        description = "Enable to hear the clicker sound on events!",
        tooltip = "Toggle Clicker Sound On/Off",
        var = "muted",
    },
    {
        label = "Click Sound Volume",
        description = "Set the volume of the click sound.",
        tooltip = "Choose volume level for click sound",
        var = "useClick",
    },
    {
        label = "Sound Channel",
        description = "Set the sound channel for the click sound.",
        tooltip = "Choose sound channel for click sound",
        var = "useChannel",
    }
}

SLASH_CLICKER1 = "/clicker"
function SlashCmdList.CLICKER(msg, editbox)
    local command, rest = msg:match("^(%S*)%s*(.-)$")
    command = strlower(command or "")
    rest = strlower(rest or "")

    if command == "debug" then
        if debugFrame:IsShown() then
            debugFrame:Hide()
        else
            debugFrame:Show()
        end

    elseif command == "enable" then
        ClickerDB.clickerEnabled = true
        print("Clicker Addon Enabled.")

    elseif command == "disable" then
        ClickerDB.clickerEnabled = false
        print("Clicker Addon Disabled.")

    elseif command == "settings" then
        if settingsFrame:IsShown() then
            settingsFrame:Hide()
        else
            settingsFrame:Show()
        end

    elseif command == "toast" then
        -- Toggle toast functionality here
        local clickerToast = not ClickerDB.toastEnabled
        ClickerDB.toastEnabled = clickerToast
        print("Clicker Toast Enabled set to " .. tostring(clickerToast))

    elseif command == "mute" then
        -- Toggle mute functionality here
        local clickerMuted = not ClickerDB.muted
        ClickerDB.muted = clickerMuted
        print("Clicker Mute set to " .. tostring(clickerMuted))

    elseif command == "volume" then
        local volume = tonumber(rest)
        if volume == 1 then
            ClickerDB.useClick = "clicker"
            print("Clicker Volume Set to default")
        elseif volume == 6 then
            ClickerDB.useClick = "clicker6"
            print("Clicker Volume Set to +6db")
        elseif volume == 12 then
            ClickerDB.useClick = "clicker12"
            print("Clicker Volume Set to +12db")
        elseif volume == 18 then
            ClickerDB.useClick = "clicker18"
            print("Clicker Volume Set to +18db")
        else
            print("The current volume is set to " .. ClickerDB.useClick .. ".ogg")
        end

    elseif command == "channel" then
        local channel = tonumber(rest)
        if channel == 1 then
            ClickerDB.useChannel = "Master"
            print("Clicker Channel Set to Master")
        elseif channel == 2 then
            ClickerDB.useChannel = "SFX"
            print("Clicker Channel Set to SFX")
        elseif channel == 3 then
            ClickerDB.useChannel = "Dialog"
            print("Clicker Channel Set to Dialog")
        else
            print("Invalid channel. Please enter 1 for Master, 2 for SFX, or 3 for Dialog.")
        end

    elseif command == "resetClicks" then
        ClickerDB.numClicks = 0
        print("Clicker total clicks reset to 0.")

    elseif command == "test" then
        if not ClickerDB.muted then 
            PlaySoundFile("Interface\\Addons\\Clicker\\Media\\" .. ClickerDB.useClick .. ".ogg", ClickerDB.useChannel)
        print("Clicker test sound played on channel " .. ClickerDB.useChannel .. ", filename is " .. ClickerDB.useClick .. ".ogg")
        end

    elseif command == "test6" then
        if not ClickerDB.muted then PlaySoundFile("Interface\\Addons\\Clicker\\Media\\clicker6.ogg", ClickerDB.useChannel)
        print("Clicker test +6db sound played on the channel " .. ClickerDB.useChannel)
        end

    elseif command == "test12" then
        if not ClickerDB.muted then PlaySoundFile("Interface\\Addons\\Clicker\\Media\\clicker12.ogg", ClickerDB.useChannel)
        print("Clicker test +12db sound played on the channel " .. ClickerDB.useChannel)
        end

    elseif command == "test18" then
        if not ClickerDB.muted then PlaySoundFile("Interface\\Addons\\Clicker\\Media\\clicker18.ogg", ClickerDB.useChannel)
        print("Clicker test +18db sound played on the channel " .. ClickerDB.useChannel)
        end

    else
        print("Clicker Addon Commands:")
        print("/clicker enable - Enable the Clicker addon.")
        print("/clicker disable - Disable the Clicker addon.") 
        print("/clicker debug - Show the Clicker debug frame.")
        print("/clicker settings - Open the Clicker settings frame.")
        print("/clicker mute - Toggle mute on/off for Clicker.")
        print("/clicker volume [0,6,12,18] - Set click sound volume. 0=default, 6=+6db, 12=+12db, 18=+18db.")
        print("/clicker channel [1,2,3] - Set sound channel. 1=Master, 2=SFX, 3=Dialog.")
        print("/clicker test - Play test click sound.")
        print("/clicker test6 - Play test +6db click sound.")
        print("/clicker test12 - Play test +12db click sound.")
        print("/clicker test18 - Play test +18db click sound.")
    end
end

-- Hide the frame when the user presses the Escape key
table.insert(UISpecialFrames, "ClickerMainFrame")

--Magic happens here! Event Listener Frame and functions
local eventListenerFrame = CreateFrame("Frame", "ClickerEventListenerFrame", UIParent)
local function eventHandler(self, event, ...)
    if event == "PLAYER_LEVEL_UP" then
        print("Player has leveled up. Click Time!.")
        if not ClickerDB.muted then PlaySoundFile("Interface\\Addons\\Clicker\\Media\\" .. ClickerDB.useClick .. ".ogg", ClickerDB.useChannel)
        ClickerDB.numClicks = ClickerDB.numClicks + 1
        end
    end
    if event == "PLAYER_PVP_KILLS_CHANGED" then
        print("Player received credit for a PvP kill. Click Time!.")
        if not ClickerDB.muted then PlaySoundFile("Interface\\Addons\\Clicker\\Media\\" .. ClickerDB.useClick .. ".ogg", ClickerDB.useChannel)
        ClickerDB.numClicks = ClickerDB.numClicks + 1
        end
    end
end

eventListenerFrame:SetScript("OnEvent", eventHandler)
eventListenerFrame:RegisterEvent("PLAYER_LEVEL_UP")