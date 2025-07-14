---@class Anysphere
---@field config AnysphereConfig
---@field palette AnyspherePalette
local Anysphere = {}

---@class ItalicConfig
---@field strings boolean
---@field comments boolean
---@field operators boolean
---@field folds boolean
---@field emphasis boolean

---@class HighlightDefinition
---@field fg string?
---@field bg string?
---@field sp string?
---@field blend integer?
---@field bold boolean?
---@field standout boolean?
---@field underline boolean?
---@field undercurl boolean?
---@field underdouble boolean?
---@field underdotted boolean?
---@field strikethrough boolean?
---@field italic boolean?
---@field reverse boolean?
---@field nocombine boolean?

---@class AnysphereConfig
---@field bold boolean?
---@field dim_inactive boolean?
---@field inverse boolean?
---@field invert_selection boolean?
---@field invert_signs boolean?
---@field invert_tabline boolean?
---@field italic ItalicConfig?
---@field overrides table<string, HighlightDefinition>?
---@field palette_overrides table<string, string>?
---@field strikethrough boolean?
---@field terminal_colors boolean?
---@field transparent_mode boolean?
---@field undercurl boolean?
---@field underline boolean?
local default_config = {
  terminal_colors = true,
  undercurl = true,
  underline = true,
  bold = true,
  italic = {
    strings = true,
    emphasis = true,
    comments = true,
    operators = false,
    folds = true,
  },
  strikethrough = true,
  invert_selection = false,
  invert_signs = false,
  invert_tabline = false,
  inverse = true,
  palette_overrides = {},
  overrides = {},
  dim_inactive = false,
  transparent_mode = false,
}

Anysphere.config = vim.deepcopy(default_config)

-- main anysphere color palette - updated with VS Code theme colors
---@class AnyspherePalette
Anysphere.palette = {
  dark0 = "#181818",
  dark1 = "#1d1d1d",
  dark2 = "#212121",
  dark3 = "#2c2c2c",
  dark4 = "#383838",
  light0 = "#d6d6dd",
  light1 = "#d1d1d1",
  light2 = "#c2c2c2",
  light3 = "#a6a6a6",
  light4 = "#838383",
  bright_red = "#f14c4c",
  bright_green = "#a8cc7c",
  bright_yellow = "#f8c762",
  bright_blue = "#87c3ff",
  bright_purple = "#e394dc",  -- Using VS Code string color
  bright_aqua = "#83d6c5",
  bright_orange = "#efb080",
  neutral_red = "#f14c4c",
  neutral_green = "#15ac91",
  neutral_yellow = "#e5b95c",
  neutral_blue = "#4c9df3",
  neutral_purple = "#af9cff",
  neutral_aqua = "#75d3ba",
  neutral_orange = "#ea7620",
  faded_red = "#cc7c8a",
  faded_green = "#5a964d",
  faded_yellow = "#ebc88d",
  faded_blue = "#228df2",
  faded_purple = "#aa9bf5",
  faded_aqua = "#82d2ce",
  faded_orange = "#ea7620",
  dark_red = "#722529",
  light_red = "#f14c4c",
  dark_green = "#1a493d",
  light_green = "#a8cc7c",
  dark_aqua = "#28384b",
  light_aqua = "#83d6c5",
  gray = "#6d6d6d",
}

-- get a hex list of anysphere colors based on current bg and constrast config
local function get_colors()
  local p = Anysphere.palette
  local config = Anysphere.config

  for color, hex in pairs(config.palette_overrides) do
    p[color] = hex
  end

  local bg = vim.o.background

  local color_groups = {
    dark = {
      bg0 = p.dark0,
      bg1 = p.dark1,
      bg2 = p.dark2,
      bg3 = p.dark3,
      bg4 = p.dark4,
      fg0 = p.light0,
      fg1 = p.light1,
      fg2 = p.light2,
      fg3 = p.light3,
      fg4 = p.light4,
      red = p.bright_red,
      green = p.bright_green,
      yellow = p.bright_yellow,
      blue = p.bright_blue,
      purple = p.bright_purple,
      aqua = p.bright_aqua,
      orange = p.bright_orange,
      neutral_red = p.neutral_red,
      neutral_green = p.neutral_green,
      neutral_yellow = p.neutral_yellow,
      neutral_blue = p.neutral_blue,
      neutral_purple = p.neutral_purple,
      neutral_aqua = p.neutral_aqua,
      dark_red = p.dark_red,
      dark_green = p.dark_green,
      dark_aqua = p.dark_aqua,
      gray = p.gray,
    },
    light = {
      bg0 = p.light0,
      bg1 = p.light1,
      bg2 = p.light2,
      bg3 = p.light3,
      bg4 = p.light4,
      fg0 = p.dark0,
      fg1 = p.dark1,
      fg2 = p.dark2,
      fg3 = p.dark3,
      fg4 = p.dark4,
      red = p.faded_red,
      green = p.faded_green,
      yellow = p.faded_yellow,
      blue = p.faded_blue,
      purple = p.faded_purple,
      aqua = p.faded_aqua,
      orange = p.faded_orange,
      neutral_red = p.neutral_red,
      neutral_green = p.neutral_green,
      neutral_yellow = p.neutral_yellow,
      neutral_blue = p.neutral_blue,
      neutral_purple = p.neutral_purple,
      neutral_aqua = p.neutral_aqua,
      dark_red = p.light_red,
      dark_green = p.light_green,
      dark_aqua = p.light_aqua,
      gray = p.gray,
    },
  }

  return color_groups[bg]
end

local function get_groups()
  local colors = get_colors()
  local config = Anysphere.config

  if config.terminal_colors then
    local term_colors = {
      colors.bg0,
      colors.neutral_red,
      colors.neutral_green,
      colors.neutral_yellow,
      colors.neutral_blue,
      colors.neutral_purple,
      colors.neutral_aqua,
      colors.fg4,
      colors.gray,
      colors.red,
      colors.green,
      colors.yellow,
      colors.blue,
      colors.purple,
      colors.aqua,
      colors.fg1,
    }
    for index, value in ipairs(term_colors) do
      vim.g["terminal_color_" .. index - 1] = value
    end
  end

  local groups = {
    AnysphereFg0 = { fg = colors.fg0 },
    AnysphereFg1 = { fg = colors.fg1 },
    AnysphereFg2 = { fg = colors.fg2 },
    AnysphereFg3 = { fg = colors.fg3 },
    AnysphereFg4 = { fg = colors.fg4 },
    AnysphereGray = { fg = colors.gray },
    AnysphereBg0 = { fg = colors.bg0 },
    AnysphereBg1 = { fg = colors.bg1 },
    AnysphereBg2 = { fg = colors.bg2 },
    AnysphereBg3 = { fg = colors.bg3 },
    AnysphereBg4 = { fg = colors.bg4 },
    AnysphereRed = { fg = colors.red },
    AnysphereRedBold = { fg = colors.red, bold = config.bold },
    AnysphereGreen = { fg = colors.green },
    AnysphereGreenBold = { fg = colors.green, bold = config.bold },
    AnysphereYellow = { fg = colors.yellow },
    AnysphereYellowBold = { fg = colors.yellow, bold = config.bold },
    AnysphereBlue = { fg = colors.blue },
    AnysphereBlueBold = { fg = colors.blue, bold = config.bold },
    AnyspherePurple = { fg = colors.purple },
    AnyspherePurpleBold = { fg = colors.purple, bold = config.bold },
    AnysphereAqua = { fg = colors.aqua },
    AnysphereAquaBold = { fg = colors.aqua, bold = config.bold },
    AnysphereOrange = { fg = colors.orange },
    AnysphereOrangeBold = { fg = colors.orange, bold = config.bold },
    AnysphereRedSign = config.transparent_mode and { fg = colors.red, reverse = config.invert_signs }
      or { fg = colors.red, bg = colors.bg1, reverse = config.invert_signs },
    AnysphereGreenSign = config.transparent_mode and { fg = colors.green, reverse = config.invert_signs }
      or { fg = colors.green, bg = colors.bg1, reverse = config.invert_signs },
    AnysphereYellowSign = config.transparent_mode and { fg = colors.yellow, reverse = config.invert_signs }
      or { fg = colors.yellow, bg = colors.bg1, reverse = config.invert_signs },
    AnysphereBlueSign = config.transparent_mode and { fg = colors.blue, reverse = config.invert_signs }
      or { fg = colors.blue, bg = colors.bg1, reverse = config.invert_signs },
    AnyspherePurpleSign = config.transparent_mode and { fg = colors.purple, reverse = config.invert_signs }
      or { fg = colors.purple, bg = colors.bg1, reverse = config.invert_signs },
    AnysphereAquaSign = config.transparent_mode and { fg = colors.aqua, reverse = config.invert_signs }
      or { fg = colors.aqua, bg = colors.bg1, reverse = config.invert_signs },
    AnysphereOrangeSign = config.transparent_mode and { fg = colors.orange, reverse = config.invert_signs }
      or { fg = colors.orange, bg = colors.bg1, reverse = config.invert_signs },
    AnysphereRedUnderline = { undercurl = config.undercurl, sp = colors.red },
    AnysphereGreenUnderline = { undercurl = config.undercurl, sp = colors.green },
    AnysphereYellowUnderline = { undercurl = config.undercurl, sp = colors.yellow },
    AnysphereBlueUnderline = { undercurl = config.undercurl, sp = colors.blue },
    AnyspherePurpleUnderline = { undercurl = config.undercurl, sp = colors.purple },
    AnysphereAquaUnderline = { undercurl = config.undercurl, sp = colors.aqua },
    AnysphereOrangeUnderline = { undercurl = config.undercurl, sp = colors.orange },
    Normal = config.transparent_mode and { fg = colors.fg1, bg = nil } or { fg = colors.fg1, bg = colors.bg0 },
    NormalFloat = config.transparent_mode and { fg = colors.fg1, bg = nil } or { fg = colors.fg1, bg = colors.bg1 },
    NormalNC = config.dim_inactive and { fg = colors.fg0, bg = colors.bg1 } or { link = "Normal" },
    CursorLine = { bg = colors.bg1 },
    CursorColumn = { link = "CursorLine" },
    TabLineFill = { fg = colors.bg4, bg = colors.bg1, reverse = config.invert_tabline },
    TabLineSel = { fg = colors.green, bg = colors.bg1, reverse = config.invert_tabline },
    TabLine = { link = "TabLineFill" },
    MatchParen = { bg = colors.bg3, bold = config.bold },
    ColorColumn = { bg = colors.bg1 },
    Conceal = { fg = colors.blue },
    CursorLineNr = { fg = colors.yellow, bg = colors.bg1 },
    NonText = { link = "AnysphereBg2" },
    SpecialKey = { link = "AnysphereFg4" },
    Visual = { bg = colors.bg3, reverse = config.invert_selection },
    VisualNOS = { link = "Visual" },
    Search = { fg = colors.yellow, bg = colors.bg0, reverse = config.inverse },
    IncSearch = { fg = colors.orange, bg = colors.bg0, reverse = config.inverse },
    CurSearch = { link = "IncSearch" },
    QuickFixLine = { link = "AnyspherePurple" },
    Underlined = { fg = colors.blue, underline = config.underline },
    StatusLine = { fg = colors.fg1, bg = colors.bg2 },
    StatusLineNC = { fg = colors.fg4, bg = colors.bg1 },
    WinBar = { fg = colors.fg4, bg = colors.bg0 },
    WinBarNC = { fg = colors.fg3, bg = colors.bg1 },
    WinSeparator = config.transparent_mode and { fg = colors.bg3, bg = nil } or { fg = colors.bg3, bg = colors.bg0 },
    WildMenu = { fg = colors.blue, bg = colors.bg2, bold = config.bold },
    Directory = { link = "AnysphereGreenBold" },
    Title = { link = "AnysphereGreenBold" },
    ErrorMsg = { fg = colors.bg0, bg = colors.red, bold = config.bold },
    MoreMsg = { link = "AnysphereYellowBold" },
    ModeMsg = { link = "AnysphereYellowBold" },
    Question = { link = "AnysphereOrangeBold" },
    WarningMsg = { link = "AnysphereRedBold" },
    LineNr = { fg = colors.bg4 },
    SignColumn = config.transparent_mode and { bg = nil } or { bg = colors.bg1 },
    Folded = { fg = colors.gray, bg = colors.bg1, italic = config.italic.folds },
    FoldColumn = config.transparent_mode and { fg = colors.gray, bg = nil } or { fg = colors.gray, bg = colors.bg1 },
    Cursor = { reverse = config.inverse },
    vCursor = { link = "Cursor" },
    iCursor = { link = "Cursor" },
    lCursor = { link = "Cursor" },
    Special = { fg = "#82d2ce" },  -- VS Code storage color
    Comment = { fg = "#6d6d6d", italic = config.italic.comments },  -- VS Code comment color
    Todo = { fg = colors.bg0, bg = colors.yellow, bold = config.bold, italic = config.italic.comments },
    Done = { fg = colors.orange, bold = config.bold, italic = config.italic.comments },
    Error = { fg = colors.red, bold = config.bold, reverse = config.inverse },
    Statement = { fg = "#83d6c5" },  -- VS Code keyword color
    Conditional = { fg = "#83d6c5" },  -- VS Code keyword color
    Repeat = { fg = "#83d6c5" },  -- VS Code keyword color
    Label = { fg = "#83d6c5" },  -- VS Code keyword color
    Exception = { fg = "#83d6c5" },  -- VS Code keyword color
    Operator = { fg = "#d6d6dd", italic = config.italic.operators },  -- VS Code operator color
    Keyword = { fg = "#83d6c5" },  -- VS Code keyword color
    Identifier = { fg = "#d6d6dd" },  -- VS Code variable color
    Function = { fg = "#E3C893", bold = config.bold },  -- VS Code entity.name.function color (function definitions)
    PreProc = { fg = "#a8cc7c" },  -- VS Code preprocessor color
    Include = { fg = "#a8cc7c" },  -- VS Code include color
    Define = { fg = "#a8cc7c" },  -- VS Code define color
    Macro = { fg = "#a8cc7c" },  -- VS Code macro color
    PreCondit = { fg = "#a8cc7c" },  -- VS Code precondit color
    Constant = { fg = "#f8c762" },  -- VS Code constant color
    Character = { fg = "#f8c762" },  -- VS Code constant color
    String = { fg = "#e394dc", italic = config.italic.strings },  -- VS Code string color
    Boolean = { fg = "#82d2ce" },  -- VS Code boolean color
    Number = { fg = "#ebc88d" },  -- VS Code number color
    Float = { fg = "#ebc88d" },  -- VS Code number color
    Type = { fg = "#efb080" },  -- VS Code type/class color (struct/trait types should be orange)
    StorageClass = { fg = "#82d2ce" },  -- VS Code storage color
    Structure = { fg = "#efb080" },  -- VS Code structure color (should be orange)
    Typedef = { fg = "#efb080" },  -- VS Code typedef color (should be orange)
    Pmenu = { fg = colors.fg1, bg = colors.bg2 },
    PmenuSel = { fg = colors.bg2, bg = colors.blue, bold = config.bold },
    PmenuSbar = { bg = colors.bg2 },
    PmenuThumb = { bg = colors.bg4 },
    DiffDelete = { bg = colors.dark_red },
    DiffAdd = { bg = colors.dark_green },
    DiffChange = { bg = colors.dark_aqua },
    DiffText = { bg = colors.yellow, fg = colors.bg0 },
    SpellCap = { link = "AnysphereBlueUnderline" },
    SpellBad = { link = "AnysphereRedUnderline" },
    SpellLocal = { link = "AnysphereAquaUnderline" },
    SpellRare = { link = "AnyspherePurpleUnderline" },
    Whitespace = { fg = colors.bg2 },
    Delimiter = { link = "AnysphereOrange" },
    EndOfBuffer = { link = "NonText" },
    DiagnosticError = { link = "AnysphereRed" },
    DiagnosticWarn = { link = "AnysphereYellow" },
    DiagnosticInfo = { link = "AnysphereBlue" },
    DiagnosticHint = { link = "AnysphereAqua" },
    DiagnosticOk = { link = "AnysphereGreen" },
    DiagnosticSignError = { link = "AnysphereRedSign" },
    DiagnosticSignWarn = { link = "AnysphereYellowSign" },
    DiagnosticSignInfo = { link = "AnysphereBlueSign" },
    DiagnosticSignHint = { link = "AnysphereAquaSign" },
    DiagnosticSignOk = { link = "AnysphereGreenSign" },
    DiagnosticUnderlineError = { link = "AnysphereRedUnderline" },
    DiagnosticUnderlineWarn = { link = "AnysphereYellowUnderline" },
    DiagnosticUnderlineInfo = { link = "AnysphereBlueUnderline" },
    DiagnosticUnderlineHint = { link = "AnysphereAquaUnderline" },
    DiagnosticUnderlineOk = { link = "AnysphereGreenUnderline" },
    DiagnosticFloatingError = { link = "AnysphereRed" },
    DiagnosticFloatingWarn = { link = "AnysphereOrange" },
    DiagnosticFloatingInfo = { link = "AnysphereBlue" },
    DiagnosticFloatingHint = { link = "AnysphereAqua" },
    DiagnosticFloatingOk = { link = "AnysphereGreen" },
    DiagnosticVirtualTextError = { link = "AnysphereRed" },
    DiagnosticVirtualTextWarn = { link = "AnysphereYellow" },
    DiagnosticVirtualTextInfo = { link = "AnysphereBlue" },
    DiagnosticVirtualTextHint = { link = "AnysphereAqua" },
    DiagnosticVirtualTextOk = { link = "AnysphereGreen" },
    LspReferenceRead = { link = "AnysphereYellowBold" },
    LspReferenceTarget = { link = "Visual" },
    LspReferenceText = { link = "AnysphereYellowBold" },
    LspReferenceWrite = { link = "AnysphereOrangeBold" },
    LspCodeLens = { link = "AnysphereGray" },
    LspSignatureActiveParameter = { link = "Search" },
    gitcommitSelectedFile = { link = "AnysphereGreen" },
    gitcommitDiscardedFile = { link = "AnysphereRed" },
    GitSignsAdd = { link = "AnysphereGreen" },
    GitSignsChange = { link = "AnysphereOrange" },
    GitSignsDelete = { link = "AnysphereRed" },
    NvimTreeSymlink = { fg = colors.neutral_aqua },
    NvimTreeRootFolder = { fg = colors.neutral_purple, bold = true },
    NvimTreeFolderIcon = { fg = colors.neutral_blue, bold = true },
    NvimTreeFileIcon = { fg = colors.light2 },
    NvimTreeExecFile = { fg = colors.neutral_green, bold = true },
    NvimTreeOpenedFile = { fg = colors.bright_red, bold = true },
    NvimTreeSpecialFile = { fg = colors.neutral_yellow, bold = true, underline = true },
    NvimTreeImageFile = { fg = colors.neutral_purple },
    NvimTreeIndentMarker = { fg = colors.dark3 },
    NvimTreeGitDirty = { fg = colors.neutral_yellow },
    NvimTreeGitStaged = { fg = colors.neutral_yellow },
    NvimTreeGitMerge = { fg = colors.neutral_purple },
    NvimTreeGitRenamed = { fg = colors.neutral_purple },
    NvimTreeGitNew = { fg = colors.neutral_yellow },
    NvimTreeGitDeleted = { fg = colors.neutral_red },
    NvimTreeWindowPicker = { bg = colors.aqua },
    debugPC = { link = "DiffAdd" },
    debugBreakpoint = { link = "AnysphereRedSign" },
    StartifyBracket = { link = "AnysphereFg3" },
    StartifyFile = { link = "AnysphereFg1" },
    StartifyNumber = { link = "AnysphereBlue" },
    StartifyPath = { link = "AnysphereGray" },
    StartifySlash = { link = "AnysphereGray" },
    StartifySection = { link = "AnysphereYellow" },
    StartifySpecial = { link = "AnysphereBg2" },
    StartifyHeader = { link = "AnysphereOrange" },
    StartifyFooter = { link = "AnysphereBg2" },
    StartifyVar = { link = "StartifyPath" },
    StartifySelect = { link = "Title" },
    DirvishPathTail = { link = "AnysphereAqua" },
    DirvishArg = { link = "AnysphereYellow" },
    netrwDir = { link = "AnysphereAqua" },
    netrwClassify = { link = "AnysphereAqua" },
    netrwLink = { link = "AnysphereGray" },
    netrwSymLink = { link = "AnysphereFg1" },
    netrwExe = { link = "AnysphereYellow" },
    netrwComment = { link = "AnysphereGray" },
    netrwList = { link = "AnysphereBlue" },
    netrwHelpCmd = { link = "AnysphereAqua" },
    netrwCmdSep = { link = "AnysphereFg3" },
    netrwVersion = { link = "AnysphereGreen" },
    NERDTreeDir = { link = "AnysphereAqua" },
    NERDTreeDirSlash = { link = "AnysphereAqua" },
    NERDTreeOpenable = { link = "AnysphereOrange" },
    NERDTreeClosable = { link = "AnysphereOrange" },
    NERDTreeFile = { link = "AnysphereFg1" },
    NERDTreeExecFile = { link = "AnysphereYellow" },
    NERDTreeUp = { link = "AnysphereGray" },
    NERDTreeCWD = { link = "AnysphereGreen" },
    NERDTreeHelp = { link = "AnysphereFg1" },
    NERDTreeToggleOn = { link = "AnysphereGreen" },
    NERDTreeToggleOff = { link = "AnysphereRed" },
    CocErrorSign = { link = "AnysphereRedSign" },
    CocWarningSign = { link = "AnysphereOrangeSign" },
    CocInfoSign = { link = "AnysphereBlueSign" },
    CocHintSign = { link = "AnysphereAquaSign" },
    CocErrorFloat = { link = "AnysphereRed" },
    CocWarningFloat = { link = "AnysphereOrange" },
    CocInfoFloat = { link = "AnysphereBlue" },
    CocHintFloat = { link = "AnysphereAqua" },
    CocDiagnosticsError = { link = "AnysphereRed" },
    CocDiagnosticsWarning = { link = "AnysphereOrange" },
    CocDiagnosticsInfo = { link = "AnysphereBlue" },
    CocDiagnosticsHint = { link = "AnysphereAqua" },
    CocSearch = { link = "AnysphereBlue" },
    CocSelectedText = { link = "AnysphereRed" },
    CocMenuSel = { link = "PmenuSel" },
    CocCodeLens = { link = "AnysphereGray" },
    CocErrorHighlight = { link = "AnysphereRedUnderline" },
    CocWarningHighlight = { link = "AnysphereOrangeUnderline" },
    CocInfoHighlight = { link = "AnysphereBlueUnderline" },
    CocHintHighlight = { link = "AnysphereAquaUnderline" },
    SnacksPicker = { link = "AnysphereFg1" },
    SnacksPickerBorder = { link = "SnacksPicker" },
    SnacksPickerListCursorLine = { link = "CursorLine" },
    SnacksPickerMatch = { link = "AnysphereOrange" },
    SnacksPickerPrompt = { link = "AnysphereRed" },
    SnacksPickerTitle = { link = "SnacksPicker" },
    SnacksPickerDir = { link = "AnysphereGray" },
    SnacksPickerPathHidden = { link = "AnysphereGray" },
    SnacksPickerGitStatusUntracked = { link = "AnysphereGray" },
    SnacksPickerPathIgnored = { link = "AnysphereBg3" },
    TelescopeNormal = { link = "AnysphereFg1" },
    TelescopeSelection = { link = "CursorLine" },
    TelescopeSelectionCaret = { link = "AnysphereRed" },
    TelescopeMultiSelection = { link = "AnysphereGray" },
    TelescopeBorder = { link = "TelescopeNormal" },
    TelescopePromptBorder = { link = "TelescopeNormal" },
    TelescopeResultsBorder = { link = "TelescopeNormal" },
    TelescopePreviewBorder = { link = "TelescopeNormal" },
    TelescopeMatching = { link = "AnysphereOrange" },
    TelescopePromptPrefix = { link = "AnysphereRed" },
    TelescopePrompt = { link = "TelescopeNormal" },
    CmpItemAbbr = { link = "AnysphereFg0" },
    CmpItemAbbrDeprecated = { link = "AnysphereFg1" },
    CmpItemAbbrMatch = { link = "AnysphereBlueBold" },
    CmpItemAbbrMatchFuzzy = { link = "AnysphereBlueUnderline" },
    CmpItemMenu = { link = "AnysphereGray" },
    CmpItemKindText = { link = "AnysphereOrange" },
    CmpItemKindVariable = { link = "AnysphereOrange" },
    CmpItemKindMethod = { link = "AnysphereBlue" },
    CmpItemKindFunction = { link = "AnysphereBlue" },
    CmpItemKindConstructor = { link = "AnysphereYellow" },
    CmpItemKindUnit = { link = "AnysphereBlue" },
    CmpItemKindField = { link = "AnysphereBlue" },
    CmpItemKindClass = { link = "AnysphereYellow" },
    CmpItemKindInterface = { link = "AnysphereYellow" },
    CmpItemKindModule = { link = "AnysphereBlue" },
    CmpItemKindProperty = { link = "AnysphereBlue" },
    CmpItemKindValue = { link = "AnysphereOrange" },
    CmpItemKindEnum = { link = "AnysphereYellow" },
    CmpItemKindOperator = { link = "AnysphereYellow" },
    CmpItemKindKeyword = { link = "AnyspherePurple" },
    CmpItemKindEvent = { link = "AnyspherePurple" },
    CmpItemKindReference = { link = "AnyspherePurple" },
    CmpItemKindColor = { link = "AnyspherePurple" },
    CmpItemKindSnippet = { link = "AnysphereGreen" },
    CmpItemKindFile = { link = "AnysphereBlue" },
    CmpItemKindFolder = { link = "AnysphereBlue" },
    CmpItemKindEnumMember = { link = "AnysphereAqua" },
    CmpItemKindConstant = { link = "AnysphereOrange" },
    CmpItemKindStruct = { link = "AnysphereOrange" },
    CmpItemKindTypeParameter = { link = "AnysphereYellow" },
    BlinkCmpLabel = { link = "AnysphereFg0" },
    BlinkCmpLabelDeprecated = { link = "AnysphereFg1" },
    BlinkCmpLabelMatch = { link = "AnysphereBlueBold" },
    BlinkCmpLabelDetail = { link = "AnysphereGray" },
    BlinkCmpLabelDescription = { link = "AnysphereGray" },
    BlinkCmpKindText = { link = "AnysphereOrange" },
    BlinkCmpKindVariable = { link = "AnysphereOrange" },
    BlinkCmpKindMethod = { link = "AnysphereBlue" },
    BlinkCmpKindFunction = { link = "AnysphereBlue" },
    BlinkCmpKindConstructor = { link = "AnysphereYellow" },
    BlinkCmpKindUnit = { link = "AnysphereBlue" },
    BlinkCmpKindField = { link = "AnysphereBlue" },
    BlinkCmpKindClass = { link = "AnysphereYellow" },
    BlinkCmpKindInterface = { link = "AnysphereYellow" },
    BlinkCmpKindModule = { link = "AnysphereBlue" },
    BlinkCmpKindProperty = { link = "AnysphereBlue" },
    BlinkCmpKindValue = { link = "AnysphereOrange" },
    BlinkCmpKindEnum = { link = "AnysphereYellow" },
    BlinkCmpKindOperator = { link = "AnysphereYellow" },
    BlinkCmpKindKeyword = { link = "AnyspherePurple" },
    BlinkCmpKindEvent = { link = "AnyspherePurple" },
    BlinkCmpKindReference = { link = "AnyspherePurple" },
    BlinkCmpKindColor = { link = "AnyspherePurple" },
    BlinkCmpKindSnippet = { link = "AnysphereGreen" },
    BlinkCmpKindFile = { link = "AnysphereBlue" },
    BlinkCmpKindFolder = { link = "AnysphereBlue" },
    BlinkCmpKindEnumMember = { link = "AnysphereAqua" },
    BlinkCmpKindConstant = { link = "AnysphereOrange" },
    BlinkCmpKindStruct = { link = "AnysphereOrange" },
    BlinkCmpKindTypeParameter = { link = "AnysphereYellow" },
    BlinkCmpSource = { link = "AnysphereGray" },
    BlinkCmpGhostText = { link = "AnysphereBg4" },
    diffAdded = { link = "DiffAdd" },
    diffRemoved = { link = "DiffDelete" },
    diffChanged = { link = "DiffChange" },
    diffFile = { link = "AnysphereOrange" },
    diffNewFile = { link = "AnysphereYellow" },
    diffOldFile = { link = "AnysphereOrange" },
    diffLine = { link = "AnysphereBlue" },
    diffIndexLine = { link = "diffChanged" },
    NavicIconsFile = { link = "AnysphereBlue" },
    NavicIconsModule = { link = "AnysphereOrange" },
    NavicIconsNamespace = { link = "AnysphereBlue" },
    NavicIconsPackage = { link = "AnysphereAqua" },
    NavicIconsClass = { link = "AnysphereYellow" },
    NavicIconsMethod = { link = "AnysphereBlue" },
    NavicIconsProperty = { link = "AnysphereAqua" },
    NavicIconsField = { link = "AnyspherePurple" },
    NavicIconsConstructor = { link = "AnysphereBlue" },
    NavicIconsEnum = { link = "AnyspherePurple" },
    NavicIconsInterface = { link = "AnysphereGreen" },
    NavicIconsFunction = { link = "AnysphereBlue" },
    NavicIconsVariable = { link = "AnyspherePurple" },
    NavicIconsConstant = { link = "AnysphereOrange" },
    NavicIconsString = { link = "AnysphereGreen" },
    NavicIconsNumber = { link = "AnysphereOrange" },
    NavicIconsBoolean = { link = "AnysphereOrange" },
    NavicIconsArray = { link = "AnysphereOrange" },
    NavicIconsObject = { link = "AnysphereOrange" },
    NavicIconsKey = { link = "AnysphereAqua" },
    NavicIconsNull = { link = "AnysphereOrange" },
    NavicIconsEnumMember = { link = "AnysphereYellow" },
    NavicIconsStruct = { link = "AnyspherePurple" },
    NavicIconsEvent = { link = "AnysphereYellow" },
    NavicIconsOperator = { link = "AnysphereRed" },
    NavicIconsTypeParameter = { link = "AnysphereRed" },
    NavicText = { link = "AnysphereWhite" },
    NavicSeparator = { link = "AnysphereWhite" },
    htmlTag = { fg = "#87c3ff", bold = config.bold },  -- VS Code HTML tag color
    htmlEndTag = { fg = "#87c3ff", bold = config.bold },  -- VS Code HTML end tag color
    htmlTagName = { fg = "#87c3ff" },  -- VS Code HTML tag name color
    htmlArg = { fg = "#aaa0fa" },  -- VS Code HTML attribute color
    htmlTagN = { fg = "#d6d6dd" },  -- VS Code HTML tag N color
    htmlSpecialTagName = { fg = "#87c3ff" },  -- VS Code HTML special tag name color
    htmlLink = { fg = colors.fg4, underline = config.underline },
    htmlSpecialChar = { fg = "#83d6c5" },  -- VS Code HTML special char color
    htmlBold = { fg = colors.fg0, bg = colors.bg0, bold = config.bold },
    htmlBoldUnderline = { fg = colors.fg0, bg = colors.bg0, bold = config.bold, underline = config.underline },
    htmlBoldItalic = { fg = colors.fg0, bg = colors.bg0, bold = config.bold, italic = true },
    htmlBoldUnderlineItalic = {
      fg = colors.fg0,
      bg = colors.bg0,
      bold = config.bold,
      italic = true,
      underline = config.underline,
    },
    htmlUnderline = { fg = colors.fg0, bg = colors.bg0, underline = config.underline },
    htmlUnderlineItalic = {
      fg = colors.fg0,
      bg = colors.bg0,
      italic = true,
      underline = config.underline,
    },
    htmlItalic = { fg = colors.fg0, bg = colors.bg0, italic = true },
    xmlTag = { link = "AnysphereAquaBold" },
    xmlEndTag = { link = "AnysphereAquaBold" },
    xmlTagName = { link = "AnysphereBlue" },
    xmlEqual = { link = "AnysphereBlue" },
    docbkKeyword = { link = "AnysphereAquaBold" },
    xmlDocTypeDecl = { link = "AnysphereGray" },
    xmlDocTypeKeyword = { link = "AnyspherePurple" },
    xmlCdataStart = { link = "AnysphereGray" },
    xmlCdataCdata = { link = "AnyspherePurple" },
    dtdFunction = { link = "AnysphereGray" },
    dtdTagName = { link = "AnyspherePurple" },
    xmlAttrib = { link = "AnysphereOrange" },
    xmlProcessingDelim = { link = "AnysphereGray" },
    dtdParamEntityPunct = { link = "AnysphereGray" },
    dtdParamEntityDPunct = { link = "AnysphereGray" },
    xmlAttribPunct = { link = "AnysphereGray" },
    xmlEntity = { link = "AnysphereRed" },
    xmlEntityPunct = { link = "AnysphereRed" },
    clojureKeyword = { link = "AnysphereBlue" },
    clojureCond = { link = "AnysphereOrange" },
    clojureSpecial = { link = "AnysphereOrange" },
    clojureDefine = { link = "AnysphereOrange" },
    clojureFunc = { link = "AnysphereYellow" },
    clojureRepeat = { link = "AnysphereYellow" },
    clojureCharacter = { link = "AnysphereAqua" },
    clojureStringEscape = { link = "AnysphereAqua" },
    clojureException = { link = "AnysphereRed" },
    clojureRegexp = { link = "AnysphereAqua" },
    clojureRegexpEscape = { link = "AnysphereAqua" },
    clojureRegexpCharClass = { fg = colors.fg3, bold = config.bold },
    clojureRegexpMod = { link = "clojureRegexpCharClass" },
    clojureRegexpQuantifier = { link = "clojureRegexpCharClass" },
    clojureParen = { link = "AnysphereFg3" },
    clojureAnonArg = { link = "AnysphereYellow" },
    clojureVariable = { link = "AnysphereBlue" },
    clojureMacro = { link = "AnysphereOrange" },
    clojureMeta = { link = "AnysphereYellow" },
    clojureDeref = { link = "AnysphereYellow" },
    clojureQuote = { link = "AnysphereYellow" },
    clojureUnquote = { link = "AnysphereYellow" },
    cOperator = { link = "AnyspherePurple" },
    cppOperator = { link = "AnyspherePurple" },
    cStructure = { link = "AnysphereOrange" },
    -- C++ specific overrides to match JSON theme
    ["@function.cpp"] = { fg = "#efefef", bold = config.bold },  -- C++ functions use white with bold
    ["@method.cpp"] = { fg = "#87c3ff" },  -- C++ methods use blue
    -- C specific overrides to match JSON theme
    ["@function.c"] = { fg = "#efefef", bold = config.bold },  -- C functions use white with bold (same as C++)
    -- Python specific overrides to match JSON theme  
    ["@function.python"] = { fg = "#ebc88d" },  -- Python functions/methods use yellow
    ["@method.python"] = { fg = "#ebc88d" },  -- Python methods use yellow
    ["@function.call.python"] = { fg = "#ebc88d" },  -- Python function calls use yellow
    -- JavaScript specific console functions
    ["entity.name.function.js"] = { fg = "#ebc88d" },  -- JS console functions use yellow
    ["support.function.console.js"] = { fg = "#ebc88d" },  -- JS console functions use yellow
    pythonBuiltin = { fg = "#82d2ce" },  -- VS Code builtin color
    pythonBuiltinObj = { fg = "#82d2ce" },  -- VS Code builtin color
    pythonBuiltinFunc = { fg = "#82d2ce" },  -- VS Code builtin function color
    pythonFunction = { fg = "#ebc88d" },  -- VS Code Python method color (matching JSON theme)
    pythonDecorator = { fg = "#a8cc7c" },  -- VS Code decorator color
    pythonInclude = { fg = "#83d6c5" },  -- VS Code include color
    pythonImport = { fg = "#83d6c5" },  -- VS Code import color
    pythonRun = { fg = "#83d6c5" },  -- VS Code run color
    pythonCoding = { fg = "#83d6c5" },  -- VS Code coding color
    pythonOperator = { fg = "#d6d6dd" },  -- VS Code operator color
    pythonException = { fg = "#83d6c5" },  -- VS Code exception color
    pythonExceptions = { fg = "#87c3ff" },  -- VS Code exceptions color
    pythonBoolean = { fg = "#82d2ce" },  -- VS Code boolean color
    pythonDot = { fg = "#d6d6dd" },  -- VS Code dot color
    pythonConditional = { fg = "#83d6c5" },  -- VS Code conditional color
    pythonRepeat = { fg = "#83d6c5" },  -- VS Code repeat color
    pythonDottedName = { fg = "#ebc88d", bold = config.bold },  -- VS Code class:python color
    cssBraces = { link = "AnysphereBlue" },
    cssFunctionName = { link = "AnysphereYellow" },
    cssIdentifier = { link = "AnysphereOrange" },
    cssClassName = { link = "AnysphereGreen" },
    cssColor = { link = "AnysphereBlue" },
    cssSelectorOp = { link = "AnysphereBlue" },
    cssSelectorOp2 = { link = "AnysphereBlue" },
    cssImportant = { link = "AnysphereGreen" },
    cssVendor = { link = "AnysphereFg1" },
    cssTextProp = { link = "AnysphereAqua" },
    cssAnimationProp = { link = "AnysphereAqua" },
    cssUIProp = { link = "AnysphereYellow" },
    cssTransformProp = { link = "AnysphereAqua" },
    cssTransitionProp = { link = "AnysphereAqua" },
    cssPrintProp = { link = "AnysphereAqua" },
    cssPositioningProp = { link = "AnysphereYellow" },
    cssBoxProp = { link = "AnysphereAqua" },
    cssFontDescriptorProp = { link = "AnysphereAqua" },
    cssFlexibleBoxProp = { link = "AnysphereAqua" },
    cssBorderOutlineProp = { link = "AnysphereAqua" },
    cssBackgroundProp = { link = "AnysphereAqua" },
    cssMarginProp = { link = "AnysphereAqua" },
    cssListProp = { link = "AnysphereAqua" },
    cssTableProp = { link = "AnysphereAqua" },
    cssFontProp = { link = "AnysphereAqua" },
    cssPaddingProp = { link = "AnysphereAqua" },
    cssDimensionProp = { link = "AnysphereAqua" },
    cssRenderProp = { link = "AnysphereAqua" },
    cssColorProp = { link = "AnysphereAqua" },
    cssGeneratedContentProp = { link = "AnysphereAqua" },
    javaScriptBraces = { fg = "#d6d6dd" },  -- VS Code braces color
    javaScriptFunction = { fg = "#83d6c5" },  -- VS Code function keyword color
    javaScriptIdentifier = { fg = "#83d6c5" },  -- VS Code identifier color
    javaScriptMember = { fg = "#AA9BF5" },  -- VS Code member color
    javaScriptNumber = { fg = "#ebc88d" },  -- VS Code number color
    javaScriptNull = { fg = "#82d2ce" },  -- VS Code null color
    javaScriptParens = { fg = "#d6d6dd" },  -- VS Code parens color
    typescriptReserved = { fg = "#83d6c5" },  -- VS Code reserved color
    typescriptLabel = { fg = "#83d6c5" },  -- VS Code label color
    typescriptFuncKeyword = { fg = "#83d6c5" },  -- VS Code function keyword color
    typescriptIdentifier = { fg = "#d6d6dd" },  -- VS Code identifier color
    typescriptBraces = { fg = "#d6d6dd" },  -- VS Code braces color
    typescriptEndColons = { fg = "#d6d6dd" },  -- VS Code end colons color
    typescriptDOMObjects = { fg = "#d6d6dd" },  -- VS Code DOM objects color
    typescriptAjaxMethods = { fg = "#d6d6dd" },  -- VS Code Ajax methods color
    typescriptLogicSymbols = { fg = "#d6d6dd" },  -- VS Code logic symbols color
    typescriptDocSeeTag = { link = "Comment" },
    typescriptDocParam = { link = "Comment" },
    typescriptDocTags = { link = "vimCommentTitle" },
    typescriptGlobalObjects = { fg = "#d6d6dd" },  -- VS Code global objects color
    typescriptParens = { fg = "#d6d6dd" },  -- VS Code parens color
    typescriptOpSymbols = { fg = "#d6d6dd" },  -- VS Code operator symbols color
    typescriptHtmlElemProperties = { fg = "#d6d6dd" },  -- VS Code HTML element properties color
    typescriptNull = { fg = "#82d2ce" },  -- VS Code null color
    typescriptInterpolationDelimiter = { fg = "#83d6c5" },  -- VS Code interpolation delimiter color
    purescriptModuleKeyword = { link = "AnysphereAqua" },
    purescriptModuleName = { link = "AnysphereFg1" },
    purescriptWhere = { link = "AnysphereAqua" },
    purescriptDelimiter = { link = "AnysphereFg4" },
    purescriptType = { link = "AnysphereFg1" },
    purescriptImportKeyword = { link = "AnysphereAqua" },
    purescriptHidingKeyword = { link = "AnysphereAqua" },
    purescriptAsKeyword = { link = "AnysphereAqua" },
    purescriptStructure = { link = "AnysphereAqua" },
    purescriptOperator = { link = "AnysphereBlue" },
    purescriptTypeVar = { link = "AnysphereFg1" },
    purescriptConstructor = { link = "AnysphereFg1" },
    purescriptFunction = { link = "AnysphereFg1" },
    purescriptConditional = { link = "AnysphereOrange" },
    purescriptBacktick = { link = "AnysphereOrange" },
    coffeeExtendedOp = { link = "AnysphereFg3" },
    coffeeSpecialOp = { link = "AnysphereFg3" },
    coffeeCurly = { link = "AnysphereOrange" },
    coffeeParen = { link = "AnysphereFg3" },
    coffeeBracket = { link = "AnysphereOrange" },
    rubyStringDelimiter = { link = "AnysphereGreen" },
    rubyInterpolationDelimiter = { link = "AnysphereAqua" },
    rubyDefinedOperator = { link = "rubyKeyword" },
    objcTypeModifier = { link = "AnysphereRed" },
    objcDirective = { link = "AnysphereBlue" },
    goDirective = { link = "AnysphereAqua" },
    goConstants = { link = "AnyspherePurple" },
    goDeclaration = { link = "AnysphereRed" },
    goDeclType = { link = "AnysphereBlue" },
    goBuiltins = { link = "AnysphereOrange" },
    luaIn = { link = "AnysphereRed" },
    luaFunction = { link = "AnysphereAqua" },
    luaTable = { link = "AnysphereOrange" },
    moonSpecialOp = { link = "AnysphereFg3" },
    moonExtendedOp = { link = "AnysphereFg3" },
    moonFunction = { link = "AnysphereFg3" },
    moonObject = { link = "AnysphereYellow" },
    javaAnnotation = { link = "AnysphereBlue" },
    javaDocTags = { link = "AnysphereAqua" },
    javaCommentTitle = { link = "vimCommentTitle" },
    javaParen = { link = "AnysphereFg3" },
    javaParen1 = { link = "AnysphereFg3" },
    javaParen2 = { link = "AnysphereFg3" },
    javaParen3 = { link = "AnysphereFg3" },
    javaParen4 = { link = "AnysphereFg3" },
    javaParen5 = { link = "AnysphereFg3" },
    javaOperator = { link = "AnysphereOrange" },
    javaVarArg = { link = "AnysphereGreen" },
    elixirDocString = { link = "Comment" },
    elixirStringDelimiter = { link = "AnysphereGreen" },
    elixirInterpolationDelimiter = { link = "AnysphereAqua" },
    elixirModuleDeclaration = { link = "AnysphereYellow" },
    scalaNameDefinition = { link = "AnysphereFg1" },
    scalaCaseFollowing = { link = "AnysphereFg1" },
    scalaCapitalWord = { link = "AnysphereFg1" },
    scalaTypeExtension = { link = "AnysphereFg1" },
    scalaKeyword = { link = "AnysphereRed" },
    scalaKeywordModifier = { link = "AnysphereRed" },
    scalaSpecial = { link = "AnysphereAqua" },
    scalaOperator = { link = "AnysphereFg1" },
    scalaTypeDeclaration = { link = "AnysphereYellow" },
    scalaTypeTypePostDeclaration = { link = "AnysphereYellow" },
    scalaInstanceDeclaration = { link = "AnysphereFg1" },
    scalaInterpolation = { link = "AnysphereAqua" },
    markdownItalic = { fg = colors.fg3, italic = true },
    markdownBold = { fg = colors.fg3, bold = config.bold },
    markdownBoldItalic = { fg = colors.fg3, bold = config.bold, italic = true },
    markdownH1 = { link = "AnysphereGreenBold" },
    markdownH2 = { link = "AnysphereGreenBold" },
    markdownH3 = { link = "AnysphereYellowBold" },
    markdownH4 = { link = "AnysphereYellowBold" },
    markdownH5 = { link = "AnysphereYellow" },
    markdownH6 = { link = "AnysphereYellow" },
    markdownCode = { link = "AnysphereAqua" },
    markdownCodeBlock = { link = "AnysphereAqua" },
    markdownCodeDelimiter = { link = "AnysphereAqua" },
    markdownBlockquote = { link = "AnysphereGray" },
    markdownListMarker = { link = "AnysphereGray" },
    markdownOrderedListMarker = { link = "AnysphereGray" },
    markdownRule = { link = "AnysphereGray" },
    markdownHeadingRule = { link = "AnysphereGray" },
    markdownUrlDelimiter = { link = "AnysphereFg3" },
    markdownLinkDelimiter = { link = "AnysphereFg3" },
    markdownLinkTextDelimiter = { link = "AnysphereFg3" },
    markdownHeadingDelimiter = { link = "AnysphereOrange" },
    markdownUrl = { link = "AnyspherePurple" },
    markdownUrlTitleDelimiter = { link = "AnysphereGreen" },
    markdownLinkText = { fg = colors.gray, underline = config.underline },
    markdownIdDeclaration = { link = "markdownLinkText" },
    haskellType = { link = "AnysphereBlue" },
    haskellIdentifier = { link = "AnysphereAqua" },
    haskellSeparator = { link = "AnysphereFg4" },
    haskellDelimiter = { link = "AnysphereOrange" },
    haskellOperators = { link = "AnyspherePurple" },
    haskellBacktick = { link = "AnysphereOrange" },
    haskellStatement = { link = "AnyspherePurple" },
    haskellConditional = { link = "AnyspherePurple" },
    haskellLet = { link = "AnysphereRed" },
    haskellDefault = { link = "AnysphereRed" },
    haskellWhere = { link = "AnysphereRed" },
    haskellBottom = { link = "AnysphereRedBold" },
    haskellImportKeywords = { link = "AnyspherePurpleBold" },
    haskellDeclKeyword = { link = "AnysphereOrange" },
    haskellDecl = { link = "AnysphereOrange" },
    haskellDeriving = { link = "AnyspherePurple" },
    haskellAssocType = { link = "AnysphereAqua" },
    haskellNumber = { link = "AnysphereAqua" },
    haskellPragma = { link = "AnysphereRedBold" },
    haskellTH = { link = "AnysphereAquaBold" },
    haskellForeignKeywords = { link = "AnysphereGreen" },
    haskellKeyword = { link = "AnysphereRed" },
    haskellFloat = { link = "AnysphereAqua" },
    haskellInfix = { link = "AnyspherePurple" },
    haskellQuote = { link = "AnysphereGreenBold" },
    haskellShebang = { link = "AnysphereYellowBold" },
    haskellLiquid = { link = "AnyspherePurpleBold" },
    haskellQuasiQuoted = { link = "AnysphereBlueBold" },
    haskellRecursiveDo = { link = "AnyspherePurple" },
    haskellQuotedType = { link = "AnysphereRed" },
    haskellPreProc = { link = "AnysphereFg4" },
    haskellTypeRoles = { link = "AnysphereRedBold" },
    haskellTypeForall = { link = "AnysphereRed" },
    haskellPatternKeyword = { link = "AnysphereBlue" },
    jsonKeyword = { link = "AnysphereGreen" },
    jsonQuote = { link = "AnysphereGreen" },
    jsonBraces = { link = "AnysphereFg1" },
    jsonString = { link = "AnysphereFg1" },
    mailQuoted1 = { link = "AnysphereAqua" },
    mailQuoted2 = { link = "AnyspherePurple" },
    mailQuoted3 = { link = "AnysphereYellow" },
    mailQuoted4 = { link = "AnysphereGreen" },
    mailQuoted5 = { link = "AnysphereRed" },
    mailQuoted6 = { link = "AnysphereOrange" },
    mailSignature = { link = "Comment" },
    csBraces = { link = "AnysphereFg1" },
    csEndColon = { link = "AnysphereFg1" },
    csLogicSymbols = { link = "AnysphereFg1" },
    csParens = { link = "AnysphereFg3" },
    csOpSymbols = { link = "AnysphereFg3" },
    csInterpolationDelimiter = { link = "AnysphereFg3" },
    csInterpolationAlignDel = { link = "AnysphereAquaBold" },
    csInterpolationFormat = { link = "AnysphereAqua" },
    csInterpolationFormatDel = { link = "AnysphereAquaBold" },
    rustSigil = { link = "AnysphereOrange" },
    rustEscape = { link = "AnysphereAqua" },
    rustStringContinuation = { link = "AnysphereAqua" },
    rustEnum = { link = "AnysphereAqua" },
    rustStructure = { link = "AnysphereAqua" },
    rustModPathSep = { link = "AnysphereFg2" },
    rustCommentLineDoc = { link = "Comment" },
    rustDefault = { link = "AnysphereAqua" },
    ocamlOperator = { link = "AnysphereFg1" },
    ocamlKeyChar = { link = "AnysphereOrange" },
    ocamlArrow = { link = "AnysphereOrange" },
    ocamlInfixOpKeyword = { link = "AnysphereRed" },
    ocamlConstructor = { link = "AnysphereOrange" },
    LspSagaCodeActionTitle = { link = "Title" },
    LspSagaCodeActionBorder = { link = "AnysphereFg1" },
    LspSagaCodeActionContent = { fg = colors.green, bold = config.bold },
    LspSagaLspFinderBorder = { link = "AnysphereFg1" },
    LspSagaAutoPreview = { link = "AnysphereOrange" },
    TargetWord = { fg = colors.blue, bold = config.bold },
    FinderSeparator = { link = "AnysphereAqua" },
    LspSagaDefPreviewBorder = { link = "AnysphereBlue" },
    LspSagaHoverBorder = { link = "AnysphereOrange" },
    LspSagaRenameBorder = { link = "AnysphereBlue" },
    LspSagaDiagnosticSource = { link = "AnysphereOrange" },
    LspSagaDiagnosticBorder = { link = "AnyspherePurple" },
    LspSagaDiagnosticHeader = { link = "AnysphereGreen" },
    LspSagaSignatureHelpBorder = { link = "AnysphereGreen" },
    SagaShadow = { link = "AnysphereBg0" },
    DashboardShortCut = { link = "AnysphereOrange" },
    DashboardHeader = { link = "AnysphereAqua" },
    DashboardCenter = { link = "AnysphereYellow" },
    DashboardFooter = { fg = colors.purple, italic = true },
    MasonHighlight = { link = "AnysphereAqua" },
    MasonHighlightBlock = { fg = colors.bg0, bg = colors.blue },
    MasonHighlightBlockBold = { fg = colors.bg0, bg = colors.blue, bold = true },
    MasonHighlightSecondary = { fg = colors.yellow },
    MasonHighlightBlockSecondary = { fg = colors.bg0, bg = colors.yellow },
    MasonHighlightBlockBoldSecondary = { fg = colors.bg0, bg = colors.yellow, bold = true },
    MasonHeader = { link = "MasonHighlightBlockBoldSecondary" },
    MasonHeaderSecondary = { link = "MasonHighlightBlockBold" },
    MasonMuted = { fg = colors.fg4 },
    MasonMutedBlock = { fg = colors.bg0, bg = colors.fg4 },
    MasonMutedBlockBold = { fg = colors.bg0, bg = colors.fg4, bold = true },
    LspInlayHint = { link = "comment" },
    CarbonFile = { link = "AnysphereFg1" },
    CarbonExe = { link = "AnysphereYellow" },
    CarbonSymlink = { link = "AnysphereAqua" },
    CarbonBrokenSymlink = { link = "AnysphereRed" },
    CarbonIndicator = { link = "AnysphereGray" },
    CarbonDanger = { link = "AnysphereRed" },
    CarbonPending = { link = "AnysphereYellow" },
    NoiceCursor = { link = "TermCursor" },
    NoiceCmdlinePopupBorder = { fg = colors.blue, bg = nil },
    NoiceCmdlineIcon = { link = "NoiceCmdlinePopupBorder" },
    NoiceConfirmBorder = { link = "NoiceCmdlinePopupBorder" },
    NoiceCmdlinePopupBorderSearch = { fg = colors.yellow, bg = nil },
    NoiceCmdlineIconSearch = { link = "NoiceCmdlinePopupBorderSearch" },
    NotifyDEBUGBorder = { link = "AnysphereBlue" },
    NotifyDEBUGIcon = { link = "AnysphereBlue" },
    NotifyDEBUGTitle = { link = "AnysphereBlue" },
    NotifyERRORBorder = { link = "AnysphereRed" },
    NotifyERRORIcon = { link = "AnysphereRed" },
    NotifyERRORTitle = { link = "AnysphereRed" },
    NotifyINFOBorder = { link = "AnysphereAqua" },
    NotifyINFOIcon = { link = "AnysphereAqua" },
    NotifyINFOTitle = { link = "AnysphereAqua" },
    NotifyTRACEBorder = { link = "AnysphereGreen" },
    NotifyTRACEIcon = { link = "AnysphereGreen" },
    NotifyTRACETitle = { link = "AnysphereGreen" },
    NotifyWARNBorder = { link = "AnysphereYellow" },
    NotifyWARNIcon = { link = "AnysphereYellow" },
    NotifyWARNTitle = { link = "AnysphereYellow" },
    IlluminatedWordText = { link = "LspReferenceText" },
    IlluminatedWordRead = { link = "LspReferenceRead" },
    IlluminatedWordWrite = { link = "LspReferenceWrite" },
    TSRainbowRed = { fg = colors.red },
    TSRainbowOrange = { fg = colors.orange },
    TSRainbowYellow = { fg = colors.yellow },
    TSRainbowGreen = { fg = colors.green },
    TSRainbowBlue = { fg = colors.blue },
    TSRainbowViolet = { fg = colors.purple },
    TSRainbowCyan = { fg = colors.aqua },
    RainbowDelimiterRed = { fg = colors.red },
    RainbowDelimiterOrange = { fg = colors.orange },
    RainbowDelimiterYellow = { fg = colors.yellow },
    RainbowDelimiterGreen = { fg = colors.green },
    RainbowDelimiterBlue = { fg = colors.blue },
    RainbowDelimiterViolet = { fg = colors.purple },
    RainbowDelimiterCyan = { fg = colors.aqua },
    DapBreakpointSymbol = { fg = colors.red, bg = colors.bg1 },
    DapStoppedSymbol = { fg = colors.green, bg = colors.bg1 },
    DapUIBreakpointsCurrentLine = { link = "AnysphereYellow" },
    DapUIBreakpointsDisabledLine = { link = "AnysphereGray" },
    DapUIBreakpointsInfo = { link = "AnysphereAqua" },
    DapUIBreakpointsLine = { link = "AnysphereYellow" },
    DapUIBreakpointsPath = { link = "AnysphereBlue" },
    DapUICurrentFrameName = { link = "AnyspherePurple" },
    DapUIDecoration = { link = "AnyspherePurple" },
    DapUIEndofBuffer = { link = "EndOfBuffer" },
    DapUIFloatBorder = { link = "AnysphereAqua" },
    DapUILineNumber = { link = "AnysphereYellow" },
    DapUIModifiedValue = { link = "AnysphereRed" },
    DapUIPlayPause = { fg = colors.green, bg = colors.bg1 },
    DapUIRestart = { fg = colors.green, bg = colors.bg1 },
    DapUIScope = { link = "AnysphereBlue" },
    DapUISource = { link = "AnysphereFg1" },
    DapUIStepBack = { fg = colors.blue, bg = colors.bg1 },
    DapUIStepInto = { fg = colors.blue, bg = colors.bg1 },
    DapUIStepOut = { fg = colors.blue, bg = colors.bg1 },
    DapUIStepOver = { fg = colors.blue, bg = colors.bg1 },
    DapUIStop = { fg = colors.red, bg = colors.bg1 },
    DapUIStoppedThread = { link = "AnysphereBlue" },
    DapUIThread = { link = "AnysphereBlue" },
    DapUIType = { link = "AnysphereOrange" },
    DapUIUnavailable = { link = "AnysphereGray" },
    DapUIWatchesEmpty = { link = "AnysphereGray" },
    DapUIWatchesError = { link = "AnysphereRed" },
    DapUIWatchesValue = { link = "AnysphereYellow" },
    DapUIWinSelect = { link = "AnysphereYellow" },
    NeogitDiffDelete = { link = "DiffDelete" },
    NeogitDiffAdd = { link = "DiffAdd" },
    NeogitHunkHeader = { link = "WinBar" },
    NeogitHunkHeaderHighlight = { link = "WinBarNC" },
    DiffviewStatusModified = { link = "AnysphereGreenBold" },
    DiffviewFilePanelInsertions = { link = "AnysphereGreenBold" },
    DiffviewFilePanelDeletions = { link = "AnysphereRedBold" },
    MiniAnimateCursor = { reverse = true, nocombine = true },
    MiniAnimateNormalFloat = { fg = colors.fg1, bg = colors.bg1 },
    MiniClueBorder = { link = "FloatBorder" },
    MiniClueDescGroup = { link = "DiagnosticFloatingWarn" },
    MiniClueDescSingle = { link = "NormalFloat" },
    MiniClueNextKey = { link = "DiagnosticFloatingHint" },
    MiniClueNextKeyWithPostkeys = { link = "DiagnosticFloatingError" },
    MiniClueSeparator = { link = "DiagnosticFloatingInfo" },
    MiniClueTitle = { link = "FloatTitle" },
    MiniCompletionActiveParameter = { underline = true },
    MiniCursorword = { underline = true },
    MiniCursorwordCurrent = { underline = true },
    MiniDepsChangeAdded = { link = "AnysphereGreen" },
    MiniDepsChangeRemoved = { link = "AnysphereRed" },
    MiniDepsHint = { link = "DiagnosticHint" },
    MiniDepsInfo = { link = "DiagnosticInfo" },
    MiniDepsMsgBreaking = { link = "DiagnosticWarn" },
    MiniDepsPlaceholder = { link = "Comment" },
    MiniDepsTitle = { link = "Title" },
    MiniDepsTitleError = { link = "DiffDelete" },
    MiniDepsTitleSame = { link = "DiffChange" },
    MiniDepsTitleUpdate = { link = "DiffAdd" },
    MiniDiffOverAdd = { link = "DiffAdd" },
    MiniDiffOverChange = { link = "DiffText" },
    MiniDiffOverContext = { link = "DiffChange" },
    MiniDiffOverDelete = { link = "DiffDelete" },
    MiniDiffSignAdd = { link = "AnysphereGreen" },
    MiniDiffSignChange = { link = "AnysphereAqua" },
    MiniDiffSignDelete = { link = "AnysphereRed" },
    MiniFilesBorder = { link = "FloatBorder" },
    MiniFilesBorderModified = { link = "DiagnosticFloatingWarn" },
    MiniFilesCursorLine = { bg = colors.bg2 },
    MiniFilesDirectory = { link = "Directory" },
    MiniFilesFile = { link = "AnysphereFg1" },
    MiniFilesNormal = { link = "NormalFloat" },
    MiniFilesTitle = { link = "FloatTitle" },
    MiniFilesTitleFocused = { link = "AnysphereOrangeBold" },
    MiniHipatternsFixme = { fg = colors.bg0, bg = colors.red, bold = config.bold },
    MiniHipatternsHack = { fg = colors.bg0, bg = colors.yellow, bold = config.bold },
    MiniHipatternsNote = { fg = colors.bg0, bg = colors.blue, bold = config.bold },
    MiniHipatternsTodo = { fg = colors.bg0, bg = colors.aqua, bold = config.bold },
    MiniIconsAzure = { link = "AnysphereBlue" },
    MiniIconsBlue = { link = "AnysphereBlue" },
    MiniIconsCyan = { link = "AnysphereAqua" },
    MiniIconsGreen = { link = "AnysphereGreen" },
    MiniIconsGrey = { link = "AnysphereFg0" },
    MiniIconsOrange = { link = "AnysphereOrange" },
    MiniIconsPurple = { link = "AnyspherePurple" },
    MiniIconsRed = { link = "AnysphereRed" },
    MiniIconsYellow = { link = "AnysphereYellow" },
    MiniIndentscopeSymbol = { link = "AnysphereGray" },
    MiniIndentscopeSymbolOff = { link = "AnysphereYellow" },
    MiniJump = { link = "AnysphereOrangeUnderline" },
    MiniJump2dDim = { link = "AnysphereGray" },
    MiniJump2dSpot = { fg = colors.orange, bold = config.bold, nocombine = true },
    MiniJump2dSpotAhead = { fg = colors.aqua, bg = colors.bg0, nocombine = true },
    MiniJump2dSpotUnique = { fg = colors.yellow, bold = config.bold, nocombine = true },
    MiniMapNormal = { link = "NormalFloat" },
    MiniMapSymbolCount = { link = "Special" },
    MiniMapSymbolLine = { link = "Title" },
    MiniMapSymbolView = { link = "Delimiter" },
    MiniNotifyBorder = { link = "FloatBorder" },
    MiniNotifyNormal = { link = "NormalFloat" },
    MiniNotifyTitle = { link = "FloatTitle" },
    MiniOperatorsExchangeFrom = { link = "IncSearch" },
    MiniPickBorder = { link = "FloatBorder" },
    MiniPickBorderBusy = { link = "DiagnosticFloatingWarn" },
    MiniPickBorderText = { link = "FloatTitle" },
    MiniPickIconDirectory = { link = "Directory" },
    MiniPickIconFile = { link = "MiniPickNormal" },
    MiniPickHeader = { link = "DiagnosticFloatingHint" },
    MiniPickMatchCurrent = { bg = colors.bg2 },
    MiniPickMatchMarked = { link = "Visual" },
    MiniPickMatchRanges = { link = "DiagnosticFloatingHint" },
    MiniPickNormal = { link = "NormalFloat" },
    MiniPickPreviewLine = { link = "CursorLine" },
    MiniPickPreviewRegion = { link = "IncSearch" },
    MiniPickPrompt = { link = "DiagnosticFloatingInfo" },
    MiniStarterCurrent = { nocombine = true },
    MiniStarterFooter = { link = "AnysphereGray" },
    MiniStarterHeader = { link = "Title" },
    MiniStarterInactive = { link = "Comment" },
    MiniStarterItem = { link = "Normal" },
    MiniStarterItemBullet = { link = "Delimiter" },
    MiniStarterItemPrefix = { link = "WarningMsg" },
    MiniStarterSection = { link = "Delimiter" },
    MiniStarterQuery = { link = "MoreMsg" },
    MiniStatuslineDevinfo = { link = "StatusLine" },
    MiniStatuslineFileinfo = { link = "StatusLine" },
    MiniStatuslineFilename = { link = "StatusLineNC" },
    MiniStatuslineInactive = { link = "StatusLineNC" },
    MiniStatuslineModeCommand = { fg = colors.bg0, bg = colors.yellow, bold = config.bold, nocombine = true },
    MiniStatuslineModeInsert = { fg = colors.bg0, bg = colors.blue, bold = config.bold, nocombine = true },
    MiniStatuslineModeNormal = { fg = colors.bg0, bg = colors.fg1, bold = config.bold, nocombine = true },
    MiniStatuslineModeOther = { fg = colors.bg0, bg = colors.aqua, bold = config.bold, nocombine = true },
    MiniStatuslineModeReplace = { fg = colors.bg0, bg = colors.red, bold = config.bold, nocombine = true },
    MiniStatuslineModeVisual = { fg = colors.bg0, bg = colors.green, bold = config.bold, nocombine = true },
    MiniSurround = { link = "IncSearch" },
    MiniTablineCurrent = { fg = colors.green, bg = colors.bg1, bold = config.bold, reverse = config.invert_tabline },
    MiniTablineFill = { link = "TabLineFill" },
    MiniTablineHidden = { fg = colors.bg4, bg = colors.bg1, reverse = config.invert_tabline },
    MiniTablineModifiedCurrent = {
      fg = colors.bg1,
      bg = colors.green,
      bold = config.bold,
      reverse = config.invert_tabline,
    },
    MiniTablineModifiedHidden = { fg = colors.bg1, bg = colors.bg4, reverse = config.invert_tabline },
    MiniTablineModifiedVisible = { fg = colors.bg1, bg = colors.fg1, reverse = config.invert_tabline },
    MiniTablineTabpagesection = { link = "Search" },
    MiniTablineVisible = { fg = colors.fg1, bg = colors.bg1, reverse = config.invert_tabline },
    MiniTestEmphasis = { bold = config.bold },
    MiniTestFail = { link = "AnysphereRedBold" },
    MiniTestPass = { link = "AnysphereGreenBold" },
    MiniTrailspace = { bg = colors.red },
    WhichKeyTitle = { link = "NormalFloat" },
    NeoTreeFloatBorder = { link = "AnysphereGray" },
    NeoTreeTitleBar = { fg = colors.fg1, bg = colors.bg2 },
    NeoTreeDirectoryIcon = { link = "AnysphereGreen" },
    NeoTreeDirectoryName = { link = "AnysphereGreenBold" },
    ["@comment"] = { fg = "#6d6d6d", italic = config.italic.comments },  -- VS Code comment color
    ["@none"] = { bg = "NONE", fg = "NONE" },
    ["@preproc"] = { fg = "#a8cc7c" },  -- VS Code preprocessor color
    ["@define"] = { fg = "#a8cc7c" },  -- VS Code define color
    ["@operator"] = { fg = "#d6d6dd" },  -- VS Code operator color
    ["@punctuation.delimiter"] = { fg = "#d6d6dd" },  -- VS Code delimiter color
    ["@punctuation.bracket"] = { fg = "#d6d6dd" },  -- VS Code bracket color
    ["@punctuation.special"] = { fg = "#d6d6dd" },  -- VS Code special punctuation color
    ["@string"] = { fg = "#e394dc", italic = config.italic.strings },  -- VS Code string color
    ["@string.regex"] = { fg = "#e394dc" },  -- VS Code string regex color
    ["@string.regexp"] = { fg = "#e394dc" },  -- VS Code string regexp color
    ["@string.escape"] = { fg = "#83d6c5" },  -- VS Code string escape color
    ["@string.special"] = { fg = "#83d6c5" },  -- VS Code string special color
    ["@string.special.path"] = { fg = "#e394dc", underline = config.underline },  -- VS Code path color
    ["@string.special.symbol"] = { fg = "#d6d6dd" },  -- VS Code symbol color
    ["@string.special.url"] = { fg = "#e394dc", underline = config.underline },  -- VS Code URL color
    ["@character"] = { fg = "#f8c762" },  -- VS Code character color
    ["@character.special"] = { fg = "#83d6c5" },  -- VS Code special character color
    ["@boolean"] = { fg = "#82d2ce" },  -- VS Code boolean color
    ["@number"] = { fg = "#ebc88d" },  -- VS Code number color
    ["@number.float"] = { fg = "#ebc88d" },  -- VS Code float color
    ["@float"] = { fg = "#ebc88d" },  -- VS Code float color
    ["@function"] = { fg = "#E3C893" },  -- VS Code entity.name.function color (function definitions)
    ["@function.builtin"] = { fg = "#82d2ce" },  -- VS Code builtin function color
    ["@function.call"] = { fg = "#ebc88d" },  -- VS Code function call color (should be yellow, different from method calls)
    ["@function.macro"] = { fg = "#a8cc7c" },  -- VS Code macro color
    ["@function.method"] = { fg = "#efb080" },  -- VS Code method color (method.declaration - orange for method definitions)
    ["@method"] = { fg = "#efb080" },  -- VS Code method color (orange for method definitions)
    ["@method.call"] = { fg = "#efb080" },  -- VS Code method call color (orange for method calls)
    ["@constructor"] = { fg = "#efb080" },  -- VS Code constructor color (should be orange)
    ["@parameter"] = { fg = "#d6d6dd" },  -- VS Code parameter color
    ["@keyword"] = { fg = "#83d6c5" },  -- VS Code keyword color
    ["@keyword.conditional"] = { fg = "#83d6c5" },  -- VS Code conditional color
    ["@keyword.debug"] = { fg = "#83d6c5" },  -- VS Code debug color
    ["@keyword.directive"] = { fg = "#a8cc7c" },  -- VS Code directive color
    ["@keyword.directive.define"] = { fg = "#a8cc7c" },  -- VS Code define color
    ["@keyword.exception"] = { fg = "#83d6c5" },  -- VS Code exception color
    ["@keyword.function"] = { fg = "#83d6c5" },  -- VS Code function keyword color
    ["@keyword.import"] = { fg = "#83d6c5" },  -- VS Code import color
    ["@keyword.operator"] = { fg = "#83d6c5" },  -- VS Code operator keyword color
    ["@keyword.repeat"] = { fg = "#83d6c5" },  -- VS Code repeat color
    ["@keyword.return"] = { fg = "#83d6c5" },  -- VS Code return color
    ["@keyword.storage"] = { fg = "#82d2ce" },  -- VS Code storage color
    ["@conditional"] = { fg = "#83d6c5" },  -- VS Code conditional color
    ["@repeat"] = { fg = "#83d6c5" },  -- VS Code repeat color
    ["@debug"] = { fg = "#83d6c5" },  -- VS Code debug color
    ["@label"] = { fg = "#83d6c5" },  -- VS Code label color
    ["@include"] = { fg = "#83d6c5" },  -- VS Code include color
    ["@exception"] = { fg = "#83d6c5" },  -- VS Code exception color
    ["@type"] = { fg = "#efb080" },  -- VS Code type color (struct/trait types should be orange)
    ["@type.builtin"] = { fg = "#82d2ce" },  -- VS Code builtin type color
    ["@type.definition"] = { fg = "#efb080" },  -- VS Code type definition color (entity.name.type)
    ["@type.qualifier"] = { fg = "#87c3ff" },  -- VS Code type qualifier color
    ["@storageclass"] = { fg = "#82d2ce" },  -- VS Code storage class color
    ["@attribute"] = { fg = "#aaa0fa" },  -- VS Code attribute color
    ["@field"] = { fg = "#AA9BF5" },  -- VS Code field color
    ["@property"] = { fg = "#AA9BF5" },  -- VS Code property color
    ["@variable"] = { fg = "#d6d6dd" },  -- VS Code variable color
    ["@variable.builtin"] = { fg = "#82d2ce" },  -- VS Code builtin variable color
    ["@variable.member"] = { fg = "#AA9BF5" },  -- VS Code member variable color
    ["@variable.parameter"] = { fg = "#d6d6dd" },  -- VS Code parameter color
    ["@constant"] = { fg = "#f8c762" },  -- VS Code constant color
    ["@constant.builtin"] = { fg = "#82d2ce" },  -- VS Code builtin constant color
    ["@constant.macro"] = { fg = "#a8cc7c" },  -- VS Code macro constant color
    ["@markup"] = { link = "AnysphereFg1" },
    ["@markup.strong"] = { bold = config.bold },
    ["@markup.italic"] = { link = "@text.emphasis" },
    ["@markup.underline"] = { underline = config.underline },
    ["@markup.strikethrough"] = { strikethrough = config.strikethrough },
    ["@markup.heading"] = { link = "Title" },
    ["@markup.raw"] = { link = "String" },
    ["@markup.math"] = { link = "Special" },
    ["@markup.environment"] = { link = "Macro" },
    ["@markup.environment.name"] = { link = "Type" },
    ["@markup.link"] = { link = "Underlined" },
    ["@markup.link.label"] = { link = "SpecialChar" },
    ["@markup.list"] = { link = "Delimiter" },
    ["@markup.list.checked"] = { link = "AnysphereGreen" },
    ["@markup.list.unchecked"] = { link = "AnysphereGray" },
    ["@comment.todo"] = { link = "Todo" },
    ["@comment.note"] = { link = "SpecialComment" },
    ["@comment.warning"] = { link = "WarningMsg" },
    ["@comment.error"] = { link = "ErrorMsg" },
    ["@diff.plus"] = { link = "diffAdded" },
    ["@diff.minus"] = { link = "diffRemoved" },
    ["@diff.delta"] = { link = "diffChanged" },
    ["@module"] = { link = "AnysphereFg1" },
    ["@namespace"] = { link = "AnysphereFg1" },
    ["@symbol"] = { link = "Identifier" },
    ["@text"] = { link = "AnysphereFg1" },
    ["@text.strong"] = { bold = config.bold },
    ["@text.emphasis"] = { italic = config.italic.emphasis },
    ["@text.underline"] = { underline = config.underline },
    ["@text.strike"] = { strikethrough = config.strikethrough },
    ["@text.title"] = { link = "Title" },
    ["@text.literal"] = { link = "String" },
    ["@text.uri"] = { link = "Underlined" },
    ["@text.math"] = { link = "Special" },
    ["@text.environment"] = { link = "Macro" },
    ["@text.environment.name"] = { link = "Type" },
    ["@text.reference"] = { link = "Constant" },
    ["@text.todo"] = { link = "Todo" },
    ["@text.todo.checked"] = { link = "AnysphereGreen" },
    ["@text.todo.unchecked"] = { link = "AnysphereGray" },
    ["@text.note"] = { link = "SpecialComment" },
    ["@text.note.comment"] = { fg = colors.purple, bold = config.bold },
    ["@text.warning"] = { link = "WarningMsg" },
    ["@text.danger"] = { link = "ErrorMsg" },
    ["@text.danger.comment"] = { fg = colors.fg0, bg = colors.red, bold = config.bold },
    ["@text.diff.add"] = { link = "diffAdded" },
    ["@text.diff.delete"] = { link = "diffRemoved" },
    ["@tag"] = { link = "Tag" },
    ["@tag.attribute"] = { link = "Identifier" },
    ["@tag.delimiter"] = { link = "Delimiter" },
    ["@punctuation"] = { link = "Delimiter" },
    ["@macro"] = { link = "Macro" },
    ["@structure"] = { link = "Structure" },
    ["@lsp.type.class"] = { fg = "#ebc88d" },  -- VS Code class name color (matching Python class color)
    ["@lsp.type.comment"] = { link = "@comment" },
    ["@lsp.type.decorator"] = { link = "@macro" },
    ["@lsp.type.enum"] = { fg = "#efb080" },  -- VS Code enum type color (should be orange like other types)
    ["@lsp.type.enumMember"] = { fg = "#d6d6dd" },  -- VS Code enum member color (from semanticTokenColors)
    ["@lsp.type.function"] = { fg = "#E3C893" },  -- VS Code function color (function definitions)
    ["@lsp.type.interface"] = { fg = "#efb080" },  -- VS Code interface color (should be orange like other type definitions)
    ["@lsp.type.macro"] = { link = "@macro" },
    ["@lsp.type.method"] = { fg = "#efb080" },  -- VS Code method color (orange for method definitions)
    ["@lsp.type.modifier.java"] = { link = "@keyword.type.java" },
    ["@lsp.type.namespace"] = { fg = "#d1d1d1" },  -- VS Code namespace color
    ["@lsp.type.parameter"] = { link = "@parameter" },
    ["@lsp.type.property"] = { fg = "#AA9BF5" },  -- VS Code property color
    ["@lsp.type.struct"] = { fg = "#efb080" },  -- VS Code struct color (should be orange)
    ["@lsp.type.type"] = { fg = "#efb080" },  -- VS Code type color (should be orange)
    ["@lsp.type.typeParameter"] = { fg = "#efb080" },  -- VS Code type parameter color
    ["@lsp.type.variable"] = { fg = "#d6d6dd" },  -- VS Code variable color

    -- NeoTreeDirectoryName = { link = "Directory" },
    -- NeoTreeDotfile = { fg = colors.fg4 },
    -- NeoTreeFadeText1 = { fg = colors.fg3 },
    -- NeoTreeFadeText2 = { fg = colors.fg4 },
    -- NeoTreeFileIcon = { fg = colors.blue },
    -- NeoTreeFileName = { fg = colors.fg1 },
    -- NeoTreeFileNameOpened = { fg = colors.fg1, bold = true },
    -- NeoTreeFileStats = { fg = colors.fg3 },
    -- NeoTreeFileStatsHeader = { fg = colors.fg2, italic = true },
    -- NeoTreeFilterTerm = { link = "SpecialChar" },
    -- NeoTreeHiddenByName = { link = "NeoTreeDotfile" },
    -- NeoTreeIndentMarker = { fg = colors.fg4 },
    -- NeoTreeMessage = { fg = colors.fg3, italic = true },
    -- NeoTreeModified = { fg = colors.yellow },
    -- NeoTreeRootName = { fg = colors.fg1, bold = true, italic = true },
    -- NeoTreeSymbolicLinkTarget = { link = "NeoTreeFileName" },
    -- NeoTreeExpander = { fg = colors.fg4 },
    -- NeoTreeWindowsHidden = { link = "NeoTreeDotfile" },
    -- NeoTreePreview = { link = "Search" },
    -- NeoTreeGitAdded = { link = "GitGutterAdd" },
    -- NeoTreeGitConflict = { fg = colors.orange, bold = true, italic = true },
    -- NeoTreeGitDeleted = { link = "GitGutterDelete" },
    -- NeoTreeGitIgnored = { link = "NeoTreeDotfile" },
    -- NeoTreeGitModified = { link = "GitGutterChange" },
    -- NeoTreeGitRenamed = { link = "NeoTreeGitModified" },
    -- NeoTreeGitStaged = { link = "NeoTreeGitAdded" },
    -- NeoTreeGitUntracked = { fg = colors.orange, italic = true },
    -- NeoTreeGitUnstaged = { link = "NeoTreeGitConflict" },
    -- NeoTreeTabActive = { fg = colors.fg1, bold = true },
    -- NeoTreeTabInactive = { fg = colors.fg4, bg = colors.bg1 },
    -- NeoTreeTabSeparatorActive = { fg = colors.bg1 },
    -- NeoTreeTabSeparatorInactive = { fg = colors.bg2, bg = colors.bg1 },
  }

  for group, hl in pairs(config.overrides) do
    if groups[group] then
      -- "link" should not mix with other configs (:h hi-link)
      groups[group].link = nil
    end

    groups[group] = vim.tbl_extend("force", groups[group] or {}, hl)
  end

  return groups
end

---@param config AnysphereConfig?
Anysphere.setup = function(config)
  Anysphere.config = vim.deepcopy(default_config)
  Anysphere.config = vim.tbl_deep_extend("force", Anysphere.config, config or {})
end

--- main load function
Anysphere.load = function()
  if vim.version().minor < 8 then
    vim.notify_once("anysphere.nvim: you must use neovim 0.8 or higher")
    return
  end

  -- reset colors
  if vim.g.colors_name then
    vim.cmd.hi("clear")
  end
  vim.g.colors_name = "anysphere"
  vim.o.termguicolors = true

  local groups = get_groups()

  -- add highlights
  for group, settings in pairs(groups) do
    vim.api.nvim_set_hl(0, group, settings)
  end
end

return Anysphere
