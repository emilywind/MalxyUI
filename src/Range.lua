OnPlayerLogin(function()
  local UPDATE_DELAY = .2
  local buttonColors, buttonsToUpdate = {}, {}
  local updater = CreateFrame("Frame")
  local timeElapsed = 0

  local colors = {
    ["normal"] = {1, 1, 1},
    ["oor"] = {.8, .1, .1},
    ["oom"] = {.5, .5, 1},
    ["unusable"] = {.3, .3, .3}
  }

  function OnUpdateRange(self, elapsed)
    timeElapsed = (timeElapsed or UPDATE_DELAY) - elapsed
    if timeElapsed <= 0 then
      timeElapsed = UPDATE_DELAY

      if not UpdateButtons() then
        self:Hide()
      end
    end
  end
  updater:SetScript("OnUpdate", OnUpdateRange)

  function UpdateButtons()
    if next(buttonsToUpdate) then
      for button in pairs(buttonsToUpdate) do
        UpdateButtonUsable(button)
      end
      return true
    end

    return false
  end

  function UpdateButtonStatus(button)
    local action = button.action

    buttonsToUpdate[button] = (action and button:IsVisible() and HasAction(action)) and true or nil

    if next(buttonsToUpdate) then
      updater:Show()
    end
  end

  function UpdateButtonUsable(button, force)
    if force then
      buttonColors[button] = nil
    end

    local action = button.action
    local isUsable, notEnoughMana = IsUsableAction(action)

    if isUsable then
      local inRange = IsActionInRange(action)
      SetButtonColor(button, inRange == false and "oor" or "normal")
    elseif notEnoughMana then
      SetButtonColor(button, "oom")
    else
      SetButtonColor(button, "unusable")
    end
  end

  function SetButtonColor(button, colorIndex)
    if buttonColors[button] == colorIndex then
      return
    end
    buttonColors[button] = colorIndex

    local r, g, b = unpack(colors[colorIndex])
    button.icon:SetVertexColor(r, g, b)
  end

  function Register(button)
    button:HookScript("OnShow", UpdateButtonStatus)
    button:HookScript("OnHide", UpdateButtonStatus)
    button:SetScript("OnUpdate", nil)
    UpdateButtonStatus(button)
  end

  local function button_UpdateUsable(button)
    UpdateButtonUsable(button, true)
  end

  local function registerButtonRange(button)
    if button.Update then
      Register(button)
      hooksecurefunc(button, "Update", UpdateButtonStatus)
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
