print ("Clicker Loaded Successfully")
local mainFrame = CreateFrame("Frame", "ClickerMainFrame", UIParent, "BasicFrameTemplateWithInset")
mainFrame:SetSize(300, 300) mainFrame:SetPoint("CENTER") mainFrame.title = mainFrame:CreateFontString(nil, "OVERLAY") mainFrame.title:SetFontObject("GameFontHighlight") mainFrame.title:SetPoint("LEFT", mainFrame.TitleBg, "CENTER", 5, 0) mainFrame.title:SetText("Clicker Addon")
mainFrame:SetPoint("CENTER")
mainFrame.title = mainFrame:CreateFontString(nil, "OVERLAY")
mainFrame.title:SetFontObject("GameFontHighlight")
mainFrame.title:SetPoint("TOPLEFT", mainFrame.TitleBg, "CENTER", 5, 0)
mainFrame.title:SetText("Clicker Addon")
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
    print("Clicker Mute Toggled")
end

-- Hide the frame when the user presses the Escape key
table.insert(UISpecialFrames, "ClickerMainFrame")