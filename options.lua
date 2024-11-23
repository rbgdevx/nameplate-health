local AddonName, NS = ...

local CopyTable = CopyTable

NS.AceConfig = {
  name = AddonName,
  type = "group",
  childGroups = "tab",
  args = {
    general = {
      name = "General",
      type = "group",
      args = {
        test = {
          name = "Turn on test mode",
          desc = "Only works outside of instances.",
          type = "toggle",
          width = "double",
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
          order = 4,
          set = function(_, val)
            NS.db.global.showPercentageOnly = val

            NS.OnDbChanged()
          end,
          get = function(_)
            return NS.db.global.showPercentageOnly
          end,
        },
        showAllies = {
          name = "Show for Allies",
          desc = "Enabling this shows on allies.",
          type = "toggle",
          width = "double",
          order = 5,
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
          width = "double",
          order = 6,
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
          width = "double",
          order = 7,
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
        -- exclusions
        exclusionsGroup = {
          name = "Show only for specific units:",
          type = "group",
          inline = true,
          order = 8,
          args = {
            showPlayersOnly = {
              name = "Show only for players",
              desc = 'Enabling this shows only on players. This will disable "Show for NPCs."',
              type = "toggle",
              width = "double",
              order = 1,
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
              width = "double",
              order = 1,
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
          order = 9,
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
        spacing1 = { type = "description", order = 10, name = " " },
        fontSize = {
          type = "range",
          name = "Font Size",
          order = 11,
          min = 1,
          max = 120,
          step = 1,
          set = function(_, val)
            NS.db.global.fontSize = val

            NS.OnDbChanged()
          end,
          get = function(_)
            return NS.db.global.fontSize
          end,
        },
        spacing2 = { type = "description", order = 12, name = " " },
        fontFamily = {
          type = "select",
          name = "Font Family",
          order = 13,
          dialogControl = "LSM30_Font",
          values = AceGUIWidgetLSMlists.font,
          set = function(_, val)
            NS.db.global.fontFamily = val

            NS.OnDbChanged()
          end,
          get = function(_)
            return NS.db.global.fontFamily
          end,
        },
        spacing3 = { type = "description", order = 14, name = " " },
        color = {
          type = "color",
          name = "Text Color",
          width = "double",
          order = 15,
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
        spacing4 = { type = "description", order = 99, name = " " },
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
    },
  },
}
