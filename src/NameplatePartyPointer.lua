-- Healer spec id's
local HealerSpecs = {
  [105]  = true,   --> druid resto
  [270]  = true,   --> monk mw
  [65]   = true,   --> paladin holy
  [256]  = true,   --> priest disc
  [257]  = true,   --> priest holy
  [264]  = true,   --> shaman resto
  [1468] = true,   --> preservation evoker
}

local ppTextures = {
  [1] = "UI-QuestPoiImportant-QuestNumber-SuperTracked",
  [2] = "CreditsScreen-Assets-Buttons-Rewind",           --rotate
  [3] = "CovenantSanctum-Renown-DoubleArrow-Disabled",   -- rotate
  [4] = "Crosshair_Quest_128",
  [5] = "Crosshair_Wrapper_128",
  [6] = "honorsystem-icon-prestige-2",
  [7] = "plunderstorm-glues-queueselector-solo-selected",
  [8] = "plunderstorm-glues-queueselector-solo",
  [9] = "AutoQuest-Badge-Campaign",
  [10] = "Ping_Marker_Icon_OnMyWay",
  [11] = "Ping_Marker_Icon_NonThreat",
  [12] = "charactercreate-icon-customize-body-selected",
  [13] = "128-RedButton-Delete",
  [14] = 'plunderstorm-glues-logoarrow',
}

local pointerOffsets = {
  [2] = 2,
  [5] = -2,
}

local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local playerClass = select(2, UnitClass("player"))

-- Class Indicator
function PartyPointer(frame)
  if not frame.EUI then
    frame.EUI = {}
  end

  local info = frame.EUI.unitInfo or GetNameplateUnitInfo(frame)
  frame.EUI.unitInfo = info
  if not info or not info.isPlayer then return end

  local instanceInfo = GetInstanceData()

  local isInParty = UnitInParty(frame.unit)

  local pointerMode =  EUIDB.partyPointerTexture
  local normalTexture = ppTextures[pointerMode]

  if isInParty and not info.isFriend or info.isSelf then
    if EUIDB.partyPointerHideRaidmarker then
      frame.RaidTargetFrame.RaidTargetIcon:SetAlpha(1)
    end
    if frame.partyPointer then
      frame.partyPointer:Hide()
    end
    if frame.ppChange then
      frame.hideNameOverride = nil
      frame.ppChange = nil
    end
    return
  end

  -- Initialize Class Icon Frame
  if not frame.partyPointer then
    frame.partyPointer = CreateFrame("Frame", nil, frame)
    frame.partyPointer:SetFrameLevel(0)
    frame.partyPointer:SetSize(24, 24)
    frame.partyPointer.icon = frame.partyPointer:CreateTexture(nil, "BACKGROUND", nil, 1)
    frame.partyPointer.icon:SetAtlas(normalTexture)
    frame.partyPointer.icon:SetSize(34, 48)
    frame.partyPointer.icon:SetPoint("BOTTOM", frame.partyPointer, "BOTTOM", 0, 5)
    frame.partyPointer.icon:SetDesaturated(true)

    frame.partyPointer.highlight = frame.partyPointer:CreateTexture(nil, "BACKGROUND")
    frame.partyPointer.highlight:SetAtlas(normalTexture)
    frame.partyPointer.highlight:SetSize(55, 69)
    frame.partyPointer.highlight:SetPoint("CENTER", frame.partyPointer.icon, "CENTER", 0, -1)
    frame.partyPointer.highlight:SetDesaturated(true)
    frame.partyPointer.highlight:SetBlendMode("ADD")
    frame.partyPointer.highlight:SetVertexColor(1, 1, 0)
    frame.partyPointer.highlight:Hide()

    frame.partyPointer.healerIcon = frame.partyPointer:CreateTexture(nil, "BORDER")
    frame.partyPointer.healerIcon:SetAtlas("communities-chat-icon-plus")
    frame.partyPointer.healerIcon:SetSize(45, 45)
    frame.partyPointer.healerIcon:SetPoint("BOTTOM", frame.partyPointer.icon, "TOP", 0, -13)
    frame.partyPointer.healerIcon:SetDesaturated(true)
    frame.partyPointer.healerIcon:SetVertexColor(0, 1, 0)
    frame.partyPointer.healerIcon:Hide()

    frame.partyPointer:SetIgnoreParentAlpha(true)
    frame.partyPointer:SetFrameStrata("LOW")

    if not frame.classIndicatorCC then
      frame.classIndicatorCC = CreateFrame("Frame", nil, frame.partyPointer)
      frame.classIndicatorCC:SetSize(39, 39)
      frame.classIndicatorCC:SetFrameStrata("HIGH")
      frame.classIndicatorCC:Hide()

      frame.classIndicatorCC.Icon = frame.classIndicatorCC:CreateTexture(nil, "OVERLAY", nil, 6)
      frame.classIndicatorCC.Icon:SetPoint("CENTER", frame.partyPointer.icon)
      frame.classIndicatorCC.mask = frame.classIndicatorCC:CreateMaskTexture()
      frame.classIndicatorCC.mask:SetTexture("Interface/Masks/CircleMaskScalable")
      frame.classIndicatorCC.mask:SetSize(40, 40)
      frame.classIndicatorCC.mask:SetPoint("CENTER", frame.partyPointer.icon)
      frame.classIndicatorCC.Icon:AddMaskTexture(frame.classIndicatorCC.mask)
      frame.classIndicatorCC.Icon:SetSize(39, 39)

      frame.classIndicatorCC.Cooldown = CreateFrame("Cooldown", nil, frame.classIndicatorCC, "CooldownFrameTemplate")
      frame.classIndicatorCC.Cooldown:SetAllPoints(frame.classIndicatorCC.Icon)
      frame.classIndicatorCC.Cooldown:SetDrawEdge(false)
      frame.classIndicatorCC.Cooldown:SetDrawSwipe(true)
      frame.classIndicatorCC.Cooldown:SetSwipeColor(0, 0, 0, 0.7)
      frame.classIndicatorCC.Cooldown:SetSwipeTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
      frame.classIndicatorCC.Cooldown:SetUseCircularEdge(true)
      frame.classIndicatorCC.Cooldown:SetReverse(true)

      frame.classIndicatorCC.Glow = frame.classIndicatorCC:CreateTexture(nil, "OVERLAY", nil, 7)
      frame.classIndicatorCC.Glow:SetAtlas("charactercreate-ring-select")
      frame.classIndicatorCC.Glow:SetPoint("CENTER", frame.partyPointer.icon, "CENTER", 0, 0)
      frame.classIndicatorCC.Glow:SetDesaturated(true)
      frame.classIndicatorCC.Glow:SetSize(54, 54)
      frame.classIndicatorCC.Glow:SetDrawLayer("OVERLAY", 7)
    end
  end
  frame.partyPointer.icon:SetAtlas(normalTexture)
  frame.partyPointer:SetAlpha(1)


  if pointerMode == 2 or pointerMode == 3 then
    frame.partyPointer.icon:SetRotation(math.rad(90))
  else
    frame.partyPointer.icon:SetRotation(0)
  end

  frame.partyPointer:SetScale(EUIDB.partyPointerScale)
  frame.partyPointer.icon:SetWidth(120)
  frame.partyPointer.highlight:SetWidth(120 + 26)
  frame.partyPointer.healerIcon:SetScale(EUIDB.partyPointerScale)

  -- Visibility checks
  -- if ((config.partyPointerArenaOnly and not BBP.isInArena) or (config.partyPointerBgOnly and not BBP.isInBg)) and not config.partyPointerTestMode then
  --   if not ((config.partyPointerArenaOnly and config.partyPointerBgOnly) and (BBP.isInArena or BBP.isInBg)) then
  --     frame.partyPointer:Hide()
  --     if config.partyPointerHideRaidmarker then
  --       if not config.hideRaidmarkIndicator then
  --         frame.RaidTargetFrame.RaidTargetIcon:SetAlpha(1)
  --       end
  --     end
  --     return
  --   end
  -- end

  local resourceAnchor = nil
  if EUIDB.nameplateResourceOnTarget then
    resourceAnchor = frame:GetParent().driverFrame.classNamePlateMechanicFrame
  end

  frame.partyPointer:SetPoint("BOTTOM", resourceAnchor or frame.name, "TOP", 0, 70)

  local classColor = RAID_CLASS_COLORS[class]
  local r, g, b = classColor.r, classColor.g, classColor.b

  frame.partyPointer.icon:SetVertexColor(r, g, b)

  if EUIDB.partyPointerHighlight then
    frame.partyPointer.highlight:SetScale(EUIDB.partyPointerScale)
    if info.isTarget then
      frame.partyPointer.highlight:Show()
    else
      frame.partyPointer.highlight:Hide()
    end
  end

  -- Check for Healer Only Mode
  local specID = GetSpecID(frame)

  if EUIDB.partyPointerHealer then
    if HealerSpecs[specID] then
      frame.partyPointer.healerIcon:Show()
      frame.partyPointer.healerIcon:ClearAllPoints()
      frame.partyPointer.healerIcon:SetPoint("CENTER", frame.partyPointer.icon, "CENTER", 0, 0)
      frame.partyPointer.icon:Hide()
    else
      frame.partyPointer.healerIcon:Hide()
      frame.partyPointer.icon:Show()
    end
  else
    frame.partyPointer.healerIcon:Hide()
  end
  frame.partyPointer:Show()
  if EUIDB.partyPointerHideRaidmarker then
    frame.RaidTargetFrame.RaidTargetIcon:SetAlpha(0)
  end

  if frame.ppChange then
    frame.HealthBarsContainer:SetAlpha(1)
    frame.hideNameOverride = nil
    frame.ppChange = nil
  end
end
