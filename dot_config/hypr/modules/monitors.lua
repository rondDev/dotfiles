-- # monitor=desc:Samsung Electric Company Odyssey G40B HNMT601018,1920x1080@240,0x0,auto # Huawei
-- monitor=desc:Huawei Technologies Co. Inc. ZQE-CAA,3440x1440@165,3440x0,auto # Huawei
-- # monitor=desc:Huawei Technologies Co. Inc. ZQE-CAA,1024x760@165,3440x0,auto # Huawei
-- # monitor=DP-2,3440x1440@30,0x-1440,auto # Huawei
-- # monitor=desc:Samsung Electric Company LC34G55T HNTW503780,3440x1440@165,0x0, 1, bitdepth, 10, cm,hdr # Samsung
-- monitorv2 {
--   # output = DP-2
--   output = desc:Samsung Electric Company LC34G55T HNTW503780
--   mode = 3440x1440@165
--   position = 0x0
--   # cm = hdr # supports_wide_color = 1 # supports_hdr = 1 # sdrbrightness = 1.2 # sdrsaturation = 1 # sdr_min_luminance = 0 # sdr_max_luminance = 250 # min_luminance = 0 # max_luminance = 600 # max_avg_luminance = 350
-- }
-- # monitor=desc:Samsung Electric Company LC34G55T HNTW503780,3440x1440@165,0x-1440,auto # Samsung
-- monitor= , preferred, auto, 1

hl.monitor({
  output = "desc:Samsung Electric Company LC34G55T HNTW503780",
  mode = "3440x1440@165",
  position = "0x0",
})

hl.monitor({
  output = "desc:Huawei Technologies Co. Inc. ZQE-CAA",
  mode = "3440x1440@165",
  position = "3440x0",
})

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1" })
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1" })
