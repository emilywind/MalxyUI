local tDelay = 0

local function FastLoot()
  if not EUIDB.fasterLoot then return end

  if GetTime() - tDelay >= 0.3 then
    tDelay = GetTime()
    if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
      if TSMDestroyBtn and TSMDestroyBtn:IsShown() and TSMDestroyBtn:GetButtonState() == "DISABLED" then
        tDelay = GetTime()
        return
      end
      for i = GetNumLootItems(), 1, -1 do
        LootSlot(i)
      end
      tDelay = GetTime()
    end
  end
end

OnEvent("LOOT_READY", FastLoot)
