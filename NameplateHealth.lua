local AddonName, NS = ...

local CreateFrame = CreateFrame
local type = type
local tonumber = tonumber
local AbbreviateNumbers = AbbreviateNumbers
local Round = Round
local BreakUpLargeNumbers = BreakUpLargeNumbers
local floor = floor
local ceil = ceil
local issecure = issecure
local IsInInstance = IsInInstance
local UnitIsUnit = UnitIsUnit
local UnitIsPlayer = UnitIsPlayer
local UnitIsFriend = UnitIsFriend
local UnitIsEnemy = UnitIsEnemy
local UnitCanAttack = UnitCanAttack
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
-- local UnitReaction = UnitReaction
local pairs = pairs
local UnitAffectingCombat = UnitAffectingCombat
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitGUID = UnitGUID
local select = select
local strsplit = strsplit
local LibStub = LibStub
local next = next

local sformat = string.format
local smatch = string.match

local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local GetNamePlates = C_NamePlate.GetNamePlates
local After = C_Timer.After

local LSM = LibStub("LibSharedMedia-3.0")

local NameplateHealth = NS.NameplateHealth
local NameplateHealthFrame = NS.NameplateHealth.frame
NameplateHealthFrame.dbChanged = false
NameplateHealthFrame.inArena = false
NameplateHealthFrame.wasOnLoadingScreen = true

local simpleFormatters = {
  AbbreviateNumbers = function(value)
    if type(value) == "string" then
      value = tonumber(value)
    end
    return (type(value) == "number") and AbbreviateNumbers(value) or value
  end,
  AbbreviateLargeNumbers = function(value)
    if type(value) == "string" then
      value = tonumber(value)
    end
    return (type(value) == "number") and AbbreviateLargeNumbers(Round(value)) or value
  end,
  BreakUpLargeNumbers = function(value)
    if type(value) == "string" then
      value = tonumber(value)
    end
    return (type(value) == "number") and BreakUpLargeNumbers(value) or value
  end,
  floor = function(value)
    if type(value) == "string" then
      value = tonumber(value)
    end
    return (type(value) == "number") and floor(value) or value
  end,
  ceil = function(value)
    if type(value) == "string" then
      value = tonumber(value)
    end
    return (type(value) == "number") and ceil(value) or value
  end,
  round = function(value)
    if type(value) == "string" then
      value = tonumber(value)
    end
    return (type(value) == "number") and Round(value) or value
  end,
}

local function GetSafeNameplateFrame(nameplate)
  if not nameplate then
    return nil
  end

  if not nameplate.UnitFrame then
    return nil
  end

  local frame = nameplate.UnitFrame

  if frame:IsForbidden() then
    return nil
  end

  if not frame.unit then
    return nil
  end

  if not smatch(frame.unit, "nameplate") then
    return nil
  end

  return frame
end

local function GetHealthbarFrame(nameplate)
  local frame = GetSafeNameplateFrame(nameplate)
  if frame then
    if frame.HealthBarsContainer then
      return frame.HealthBarsContainer.healthBar
    else
      return frame
    end
  end
  return nameplate
end

local function instanceCheck()
  local inInstance, instanceType = IsInInstance()
  NameplateHealthFrame.inArena = inInstance and (instanceType == "arena")
end

local function GetUnitHealthText(unit, health, absorb)
  local healthAmount = health and health or UnitHealth(unit) -- doesn't include absorb amount
  local totalAmount = UnitHealthMax(unit) -- doesn't include absorb amount

  local finalString = ""

  if NS.db.global.showAbsorb then
    local absorbAmount = absorb and absorb or UnitGetTotalAbsorbs(unit)

    if NS.db.global.showPercentage then
      local healthPercentAmount = totalAmount ~= 0 and ((healthAmount + absorbAmount) / totalAmount) * 100 or 0
      local healthPercentString = simpleFormatters.floor(healthPercentAmount)

      if NS.db.global.showPercentageOnly then
        finalString = sformat("%s%%", healthPercentString)
      else
        local healthString = simpleFormatters.AbbreviateNumbers(healthAmount + absorbAmount)

        finalString = sformat("%s (%s%%)", healthString, healthPercentString)
      end
    else
      local healthString = simpleFormatters.AbbreviateNumbers(healthAmount + absorbAmount)

      finalString = sformat("%s", healthString)
    end
  else
    if NS.db.global.showPercentage then
      local healthPercentAmount = totalAmount ~= 0 and (healthAmount / totalAmount) * 100 or 0
      local healthPercentString = simpleFormatters.floor(healthPercentAmount)

      if NS.db.global.showPercentageOnly then
        finalString = sformat("%s%%", healthPercentString)
      else
        local healthString = simpleFormatters.AbbreviateNumbers(healthAmount)

        finalString = sformat("%s (%s%%)", healthString, healthPercentString)
      end
    else
      local healthString = simpleFormatters.AbbreviateNumbers(healthAmount)

      finalString = sformat("%s", healthString)
    end
  end

  return finalString
end

local function addNameplateHealth(nameplate, guid)
  if not nameplate.namePlateUnitToken then
    return
  end

  local unit = nameplate.namePlateUnitToken

  local isPlayer = UnitIsPlayer(unit)
  local isNpc = not isPlayer
  local isSelf = UnitIsUnit(unit, "player")
  local isEnemy = UnitIsEnemy("player", unit)
  local isFriend = UnitIsFriend("player", unit)
  local canAttack = UnitCanAttack("player", unit)
  local isDeadOrGhost = UnitIsDeadOrGhost(unit)
  -- local npcID = select(6, strsplit("-", guid))

  local hideDead = isDeadOrGhost
  local hideNPCs = not NS.db.global.showNPCs and isNpc
  local hideSelf = isSelf
  local hideAllies = not NS.db.global.showAllies and isFriend
  local hideEnemies = not NS.db.global.showEnemies and isEnemy
  local hideCanAttack = not NS.db.global.showAllies and (NS.db.global.showCanAttackOnly and not canAttack)
  local hideNonPlayers = NS.db.global.showPlayersOnly and isNpc
  local showTestMode = not NS.db.global.test
  local hideHealthNumbers = showTestMode
    and (hideNPCs or hideSelf or hideDead or hideAllies or hideEnemies or hideNonPlayers or hideCanAttack)

  if hideHealthNumbers then
    if nameplate.nphHealthText then
      nameplate.nphHealthText:Hide()
    end
    return
  end

  local frame = GetSafeNameplateFrame(nameplate)
  local anchorFrame = frame and frame.healthBar or nameplate
  local offsetX = 0
  if frame and frame.healthBar then
  else
    if NS.db.global.position == "LEFT" then
      offsetX = 12
    elseif NS.db.global.position == "RIGHT" then
      offsetX = -12
    end
  end
  local offset = {
    x = offsetX,
    y = 0,
  }

  if not nameplate.nphHealthText then
    nameplate.nphHealthText = nameplate.rbgdAnchorFrame:CreateFontString(nil, "OVERLAY")
    nameplate.nphHealthText:SetFont(LSM:Fetch("font", NS.db.global.fontFamily), NS.db.global.fontSize, "OUTLINE")
    nameplate.nphHealthText:SetTextColor(
      NS.db.global.color.r,
      NS.db.global.color.g,
      NS.db.global.color.b,
      NS.db.global.color.a
    )
    nameplate.nphHealthText:ClearAllPoints()
    nameplate.nphHealthText:SetPoint(NS.db.global.position, anchorFrame, NS.db.global.position, offset.x, offset.y)
    nameplate.nphHealthText:SetShadowOffset(1, -1)
    nameplate.nphHealthText:SetShadowColor(0, 0, 0, 0.2)
    nameplate.nphHealthText:SetJustifyH("CENTER")
    nameplate.nphHealthText:SetScale(1)
    nameplate.nphHealthAmount = UnitHealth(unit)
    nameplate.nphHealthAbsorb = nil
    if NS.db.global.showAbsorb then
      nameplate.nphHealthAbsorb = UnitGetTotalAbsorbs(unit)
    end
    local healthText = GetUnitHealthText(unit, nameplate.nphHealthAmount, nameplate.nphHealthAbsorb)
    nameplate.nphHealthText:SetText(healthText)
  end

  if NameplateHealthFrame.dbChanged then
    nameplate.nphHealthText:SetFont(LSM:Fetch("font", NS.db.global.fontFamily), NS.db.global.fontSize, "OUTLINE")
    nameplate.nphHealthText:SetTextColor(
      NS.db.global.color.r,
      NS.db.global.color.g,
      NS.db.global.color.b,
      NS.db.global.color.a
    )
    nameplate.nphHealthText:ClearAllPoints()
    nameplate.nphHealthText:SetPoint(NS.db.global.position, anchorFrame, NS.db.global.position, offset.x, offset.y)
  end

  local unitHealth = UnitHealth(unit)
  local unitAbsorb = nil
  if NS.db.global.showAbsorb then
    unitAbsorb = UnitGetTotalAbsorbs(unit)
  end

  if
    nameplate.nphHealthAmount ~= unitHealth
    or nameplate.nphHealthAbsorb ~= unitAbsorb
    or NameplateHealthFrame.dbChanged
  then
    nameplate.nphHealthAmount = unitHealth
    nameplate.nphHealthAbsorb = unitAbsorb
    local healthText = GetUnitHealthText(unit, nameplate.nphHealthAmount, nameplate.nphHealthAbsorb)
    nameplate.nphHealthText:SetText(healthText)
  end

  nameplate.nphHealthText:Show()
end

local function refreshNameplates(override)
  if not override and NameplateHealthFrame.wasOnLoadingScreen then
    return
  end

  for _, nameplate in pairs(GetNamePlates(issecure())) do
    if nameplate and nameplate.namePlateUnitToken then
      local guid = UnitGUID(nameplate.namePlateUnitToken)
      if guid then
        NameplateHealth:attachToNameplate(nameplate, guid)
      end
    end
  end
end

function NameplateHealth:detachFromNameplate(nameplate)
  if nameplate.nphHealthText ~= nil then
    nameplate.nphHealthText:Hide()
  end
end

function NameplateHealth:attachToNameplate(nameplate, guid)
  if not nameplate.rbgdAnchorFrame then
    local healthBarFrame = GetHealthbarFrame(nameplate)
    local attachmentFrame = healthBarFrame and healthBarFrame or nameplate
    nameplate.rbgdAnchorFrame = CreateFrame("Frame", nil, attachmentFrame)
  end

  addNameplateHealth(nameplate, guid)
end

function NameplateHealth:NAME_PLATE_UNIT_REMOVED(unitToken)
  if not unitToken then
    return
  end

  local nameplate = GetNamePlateForUnit(unitToken, issecure())

  if nameplate then
    self:detachFromNameplate(nameplate)
  end
end

function NameplateHealth:NAME_PLATE_UNIT_ADDED(unitToken)
  if not unitToken then
    return
  end

  local nameplate = GetNamePlateForUnit(unitToken, issecure())
  local guid = UnitGUID(unitToken)

  if nameplate and guid then
    self:attachToNameplate(nameplate, guid)
  end
end

function NameplateHealth:UNIT_ABSORB_AMOUNT_CHANGED(unitTarget)
  if not unitTarget then
    return
  end

  local nameplate = GetNamePlateForUnit(unitTarget, issecure())
  local guid = UnitGUID(unitTarget)

  if nameplate and guid then
    addNameplateHealth(nameplate, guid)
  end
end

function NameplateHealth:UNIT_HEALTH(unitTarget)
  if not unitTarget then
    return
  end

  local nameplate = GetNamePlateForUnit(unitTarget, issecure())
  local guid = UnitGUID(unitTarget)

  if nameplate and guid then
    addNameplateHealth(nameplate, guid)
  end
end

local ShuffleFrame = CreateFrame("Frame")
ShuffleFrame.eventRegistered = false

function NameplateHealth:PLAYER_REGEN_ENABLED()
  NameplateHealthFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
  ShuffleFrame.eventRegistered = false

  refreshNameplates()
end

function NameplateHealth:GROUP_ROSTER_UPDATE()
  if not NameplateHealthFrame.inArena then
    return
  end

  local name = AuraUtil.FindAuraByName("Arena Preparation", "player", "HELPFUL")
  if not name then
    return
  end

  if UnitAffectingCombat("player") then
    if not ShuffleFrame.eventRegistered then
      NameplateHealthFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
      ShuffleFrame.eventRegistered = true
    end
  else
    refreshNameplates()
  end
end

function NameplateHealth:ARENA_OPPONENT_UPDATE()
  if not NameplateHealthFrame.inArena then
    return
  end

  local name = AuraUtil.FindAuraByName("Arena Preparation", "player", "HELPFUL")
  if not name then
    return
  end

  if UnitAffectingCombat("player") then
    if not ShuffleFrame.eventRegistered then
      NameplateHealthFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
      ShuffleFrame.eventRegistered = true
    end
  else
    refreshNameplates()
  end
end

function NameplateHealth:PLAYER_LEAVING_WORLD()
  After(2, function()
    NameplateHealthFrame.wasOnLoadingScreen = false
  end)
end

function NameplateHealth:LOADING_SCREEN_DISABLED()
  After(2, function()
    NameplateHealthFrame.wasOnLoadingScreen = false
  end)
end

function NameplateHealth:LOADING_SCREEN_ENABLED()
  NameplateHealthFrame.wasOnLoadingScreen = true
end

function NameplateHealth:PLAYER_ENTERING_WORLD()
  NameplateHealthFrame.wasOnLoadingScreen = true

  instanceCheck()

  if not NameplateHealthFrame.loaded then
    NameplateHealthFrame.loaded = true

    NameplateHealthFrame:RegisterEvent("UNIT_HEALTH")
    NameplateHealthFrame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    NameplateHealthFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    NameplateHealthFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    NameplateHealthFrame:RegisterEvent("ARENA_OPPONENT_UPDATE")
    NameplateHealthFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
  end
end

function NameplateHealth:PLAYER_LOGIN()
  NameplateHealthFrame:UnregisterEvent("PLAYER_LOGIN")

  NameplateHealthFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
  NameplateHealthFrame:RegisterEvent("PLAYER_LEAVING_WORLD")
  NameplateHealthFrame:RegisterEvent("LOADING_SCREEN_ENABLED")
  NameplateHealthFrame:RegisterEvent("LOADING_SCREEN_DISABLED")
end
NameplateHealthFrame:RegisterEvent("PLAYER_LOGIN")

function NS.OnDbChanged()
  NameplateHealthFrame.dbChanged = true
  refreshNameplates(true)
  NameplateHealthFrame.dbChanged = false
end

function NS.Options_SlashCommands(_)
  LibStub("AceConfigDialog-3.0"):Open(AddonName)
end

function NS.Options_Setup()
  LibStub("AceConfig-3.0"):RegisterOptionsTable(AddonName, NS.AceConfig)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddonName, AddonName)

  SLASH_NPH1 = AddonName
  SLASH_NPH2 = "/nph"

  function SlashCmdList.NPH(message)
    NS.Options_SlashCommands(message)
  end
end

function NameplateHealth:ADDON_LOADED(addon)
  if addon == AddonName then
    NameplateHealthFrame:UnregisterEvent("ADDON_LOADED")

    NameplateHealthDB = NameplateHealthDB and next(NameplateHealthDB) ~= nil and NameplateHealthDB or {}

    -- Copy any settings from default if they don't exist in current profile
    NS.CopyDefaults(NS.DefaultDatabase, NameplateHealthDB)

    -- Reference to active db profile
    -- Always use this directly or reference will be invalid
    NS.db = NameplateHealthDB

    -- Remove table values no longer found in default settings
    NS.CleanupDB(NameplateHealthDB, NS.DefaultDatabase)

    NS.Options_Setup()
  end
end
NameplateHealthFrame:RegisterEvent("ADDON_LOADED")
