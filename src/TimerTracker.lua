OnPlayerLogin(function()
  TimerTracker:HookScript("OnEvent", function(self, event, timerType, timeSeconds, totalTime)
    if event ~= "START_TIMER" then return end

    for i = 1, #self.timerList do
      local prefix = 'TimerTrackerTimer'..i
      local timer = _G[prefix]
      local statusBar = _G['TimerTrackerTimer'..i..'StatusBar']
      if statusBar and not timer.isFree and not timer.euiClean then
        _G[prefix..'StatusBarBorder']:Hide()
        SkinStatusBar(statusBar)
      end
    end
  end)

  MirrorTimerContainer:HookScript("OnEvent", function(self, event, timerType, timeSeconds, totalTime)
    if event ~= 'MIRROR_TIMER_START' then return end

    for _, timer in pairs(self.mirrorTimers) do
      if not timer.euiClean then
        timer.TextBorder:Hide()
        timer.Text:ClearAllPoints()
        timer.Text:SetPoint("CENTER", timer.StatusBar, "CENTER")
        timer.Text:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
        DarkenTexture(timer.Border)
        timer.euiClean = true
      end
    end
  end)
end)
