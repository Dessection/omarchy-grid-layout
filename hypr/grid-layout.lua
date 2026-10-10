-- omarchy-grid-layout: an equal-size grid layout for Hyprland, plus a
-- SUPER + L binding that cycles dwindle -> scrolling -> grid.
-- https://github.com/Dessection/omarchy-grid-layout

-- Every tiled window gets the same size: 4 windows = 2x2, 5-6 = 3x2,
-- 7-9 = 3x3. Use it as "lua:grid". Based on example/layouts/grid.lua in the
-- Hyprland repository.
hl.layout.register("grid", {
  recalculate = function(ctx)
    local n = #ctx.targets
    if n == 0 then
      return
    end

    local cols = math.ceil(math.sqrt(n))

    for i, target in ipairs(ctx.targets) do
      target:place(ctx:grid_cell(i, cols))
    end
  end,
})

-- Replace Omarchy's dwindle/scrolling toggle with a three-way cycle.
hl.unbind("SUPER + L")
o.bind("SUPER + L", "Cycle workspace layout", os.getenv("HOME") .. "/.config/hypr/scripts/omarchy-grid-layout-cycle.sh")
