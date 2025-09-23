local SetCVar = C_CVar.SetCVar

OnEvents({
  "PLAYER_ENTERING_WORLD",
  "ZONE_CHANGED_NEW_AREA"
}, function()
    local instanceInfo = GetInstanceData()

    if instanceInfo.isInPvE and EUIDB.nameplateHideFriendsPve then
      SetCVar("nameplateShowFriends", 0)
    elseif EUIDB.nameplateShowFriends then
      SetCVar("nameplateShowFriends", 1)
    end
  end)
