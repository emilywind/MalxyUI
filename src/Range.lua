OnPlayerLogin(function()
  local Module = CreateFrame('Frame')

  local UPDATE_DELAY = .2
  local buttonColors, buttonsToUpdate = {}, {}
  local updater = CreateFrame("Frame")

  local colors = {
    ["normal"] = {1, 1, 1},
    ["oor"] = {.8, .1, .1},
    ["oom"] = {.5, .5, 1},
    ["unusable"] = {.3, .3, .3}
  }

  function Module:OnUpdateRange(elapsed)
    self.elapsed = (self.elapsed or UPDATE_DELAY) - elapsed
    if self.elapsed <= 0 then
      self.elapsed = UPDATE_DELAY

      if not Module:UpdateButtons() then
        self:Hide()
      end
    end
  end
  updater:SetScript("OnUpdate", Module.OnUpdateRange)

  function Module:UpdateButtons()
    if next(buttonsToUpdate) then
      for button in pairs(buttonsToUpdate) do
        self.UpdateButtonUsable(button)
      end
      return true
    end

    return false
  end

  function Module:UpdateButtonStatus()
    local action = self.action

    buttonsToUpdate[self] = (action and self:IsVisible() and HasAction(action)) and true or nil

    if next(buttonsToUpdate) then
      updater:Show()
    end
  end

  function Module:UpdateButtonUsable(force)
    if force then
      buttonColors[self] = nil
    end

    local action = self.action
    local isUsable, notEnoughMana = IsUsableAction(action)

    if isUsable then
      local inRange = IsActionInRange(action)
      Module.SetButtonColor(self, inRange == false and "oor" or "normal")
    elseif notEnoughMana then
      Module.SetButtonColor(self, "oom")
    else
      Module.SetButtonColor(self, "unusable")
    end
  end

  function Module:SetButtonColor(colorIndex)
    if buttonColors[self] == colorIndex then
      return
    end
    buttonColors[self] = colorIndex

    local r, g, b = unpack(colors[colorIndex])
    self.icon:SetVertexColor(r, g, b)
  end

  function Module:Register()
    self:HookScript("OnShow", Module.UpdateButtonStatus)
    self:HookScript("OnHide", Module.UpdateButtonStatus)
    self:SetScript("OnUpdate", nil)
    Module.UpdateButtonStatus(self)
  end

  local function button_UpdateUsable(button)
    Module.UpdateButtonUsable(button, true)
  end

  local function registerButtonRange(button)
    if button.Update then
      Module.Register(button)
      hooksecurefunc(button, "Update", Module.UpdateButtonStatus)
      hooksecurefunc(button, "UpdateUsable", button_UpdateUsable)
    end
  end

  for i = 1, NUM_ACTIONBAR_BUTTONS do
    registerButtonRange(_G["ActionButton" .. i])
    registerButtonRange(_G["MultiBarBottomLeftButton" .. i])
    registerButtonRange(_G["MultiBarBottomRightButton" .. i])
    for k = 5, 7 do
      registerButtonRange(_G["MultiBar" .. k .. "Button" .. i])
    end
    registerButtonRange(_G["MultiBarRightButton" .. i])
    registerButtonRange(_G["MultiBarLeftButton" .. i])
  end
end)
