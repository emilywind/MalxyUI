OnPlayerLogin(function()
  local UPDATE_DELAY = .2
  local buttonColors, buttonsToUpdate = {}, {}
  local updater = CreateFrame("Frame")
  local timeElapsed = 0

  local colors = {
    ["normal"] = COLOR_WHITE,
    ["oor"] = CreateColor(.8, .1, .1),
    ["oom"] = CreateColor(.5, .5, 1),
    ["unusable"] = CreateColor(.3, .3, .3)
  }

  ---@param button Button
  ---@param colorIndex "normal"|"oor"|"oom"|"unusable"
  local function setButtonColor(button, colorIndex)
    if buttonColors[button] == colorIndex then
      return
    end
    buttonColors[button] = colorIndex

    SetVertexColor(button.icon, colors[colorIndex])
  end

  ---@param button Button
  ---@param force? boolean
  local function updateButtonUsable(button, force)
    if force then
      buttonColors[button] = nil
    end

    local action = button.action
    local isUsable, notEnoughMana = IsUsableAction(action)

    if isUsable then
      local inRange = IsActionInRange(action)
      setButtonColor(button, inRange == false and "oor" or "normal")
    elseif notEnoughMana then
      setButtonColor(button, "oom")
    else
      setButtonColor(button, "unusable")
    end
  end

  local function updateButtons()
    if next(buttonsToUpdate) then
      for button in pairs(buttonsToUpdate) do
        updateButtonUsable(button)
      end
      return true
    end

    return false
  end

  ---@param self Button
  ---@param elapsed number
  local function onUpdateRange(self, elapsed)
    timeElapsed = (timeElapsed or UPDATE_DELAY) - elapsed
    if timeElapsed <= 0 then
      timeElapsed = UPDATE_DELAY

      if not updateButtons() then
        self:Hide()
      end
    end
  end
  updater:SetScript("OnUpdate", onUpdateRange)

  ---@param button Button
  local function updateButtonStatus(button)
    local action = button.action

    buttonsToUpdate[button] = (action and button:IsVisible() and HasAction(action)) and true or nil

    if next(buttonsToUpdate) then
      updater:Show()
    end
  end

  ---@param button Button
  local function register(button)
    button:HookScript("OnShow", updateButtonStatus)
    button:HookScript("OnHide", updateButtonStatus)
    button:SetScript("OnUpdate", nil)
    updateButtonStatus(button)
  end

  ---@param button Button
  local function registerButtonRange(button)
    if button.Update then
      register(button)
      hooksecurefunc(button, "Update", updateButtonStatus)
      hooksecurefunc(button, "UpdateUsable", function(self)
        updateButtonUsable(self, true)
      end)
    end
  end

  DoToActionButtons(registerButtonRange)
end)
