local AddonName, NS = ...

local CopyTable = CopyTable
local LibStub = LibStub

local SharedMedia = LibStub("LibSharedMedia-3.0")

NS.AceConfig = {
  name = AddonName,
  type = "group",
  childGroups = "tab",
  args = {
    test = {
      name = "Turn on test mode",
      desc = "Only works outside of instances.",
      type = "toggle",
      width = "full",
      order = 1,
      set = function(_, val)
        NS.db.global.test = val
        NS.OnDbChanged()
      end,
      get = function(_)
        return NS.db.global.test
      end,
    },
    showAbsorb = {
      name = "Include absorb amount",
      desc = "Enabling this includes absorb amount into the numbers you see.",
      type = "toggle",
      width = "full",
      order = 2,
      set = function(_, val)
        NS.db.global.showAbsorb = val
        NS.OnDbChanged()
      end,
      get = function(_)
        return NS.db.global.showAbsorb
      end,
    },
    showPercentage = {
      name = "Show Percentage",
      desc = "Enabling this shows health as a percentage next to the numeric amount.",
      type = "toggle",
      width = 1.1,
      order = 3,
      set = function(_, val)
        NS.db.global.showPercentage = val
        NS.OnDbChanged()
      end,
      get = function(_)
        return NS.db.global.showPercentage
      end,
    },
    showPercentageOnly = {
      name = "Show only percentage",
      desc = "Enabling this shows health only as a percentage.",
      type = "toggle",
      width = 1.1,
      order = 4,
      set = function(_, val)
        NS.db.global.showPercentageOnly = val
        NS.OnDbChanged()
      end,
      get = function(_)
        return NS.db.global.showPercentageOnly
      end,
    },
    -- exclusions
    exclusionsGroup = {
      name = "Show only for specific units:",
      type = "group",
      inline = true,
      order = 9,
      args = {
        showAllies = {
          name = "Show for Allies",
          desc = "Enabling this shows on allies.",
          type = "toggle",
          width = "full",
          order = 1,
          set = function(_, val)
            NS.db.global.showAllies = val
            if val then
              NS.db.global.showCanAttackOnly = false
            end
            NS.OnDbChanged()
          end,
          get = function(_)
            return not NS.db.global.showCanAttackOnly and NS.db.global.showAllies
          end,
        },
        showEnemies = {
          name = "Show for Enemies",
          desc = "Enabling this shows on enemies.",
          type = "toggle",
          width = "full",
          order = 2,
          set = function(_, val)
            NS.db.global.showEnemies = val
            NS.OnDbChanged()
          end,
          get = function(_)
            return NS.db.global.showEnemies
          end,
        },
        showNPCs = {
          name = "Show for NPCs",
          desc = "Enabling this shows on NPCs.",
          type = "toggle",
          width = "full",
          order = 3,
          set = function(_, val)
            NS.db.global.showNPCs = val
            if val then
              NS.db.global.showPlayersOnly = false
            end
            NS.OnDbChanged()
          end,
          get = function(_)
            return not NS.db.global.showPlayersOnly and NS.db.global.showNPCs
          end,
        },
        showPlayersOnly = {
          name = "Show only for players",
          desc = 'Enabling this shows only on players. This will disable "Show for NPCs."',
          type = "toggle",
          width = "full",
          order = 4,
          set = function(_, val)
            NS.db.global.showPlayersOnly = val
            if val then
              NS.db.global.showNPCs = false
            end
            NS.OnDbChanged()
          end,
          get = function(_)
            return not NS.db.global.showNPCs and NS.db.global.showPlayersOnly
          end,
        },
        showCanAttackOnly = {
          name = "Show only for units you can attack",
          desc = 'Enabling this shows only on units you can attack. This will disable "Show for Allies."',
          type = "toggle",
          width = "full",
          order = 5,
          set = function(_, val)
            NS.db.global.showCanAttackOnly = val
            if val then
              NS.db.global.showAllies = false
            end
            NS.OnDbChanged()
          end,
          get = function(_)
            return not NS.db.global.showAllies and NS.db.global.showCanAttackOnly
          end,
        },
      },
    },
    position = {
      name = "Nameplate Positioning",
      desc = "Set where you want the text to show up within the nameplate health bar.",
      type = "select",
      width = 1.5,
      order = 10,
      values = {
        ["LEFT"] = "Left",
        ["CENTER"] = "Center",
        ["RIGHT"] = "Right",
      },
      sorting = {
        "LEFT",
        "CENTER",
        "RIGHT",
      },
      set = function(_, val)
        NS.db.global.position = val
        NS.OnDbChanged()
      end,
      get = function(_)
        return NS.db.global.position
      end,
    },
    spacer2 = { name = " ", type = "description", order = 11, width = "full" },
    fontSize = {
      type = "range",
      name = "Font Size",
      width = 1.5,
      order = 12,
      min = 2,
      max = 64,
      step = 1,
      set = function(_, val)
        NS.db.global.fontSize = val
        NS.OnDbChanged()
      end,
      get = function(_)
        return NS.db.global.fontSize
      end,
    },
    spacer3 = { name = " ", type = "description", order = 13, width = "full" },
    fontFamily = {
      type = "select",
      name = "Font Family",
      width = 1.5,
      order = 14,
      dialogControl = "LSM30_Font",
      values = SharedMedia:HashTable("font"),
      set = function(_, val)
        NS.db.global.fontFamily = val
        NS.OnDbChanged()
      end,
      get = function(_)
        return NS.db.global.fontFamily
      end,
    },
    spacer4 = { name = "", type = "description", order = 15, width = 0.1 },
    color = {
      type = "color",
      name = "Color",
      width = 0.5,
      order = 16,
      hasAlpha = true,
      set = function(_, val1, val2, val3, val4)
        NS.db.global.color.r = val1
        NS.db.global.color.g = val2
        NS.db.global.color.b = val3
        NS.db.global.color.a = val4
        NS.OnDbChanged()
      end,
      get = function(_)
        return NS.db.global.color.r, NS.db.global.color.g, NS.db.global.color.b, NS.db.global.color.a
      end,
    },
    spacer5 = { type = "description", order = 17, name = " ", width = "full" },
    reset = {
      name = "Reset Everything",
      type = "execute",
      width = "normal",
      order = 100,
      func = function()
        NameplateHealthDB = CopyTable(NS.DefaultDatabase)
        NS.db = CopyTable(NS.DefaultDatabase)
        NS.OnDbChanged()
      end,
    },
  },
}
