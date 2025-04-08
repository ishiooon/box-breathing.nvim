-- setup関数を呼び出して明示的に初期化する
local box_breathing = require('box-breathing')
box_breathing.setup()

-- nvim起動時に自動的にBox Breathingを開始する
vim.defer_fn(function()
  box_breathing.stop()
end, 1000)  -- 1秒後に開始（Neovimの起動が完了するのを待つため）

