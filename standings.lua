local T = AceLibrary("Tablet-2.0")
local C = AceLibrary("Crayon-2.0")
local BC = AceLibrary("Babble-Class-2.2")

HonorSpyStandings = HonorSpy:NewModule("HonorSpyStandings", "AceDB-2.0")

local playerName = UnitName("player");

function HonorSpyStandings:OnEnable()
  if not T:IsRegistered("HonorSpyStandings") then
    T:Register("HonorSpyStandings",
      "children", function()
        T:SetTitle("HonorSpy standings")
        self:OnTooltipUpdate()
      end,
  		"showTitleWhenDetached", false,
  		"showHintWhenDetached", false,
  		"cantAttach", true
    )
  end
  if not T:IsAttached("HonorSpyStandings") then
    T:Open("HonorSpyStandings")
  end
end

function HonorSpyStandings:OnDisable()
  T:Close("HonorSpyStandings")
end

function HonorSpyStandings:Refresh()
	if (T:IsRegistered("HonorSpyStandings")) then
		T:Refresh("HonorSpyStandings")
	end
end

function HonorSpyStandings:Toggle()
  if T:IsAttached("HonorSpyStandings") then
    T:Detach("HonorSpyStandings")
    if (T:IsLocked("HonorSpyStandings")) then
      T:ToggleLocked("HonorSpyStandings")
    end
  else
    T:Attach("HonorSpyStandings")
  end
end

function HonorSpyStandings:BuildStandingsTable()
  local t = { }
  for playerName, player in pairs(HonorSpy.db.realm.hs.currentStandings) do
    table.insert(t, {playerName, player.class, player.thisWeekHonor, player.lastWeekHonor, player.standing, player.RP, player.rank, player.last_checked})
  end
  local sort_column = 3; -- ThisWeekHonor
  if (HonorSpy.db.realm.hs.sort == "Rank") then sort_column = 6; end
  table.sort(t, function(a,b)
    return a[sort_column] > b[sort_column]
    end)
  return t
end

function HonorSpyStandings:OnTooltipUpdate()
	local cat = T:AddCategory(
	  "columns", 6,
	  "text",  C:Orange("Name"),   "child_textR",    1, "child_textG",    1, "child_textB",    1, "child_justify",  "LEFT",
	  "text2", C:Orange("ThisWeekHonor"),     "child_text2R",   1, "child_text2G",   1, "child_text2B",   1, "child_justify2", "RIGHT",
	  "text3", C:Orange("LastWeekHonor"),     "child_text3R",   1, "child_text3G",   1, "child_text3B",   1, "child_justify3", "RIGHT",
	  "text4", C:Orange("Standing"),     "child_text4R",   1, "child_text4G",   1, "child_text4B",   0, "child_justify4", "RIGHT",
	  "text5", C:Orange("RP"),     "child_text5R",   1, "child_text5G",   1, "child_text5B",   0, "child_justify5", "RIGHT",
	  "text6", C:Orange("Rank"),     "child_text6R",   1, "child_text6G",   0, "child_text6B",   0, "child_justify6", "RIGHT"
	)
	
	local t = self:BuildStandingsTable()
	HonorSpy.pool_size = table.getn(t);
	local curtime = time()
	
	for i = 1, math.min(table.getn(t)) do
		local name, class, thisWeekHonor, lastWeekHonor, standing, RP, rank, last_checked = unpack(t[i])

		if (name == playerName) then
			HonorSpy.player_standing = i;
		end
		
		if (i <= 199) then
			local last_seen = (curtime - last_checked)
			local last_seen_human = HonorSpy:HumanTime(last_seen)

			local class_color = BC:GetHexColor(class)
			cat:AddLine(
				"text", C:Colorize("444444", i).." "..C:Colorize(class_color, name),
				"text2", C:Colorize(class_color, string.format("%d", thisWeekHonor)),
				"text3", C:Colorize(class_color, string.format("%d", lastWeekHonor)),
				"text4", C:Colorize(class_color, string.format("%d", standing)),
				"text5", C:Colorize(class_color, string.format("%d", RP)),
				"text6", C:Colorize(class_color, string.format("%d", rank)),
				"func", function() end,
				"onEnterFunc", function()
					GameTooltip:SetOwner(this, "ANCHOR_CURSOR")
					GameTooltip:AddLine(last_seen_human, 1, 1, 1)
					GameTooltip:Show()
				end,
				"onLeaveFunc", function()
					GameTooltip:Hide()
				end
			)
		end
	end
end

