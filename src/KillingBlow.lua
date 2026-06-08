local KB_TEXTURE = TextureDir .. [[\misc\garouko.tga]]

-- The height/width of the texture. Using a height:width ratio different to that of the texture file may result in distortion.
local TEXTURE_WIDTH         = 100
local TEXTURE_HEIGHT        = 100

-------
-- These four variables control how the image is anchored to the screen.
-------

-- Used in image:SetPoint(TEXTURE_POINT, UIParent, ANCHOR_POINT, OFFSET_X, OFFSET_Y)
-- See http://www.wowpedia.org/API_Region_SetPoint for explanation.
local TEXTURE_POINT         = "CENTER" -- The point of the texture that should be anchored to the screen.
local ANCHOR_POINT          = "TOP" -- The point of the screen the texture should be anchored to.
local OFFSET_X              = 0        -- The x/y offset of the texture relative to the anchor point.
local OFFSET_Y              = -200

-------
-- These four variables control the animation that plays when the image is shown
-------

local SCALE_X               = 1.5  -- The X scalar that the image should scale by
local SCALE_Y               = 1.5  -- The Y scalar that the image should scale by
local SCALE_DURATION        = 2 -- The duration of the scaling animation in seconds

local DELAY_DURATION        = 2 -- The amount of time between the end of the scaling animation and the image hiding

-------
-- Other options
-------

-- The sound to play when you get a killing blow
local SOUND_PATH            = SoundDir .. [[\garou-fullko.ogg]]

-- The channel to play the sound through. This can be "Master", "SFX", "Music" or "Ambience"
local SOUND_CHANNEL         = "Master"

-- If true, the AddOn will only record killing blows on players. If false, it will record all killing blows.
local PLAYER_KILLS_ONLY     = true

-------------------
-- END OF CONFIG --
-------------------
-- Do not change anything below here!


------
-- Animations
------
local frame = CreateFrame("Frame", "KillingBlow_EnhancedFrame", UIParent)
frame:SetPoint(TEXTURE_POINT, UIParent, ANCHOR_POINT, OFFSET_X, OFFSET_Y)
frame:SetFrameStrata("HIGH")
frame:SetAlpha(0.6)
frame:Hide()

local texture = frame:CreateTexture()
texture:SetAllPoints()

local group = texture:CreateAnimationGroup()

group:SetScript("OnPlay", function()
  frame:SetSize(TEXTURE_WIDTH, TEXTURE_HEIGHT) -- Set the frame to the configured size before scaling animation starts
end)

local scale = group:CreateAnimation("Scale")
scale:SetScale(SCALE_X, SCALE_Y)
scale:SetDuration(SCALE_DURATION)

local delay = group:CreateAnimation("Animation")
delay:SetDuration(DELAY_DURATION)

delay:SetScript("OnPlay", function()
  frame:SetSize(TEXTURE_WIDTH * SCALE_X, TEXTURE_HEIGHT * SCALE_Y) -- Set the frame to the scaled size after the scaling animation ends
end)

group:SetScript("OnFinished", function()
  frame:Hide()
end)

frame:SetScript("OnShow", function()
  group:Play()
  PlaySoundFile(SOUND_PATH, SOUND_CHANNEL)
end)

------------
-- Events --
------------
local PLAYER_GUID = UnitGUID("player")

-- Thanks to ErnestasBaltinas' HK Sounds for this method of tracking killing blows
local TOTAL_KILLING_BLOWS_ACHIEVEMENT_ID = 1487

local FirstLoad = true
local PreviousKillingBlows = 0

local function GetKillingBlows()
  local _, _, _, killingBlows = GetAchievementCriteriaInfoByID(TOTAL_KILLING_BLOWS_ACHIEVEMENT_ID, 0)
  return killingBlows
end

local function CheckKillingBlowsIncreased()
  local killingBlows = GetKillingBlows()
  if killingBlows <= PreviousKillingBlows then
    return false
  end

  PreviousKillingBlows = killingBlows
  return true
end

local function KillingBlow()
  frame:Show()
end

local inInstancedPvP = false

function frame:RegisterCombatLogEvents()
  frame:RegisterEvent("PARTY_KILL")
  frame:RegisterEvent("PLAYER_PVP_KILLS_CHANGED")
end

function frame:UnregisterCombatLogEvents()
  frame:UnregisterEvent("PARTY_KILL")
  frame:UnregisterEvent("PLAYER_PVP_KILLS_CHANGED")
end

function ModifyKillingBlowSetting(value)
  if value then
    frame:RegisterCombatLogEvents()
  else
    frame:UnregisterCombatLogEvents()
  end
end

-- Instance
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event, ...)
  self[event](self, ...)
end)

function frame:PLAYER_LOGIN()
  PLAYER_GUID = UnitGUID("player")
  if EUIDB.showKillingBlows then
    frame:RegisterCombatLogEvents()
  end
end

function frame:PLAYER_ENTERING_WORLD()
  if FirstLoad then
    FirstLoad = false
    texture:SetTexture(KB_TEXTURE)

    PreviousKillingBlows = GetKillingBlows()
  end

  local inInstance, instanceType = IsInInstance()
  if inInstance and (instanceType == "pvp" or instanceType == "arena") then
    inInstancedPvP = true
  else
    inInstancedPvP = false
  end
end

function frame:PARTY_KILL(attackerGUID, targetGUID)
  -- If we're in instanced PvP, the kill should be handled by PLAYER_PVP_KILLS_CHANGED
  if inInstancedPvP then
    return
  end

  -- If the player's total killing blows hasn't increased, return now
  local killingBlowsIncreased = CheckKillingBlowsIncreased()
  if not killingBlowsIncreased then
    return
  end

  -- If attacker is secret or not the player or their pet, return now
  if not canaccessvalue(attackerGUID) or (attackerGUID ~= PLAYER_GUID and UnitTokenFromGUID(attackerGUID) ~= "pet") then
    return
  end

  -- If we're only recording player kills and the target is secret or not a player, return now
  if PLAYER_KILLS_ONLY and (not canaccessvalue(targetGUID) or not targetGUID:find("^Player%-")) then
    return
  end

  KillingBlow()
end

function frame:PLAYER_PVP_KILLS_CHANGED()
  -- If we're not in instanced PvP, the kill should be handled by PARTY_KILL
  if not inInstancedPvP then
    return
  end

  -- If the player's total killing blows hasn't increased, return now
  local killingBlowsIncreased = CheckKillingBlowsIncreased()
  if not killingBlowsIncreased then
    return
  end

  KillingBlow()
end
