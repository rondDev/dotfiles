local M = {}

function M.setup_vkfix()
  if hl.plugin.csgo_vulkan_fix ~= nil then
    hl.plugin.csgo_vulkan_fix.vkfix_app({ app = "cs2", w = 1920, h = 1440 })

    hl.config({
      plugin = {
        csgo_vulkan_fix = {
          fix_mouse = true,
        },
      },
    })
  end
end

return M
