OnPlayerLogin(function()
  local _, shadow1, shadow2, icon = LossOfControlFrame:GetRegions()

  shadow1:SetAlpha(0)
  shadow2:SetAlpha(0)

  ApplyEuiBackdrop(icon, LossOfControlFrame)
end)
