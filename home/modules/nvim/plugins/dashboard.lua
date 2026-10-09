local function lines(s)
  return vim.split(s, "\n", { plain = true, trimempty = true })
end

-- Stockly's bird. `facets` tells which of the logo's two purples each cell
-- has: m for the wing and tail, d for the body.
local bird = lines([==[
    ,.
    ]H.
    `HHb.
     HHHHba
     ]HHHHHHHaa       adHHHHHHHa.
      HHHHHHHHHHHaa aHHHHHHHHHHHHb.
      `HHHHHHHHHHHHHHHHHHHHHHHHHHHH.
       `HHHHHHHHHHHHHHHHHHHHHHHHHHHH.
        `HHHHHHHHHHHHHHHHHHHHHHH"""'
         `HHHHHHHHHHHHHHHHHHHH'
           VHHHHHHHHHHHHHHHHH
            `VHHHHHHHHHHHHHH[
              HHHHHHHHHHHHHH
             ]HHHHHHHHHHHHH[
             dHHHHHHHHHHHHV
             HHHHHHHHHHHHV
            ]HHHHHHHHHHHV
            dHHHHHHHHHH"
            HHHHHHHHH"
           ,HHHHHHH"
           ]HHHH"'
           `""
]==])
local facets = lines([==[
    mm
    mmm
    mmmmm
     mmmmmm
     mmmmmmmmmm       mmddddddddd
      mmmmmmmmmdddd mmmdddddddddddd
      mmmmmmmmdddddddddddddddddddddd
       mmmmmmmddddddddddddddddddddddd
        mmmmmmmdddddddddddddddddddd
         mmmmmmdddddddddddddddd
           mmmddddddddddddddd
            mdddddddddddddddd
              mmdddddddddddd
             mmmmmdddddddddd
             mmmmmmmddddddd
             mmmmmmmdddddd
            mmmmmmmmmdddd
            mmmmmmmmmddd
            mmmmmmmmmm
           mmmmmmmmm
           mmmmmmm
           mmm
]==])
local name = lines([==[
 .oooooo..o     .                       oooo        oooo
d8P'    `Y8   .o8                       `888        `888
Y88bo.      .o888oo  .ooooo.   .ooooo.   888  oooo   888  oooo    ooo
 `"Y8888o.    888   d88' `88b d88' `"Y8  888 .8P'    888   `88.  .8'
     `"Y88b   888   888   888 888        888888.     888    `88..8'
oo     .d8P   888 . 888   888 888   .o8  888 `88b.   888     `888'
8""88888P'    "888" `Y8bod8P' `Y8bod8P' o888o o888o o888o     .8'
                                                          .o..P'
                                                          `Y8P'
]==])

local bird_width, name_width, gap = 38, 70, 4

local function set_highlights()
  vim.api.nvim_set_hl(0, "StocklyBirdWing", { fg = "#c45fd0" })
  vim.api.nvim_set_hl(0, "StocklyBirdBody", { fg = "#8a5fd6" })
  vim.api.nvim_set_hl(0, "StocklyName", { fg = "#ca9ee6", bold = true })
end
set_highlights()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_highlights })

-- Highlights of one bird row shifted by `offset` columns: one range per run
-- of cells of the same facet.
local function bird_hl(row, offset)
  local ranges, mask = {}, facets[row] or ""
  local start, kind
  for col = 1, #mask + 1 do
    local cell = mask:sub(col, col)
    if cell ~= kind then
      if kind == "m" or kind == "d" then
        local group = kind == "m" and "StocklyBirdWing" or "StocklyBirdBody"
        table.insert(ranges, { group, offset + start - 1, offset + col - 1 })
      end
      start, kind = col, cell
    end
  end
  return ranges
end

local function pad(s, width)
  return s .. string.rep(" ", width - #s)
end

-- Bird and name side by side when the window is wide enough, stacked when it
-- is not, and the bird alone in a narrow one.
local function header()
  local val, hl = {}, {}
  local columns = vim.o.columns
  if columns >= bird_width + gap + name_width + 4 then
    local first = #bird - #name -- the name sits on the bird's last rows
    for row, line in ipairs(bird) do
      local ranges = bird_hl(row, 0)
      local text = name[row - first]
      if text then
        local offset = bird_width + gap
        line = pad(line, offset) .. text
        table.insert(ranges, { "StocklyName", offset, offset + #text })
      end
      table.insert(val, line)
      table.insert(hl, ranges)
    end
  else
    local stacked = columns >= name_width + 4
    local offset = stacked and math.floor((name_width - bird_width) / 2) or 0
    for row, line in ipairs(bird) do
      table.insert(val, string.rep(" ", offset) .. line)
      table.insert(hl, bird_hl(row, offset))
    end
    if stacked then
      table.insert(val, "")
      table.insert(hl, {})
      for _, text in ipairs(name) do
        table.insert(val, pad(text, name_width))
        table.insert(hl, { { "StocklyName", 0, #text } })
      end
    end
  end
  return val, hl
end

local dashboard = require("alpha.themes.dashboard")

dashboard.section.header.val, dashboard.section.header.opts.hl = header()

dashboard.section.buttons.val = {
  dashboard.button("f", "\u{f002}  Find file", "<cmd>Telescope find_files<cr>"),
  dashboard.button("n", "\u{f15b}  New file", "<cmd>enew<cr>"),
  dashboard.button("r", "\u{f1da}  Recent files", "<cmd>Telescope oldfiles<cr>"),
  dashboard.button("g", "\u{f002}  Find text", "<cmd>Telescope live_grep<cr>"),
  dashboard.button("e", "\u{f07b}  Explorer", "<cmd>Neotree reveal<cr>"),
  dashboard.button("q", "\u{f00d}  Quit", "<cmd>qa<cr>"),
}

require("alpha").setup(dashboard.config)
