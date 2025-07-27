local cleanIconBackdrop = {
  bgFile = SQUARE_TEXTURE,
  edgeFile = SQUARE_TEXTURE,
  tile = false,
  tileSize = 0,
  edgeSize = 3,
  insets = {
    left = -2,
    right = -2,
    top = -2,
    bottom = -2
  }
}

OnPlayerLogin(function(self, event, ...)
   -- Hide red shadow
  select(2,LossOfControlFrame:GetRegions()):SetAlpha(0)
  select(3,LossOfControlFrame:GetRegions()):SetAlpha(0)

  -- Style the icon
  local icon = select(4,LossOfControlFrame:GetRegions())

  ApplyEuiBackdrop(icon, LossOfControlFrame)
end)
