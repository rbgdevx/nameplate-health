local AddonName, NS = ...

local CreateFrame = CreateFrame

local NameplateHealth = {}
NS.NameplateHealth = NameplateHealth

local NameplateHealthFrame = CreateFrame("Frame", AddonName .. "Frame")
NameplateHealthFrame:SetScript("OnEvent", function(_, event, ...)
  if NameplateHealth[event] then
    NameplateHealth[event](NameplateHealth, ...)
  end
end)
NameplateHealthFrame.wasOnLoadingScreen = true
NameplateHealthFrame.inArena = false
NS.NameplateHealth.frame = NameplateHealthFrame

NS.NPC_HIDE_LIST = {
  "89",
  "416",
  "417",
  "1860",
  "1863",
  "229798",
  "63508",
  "143622",
  "98035",
  "135816",
  "136402",
  "136399",
  "31216",
  "95072",
  "29264",
  "27829",
  "24207",
  "69791",
  "69792",
  "26125",
  "62821",
  "62822",
  "142666",
  "142668",
  "32641",
  "32642",
  "189988",
  "103822",
  "198489",
  "26125",
  "55659",
  "62982",
  "105419",
  "198757",
  "192337",
  "89715",
  "165189",
  "103268",
  "65282",
  "99541",
  "163366",
  "103320",
  "17252",
  "110063",
  "197280",
  "19668",
  "166949",
  "107024",
  "100820",
  "95061",
  "77942",
  "77936",
  "61056",
  "61029",
  "106988",
  "54983",
  "62005",
  "32638",
  "32639",
  "208441",
  "224466",
  "97022",
  "217429",
  "231086",
  "231085",
}

NS.DefaultDatabase = {
  global = {
    test = false,
    fontSize = 10,
    fontFamily = "Friz Quadrata TT",
    color = {
      r = 255 / 255,
      g = 255 / 255,
      b = 255 / 255,
      a = 1.0,
    },
    position = "CENTER",
    showAllies = false,
    showEnemies = true,
    showNPCs = false,
    showPlayersOnly = true,
    showCanAttackOnly = true,
    showAbsorb = true,
    showPercentage = true,
    showPercentageOnly = false,
  },
}
