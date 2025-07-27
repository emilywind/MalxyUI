-----------------------------------
-- Adapted from LFG_ProposalTime --
-----------------------------------
function init()
  local bigWigs = C_AddOns.IsAddOnLoaded("BigWigs")
  local lfgProposalTime = C_AddOns.IsAddOnLoaded("LFG_ProposalTime")

  local TIMEOUT = 40

  local timerBar = CreateFrame("StatusBar", nil, LFGDungeonReadyPopup)
  timerBar:SetPoint("TOP", LFGDungeonReadyPopup, "BOTTOM", 0, -5)
  timerBar:SetSize(194, 14)

  SkinProgressBar(timerBar)

  if not bigWigs and not lfgProposalTime then
    timerBar.Text = timerBar:CreateFontString(nil, "OVERLAY")
    timerBar.Text:SetFontObject(GameFontHighlight)
    timerBar.Text:SetPoint("CENTER", timerBar, "CENTER")
  end

  local timeLeft = 0
  local function barUpdate(self, elapsed)
    timeLeft = (timeLeft or 0) - elapsed
    if(timeLeft <= 0) then return self:Hide() end

    self:SetValue(timeLeft)
    if not bigWigs and not lfgProposalTime then
      self.Text:SetFormattedText("%.1f", timeLeft)
    end
  end
  timerBar:SetScript("OnUpdate", barUpdate)

  local function OnEvent(self, event, ...)
    timerBar:SetMinMaxValues(0, TIMEOUT)
    timeLeft = TIMEOUT
    timerBar:Show()
  end

  local eventFrame = CreateFrame("Frame")
  eventFrame:RegisterEvent("LFG_PROPOSAL_SHOW")
  eventFrame:SetScript("OnEvent", OnEvent)
end

OnPlayerLogin(init)
