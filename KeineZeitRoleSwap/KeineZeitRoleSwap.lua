-- Keine Zeit RoleSwap: setzt deine Gruppenrolle automatisch, pro Charakter
-- /roleswap tank | dps | heal | off  (auch /rolle, dd, heiler, aus)

local P = "|cffc79c6eKeine Zeit RoleSwap:|r "
-- Sprachen, nach Client Sprache
local LOCALES = {
	enUS = { title = "Role", TANK = "Tank", DAMAGER = "Damage", HEALER = "Healer", OFF = "Off",
		set = "Role for this character: %s", off = "off, your role is no longer set automatically",
		cur = "current: %s", help = "change with /roleswap tank, dps, heal or off",
		tip = "Role: %s", hint = "Click: menu, Drag: move" },
	deDE = { title = "Rolle", TANK = "Tank", DAMAGER = "DD", HEALER = "Heiler", OFF = "Aus",
		set = "Rolle für diesen Charakter: %s", off = "aus, die Rolle wird nicht mehr automatisch gesetzt",
		cur = "aktuell: %s", help = "ändern mit /roleswap tank, dd, heal oder aus",
		tip = "Rolle: %s", hint = "Klick: Menü, Ziehen: verschieben" },
	frFR = { title = "Rôle", TANK = "Tank", DAMAGER = "DPS", HEALER = "Soigneur", OFF = "Désactivé",
		set = "Rôle pour ce personnage : %s", off = "désactivé, le rôle n'est plus défini automatiquement",
		cur = "actuel : %s", help = "changer avec /roleswap tank, dps, heal ou off",
		tip = "Rôle : %s", hint = "Clic : menu, Glisser : déplacer" },
	esES = { title = "Rol", TANK = "Tanque", DAMAGER = "Daño", HEALER = "Sanador", OFF = "Desactivado",
		set = "Rol para este personaje: %s", off = "desactivado, el rol ya no se asigna automáticamente",
		cur = "actual: %s", help = "cambiar con /roleswap tank, dps, heal u off",
		tip = "Rol: %s", hint = "Clic: menú, Arrastrar: mover" },
	itIT = { title = "Ruolo", TANK = "Difensore", DAMAGER = "Assaltatore", HEALER = "Guaritore", OFF = "Spento",
		set = "Ruolo per questo personaggio: %s", off = "spento, il ruolo non viene più impostato automaticamente",
		cur = "attuale: %s", help = "cambia con /roleswap tank, dps, heal o off",
		tip = "Ruolo: %s", hint = "Clic: menu, Trascina: sposta" },
	ptBR = { title = "Função", TANK = "Tanque", DAMAGER = "Dano", HEALER = "Curador", OFF = "Desligado",
		set = "Função para este personagem: %s", off = "desligado, a função não é mais definida automaticamente",
		cur = "atual: %s", help = "mude com /roleswap tank, dps, heal ou off",
		tip = "Função: %s", hint = "Clique: menu, Arrastar: mover" },
	ruRU = { title = "Роль", TANK = "Танк", DAMAGER = "Боец", HEALER = "Лекарь", OFF = "Выкл",
		set = "Роль для этого персонажа: %s", off = "выключено, роль больше не выбирается автоматически",
		cur = "сейчас: %s", help = "изменить: /roleswap tank, dps, heal или off",
		tip = "Роль: %s", hint = "Клик: меню, Перетащить: переместить" },
	koKR = { title = "역할", TANK = "방어 전담", DAMAGER = "공격 전담", HEALER = "치유 전담", OFF = "끄기",
		set = "이 캐릭터의 역할: %s", off = "꺼짐, 역할이 더 이상 자동으로 설정되지 않습니다",
		cur = "현재: %s", help = "/roleswap tank, dps, heal 또는 off 로 변경",
		tip = "역할: %s", hint = "클릭: 메뉴, 드래그: 이동" },
	zhCN = { title = "职责", TANK = "坦克", DAMAGER = "伤害输出", HEALER = "治疗者", OFF = "关闭",
		set = "此角色的职责：%s", off = "已关闭，不再自动设置职责",
		cur = "当前：%s", help = "使用 /roleswap tank、dps、heal 或 off 更改",
		tip = "职责：%s", hint = "点击：菜单，拖动：移动" },
	zhTW = { title = "角色職責", TANK = "坦克", DAMAGER = "傷害輸出", HEALER = "治療者", OFF = "關閉",
		set = "此角色的職責：%s", off = "已關閉，不再自動設定職責",
		cur = "目前：%s", help = "使用 /roleswap tank、dps、heal 或 off 變更",
		tip = "職責：%s", hint = "點擊：選單，拖曳：移動" },
}
LOCALES.esMX = LOCALES.esES
LOCALES.enGB = LOCALES.enUS
local L = LOCALES[GetLocale()] or LOCALES.enUS

local NAMES = { TANK = L.TANK, DAMAGER = L.DAMAGER, HEALER = L.HEALER }
local ALIAS = { tank = "TANK", dd = "DAMAGER", dps = "DAMAGER", damage = "DAMAGER", heal = "HEALER", healer = "HEALER", heiler = "HEALER" }
local OFFWORDS = { off = true, aus = true }

local function wanted()
	KZRolleDB = KZRolleDB or {}
	if KZRolleDB.role == nil then KZRolleDB.role = "TANK" end
	if KZRolleDB.role == false then return nil end
	return KZRolleDB.role
end

local busy = false
local waitCombat = false
local function apply()
	local role = wanted()
	if not role or busy or not IsInGroup() then return end
	-- im Kampf geht das nicht, darum nach dem Kampf nachholen
	if InCombatLockdown() or UnitAffectingCombat("player") then
		waitCombat = true
		return
	end
	local ok, cur = pcall(UnitGroupRolesAssigned, "player")
	if ok and cur == role then return end
	busy = true
	pcall(UnitSetRole, "player", role)
	busy = false
end

-- Rollenabfrage vom Gruppenleiter gleich selber beantworten
local function answerPoll()
	local role = wanted()
	if not role then return end
	if InCombatLockdown() or UnitAffectingCombat("player") then
		waitCombat = true
	else
		pcall(UnitSetRole, "player", role)
	end
	if RolePollPopup and RolePollPopup:IsShown() then RolePollPopup:Hide() end
end

-- Gruppensuche: Haken passend setzen, falls der Client das kennt
local function setLFG()
	local role = wanted()
	if not role or not SetLFGRoles then return end
	local leader = GetLFGRoles and select(1, GetLFGRoles()) or false
	pcall(SetLFGRoles, leader, role == "TANK", role == "HEALER", role == "DAMAGER")
end

local pending = false
local function later()
	if pending then return end
	pending = true
	C_Timer.After(1, function() pending = false; apply() end)
end

local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_LOGIN")
ev:RegisterEvent("GROUP_ROSTER_UPDATE")
ev:RegisterEvent("PLAYER_ROLES_ASSIGNED")
ev:RegisterEvent("PLAYER_REGEN_ENABLED")
pcall(ev.RegisterEvent, ev, "ROLE_POLL_BEGIN")
ev:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_LOGIN" then
		setLFG()
		later()
	elseif event == "ROLE_POLL_BEGIN" then
		answerPoll()
	elseif event == "PLAYER_REGEN_ENABLED" then
		if waitCombat then
			waitCombat = false
			later()
		end
	else
		later()
	end
end)

------------------------------------------------------------
-- Menue und Minimap Button
------------------------------------------------------------
local ICONS = {
	TANK = "Interface\\Icons\\Ability_Warrior_DefensiveStance",
	DAMAGER = "Interface\\Icons\\Ability_Warrior_BattleShout",
	HEALER = "Interface\\Icons\\Spell_Holy_Heal",
}
local setRole -- weiter unten

local menu = CreateFrame("Frame", "KZRolleMenu", UIParent, "BackdropTemplate")
menu:SetSize(162, 4 * 22 + 30)
menu:SetFrameStrata("DIALOG")
menu:SetClampedToScreen(true)
menu:Hide()
menu:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
menu:SetBackdropColor(0.06, 0.06, 0.06, 0.92)
menu:SetBackdropBorderColor(0, 0, 0, 1)
if menu.SetTemplate then pcall(menu.SetTemplate, menu, "Transparent") end

local title = menu:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", 0, -7)
title:SetText(L.title)

local entries = {}
local opts = { { "TANK", L.TANK }, { "DAMAGER", L.DAMAGER }, { "HEALER", L.HEALER }, { false, L.OFF } }
for i, o in ipairs(opts) do
	local b = CreateFrame("Button", nil, menu)
	b:SetSize(150, 20)
	b:SetPoint("TOP", 0, -24 - (i - 1) * 22)
	b:SetHighlightTexture("Interface\\Buttons\\WHITE8x8")
	b:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.12)
	local check = b:CreateTexture(nil, "OVERLAY")
	check:SetSize(14, 14)
	check:SetPoint("LEFT", 2, 0)
	check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
	local ic = b:CreateTexture(nil, "ARTWORK")
	ic:SetSize(16, 16)
	ic:SetPoint("LEFT", check, "RIGHT", 2, 0)
	if o[1] then ic:SetTexture(ICONS[o[1]]); ic:SetTexCoord(0.08, 0.92, 0.08, 0.92) end
	local t = b:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	t:SetPoint("LEFT", ic, "RIGHT", 6, 0)
	t:SetText(o[2])
	b.role, b.check = o[1], check
	b:SetScript("OnClick", function() setRole(o[1]); menu:Hide() end)
	entries[#entries + 1] = b
end

local function refreshMenu()
	local r = wanted()
	for _, b in ipairs(entries) do b.check:SetShown(b.role == (r or false)) end
end

local mb = CreateFrame("Button", "KZRolleMinimapButton", Minimap)
mb:SetSize(31, 31)
mb:SetFrameStrata("MEDIUM")
mb:SetFrameLevel(8)
mb:RegisterForClicks("LeftButtonUp", "RightButtonUp")
mb:RegisterForDrag("LeftButton")
mb:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
local mbIcon = mb:CreateTexture(nil, "BACKGROUND")
mbIcon:SetSize(20, 20)
mbIcon:SetPoint("CENTER", 0, 1)
mbIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
local border = mb:CreateTexture(nil, "OVERLAY")
border:SetSize(53, 53)
border:SetPoint("TOPLEFT")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

local function updateIcon()
	local r = wanted()
	mbIcon:SetTexture(r and ICONS[r] or "Interface\\Icons\\INV_Misc_QuestionMark")
	mbIcon:SetDesaturated(not r)
end

local function placeButton()
	local a = math.rad(KZRolleDB.angle or 200)
	local r = (Minimap:GetWidth() / 2) + 5
	mb:ClearAllPoints()
	mb:SetPoint("CENTER", Minimap, "CENTER", math.cos(a) * r, math.sin(a) * r)
end

mb:SetScript("OnDragStart", function(self)
	self:SetScript("OnUpdate", function()
		local mx, my = Minimap:GetCenter()
		local cx, cy = GetCursorPosition()
		local s = Minimap:GetEffectiveScale()
		KZRolleDB.angle = math.deg(math.atan2(cy / s - my, cx / s - mx))
		placeButton()
	end)
end)
mb:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
mb:SetScript("OnClick", function(self)
	if menu:IsShown() then menu:Hide() return end
	refreshMenu()
	menu:ClearAllPoints()
	menu:SetPoint("TOPRIGHT", self, "BOTTOMLEFT", 0, 0)
	menu:Show()
end)
mb:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:AddLine("Keine Zeit RoleSwap")
	local r = wanted()
	GameTooltip:AddLine(L.tip:format(r and NAMES[r] or L.OFF), 1, 1, 1)
	GameTooltip:AddLine(L.hint, 0.7, 0.7, 0.7)
	GameTooltip:Show()
end)
mb:SetScript("OnLeave", function() GameTooltip:Hide() end)

setRole = function(role)
	KZRolleDB = KZRolleDB or {}
	KZRolleDB.role = role
	if role then
		print(P .. L.set:format(NAMES[role]))
		setLFG()
		apply()
	else
		print(P .. L.off)
	end
	updateIcon()
	refreshMenu()
end

local init = CreateFrame("Frame")
init:RegisterEvent("PLAYER_LOGIN")
init:SetScript("OnEvent", function()
	wanted()
	placeButton()
	updateIcon()
end)

SLASH_KZROLLE1 = "/rolle"
SLASH_KZROLLE2 = "/roleswap"
SlashCmdList.KZROLLE = function(msg)
	msg = (msg or ""):lower():gsub("%s+", "")
	KZRolleDB = KZRolleDB or {}
	if OFFWORDS[msg] then
		setRole(false)
	elseif ALIAS[msg] then
		setRole(ALIAS[msg])
	else
		local r = wanted()
		print(P .. L.cur:format(r and NAMES[r] or L.OFF) .. "   " .. L.help)
	end
end
