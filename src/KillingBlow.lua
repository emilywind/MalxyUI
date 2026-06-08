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
frame:Hide()

local texture = frame:CreateTexture()
texture:SetAllPoints()

local group = texture:CreateAnimationGroup()

group:SetScript("OnPlay", function(self)
  frame:SetSize(TEXTURE_WIDTH, TEXTURE_HEIGHT) -- Set the frame to the configured size before scaling animation starts
end)

local scale = group:CreateAnimation("Scale")
scale:SetScale(SCALE_X, SCALE_Y)
scale:SetDuration(SCALE_DURATION)

local delay = group:CreateAnimation("Animation")
delay:SetDuration(DELAY_DURATION)

delay:SetScript("OnPlay", function(self)
  frame:SetSize(TEXTURE_WIDTH * SCALE_X, TEXTURE_HEIGHT * SCALE_Y) -- Set the frame to the scaled size after the scaling animation ends
end)

group:SetScript("OnFinished", function(self)
  frame:Hide()
end)

frame:SetScript("OnShow", function(self)
  group:Play()
  PlaySoundFile(SOUND_PATH, SOUND_CHANNEL)
end)


------
-- Events
------
local addon, ns = ...

local band = bit.band

-- true if we have the AddOn security restrictions added in 12.0.0
-- TODO: Confirm if this works in the next Classic version to include the secrets API
local isCombatLogSecret = C_Secrets and C_Secrets.HasSecretRestrictions and C_Secrets.HasSecretRestrictions()

local FILTER_MINE = bit.bor( -- Matches any "unit" under the player's control
  COMBATLOG_OBJECT_AFFILIATION_MINE,
  COMBATLOG_OBJECT_REACTION_FRIENDLY,
  COMBATLOG_OBJECT_CONTROL_PLAYER
)

local PLAYER_GUID = UnitGUID("player")


-- Thanks to ErnestasBaltinas' HK Sounds for this method of tracking killing blows
local TOTAL_KILLING_BLOWS_ACHIEVEMENT_ID = 1487

local FirstLoad = true
local RecentKills = setmetatable({}, { __mode = "kv" }) -- [GUID] = killTime (from GetTime())
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
  if isCombatLogSecret then
    frame:RegisterEvent("PARTY_KILL")
    frame:RegisterEvent("PLAYER_PVP_KILLS_CHANGED")
  else
    frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  end
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterCombatLogEvents()

-- Instance
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function(self, event, ...)
  self[event](self, ...)
end)

function frame:ADDON_LOADED(name)
  if name == addon then
    self:UnregisterEvent("ADDON_LOADED")
  end
end

function frame:PLAYER_LOGIN()
  PLAYER_GUID = UnitGUID("player")
  PLAYER_NAME = GetUnitName("player", true)
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

if isCombatLogSecret then
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
else
  local function HandleCLEU(timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
                            destGUID,
                            destName, destFlags, destRaidFlags, ...)
    -- If there isn't a valid destination GUID
    if not destGUID or destGUID == "" or
        -- Or the source unit isn't the player or something controlled by the player (the latter check was suggested by Caellian)
        (sourceGUID ~= PLAYER_GUID and band(sourceFlags, FILTER_MINE) ~= FILTER_MINE) or
        -- Or we're only recording player kills and the destination unit isn't a player
        (PLAYER_KILLS_ONLY and not destGUID:find("^Player%-"))
    then
      return
    end -- Return now

    local _, overkill
    if event == "SWING_DAMAGE" then
      _, overkill = ...
    elseif event:find("_DAMAGE", 1, true) and not event:find("_DURABILITY_DAMAGE", 1, true) then
      _, _, _, _, overkill = ...
    end

    local now, previousKill = GetTime(), RecentKills[destGUID]

    -- Caellian has noted that PARTY_KILL doesn't always fire correctly and suggested checking the overkill argument
    -- (which will be 0 [or maybe -1] for non-killing blows) to mitigate against this.
    --
    -- Because most kills will trigger PARTY_KILL and an overkill _DAMAGE, we need to keep a record of recent kill times
    -- and only record kills of the same unit when they're at least 1 second apart.
    if (event == "PARTY_KILL" or (overkill and overkill > 0)) and (not previousKill or now - previousKill > 1.0) then
      KillingBlow()
    end
  end

  function frame:COMBAT_LOG_EVENT_UNFILTERED()
    HandleCLEU(CombatLogGetCurrentEventInfo())
  end
end
