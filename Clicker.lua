if not ClickerDB then
    ClickerDB = {}
end

print ("Clicker Loaded Successfully")
local mainFrame = CreateFrame("Frame", "ClickerMainFrame", UIParent, "BasicFrameTemplateWithInset")
mainFrame:SetSize(300, 300)
mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
mainFrame.TitleBg:SetHeight(30)
mainFrame.title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
mainFrame.title:SetPoint("TOPLEFT", mainFrame.TitleBg, "TOPLEFT", 5, -3)
mainFrame.title:SetText("Clicker Addon Settings")
mainFrame:Hide()
mainFrame:EnableMouse(true)
mainFrame:SetMovable(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", function(self) mainFrame.StartMoving(self) end)
mainFrame:SetScript("OnDragStop", function(self) mainFrame.StopMovingOrSizing(self) end)
mainFrame:SetScript("OnShow", function(self)
    print("Clicker Main Frame Shown")
end)

SLASH_CLICKER1 = "/clicker"
SlashCmdList["CLICKER"] = function()
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
    end
end

SLASH_CLICKER2 = "/clickermute"
SlashCmdList["CLICKERMUTE"] = function()
   -- Toggle mute functionality here
    local clickerMuted = not ClickerDB.muted
    ClickerDB.muted = clickerMuted
    print("Clicker Mute Toggled")
end

local eventListenerFrame = CreateFrame("Frame", "ClickerEventListenerFrame", UIParent)
local function eventHandler(self, event, ...)
    if event == "PLAYER_LEVEL_UP" then
        print("Player has leveled up. Click Time!.")
        if not ClickerDB.muted then PlaySoundFile("Interface\\Addons\\Clicker\\Media\\clicker.ogg", "SFX")
        end
    end
    if event == "PLAYER_PVP_KILLS_CHANGED" then
        print("Player received credit for a PvP kill. Click Time!.")
        if not ClickerDB.muted then PlaySoundFile("Interface\\Addons\\Clicker\\Media\\clicker.ogg", "SFX")
        end
    end
end

eventListenerFrame:SetScript("OnEvent", eventHandler)
eventListenerFrame:RegisterEvent("PLAYER_LEVEL_UP")

-- Hide the frame when the user presses the Escape key
table.insert(UISpecialFrames, "ClickerMainFrame")