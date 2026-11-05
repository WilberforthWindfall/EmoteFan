-- Emote Fan 0.1.1 (Beta)
-- Emotes, eigene Texte und Makros per Fächer-Knopf – für Rollenspiel.
-- Offener Code, kostenlos. Nutzt nur die offizielle Add-on-Schnittstelle.
-- Jedes Emote löst der Spieler selbst per Klick aus; nichts läuft automatisch.

local ADDON_NAME = ...
local EF = {}
EmoteFan = EF
EF.VERSION = "0.1.1"

----------------------------------------------------------------------
-- Konstanten
----------------------------------------------------------------------
local K = {
  ICON_FALLBACK = "Interface\\Icons\\INV_Misc_QuestionMark",
  ICON_KNOPF = "Interface\\Icons\\Achievement_Reputation_01",
  ICON_KNOPF2 = "Interface\\Icons\\INV_Misc_Note_01",
  ICON_MEHR = "Interface\\Icons\\INV_Misc_Book_09",
  ICON_LEER = "Interface\\PaperDollInfoFrame\\Character-Plus",
  RAND = "Interface\\Minimap\\MiniMap-TrackingBorder",
  HINTERGRUND = "Interface\\Minimap\\UI-Minimap-Background",
  LEUCHTEN = "Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight",
  PFEIL = "Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up",
  ANZAHL_MIN = 4, ANZAHL_MAX = 12, ANZAHL_STD = 6,
  OEFFNEN_VERZ = 0.3, SCHLIESSEN_VERZ = 0.4,
  SLOT_SKALA = 1.3, KNOPF_SKALA = 1.7,
  TEXT_MAX = 255,
  KACHEL_SPALTEN = 4, KACHEL_ZEILEN = 4, KACHEL_B = 82, KACHEL_H = 52,
  HILFE_ZEILEN = 9,
  STANDARD_RING = { "WAVE", "BOW", "LAUGH", "CHEER", "THANK", "DANCE" },
}

K.ARTEN = {
  { value = "emote", text = "Spiel-Emote" },
  { value = "text",  text = "Eigener Text (/e)" },
  { value = "sagen", text = "Spruch sagen (/s)" },
  { value = "makro", text = "Makro" },
}
K.ART_NAME = {}
for _, a in ipairs(K.ARTEN) do K.ART_NAME[a.value] = a.text end

-- Gruppen für Spiel-Emotes (Reihenfolge = Anzeige)
K.GRUPPEN = {
  { name = "Begrüßen",       icon = "Interface\\Icons\\INV_Letter_15",
    tokens = { "WAVE", "HELLO", "BYE", "GREET", "BOW", "SALUTE" } },
  { name = "Höflichkeit",    icon = "Interface\\Icons\\Spell_Holy_Heal",
    tokens = { "THANK", "CLAP", "APPLAUD", "KNEEL", "NOD", "YES", "NO", "TOAST", "PRAY" } },
  { name = "Gefühle",        icon = "Interface\\Icons\\INV_Misc_Flower_02",
    tokens = { "LAUGH", "CHEER", "GIGGLE", "CHUCKLE", "ROFL", "SMILE", "GRIN", "BLUSH", "CRY", "SIGH", "MOURN",
               "ANGRY", "CONFUSED", "SURPRISED", "SHY", "CURIOUS", "GLARE", "COWER", "GASP", "WINK",
               "HUG", "KISS", "SHRUG" } },
  { name = "Kampf & Gruppe", icon = "Interface\\Icons\\Ability_Warrior_BattleShout",
    tokens = { "CHARGE", "FOLLOW", "WAIT", "HELPME", "HEALME", "OOM", "ATTACKMYTARGET", "ROAR", "FLEX",
               "THREATEN", "VICTORY" } },
  { name = "Alltag",         icon = "Interface\\Icons\\INV_Drink_05",
    tokens = { "DANCE", "SIT", "SLEEP", "YAWN", "TIRED", "HUNGRY", "THIRSTY", "DRINK", "EAT", "TALK",
               "TALKEX", "TALKQ", "BEG", "POINT", "CHICKEN" } },
}
K.WEITERE = "Weitere"
K.WEITERE_ICON = "Interface\\Icons\\INV_Misc_Note_01"
K.GRUPPE_VON = {}
for _, g in ipairs(K.GRUPPEN) do
  for _, t in ipairs(g.tokens) do K.GRUPPE_VON[t] = g.name end
end

-- Kurzbeschreibungen (von uns geschrieben; im Spiel prüfen)
K.BESCHR = {
  WAVE = "Winkt – jemandem im Ziel oder allen.", HELLO = "Grüßt freundlich.", BYE = "Verabschiedet sich.",
  GREET = "Begrüßt jemanden herzlich.", BOW = "Verbeugt sich.", SALUTE = "Salutiert.",
  THANK = "Bedankt sich.", CLAP = "Klatscht in die Hände.", APPLAUD = "Applaudiert begeistert.",
  KNEEL = "Kniet nieder.", NOD = "Nickt.", YES = "Nickt zustimmend.", NO = "Schüttelt den Kopf.",
  TOAST = "Stößt an.", PRAY = "Betet.",
  LAUGH = "Lacht.", CHEER = "Jubelt.", GIGGLE = "Kichert.", CHUCKLE = "Lacht leise in sich hinein.", ROFL = "Kugelt sich vor Lachen.",
  SMILE = "Lächelt.", GRIN = "Grinst breit.", BLUSH = "Errötet.", CRY = "Weint.", SIGH = "Seufzt.",
  MOURN = "Trauert.", ANGRY = "Ist wütend.", CONFUSED = "Ist verwirrt.", SURPRISED = "Ist überrascht.",
  SHY = "Ist schüchtern.", CURIOUS = "Ist neugierig.", GLARE = "Starrt böse.", COWER = "Duckt sich ängstlich.",
  GASP = "Schnappt nach Luft.", WINK = "Zwinkert.", HUG = "Umarmt jemanden.", KISS = "Wirft einen Kuss zu.",
  SHRUG = "Zuckt mit den Schultern.",
  CHARGE = "Ruft zum Angriff.", FOLLOW = "Bittet, ihm zu folgen.", WAIT = "Bittet zu warten.",
  HELPME = "Ruft um Hilfe.", HEALME = "Ruft nach Heilung.", OOM = "Meldet: kein Mana mehr.",
  ATTACKMYTARGET = "Ruft: Greift mein Ziel an!", ROAR = "Brüllt.", FLEX = "Lässt die Muskeln spielen.",
  THREATEN = "Droht.", VICTORY = "Feiert einen Sieg.",
  DANCE = "Tanzt.", SIT = "Setzt sich hin.", SLEEP = "Legt sich schlafen.", YAWN = "Gähnt.",
  TIRED = "Ist müde.", HUNGRY = "Hat Hunger.", THIRSTY = "Hat Durst.", DRINK = "Trinkt.", EAT = "Isst.",
  TALK = "Redet.", TALKEX = "Redet aufgeregt.", TALKQ = "Stellt eine Frage.", BEG = "Bettelt.",
  POINT = "Zeigt auf etwas.", CHICKEN = "Gackert wie ein Huhn.",
}

-- Symbole zur Auswahl (alle aus dem Spielclient)
K.SYMBOLE = {
  "INV_Misc_Note_01", "INV_Letter_15", "INV_Misc_Book_09", "INV_Drink_05", "INV_Misc_Food_15",
  "Spell_Holy_Heal", "Spell_Holy_PrayerOfHealing", "Spell_Holy_Silence", "Spell_Nature_Sleep",
  "Ability_Warrior_BattleShout", "INV_Sword_04", "INV_Shield_06", "Ability_Rogue_Sprint",
  "Spell_Nature_Polymorph", "Spell_Magic_PolymorphChicken", "Spell_Fire_Fire", "INV_Torch_Lit",
  "INV_Misc_Rune_01", "INV_Misc_Flower_02", "INV_Mushroom_11", "INV_Misc_Coin_01",
  "INV_Misc_Bag_08", "INV_Misc_Bandage_15", "Spell_Shadow_Charm",
}
for i, n in ipairs(K.SYMBOLE) do K.SYMBOLE[i] = "Interface\\Icons\\" .. n end

local GOLD = { 0.88, 0.76, 0.48 }
local atan2 = math.atan2 or math.atan

----------------------------------------------------------------------
-- Hilfsfunktionen
----------------------------------------------------------------------
local function Meldung(text)
  DEFAULT_CHAT_FRAME:AddMessage("|cffe0c27aEmote Fan:|r " .. tostring(text))
end
EF.Meldung = Meldung

local function Kopie(t)
  if type(t) ~= "table" then return t end
  local r = {}
  for k, v in pairs(t) do r[k] = Kopie(v) end
  return r
end

-- Prüft, ob ein Symbol-Pfad im Spiel existiert (wenn die Prüfung verlässlich ist)
function EF.Icon(pfad)
  if type(pfad) == "number" then return pfad end
  if type(pfad) ~= "string" or pfad == "" then return K.ICON_FALLBACK end
  if EF.iconPruefen == nil then
    EF.iconPruefen = (GetFileIDFromPath and GetFileIDFromPath(K.ICON_FALLBACK)) and true or false
  end
  if EF.iconPruefen and not GetFileIDFromPath(pfad) then return K.ICON_FALLBACK end
  return pfad
end

function EF.Rahmen(f, hell)
  if not f.SetBackdrop then Mixin(f, BackdropTemplateMixin) end
  f:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 14, insets = { left = 3, right = 3, top = 3, bottom = 3 },
  })
  if hell then f:SetBackdropColor(0.13, 0.105, 0.065, 1) else f:SetBackdropColor(0.07, 0.06, 0.045, 0.98) end
  f:SetBackdropBorderColor(0.79, 0.63, 0.29, 1)
end

function EF.Text(parent, schrift, text)
  local fs = parent:CreateFontString(nil, "OVERLAY", schrift or "GameFontHighlight")
  if text then fs:SetText(text) end
  return fs
end

function EF.Knopf(parent, text, breite)
  local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  b:SetSize(breite or 100, 24)
  b:SetText(text)
  return b
end

-- Fenster mit Titel, Schließen-Kreuz, verschiebbar, ESC schließt
function EF.Fenster(name, b, h, titel)
  local f = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
  f:SetSize(b, h)
  f:SetPoint("CENTER")
  f:SetFrameStrata("HIGH")
  f:SetToplevel(true)
  f:SetClampedToScreen(true)
  f:EnableMouse(true)
  f:SetMovable(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", f.StartMoving)
  f:SetScript("OnDragStop", f.StopMovingOrSizing)
  EF.Rahmen(f)
  f.titel = EF.Text(f, "GameFontNormalLarge", titel)
  f.titel:SetPoint("TOPLEFT", 16, -14)
  local x = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  x:SetPoint("TOPRIGHT", -2, -2)
  f.kreuz = x
  f:Hide()
  tinsert(UISpecialFrames, name)
  return f
end

local function Tooltip(owner, zeilen)
  GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
  for i, z in ipairs(zeilen) do
    if i == 1 then GameTooltip:SetText(z, GOLD[1], GOLD[2], GOLD[3])
    else GameTooltip:AddLine(z, 0.9, 0.9, 0.9, true) end
  end
  GameTooltip:Show()
end

----------------------------------------------------------------------
-- Emote-Katalog (aus dem Spielclient gelesen)
----------------------------------------------------------------------
EF.emotes, EF.byToken = {}, {}

local function SchoenerName(cmd)
  local s = cmd:sub(2)
  local b = s:byte(1)
  if b and b < 128 then s = s:sub(1, 1):upper() .. s:sub(2) end
  return s
end

function EF.EmotesLaden()
  wipe(EF.emotes); wipe(EF.byToken)
  for i = 1, 1200 do
    local token = _G["EMOTE" .. i .. "_TOKEN"]
    local cmd = _G["EMOTE" .. i .. "_CMD1"]
    if type(token) == "string" and type(cmd) == "string" and cmd:sub(1, 1) == "/" and not EF.byToken[token] then
      local e = { token = token, cmd = cmd, name = SchoenerName(cmd), desc = K.BESCHR[token],
                  gruppe = K.GRUPPE_VON[token] or K.WEITERE }
      tinsert(EF.emotes, e)
      EF.byToken[token] = e
    end
  end
  table.sort(EF.emotes, function(a, b) return strlower(a.name) < strlower(b.name) end)
end

function EF.GruppenIcon(name)
  for _, g in ipairs(K.GRUPPEN) do if g.name == name then return g.icon end end
  return K.WEITERE_ICON
end

-- Ein Eintrag: { art, wert, name, icon }
function EF.EmoteEintrag(token)
  local e = EF.byToken[token]
  if not e then return nil end
  return { art = "emote", wert = token, name = e.name, icon = EF.GruppenIcon(e.gruppe) }
end

local function Zeilen(text)
  local t = {}
  for z in tostring(text or ""):gmatch("[^\r\n]+") do
    z = z:gsub("^%s+", ""):gsub("%s+$", "")
    if z ~= "" then tinsert(t, z) end
  end
  return t
end

function EF.MakroText(e)
  if not e or not e.wert or e.wert == "" then return nil end
  if e.art == "emote" then
    local k = EF.byToken[e.wert]
    return k and k.cmd or ("/" .. strlower(e.wert))
  elseif e.art == "text" or e.art == "sagen" then
    local vor = (e.art == "text") and "/e " or "/s "
    local z = Zeilen(e.wert)
    for i, s in ipairs(z) do z[i] = vor .. s end
    return (#z > 0) and table.concat(z, "\n") or nil
  else
    return e.wert
  end
end

function EF.Beschreibung(e)
  if not e then return "" end
  if e.art == "emote" then
    local k = EF.byToken[e.wert]
    return k and (k.cmd .. (k.desc and (" – " .. k.desc) or "")) or e.wert
  end
  return K.ART_NAME[e.art] or ""
end

----------------------------------------------------------------------
-- Gespeicherte Daten
----------------------------------------------------------------------
function EF.DatenLaden()
  EmoteFanDB = EmoteFanDB or {}
  local db = EmoteFanDB
  db.settings = db.settings or {}
  local s = db.settings
  if s.anzahl == nil then s.anzahl = K.ANZAHL_STD end
  if s.minimapWinkel == nil then s.minimapWinkel = 90 end
  if s.minimap == nil then s.minimap = true end
  db.eigene = db.eigene or {}
  db.gruppen = db.gruppen or {}
  db.naechsteId = db.naechsteId or 1
  db.version = EF.VERSION
  EmoteFanChar = EmoteFanChar or {}
  EF.db, EF.char = db, EmoteFanChar
end

function EF.StandardRing()
  if EF.char.ring then return end
  EF.char.ring = {}
  local i = 0
  for _, t in ipairs(K.STANDARD_RING) do
    local e = EF.EmoteEintrag(t)
    if e then i = i + 1; EF.char.ring[i] = e end
  end
end

function EF.CharKey()
  return UnitGUID("player") or ((UnitName("player") or "?") .. "-" .. (GetRealmName() or "?"))
end

function EF.EigeneSichtbar()
  local key, r = EF.CharKey(), {}
  for _, e in ipairs(EF.db.eigene) do
    if not e.char or e.char == key then tinsert(r, e) end
  end
  return r
end

function EF.GruppeAnlegen(name)
  name = (name or ""):gsub("^%s+", ""):gsub("%s+$", "")
  if name == "" then return nil end
  for _, g in ipairs(EF.db.gruppen) do if g == name then return name end end
  tinsert(EF.db.gruppen, name)
  return name
end

----------------------------------------------------------------------
-- Auswahlliste (Lieblingsnutzerführung): Knopf klappt Liste auf
-- Einträge: { kopf = true, text } oder { text, value, zahl, icon }
----------------------------------------------------------------------
local Liste -- gemeinsames Listenfenster

local function ListeBauen()
  Liste = CreateFrame("Frame", "EmoteFanAuswahlListe", UIParent, "BackdropTemplate")
  EF.Rahmen(Liste)
  Liste:SetFrameStrata("FULLSCREEN_DIALOG")
  Liste:SetClampedToScreen(true)
  Liste:EnableMouse(true)
  Liste:EnableMouseWheel(true)
  Liste.zeilen, Liste.offset = {}, 0
  Liste:Hide()
  local fang = CreateFrame("Button", nil, UIParent)
  fang:SetAllPoints(UIParent)
  fang:SetFrameStrata("FULLSCREEN")
  fang:SetScript("OnClick", function() Liste:Hide() end)
  fang:Hide()
  Liste:SetScript("OnShow", function() fang:Show() end)
  Liste:SetScript("OnHide", function() fang:Hide(); Liste.owner = nil end)
  Liste:SetScript("OnMouseWheel", function(self, d)
    local max = math.max(0, #self.items - #self.zeilen)
    self.offset = math.min(max, math.max(0, self.offset - d))
    self:Fuellen()
  end)
  function Liste:Fuellen()
    for i, z in ipairs(self.zeilen) do
      local it = self.items[i + self.offset]
      if it then
        z.it = it
        z.text:SetText(it.text)
        z.zahl:SetText(it.zahl and tostring(it.zahl) or "")
        if it.kopf then
          z.text:SetFontObject("GameFontDisableSmall")
          z.text:SetPoint("LEFT", 8, 0)
          z.icon:Hide()
          z:EnableMouse(false)
          z.markiert:Hide()
        else
          z.text:SetFontObject("GameFontHighlight")
          z:EnableMouse(true)
          if it.icon then
            z.icon:SetTexture(EF.Icon(it.icon)); z.icon:Show(); z.text:SetPoint("LEFT", 30, 0)
          else
            z.icon:Hide(); z.text:SetPoint("LEFT", 12, 0)
          end
          z.markiert:SetShown(self.owner and self.owner.wert == it.value)
        end
        z:Show()
      else
        z:Hide()
      end
    end
  end
end

local function ListeZeile(i)
  local z = Liste.zeilen[i]
  if z then return z end
  z = CreateFrame("Button", nil, Liste)
  z:SetHeight(20)
  z:SetPoint("TOPLEFT", 4, -4 - (i - 1) * 20)
  z:SetPoint("TOPRIGHT", -4, -4 - (i - 1) * 20)
  z.markiert = z:CreateTexture(nil, "BACKGROUND")
  z.markiert:SetAllPoints()
  z.markiert:SetColorTexture(0.79, 0.63, 0.29, 0.18)
  z:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
  z.icon = z:CreateTexture(nil, "ARTWORK")
  z.icon:SetSize(16, 16)
  z.icon:SetPoint("LEFT", 8, 0)
  z.text = EF.Text(z, "GameFontHighlight")
  z.text:SetPoint("LEFT", 12, 0)
  z.zahl = EF.Text(z, "GameFontDisableSmall")
  z.zahl:SetPoint("RIGHT", -8, 0)
  z:SetScript("OnClick", function(self)
    local owner, it = Liste.owner, self.it
    Liste:Hide()
    if owner and it and not it.kopf then
      owner:SetWert(it.value)
      if owner.onWahl then owner.onWahl(it.value, it) end
    end
  end)
  Liste.zeilen[i] = z
  return z
end

function EF.Auswahl(parent, breite, onWahl)
  if not Liste then ListeBauen() end
  local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
  b:SetSize(breite, 26)
  EF.Rahmen(b, true)
  b.icon = b:CreateTexture(nil, "ARTWORK")
  b.icon:SetSize(16, 16)
  b.icon:SetPoint("LEFT", 8, 0)
  b.text = EF.Text(b, "GameFontHighlight")
  b.text:SetJustifyH("LEFT")
  b.pfeil = b:CreateTexture(nil, "ARTWORK")
  b.pfeil:SetTexture(K.PFEIL)
  b.pfeil:SetSize(20, 20)
  b.pfeil:SetPoint("RIGHT", -2, 0)
  b.zahl = EF.Text(b, "GameFontDisableSmall")
  b.zahl:SetPoint("RIGHT", b.pfeil, "LEFT", -2, 0)
  b:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
  b.items, b.onWahl = {}, onWahl
  function b:SetItems(items) self.items = items or {}; self:SetWert(self.wert) end
  function b:SetWert(v)
    self.wert = v
    local gefunden
    for _, it in ipairs(self.items) do
      if not it.kopf and it.value == v then gefunden = it break end
    end
    self.text:SetText(gefunden and gefunden.text or (self.leertext or "–"))
    self.zahl:SetText(gefunden and gefunden.zahl and tostring(gefunden.zahl) or "")
    if gefunden and gefunden.icon then
      self.icon:SetTexture(EF.Icon(gefunden.icon)); self.icon:Show()
      self.text:SetPoint("LEFT", 30, 0)
    else
      self.icon:Hide(); self.text:SetPoint("LEFT", 10, 0)
    end
    self.text:SetPoint("RIGHT", self.zahl, "LEFT", -4, 0)
  end
  b:SetScript("OnClick", function(self)
    if Liste:IsShown() and Liste.owner == self then Liste:Hide() return end
    Liste.owner, Liste.items, Liste.offset = self, self.items, 0
    local n = math.min(#self.items, 18)
    for i = 1, n do ListeZeile(i) end
    for i = n + 1, #Liste.zeilen do Liste.zeilen[i]:Hide() end
    Liste:ClearAllPoints()
    Liste:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -2)
    Liste:SetWidth(self:GetWidth())
    Liste:SetHeight(n * 20 + 8)
    Liste:Show()
    Liste:Fuellen()
  end)
  b:HookScript("OnHide", function(self) if Liste.owner == self then Liste:Hide() end end)
  return b
end

----------------------------------------------------------------------
-- Runde Knöpfe (Ring, Hauptknopf, Minimap)
----------------------------------------------------------------------
local function RundKnopfAussehen(b)
  b:SetSize(31, 31)
  b.hg = b:CreateTexture(nil, "BACKGROUND")
  b.hg:SetTexture(K.HINTERGRUND)
  b.hg:SetSize(20, 20)
  b.hg:SetPoint("TOPLEFT", 7, -5)
  b.icon = b:CreateTexture(nil, "ARTWORK")
  b.icon:SetSize(18, 18)
  b.icon:SetPoint("TOPLEFT", 7, -6)
  b.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  b.rand = b:CreateTexture(nil, "OVERLAY")
  b.rand:SetTexture(K.RAND)
  b.rand:SetSize(53, 53)
  b.rand:SetPoint("TOPLEFT")
  b:SetHighlightTexture(K.LEUCHTEN, "ADD")
end

----------------------------------------------------------------------
-- Hauptknopf und Ring
----------------------------------------------------------------------
function EF.KnopfBauen()
  local k = CreateFrame("Button", "EmoteFanKnopf", UIParent)
  RundKnopfAussehen(k)
  k:SetScale(K.KNOPF_SKALA)
  k.icon:SetTexture(EF.Icon(K.ICON_KNOPF) ~= K.ICON_FALLBACK and K.ICON_KNOPF or EF.Icon(K.ICON_KNOPF2))
  k:SetFrameStrata("MEDIUM")
  k:SetMovable(true)
  k:SetClampedToScreen(true)
  k:RegisterForDrag("LeftButton")
  k:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  k:SetScript("OnDragStart", function(self)
    if EF.db.settings.gesperrt or InCombatLockdown() then return end
    EF.AllesZu()
    self:StartMoving()
  end)
  k:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local x, y = self:GetCenter()
    local s = self:GetEffectiveScale()
    EF.db.settings.pos = { x = x * s, y = y * s }
    EF.KnopfPosition()
  end)
  k:SetScript("OnEnter", function(self)
    if InCombatLockdown() then
      Tooltip(self, { "Emote Fan", "Im Kampf nicht verfügbar." })
      return
    end
    if EF.ring:IsShown() then return end
    if EF.timer then EF.timer:Cancel() end
    EF.timer = C_Timer.NewTimer(K.OEFFNEN_VERZ, function()
      EF.timer = nil
      if k:IsMouseOver() then EF.RingZeigen() end
    end)
  end)
  k:SetScript("OnLeave", function()
    GameTooltip:Hide()
    if EF.timer then EF.timer:Cancel(); EF.timer = nil end
  end)
  k:SetScript("OnClick", function(self, taste)
    if taste == "RightButton" then EF.OptionenUmschalten() return end
    if EF.ring:IsShown() then EF.AllesZu() else EF.RingZeigen() end
  end)
  EF.knopf = k
  EF.KnopfPosition()
end

function EF.KnopfPosition()
  local k, p = EF.knopf, EF.db.settings.pos
  k:ClearAllPoints()
  if p and p.x and p.y then
    local s = k:GetEffectiveScale()
    k:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x / s, p.y / s)
  else
    k:SetPoint("CENTER", UIParent, "CENTER", 320 / K.KNOPF_SKALA, -220 / K.KNOPF_SKALA)
  end
end

local function SlotPostClick(self, taste, gedrueckt)
  if gedrueckt ~= nil and gedrueckt ~= EF.AktionBeiDruck() then return end
  if taste == "RightButton" or not self.eintrag then
    EF.Belegen("ring", self.nr)
  else
    EF.AllesZu()
  end
end

function EF.AktionBeiDruck()
  return GetCVarBool and GetCVarBool("ActionButtonUseKeyDown") or false
end

local function SecureKlicks(b)
  b:RegisterForClicks("AnyUp", "AnyDown")
end

function EF.RingBauen()
  local r = CreateFrame("Frame", "EmoteFanRing", UIParent)
  r:SetSize(1, 1)
  r:SetFrameStrata("MEDIUM")
  r:SetFrameLevel(EF.knopf:GetFrameLevel() + 5)
  r:Hide()
  r.slots = {}
  for i = 1, K.ANZAHL_MAX do
    local b = CreateFrame("Button", "EmoteFanRingPlatz" .. i, r, "SecureActionButtonTemplate")
    RundKnopfAussehen(b)
    b:SetScale(K.SLOT_SKALA)
    b.nr = i
    SecureKlicks(b)
    b:SetScript("PostClick", SlotPostClick)
    b:SetScript("OnEnter", function(self)
      local e = self.eintrag
      if e then
        Tooltip(self, { e.name or "?", EF.Beschreibung(e), "|cff8f8670Rechtsklick: Platz neu belegen|r" })
      else
        Tooltip(self, { "Freier Platz", "Klicken, um ihn zu belegen." })
      end
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    r.slots[i] = b
  end
  local m = CreateFrame("Button", "EmoteFanRingMehr", r)
  RundKnopfAussehen(m)
  m:SetScale(K.SLOT_SKALA)
  m.icon:SetTexture(EF.Icon(K.ICON_MEHR))
  m:SetScript("OnClick", function() EF.LeisteUmschalten() end)
  m:SetScript("OnEnter", function(self) Tooltip(self, { "Mehr …", "Alle Emotes und eigene Gruppen." }) end)
  m:SetScript("OnLeave", function() GameTooltip:Hide() end)
  r.mehr = m
  r.zuSeit = nil
  r.tick = 0
  r:SetScript("OnUpdate", function(self, el)
    self.tick = self.tick + el
    if self.tick < 0.1 then return end
    self.tick = 0
    if EF.MausDrin() then self.zuSeit = nil return end
    self.zuSeit = self.zuSeit or GetTime()
    if GetTime() - self.zuSeit >= K.SCHLIESSEN_VERZ then EF.AllesZu() end
  end)
  EF.ring = r
end

-- Ist die Maus über Knopf, Ring, Leiste oder einer offenen Liste? Offene Fenster halten alles offen.
function EF.MausDrin()
  if (EF.dialog and EF.dialog:IsShown()) or (EF.hilfe and EF.hilfe:IsShown())
     or (EF.optionen and EF.optionen:IsShown()) then return true end
  if EF.menuBis and GetTime() < EF.menuBis then return true end
  if StaticPopup_Visible and StaticPopup_Visible("EMOTEFAN_NEUEGRUPPE") then return true end
  if EF.knopf:IsMouseOver() or EF.ring.mehr:IsMouseOver() then return true end
  for i = 1, EF.db.settings.anzahl do
    if EF.ring.slots[i]:IsMouseOver() then return true end
  end
  if EF.leiste and EF.leiste:IsShown() and EF.leiste:IsMouseOver(8, -8, -8, 8) then return true end
  if Liste and Liste:IsShown() and Liste:IsMouseOver() then return true end
  return false
end

-- Anordnung: Bogen zur Bildschirmmitte hin; ab 8 Plätzen zwei Bögen
function EF.RingAnordnen()
  local r, k = EF.ring, EF.knopf
  local n = math.max(K.ANZAHL_MIN, math.min(K.ANZAHL_MAX, EF.db.settings.anzahl or K.ANZAHL_STD))
  local m = n + 1
  local kx, ky = k:GetCenter()
  local ks = k:GetEffectiveScale()
  local us = UIParent:GetEffectiveScale()
  kx, ky = kx * ks / us, ky * ks / us
  local cx, cy = UIParent:GetWidth() / 2, UIParent:GetHeight() / 2
  local dx, dy = cx - kx, cy - ky
  local a0 = (dx * dx + dy * dy > 2500) and atan2(dy, dx) or (math.pi / 2)
  local abstand = 46
  local r1 = 90
  local innen = math.min(m, 7)
  local aussen = m - innen
  local pos = {}
  local function Bogen(anz, radius)
    local span = math.min(math.pi, (anz - 1) * abstand / radius)
    for j = 1, anz do
      local a = (anz == 1) and a0 or (a0 - span / 2 + (j - 1) * span / (anz - 1))
      tinsert(pos, { math.cos(a) * radius, math.sin(a) * radius })
    end
  end
  Bogen(innen, r1)
  if aussen > 0 then Bogen(aussen, r1 + 50) end
  EF.ringRadius = (aussen > 0) and (r1 + 50) or r1
  r:ClearAllPoints()
  r:SetPoint("CENTER", k, "CENTER", 0, 0)
  local sk = K.SLOT_SKALA
  for i = 1, K.ANZAHL_MAX do
    local b = r.slots[i]
    b:ClearAllPoints()
    if i <= n then
      b:SetPoint("CENTER", r, "CENTER", pos[i][1] / sk, pos[i][2] / sk)
      b:Show()
    else
      b:Hide()
    end
  end
  r.mehr:ClearAllPoints()
  r.mehr:SetPoint("CENTER", r, "CENTER", pos[m][1] / sk, pos[m][2] / sk)
end

function EF.RingAktualisieren()
  if InCombatLockdown() then EF.nachKampf = true return end
  for i = 1, K.ANZAHL_MAX do
    local b, e = EF.ring.slots[i], EF.char.ring[i]
    if e == false then e = nil end
    b.eintrag = e
    if e then
      b.icon:SetTexture(EF.Icon(e.icon))
      b.icon:SetDesaturated(false)
      b:SetAttribute("type1", "macro")
      b:SetAttribute("macrotext1", EF.MakroText(e))
    else
      b.icon:SetTexture(K.ICON_LEER)
      b:SetAttribute("type1", nil)
      b:SetAttribute("macrotext1", nil)
    end
  end
end

function EF.RingZeigen()
  if InCombatLockdown() then Meldung("Im Kampf nicht verfügbar.") return end
  EF.RingAnordnen()
  EF.ring.zuSeit = nil
  EF.ring:Show()
end

function EF.AllesZu()
  if InCombatLockdown() then return end
  if EF.timer then EF.timer:Cancel(); EF.timer = nil end
  if Liste then Liste:Hide() end
  if EF.leiste then EF.leiste:Hide() end
  if EF.ring then EF.ring:Hide() end
end

function EF.AufRing(e, nr)
  if not nr then
    for i = 1, EF.db.settings.anzahl do
      if not EF.char.ring[i] then nr = i break end
    end
  end
  if not nr then Meldung("Der Ring ist voll. Rechtsklick auf einen Ring-Platz zum Ersetzen.") return end
  EF.char.ring[nr] = { art = e.art, wert = e.wert, name = e.name, icon = e.icon }
  EF.RingAktualisieren()
  Meldung((e.name or "?") .. " liegt jetzt auf Ring-Platz " .. nr .. ".")
end

----------------------------------------------------------------------
-- Leiste "Mehr" mit Gruppen
----------------------------------------------------------------------
function EF.LeisteBauen()
  local KB, KH = K.KACHEL_B, K.KACHEL_H
  local breite = K.KACHEL_SPALTEN * (KB + 6) + 22
  local f = CreateFrame("Frame", "EmoteFanLeiste", UIParent, "BackdropTemplate")
  EF.Rahmen(f)
  f:SetSize(breite, 96 + K.KACHEL_ZEILEN * (KH + 6) + 24)
  f:SetFrameStrata("HIGH")
  f:SetClampedToScreen(true)
  f:EnableMouse(true)
  f:EnableMouseWheel(true)
  f:Hide()
  f.titel = EF.Text(f, "GameFontNormalLarge", "Alle Emotes")
  f.titel:SetPoint("TOPLEFT", 14, -12)
  local x = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  x:SetPoint("TOPRIGHT", -2, -2)
  x:SetScript("OnClick", function() if not InCombatLockdown() then f:Hide() end end)
  f.gruppe = EF.Auswahl(f, breite - 28, function(v)
    if v == "neu" then EF.NeueGruppeFragen(function(name) EF.LeisteGruppe("e:" .. name) end) return end
    EF.LeisteGruppe(v)
  end)
  f.gruppe:SetPoint("TOPLEFT", 14, -40)
  f.kacheln = {}
  for i = 1, K.KACHEL_SPALTEN * K.KACHEL_ZEILEN do
    local t = CreateFrame("Button", "EmoteFanKachel" .. i, f, "SecureActionButtonTemplate,BackdropTemplate")
    EF.Rahmen(t, true)
    t:SetSize(KB, KH)
    local sp, ze = (i - 1) % K.KACHEL_SPALTEN, math.floor((i - 1) / K.KACHEL_SPALTEN)
    t:SetPoint("TOPLEFT", 14 + sp * (KB + 6), -76 - ze * (KH + 6))
    t.icon = t:CreateTexture(nil, "ARTWORK")
    t.icon:SetSize(22, 22)
    t.icon:SetPoint("TOP", 0, -6)
    t.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    t.name = EF.Text(t, "GameFontHighlightSmall")
    t.name:SetPoint("BOTTOMLEFT", 4, 6)
    t.name:SetPoint("BOTTOMRIGHT", -4, 6)
    t.name:SetWordWrap(false)
    t:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    SecureKlicks(t)
    t:SetScript("PostClick", function(self, taste, gedrueckt)
      if gedrueckt ~= nil and gedrueckt ~= EF.AktionBeiDruck() then return end
      local e = self.eintrag
      if not e then return end
      if e.neu then EF.Belegen("eigen", nil, f.gruppenName) return end
      if taste == "RightButton" then EF.KachelMenue(self, e) return end
      EF.AllesZu()
    end)
    t:SetScript("OnEnter", function(self)
      local e = self.eintrag
      if not e then return end
      if e.neu then Tooltip(self, { "Neuer Eintrag", "Eigenen Text, Spruch oder Makro anlegen." }) return end
      Tooltip(self, { e.name or "?", EF.Beschreibung(e), "|cff8f8670Rechtsklick: auf den Ring legen" ..
        (e.id and ", bearbeiten" or "") .. "|r" })
    end)
    t:SetScript("OnLeave", function() GameTooltip:Hide() end)
    f.kacheln[i] = t
  end
  f.info = EF.Text(f, "GameFontDisableSmall", "")
  f.info:SetPoint("BOTTOMLEFT", 14, 12)
  f.offset = 0
  f:SetScript("OnMouseWheel", function(self, d)
    if InCombatLockdown() then return end
    local zeilen = math.ceil(#(self.inhalt or {}) / K.KACHEL_SPALTEN)
    local max = math.max(0, zeilen - K.KACHEL_ZEILEN)
    self.offset = math.min(max, math.max(0, self.offset - d))
    EF.LeisteFuellen()
  end)
  EF.leiste = f
end

function EF.LeisteGruppen()
  local items = { { kopf = true, text = "Spiel-Emotes" } }
  local zaehl = {}
  for _, e in ipairs(EF.emotes) do zaehl[e.gruppe] = (zaehl[e.gruppe] or 0) + 1 end
  for _, g in ipairs(K.GRUPPEN) do
    if (zaehl[g.name] or 0) > 0 then
      tinsert(items, { text = g.name, value = "s:" .. g.name, zahl = zaehl[g.name], icon = g.icon })
    end
  end
  if (zaehl[K.WEITERE] or 0) > 0 then
    tinsert(items, { text = K.WEITERE, value = "s:" .. K.WEITERE, zahl = zaehl[K.WEITERE], icon = K.WEITERE_ICON })
  end
  tinsert(items, { kopf = true, text = "Eigene" })
  local ez = {}
  for _, e in ipairs(EF.EigeneSichtbar()) do ez[e.gruppe or ""] = (ez[e.gruppe or ""] or 0) + 1 end
  for _, g in ipairs(EF.db.gruppen) do
    tinsert(items, { text = g, value = "e:" .. g, zahl = ez[g] or 0, icon = "Interface\\Icons\\INV_Misc_Note_01" })
  end
  tinsert(items, { text = "+ Neue Gruppe", value = "neu" })
  return items
end

function EF.LeisteGruppe(v)
  local f = EF.leiste
  f.wahl = v
  f.offset = 0
  f.gruppe:SetItems(EF.LeisteGruppen())
  f.gruppe:SetWert(v)
  EF.db.settings.leisteGruppe = v
  EF.LeisteFuellen()
end

function EF.LeisteInhalt(v)
  local r = {}
  if type(v) ~= "string" then return r end
  local art, name = v:sub(1, 1), v:sub(3)
  if art == "s" then
    for _, e in ipairs(EF.emotes) do
      if e.gruppe == name then
        tinsert(r, { art = "emote", wert = e.token, name = e.name, icon = EF.GruppenIcon(e.gruppe) })
      end
    end
  elseif art == "e" then
    for _, e in ipairs(EF.EigeneSichtbar()) do
      if e.gruppe == name then tinsert(r, e) end
    end
    tinsert(r, { neu = true, name = "+ Neu", icon = K.ICON_LEER })
  end
  return r
end

function EF.LeisteFuellen()
  local f = EF.leiste
  if InCombatLockdown() then EF.nachKampf = true return end
  f.gruppenName = type(f.wahl) == "string" and f.wahl:sub(1, 1) == "e" and f.wahl:sub(3) or nil
  f.inhalt = EF.LeisteInhalt(f.wahl)
  local start = f.offset * K.KACHEL_SPALTEN
  for i, t in ipairs(f.kacheln) do
    local e = f.inhalt[start + i]
    t.eintrag = e
    if e then
      t.icon:SetTexture(EF.Icon(e.icon))
      t.name:SetText(e.name or "?")
      if e.neu then
        t:SetAttribute("type1", nil); t:SetAttribute("macrotext1", nil)
      else
        t:SetAttribute("type1", "macro"); t:SetAttribute("macrotext1", EF.MakroText(e))
      end
      t:Show()
    else
      t:SetAttribute("type1", nil); t:SetAttribute("macrotext1", nil)
      t:Hide()
    end
  end
  local zeilen = math.ceil(#f.inhalt / K.KACHEL_SPALTEN)
  if zeilen > K.KACHEL_ZEILEN then
    f.info:SetText(string.format("Mausrad: blättern (Zeile %d von %d) · Rechtsklick: Menü",
      f.offset + 1, zeilen - K.KACHEL_ZEILEN + 1))
  else
    f.info:SetText("Rechtsklick: auf den Ring legen")
  end
end

function EF.LeistePosition()
  local f, k = EF.leiste, EF.knopf
  local kx, ky = k:GetCenter()
  local ks, us = k:GetEffectiveScale(), UIParent:GetEffectiveScale()
  kx, ky = kx * ks / us, ky * ks / us
  local rechts = kx > UIParent:GetWidth() / 2
  local oben = ky > UIParent:GetHeight() / 2
  local R = (EF.ringRadius or 90) + 34
  local punkt = (oben and "TOP" or "BOTTOM") .. (rechts and "RIGHT" or "LEFT")
  f:ClearAllPoints()
  f:SetPoint(punkt, UIParent, "BOTTOMLEFT", kx + (rechts and -R or R), ky + (oben and 40 or -40))
end

function EF.LeisteUmschalten()
  if InCombatLockdown() then return end
  local f = EF.leiste
  if f:IsShown() then f:Hide() return end
  EF.LeistePosition()
  local v = f.wahl or EF.db.settings.leisteGruppe or ("s:" .. K.GRUPPEN[1].name)
  f:Show()
  EF.LeisteGruppe(v)
end

function EF.KachelMenue(owner, e)
  local function MitPause(fn) return function() EF.menuBis = nil; fn() end end
  if MenuUtil and MenuUtil.CreateContextMenu then
    EF.menuBis = GetTime() + 8
    MenuUtil.CreateContextMenu(owner, function(_, root)
      root:CreateTitle(e.name or "?")
      local sub = root:CreateButton("Auf den Ring legen")
      for i = 1, EF.db.settings.anzahl do
        local alt = EF.char.ring[i]
        local text = "Platz " .. i .. (alt and (" (statt " .. (alt.name or "?") .. ")") or " (frei)")
        sub:CreateButton(text, MitPause(function() EF.AufRing(e, i) end))
      end
      if e.id then
        root:CreateButton("Bearbeiten", MitPause(function() EF.Belegen("eigen", e) end))
        root:CreateButton("Löschen", MitPause(function() EF.EigenLoeschen(e) end))
      end
    end)
  else
    EF.AufRing(e)
  end
end

----------------------------------------------------------------------
-- Neue Gruppe (Abfrage)
----------------------------------------------------------------------
function EF.NeueGruppeFragen(danach)
  StaticPopupDialogs["EMOTEFAN_NEUEGRUPPE"] = StaticPopupDialogs["EMOTEFAN_NEUEGRUPPE"] or {
    text = "Name der neuen Gruppe:",
    button1 = OKAY, button2 = CANCEL,
    hasEditBox = true, maxLetters = 30,
    timeout = 0, whileDead = true, hideOnEscape = true,
    OnAccept = function(self)
      local eb = self.editBox or self.EditBox or (self.GetEditBox and self:GetEditBox())
      local name = EF.GruppeAnlegen(eb and eb:GetText())
      if name and EF.gruppeDanach then EF.gruppeDanach(name) end
    end,
    EditBoxOnEnterPressed = function(self)
      local p = self:GetParent()
      local name = EF.GruppeAnlegen(self:GetText())
      if name and EF.gruppeDanach then EF.gruppeDanach(name) end
      p:Hide()
    end,
  }
  EF.gruppeDanach = danach
  StaticPopup_Show("EMOTEFAN_NEUEGRUPPE")
end

----------------------------------------------------------------------
-- Fenster "Platz belegen"
----------------------------------------------------------------------
function EF.DialogBauen()
  local f = EF.Fenster("EmoteFanBelegen", 400, 470, "Platz belegen")
  local hilfe = EF.Knopf(f, "Emote-Hilfe", 110)
  hilfe:SetPoint("TOPRIGHT", -34, -12)
  hilfe:SetScript("OnClick", function() EF.HilfeZeigen(true) end)

  local y = -50
  local function Beschriftung(text)
    local fs = EF.Text(f, "GameFontNormalSmall", text)
    fs:SetPoint("TOPLEFT", 18, y)
    y = y - 16
    return fs
  end

  Beschriftung("Was soll der Platz tun?")
  f.art = EF.Auswahl(f, 364, function(v) EF.DialogArt(v) end)
  f.art:SetPoint("TOPLEFT", 18, y)
  f.art:SetItems(K.ARTEN)
  y = y - 36

  Beschriftung("Name auf dem Knopf")
  f.name = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
  f.name:SetSize(356, 22)
  f.name:SetPoint("TOPLEFT", 24, y)
  f.name:SetAutoFocus(false)
  f.name:SetMaxLetters(30)
  f.name:SetScript("OnEscapePressed", f.name.ClearFocus)
  f.name:SetScript("OnEnterPressed", f.name.ClearFocus)
  f.name:SetScript("OnTextChanged", function(_, vomSpieler) if vomSpieler then f.nameAutomatisch = false end end)
  y = y - 32

  -- Emote wählen (nur Spiel-Emote)
  f.emoteZeile = CreateFrame("Frame", nil, f)
  f.emoteZeile:SetPoint("TOPLEFT", 18, y)
  f.emoteZeile:SetSize(364, 92)
  local el = EF.Text(f.emoteZeile, "GameFontNormalSmall", "Emote")
  el:SetPoint("TOPLEFT")
  f.emoteWahl = EF.Knopf(f.emoteZeile, "Emote wählen …", 160)
  f.emoteWahl:SetPoint("TOPLEFT", 0, -18)
  f.emoteWahl:SetScript("OnClick", function() EF.HilfeZeigen(true) end)
  f.emoteInfo = EF.Text(f.emoteZeile, "GameFontHighlight", "")
  f.emoteInfo:SetPoint("TOPLEFT", 0, -50)
  f.emoteInfo:SetWidth(364)
  f.emoteInfo:SetJustifyH("LEFT")

  -- Text (eigener Text, Spruch, Makro)
  f.textZeile = CreateFrame("Frame", nil, f)
  f.textZeile:SetPoint("TOPLEFT", 18, y)
  f.textZeile:SetSize(364, 92)
  f.textLabel = EF.Text(f.textZeile, "GameFontNormalSmall", "Text")
  f.textLabel:SetPoint("TOPLEFT")
  local box = CreateFrame("Button", nil, f.textZeile, "BackdropTemplate")
  EF.Rahmen(box, true)
  box:SetPoint("TOPLEFT", 0, -16)
  box:SetSize(364, 58)
  box:SetClipsChildren(true)
  local eb = CreateFrame("EditBox", nil, box)
  eb:SetMultiLine(true)
  eb:SetAutoFocus(false)
  eb:SetFontObject(ChatFontNormal)
  eb:SetMaxLetters(K.TEXT_MAX)
  eb:SetPoint("TOPLEFT", 8, -6)
  eb:SetWidth(348)
  eb:SetScript("OnEscapePressed", eb.ClearFocus)
  box:SetScript("OnClick", function() eb:SetFocus() end)
  f.text = eb
  f.textHinweis = EF.Text(f.textZeile, "GameFontDisableSmall", "")
  f.textHinweis:SetPoint("TOPLEFT", 0, -78)
  f.textHinweis:SetWidth(364)
  f.textHinweis:SetJustifyH("LEFT")
  y = y - 98

  Beschriftung("Symbol (aus dem Spiel)")
  f.symbole = {}
  for i, pfad in ipairs(K.SYMBOLE) do
    local s = CreateFrame("Button", nil, f)
    s:SetSize(26, 26)
    local sp, ze = (i - 1) % 12, math.floor((i - 1) / 12)
    s:SetPoint("TOPLEFT", 18 + sp * 30, y - ze * 30)
    s.icon = s:CreateTexture(nil, "ARTWORK")
    s.icon:SetAllPoints()
    s.icon:SetTexture(EF.Icon(pfad))
    s.rahmen = s:CreateTexture(nil, "OVERLAY")
    s.rahmen:SetTexture("Interface\\Buttons\\CheckButtonHilight")
    s.rahmen:SetBlendMode("ADD")
    s.rahmen:SetAllPoints()
    s.rahmen:Hide()
    s:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    s.pfad = pfad
    s:SetScript("OnClick", function(self) EF.DialogSymbol(self.pfad) end)
    f.symbole[i] = s
  end
  y = y - 66

  f.eigenZeile = CreateFrame("Frame", nil, f)
  f.eigenZeile:SetPoint("TOPLEFT", 18, y)
  f.eigenZeile:SetSize(364, 46)
  local gl = EF.Text(f.eigenZeile, "GameFontNormalSmall", "Gruppe")
  gl:SetPoint("TOPLEFT")
  f.gruppe = EF.Auswahl(f.eigenZeile, 176, function(v)
    if v == "neu" then
      EF.NeueGruppeFragen(function(name) EF.DialogGruppen(name) end)
    end
  end)
  f.gruppe:SetPoint("TOPLEFT", 0, -16)
  local gf = EF.Text(f.eigenZeile, "GameFontNormalSmall", "Gilt für")
  gf:SetPoint("TOPLEFT", 188, 0)
  f.gilt = EF.Auswahl(f.eigenZeile, 176)
  f.gilt:SetPoint("TOPLEFT", 188, -16)
  f.gilt:SetItems({ { text = "Alle Charaktere", value = "alle" }, { text = "Nur diesen Charakter", value = "ich" } })

  f.fehler = EF.Text(f, "GameFontNormalSmall", "")
  f.fehler:SetTextColor(1, 0.35, 0.3)
  f.fehler:SetPoint("BOTTOMLEFT", 18, 46)

  f.speichern = EF.Knopf(f, "Speichern", 110)
  f.speichern:SetPoint("BOTTOMRIGHT", -18, 16)
  f.speichern:SetScript("OnClick", function() EF.DialogSpeichern() end)
  f.abbrechen = EF.Knopf(f, "Abbrechen", 100)
  f.abbrechen:SetPoint("RIGHT", f.speichern, "LEFT", -8, 0)
  f.abbrechen:SetScript("OnClick", function() f:Hide() end)
  f.leeren = EF.Knopf(f, "Platz leeren", 110)
  f.leeren:SetPoint("BOTTOMLEFT", 18, 16)
  f.leeren:SetScript("OnClick", function() EF.DialogLeeren() end)
  f:SetScript("OnHide", function()
    if EF.hilfe and EF.hilfe.nehmen then EF.hilfe:Hide() end
  end)
  EF.dialog = f
end

function EF.DialogGruppen(wert)
  local f = EF.dialog
  local items = { { text = "(keine Gruppe)", value = "" } }
  for _, g in ipairs(EF.db.gruppen) do tinsert(items, { text = g, value = g }) end
  tinsert(items, { text = "+ Neue Gruppe", value = "neu" })
  f.gruppe:SetItems(items)
  f.gruppe:SetWert(wert or "")
end

function EF.DialogArt(v)
  local f = EF.dialog
  f.art:SetWert(v)
  f.emoteZeile:SetShown(v == "emote")
  f.textZeile:SetShown(v ~= "emote")
  if v == "text" then
    f.textLabel:SetText("Text (erscheint als Emote im Chat)")
    f.textHinweis:SetText("Beispiel: hebt den Krug.  → " .. (UnitName("player") or "Name") .. " hebt den Krug.")
  elseif v == "sagen" then
    f.textLabel:SetText("Spruch (dein Charakter sagt ihn laut)")
    f.textHinweis:SetText("Mehrere Zeilen = mehrere Sätze nacheinander.")
  else
    f.textLabel:SetText("Makro-Text")
    f.textHinweis:SetText("Ein Befehl pro Zeile, z. B. /sitzen.  Höchstens " .. K.TEXT_MAX .. " Zeichen.")
  end
  f.fehler:SetText("")
end

function EF.DialogSymbol(pfad)
  local f = EF.dialog
  f.symbol = pfad
  for _, s in ipairs(f.symbole) do s.rahmen:SetShown(s.pfad == pfad) end
end

function EF.DialogEmote(token)
  local f = EF.dialog
  local vorher = f.emote and EF.byToken[f.emote]
  f.emote = token
  local k = token and EF.byToken[token]
  if k then
    f.emoteInfo:SetText("|cfff3dca0" .. k.name .. "|r  " .. k.cmd .. (k.desc and ("\n" .. k.desc) or ""))
    local alteNamen = f.name:GetText()
    if alteNamen == "" or f.nameAutomatisch or (vorher and alteNamen == vorher.name) then
      f.name:SetText(k.name); f.nameAutomatisch = true
    end
  else
    f.emoteInfo:SetText("|cff8f8670Noch kein Emote gewählt.|r")
  end
end

-- modus "ring": ziel = Platznummer; modus "eigen": ziel = Eintrag (oder nil = neu)
function EF.Belegen(modus, ziel, gruppe)
  if not EF.dialog then EF.DialogBauen() end
  local f = EF.dialog
  f.modus, f.ziel = modus, ziel
  local e
  if modus == "ring" then
    e = EF.char.ring[ziel] or nil
    f.titel:SetText("Ring-Platz " .. ziel .. " belegen")
    f.eigenZeile:Hide()
    f.leeren:SetText("Platz leeren")
    f.leeren:SetShown(e ~= nil)
  else
    e = ziel
    f.titel:SetText(e and "Eintrag bearbeiten" or "Neuer Eintrag")
    f.eigenZeile:Show()
    EF.DialogGruppen(e and e.gruppe or gruppe or "")
    f.gilt:SetWert((e and e.char) and "ich" or "alle")
    f.leeren:SetText("Löschen")
    f.leeren:SetShown(e ~= nil)
  end
  e = e or { art = (modus == "eigen") and "text" or "emote" }
  f.name:SetText(e.name or "")
  f.nameAutomatisch = (e.name == nil)
  f.text:SetText(e.art ~= "emote" and (e.wert or "") or "")
  EF.DialogArt(e.art)
  f.emote = nil
  EF.DialogEmote(e.art == "emote" and e.wert or nil)
  EF.DialogSymbol(e.icon or K.SYMBOLE[1])
  f:Show()
  f:Raise()
end

function EF.DialogSpeichern()
  local f = EF.dialog
  local art = f.art.wert
  local e = { art = art, icon = f.symbol }
  if art == "emote" then
    if not f.emote then f.fehler:SetText("Bitte zuerst ein Emote wählen.") return end
    e.wert = f.emote
  else
    local t = f.text:GetText() or ""
    if t:gsub("%s", "") == "" then f.fehler:SetText("Bitte einen Text eingeben.") return end
    e.wert = t
  end
  local name = (f.name:GetText() or ""):gsub("^%s+", ""):gsub("%s+$", "")
  if name == "" then
    if art == "emote" then name = (EF.byToken[e.wert] or {}).name or e.wert
    else name = (Zeilen(e.wert)[1] or "?"):sub(1, 16) end
  end
  e.name = name
  if f.modus == "ring" then
    if InCombatLockdown() then f.fehler:SetText("Im Kampf geht das nicht – gleich noch einmal versuchen.") return end
    EF.char.ring[f.ziel] = e
    EF.RingAktualisieren()
  else
    local g = f.gruppe.wert
    if g == "neu" then g = "" end
    e.gruppe = (g ~= "" and g) or nil
    if not e.gruppe then
      e.gruppe = EF.GruppeAnlegen("Eigene")
    end
    e.char = (f.gilt.wert == "ich") and EF.CharKey() or nil
    if f.ziel then
      for k, v in pairs(e) do f.ziel[k] = v end
      if not e.char then f.ziel.char = nil end
    else
      e.id = EF.db.naechsteId
      EF.db.naechsteId = EF.db.naechsteId + 1
      tinsert(EF.db.eigene, e)
    end
    if EF.leiste and EF.leiste:IsShown() and not InCombatLockdown() then EF.LeisteGruppe("e:" .. e.gruppe) end
  end
  f:Hide()
end

function EF.DialogLeeren()
  local f = EF.dialog
  if f.modus == "ring" then
    if InCombatLockdown() then return end
    EF.char.ring[f.ziel] = false
    EF.RingAktualisieren()
    f:Hide()
  elseif f.ziel then
    EF.EigenLoeschen(f.ziel)
    f:Hide()
  end
end

function EF.EigenLoeschen(e)
  for i, x in ipairs(EF.db.eigene) do
    if x == e then tremove(EF.db.eigene, i) break end
  end
  Meldung((e.name or "Eintrag") .. " gelöscht.")
  if EF.leiste and EF.leiste:IsShown() and not InCombatLockdown() then EF.LeisteGruppe(EF.leiste.wahl) end
end

----------------------------------------------------------------------
-- Emote-Hilfe
----------------------------------------------------------------------
function EF.HilfeBauen()
  local f = EF.Fenster("EmoteFanHilfe", 470, 120 + K.HILFE_ZEILEN * 42 + 40, "Emote-Hilfe")
  f:SetFrameStrata("DIALOG")
  local unter = EF.Text(f, "GameFontDisableSmall", "Alle Emotes, die das Spiel kennt.")
  unter:SetPoint("TOPLEFT", 18, -36)
  f.unter = unter
  local sl = EF.Text(f, "GameFontNormalSmall", "Suchen")
  sl:SetPoint("TOPLEFT", 18, -56)
  f.suche = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
  f.suche:SetSize(220, 22)
  f.suche:SetPoint("TOPLEFT", 24, -72)
  f.suche:SetAutoFocus(false)
  f.suche:SetScript("OnEscapePressed", f.suche.ClearFocus)
  f.suche:SetScript("OnTextChanged", function() f.offset = 0; EF.HilfeFuellen() end)
  local zl = EF.Text(f, "GameFontNormalSmall", "Zeigen")
  zl:SetPoint("TOPLEFT", 262, -56)
  f.zeigen = EF.Auswahl(f, 190, function() f.offset = 0; EF.HilfeFuellen() end)
  f.zeigen:SetPoint("TOPLEFT", 262, -70)
  f.zeilen = {}
  for i = 1, K.HILFE_ZEILEN do
    local z = CreateFrame("Frame", nil, f)
    z:SetSize(434, 40)
    z:SetPoint("TOPLEFT", 18, -104 - (i - 1) * 42)
    z.linie = z:CreateTexture(nil, "BACKGROUND")
    z.linie:SetColorTexture(0.79, 0.63, 0.29, 0.15)
    z.linie:SetPoint("BOTTOMLEFT"); z.linie:SetPoint("BOTTOMRIGHT"); z.linie:SetHeight(1)
    z.name = EF.Text(z, "GameFontNormal")
    z.name:SetPoint("TOPLEFT", 2, -4)
    z.cmd = EF.Text(z, "GameFontDisableSmall")
    z.cmd:SetPoint("LEFT", z.name, "RIGHT", 8, 0)
    z.desc = EF.Text(z, "GameFontHighlightSmall")
    z.desc:SetPoint("TOPLEFT", 2, -22)
    z.desc:SetWidth(260)
    z.desc:SetJustifyH("LEFT")
    z.desc:SetWordWrap(false)
    z.nehmen = EF.Knopf(z, "Nehmen", 74)
    z.nehmen:SetPoint("RIGHT", 0, 0)
    z.nehmen:SetScript("OnClick", function()
      if z.e and EF.dialog and EF.dialog:IsShown() then
        EF.DialogArt("emote")
        EF.DialogEmote(z.e.token)
        f:Hide()
      end
    end)
    z.vormachen = EF.Knopf(z, "Vormachen", 88)
    z.vormachen:SetPoint("RIGHT", z.nehmen, "LEFT", -4, 0)
    z.vormachen:SetScript("OnClick", function() if z.e then DoEmote(z.e.token) end end)
    f.zeilen[i] = z
  end
  f.seite = EF.Text(f, "GameFontDisableSmall", "")
  f.seite:SetPoint("BOTTOMLEFT", 18, 40)
  local tipp = EF.Text(f, "GameFontDisableSmall",
    "Tipp: Hast du jemanden im Ziel, gilt das Emote ihm – sonst allen in der Nähe.")
  tipp:SetPoint("BOTTOMLEFT", 18, 18)
  f.hoch = EF.Knopf(f, "Zurück", 70)
  f.hoch:SetPoint("BOTTOMRIGHT", -94, 34)
  f.hoch:SetScript("OnClick", function() f:GetScript("OnMouseWheel")(f, K.HILFE_ZEILEN) end)
  f.runter = EF.Knopf(f, "Weiter", 70)
  f.runter:SetPoint("LEFT", f.hoch, "RIGHT", 4, 0)
  f.runter:SetScript("OnClick", function() f:GetScript("OnMouseWheel")(f, -K.HILFE_ZEILEN) end)
  f.offset = 0
  f:EnableMouseWheel(true)
  f:SetScript("OnMouseWheel", function(self, d)
    local max = math.max(0, #(self.liste or {}) - K.HILFE_ZEILEN)
    self.offset = math.min(max, math.max(0, self.offset - d))
    EF.HilfeFuellen(true)
  end)
  EF.hilfe = f
end

function EF.HilfeZeigerItems()
  local mitDesc, zaehl = 0, {}
  for _, e in ipairs(EF.emotes) do
    if e.desc then mitDesc = mitDesc + 1 end
    zaehl[e.gruppe] = (zaehl[e.gruppe] or 0) + 1
  end
  local items = {
    { text = "Alle", value = "alle", zahl = #EF.emotes },
    { text = "Mit Beschreibung", value = "desc", zahl = mitDesc },
    { kopf = true, text = "Gruppe" },
  }
  for _, g in ipairs(K.GRUPPEN) do
    if (zaehl[g.name] or 0) > 0 then
      tinsert(items, { text = g.name, value = "g:" .. g.name, zahl = zaehl[g.name], icon = g.icon })
    end
  end
  if (zaehl[K.WEITERE] or 0) > 0 then
    tinsert(items, { text = K.WEITERE, value = "g:" .. K.WEITERE, zahl = zaehl[K.WEITERE], icon = K.WEITERE_ICON })
  end
  return items
end

function EF.HilfeFuellen(nurBlaettern)
  local f = EF.hilfe
  if not nurBlaettern then
    local such = strlower(f.suche:GetText() or "")
    local z = f.zeigen.wert or "alle"
    local liste = {}
    for _, e in ipairs(EF.emotes) do
      local ok = (z == "alle") or (z == "desc" and e.desc) or (z == "g:" .. e.gruppe)
      if ok and such ~= "" then
        ok = strlower(e.name):find(such, 1, true) or strlower(e.cmd):find(such, 1, true)
             or (e.desc and strlower(e.desc):find(such, 1, true))
      end
      if ok then tinsert(liste, e) end
    end
    f.liste = liste
  end
  local liste = f.liste or {}
  for i, zz in ipairs(f.zeilen) do
    local e = liste[f.offset + i]
    zz.e = e
    if e then
      zz.name:SetText(e.name)
      zz.cmd:SetText(e.cmd)
      zz.desc:SetText(e.desc or "|cff8f8670(noch keine Beschreibung – „Vormachen“ zeigt es)|r")
      zz.nehmen:SetShown(f.nehmen and true or false)
      zz:Show()
    else
      zz:Hide()
    end
  end
  if #liste == 0 then
    f.seite:SetText("Nichts gefunden.")
  else
    f.seite:SetText(string.format("%d–%d von %d", f.offset + 1, math.min(#liste, f.offset + K.HILFE_ZEILEN), #liste))
  end
end

-- nehmen = true: aus "Platz belegen" geöffnet, Knopf "Nehmen" sichtbar
function EF.HilfeZeigen(nehmen)
  if not EF.hilfe then EF.HilfeBauen() end
  local f = EF.hilfe
  f.nehmen = nehmen and EF.dialog and EF.dialog:IsShown()
  f.unter:SetText(f.nehmen and "Klick auf „Nehmen“ legt das Emote auf den Platz."
    or "Alle Emotes, die das Spiel kennt.")
  f.zeigen:SetItems(EF.HilfeZeigerItems())
  f.zeigen:SetWert(f.zeigen.wert or "alle")
  f.offset = 0
  EF.HilfeFuellen()
  f:Show()
  f:Raise()
end

----------------------------------------------------------------------
-- Optionen und Minimap-Knopf
----------------------------------------------------------------------
function EF.OptionenBauen()
  local f = EF.Fenster("EmoteFanOptionen", 360, 300, "Emote Fan – Optionen")
  local l = EF.Text(f, "GameFontHighlight", "Lieblinge im Ring:")
  l:SetPoint("TOPLEFT", 18, -52)
  local minus = EF.Knopf(f, "–", 30)
  minus:SetPoint("LEFT", l, "RIGHT", 12, 0)
  f.zahl = EF.Text(f, "GameFontNormalLarge", "")
  f.zahl:SetPoint("LEFT", minus, "RIGHT", 12, 0)
  f.zahl:SetWidth(24)
  local plus = EF.Knopf(f, "+", 30)
  plus:SetPoint("LEFT", f.zahl, "RIGHT", 12, 0)
  local function Aendern(d)
    if InCombatLockdown() then return end
    local s = EF.db.settings
    s.anzahl = math.max(K.ANZAHL_MIN, math.min(K.ANZAHL_MAX, s.anzahl + d))
    f.zahl:SetText(s.anzahl)
    EF.RingAktualisieren()
    if EF.ring:IsShown() then EF.RingAnordnen() end
  end
  minus:SetScript("OnClick", function() Aendern(-1) end)
  plus:SetScript("OnClick", function() Aendern(1) end)
  local h = EF.Text(f, "GameFontDisableSmall", "4 bis 12. Ab 7 Plätzen legt sich ein zweiter Bogen um den Ring.")
  h:SetPoint("TOPLEFT", 18, -76)

  local function Haken(text, y, schluessel, nachher)
    local cb = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", 14, y)
    local t = EF.Text(f, "GameFontHighlight", text)
    t:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    cb:SetScript("OnClick", function(self)
      EF.db.settings[schluessel] = self:GetChecked() and true or false
      if nachher then nachher() end
    end)
    cb.schluessel = schluessel
    return cb
  end
  f.gesperrt = Haken("Knopf festsetzen (nicht verschiebbar)", -100, "gesperrt")
  f.minimap = Haken("Knopf an der Minimap zeigen", -128, "minimap", function() EF.MinimapPosition() end)
  local mh = EF.Text(f, "GameFontDisableSmall", "Ohne Minimap-Knopf öffnest du diese Optionen mit /ef.")
  mh:SetPoint("TOPLEFT", 18, -160)

  local hilfe = EF.Knopf(f, "Emote-Hilfe", 140)
  hilfe:SetPoint("TOPLEFT", 18, -190)
  hilfe:SetScript("OnClick", function() EF.HilfeZeigen(false) end)
  local mitte = EF.Knopf(f, "Knopf in die Mitte", 160)
  mitte:SetPoint("LEFT", hilfe, "RIGHT", 10, 0)
  mitte:SetScript("OnClick", function()
    if InCombatLockdown() then return end
    EF.db.settings.pos = nil
    EF.KnopfPosition()
    EF.knopf:ClearAllPoints()
    EF.knopf:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    local x, y = EF.knopf:GetCenter()
    local s = EF.knopf:GetEffectiveScale()
    EF.db.settings.pos = { x = x * s, y = y * s }
  end)
  local v = EF.Text(f, "GameFontDisableSmall",
    "Version " .. EF.VERSION .. " (Beta)   ·   Hauptknopf: Maus darüber öffnet, ziehen verschiebt, Rechtsklick = Optionen")
  v:SetPoint("BOTTOMLEFT", 18, 18)
  v:SetWidth(324)
  v:SetJustifyH("LEFT")
  f:SetScript("OnShow", function()
    f.zahl:SetText(EF.db.settings.anzahl)
    f.gesperrt:SetChecked(EF.db.settings.gesperrt and true or false)
    f.minimap:SetChecked(EF.db.settings.minimap and true or false)
  end)
  EF.optionen = f
end

function EF.OptionenUmschalten()
  if not EF.optionen then EF.OptionenBauen() end
  EF.optionen:SetShown(not EF.optionen:IsShown())
end

function EF.MinimapBauen()
  local b = CreateFrame("Button", "EmoteFanMinimapKnopf", Minimap)
  RundKnopfAussehen(b)
  b:SetFrameStrata("MEDIUM")
  b:SetFrameLevel(8)
  b.icon:SetTexture(EF.Icon(K.ICON_KNOPF) ~= K.ICON_FALLBACK and K.ICON_KNOPF or EF.Icon(K.ICON_KNOPF2))
  b:RegisterForDrag("LeftButton")
  b:SetScript("OnClick", function() EF.OptionenUmschalten() end)
  b:SetScript("OnEnter", function(self)
    Tooltip(self, { "Emote Fan", "Klick: Optionen", "Ziehen: am Minimap-Rand verschieben" })
  end)
  b:SetScript("OnLeave", function() GameTooltip:Hide() end)
  b:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function()
      local mx, my = Minimap:GetCenter()
      local cx, cy = GetCursorPosition()
      local s = Minimap:GetEffectiveScale()
      EF.db.settings.minimapWinkel = math.deg(atan2(cy / s - my, cx / s - mx))
      EF.MinimapPosition()
    end)
  end)
  b:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
  EF.mm = b
  EF.MinimapPosition()
end

function EF.MinimapPosition()
  local b = EF.mm
  if not b then return end
  if not EF.db.settings.minimap then b:Hide() return end
  local a = math.rad(EF.db.settings.minimapWinkel or 90)
  local r = (Minimap:GetWidth() / 2) + 6
  b:ClearAllPoints()
  b:SetPoint("CENTER", Minimap, "CENTER", math.cos(a) * r, math.sin(a) * r)
  b:Show()
end

----------------------------------------------------------------------
-- Start und Ereignisse
----------------------------------------------------------------------
local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:RegisterEvent("PLAYER_LOGIN")
ev:RegisterEvent("PLAYER_REGEN_DISABLED")
ev:RegisterEvent("PLAYER_REGEN_ENABLED")
ev:SetScript("OnEvent", function(self, event, arg1)
  if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
    EF.DatenLaden()
  elseif event == "PLAYER_LOGIN" then
    -- Jeder Teil einzeln abgesichert: ein Fehler legt nicht alles lahm und wird im Chat gemeldet
    local schritte = {
      { "Daten", function() if not EF.db then EF.DatenLaden() end end },
      { "Emote-Liste", EF.EmotesLaden },
      { "Ring-Belegung", EF.StandardRing },
      { "Hauptknopf", EF.KnopfBauen },
      { "Ring", EF.RingBauen },
      { "Leiste", EF.LeisteBauen },
      { "Minimap-Knopf", EF.MinimapBauen },
      { "Ring füllen", EF.RingAktualisieren },
    }
    local fehler = 0
    for _, s in ipairs(schritte) do
      local ok, err = pcall(s[2])
      if not ok then
        fehler = fehler + 1
        Meldung("|cffff5544Fehler beim Teil \"" .. s[1] .. "\":|r " .. tostring(err))
      end
    end
    if fehler == 0 then
      Meldung("Version " .. EF.VERSION .. " geladen (" .. #EF.emotes .. " Emotes). Maus über den runden Knopf – oder /ef für Optionen.")
    else
      Meldung("Bitte diese Meldung an Claude weitergeben (Bildschirmfoto genügt).")
    end
  elseif event == "PLAYER_REGEN_DISABLED" then
    -- kurz vor dem Kampf: Fächer schließen (danach sperrt das Spiel diese Knöpfe)
    if Liste then Liste:Hide() end
    if EF.leiste then EF.leiste:Hide() end
    if EF.ring then EF.ring:Hide() end
  elseif event == "PLAYER_REGEN_ENABLED" then
    if EF.nachKampf then
      EF.nachKampf = nil
      EF.RingAktualisieren()
    end
  end
end)

SLASH_EMOTEFAN1 = "/ef"
SLASH_EMOTEFAN2 = "/emotefan"
SlashCmdList.EMOTEFAN = function(msg)
  msg = strlower(msg or "")
  if msg == "hilfe" or msg == "emotes" then
    EF.HilfeZeigen(false)
  elseif msg == "mitte" or msg == "reset" then
    if InCombatLockdown() then return end
    EF.db.settings.pos = nil
    EF.KnopfPosition()
    Meldung("Knopf zurückgesetzt.")
  else
    EF.OptionenUmschalten()
  end
end
