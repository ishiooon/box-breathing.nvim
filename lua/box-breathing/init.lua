-- box-breathing.nvim: ボックスブリージングを支援するNeoVimプラグイン
-- 画面の周囲に移動するバーを表示し、呼吸のリズムを視覚的に補助します

local M = {}

-- デフォルト設定
M.config = {
  -- バーの移動速度（各辺の移動時間、秒）
  duration = 4,
  -- バーのハイライトグループ（色設定）
  highlight_group = "BoxBreathingBar",
  -- アニメーションのタイマー間隔（ミリ秒）
  animation_interval = 50,
  -- 実行中かどうかのフラグ
  running = false
}

-- ウィンドウパラメータを保持する変数
local win = nil
local buf = nil

-- アニメーションの状態管理
local animation = {
  timer = nil,
  current_edge = 1,  -- 1: 上, 2: 右, 3: 下, 4: 左
  progress = 0,      -- 0.0 ~ 1.0の進行状況
  frame_count = 0,   -- フレームカウンター
  trail_positions = {},  -- 残像の位置を保存する配列
}

-- バーを描画する関数
local function draw_bar()
  -- バッファが有効でない場合は終了
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  -- 現在のウィンドウサイズを取得（フロートウィンドウのサイズを使用）
  local width = vim.api.nvim_win_get_width(win)
  local height = vim.api.nvim_win_get_height(win)

  -- バッファをクリア（トレイル効果のため完全にクリアしない）
  if animation.frame_count == 0 or animation.frame_count % 5 == 0 then
    -- 5フレームごとにバッファを完全にクリア
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
    -- 必要な行数分のバッファを用意
    local lines = {}
    for i = 1, height do
      lines[i] = string.rep(" ", width)
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  end
  
  -- バーの長さ（辺によって変更）
  local bar_length = 1
  
  -- 横移動（上辺または下辺）の場合、横長バーにする
  if animation.current_edge == 1 or animation.current_edge == 3 then
    -- 横長バー（画面幅の4分の1の長さにする）
    local width = vim.api.nvim_win_get_width(win)
    bar_length = math.floor(width / 4)
  end
  
  -- バーの位置計算
  local pos = {}

  
  if animation.current_edge == 1 then
    -- 上辺: 左から右へ
    pos.row = 0
    pos.col = math.floor(width * animation.progress)

  elseif animation.current_edge == 2 then
    -- 右辺: 上から下へ
    pos.row = math.floor(height * animation.progress)
    pos.col = width - 1

  elseif animation.current_edge == 3 then
    -- 下辺: 右から左へ
    pos.row = height - 1
    pos.col = width - 1 - math.floor(width * animation.progress)

  else
    -- 左辺: 下から上へ
    pos.row = height - 1 - math.floor(height * animation.progress)
    pos.col = 0

  end

  
  -- メインバーのハイライト（現在位置）
  vim.api.nvim_buf_add_highlight(buf, -1, M.config.highlight_group .. "Main", pos.row, pos.col, pos.col + bar_length)
  
  -- 残像エフェクト（トレイル）
  -- 前の位置を少し薄く表示
  local trail_positions = animation.trail_positions or {}
  
  -- 新しい位置を追加
  table.insert(trail_positions, 1, {row = pos.row, col = pos.col})
  
  -- 最大5つのトレイルを保持
  if #trail_positions > 5 then
    table.remove(trail_positions)
  end
  

  for i, trail_pos in ipairs(trail_positions) do
    if i > 1 then -- 現在位置以外
      -- 現在のバーの長さをそのまま使用する
      -- トレイルの位置はすでに記録されているので、元の形状を維持
      vim.api.nvim_buf_add_highlight(buf, -1, M.config.highlight_group .. "Trail" .. i, 
        trail_pos.row, trail_pos.col, trail_pos.col + bar_length)
    end
  end
  
  -- トレイル位置を保存
  animation.trail_positions = trail_positions
  
  -- フレームカウンターを更新
  animation.frame_count = (animation.frame_count or 0) + 1
end

-- バーの初期化
local function setup_bar()
  -- 既存のバッファとウィンドウを閉じる
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
  
  -- 新しいバッファを作成
  buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  
  -- ウィンドウサイズを取得（現在のエディタ全体のサイズ）
  local width = vim.o.columns
  local height = vim.o.lines - vim.o.cmdheight
  
  -- フロートウィンドウとして表示
  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    row = 0,
    col = 0,
    style = 'minimal',
    focusable = false,
  }
  
  win = vim.api.nvim_open_win(buf, false, opts)
  
  -- ウィンドウの設定
  vim.api.nvim_win_set_option(win, 'winblend', 90)  -- 透明度を高めに設定
  
  -- バーのハイライトグループを設定（メインバーと残像用）
  vim.cmd([[
    highlight BoxBreathingBarMain guifg=#ffffff guibg=#ffffff gui=none
    highlight BoxBreathingBarTrail2 guifg=#eeeeee guibg=#eeeeee gui=none
    highlight BoxBreathingBarTrail3 guifg=#dddddd guibg=#dddddd gui=none
    highlight BoxBreathingBarTrail4 guifg=#bbbbbb guibg=#bbbbbb gui=none
    highlight BoxBreathingBarTrail5 guifg=#999999 guibg=#999999 gui=none
  ]])
  

  M.config.highlight_group = "BoxBreathingBar"
  
  -- 初期状態を設定
  animation.current_edge = 1
  animation.progress = 0
  animation.frame_count = 0
  animation.trail_positions = {}
end

-- アニメーションを更新する関数
local function update_animation()
  -- 進行状況を更新
  animation.progress = animation.progress + (M.config.animation_interval / 1000) / M.config.duration
  
  -- 辺を移動
  if animation.progress >= 1.0 then
    animation.progress = 0
    animation.current_edge = animation.current_edge % 4 + 1
  end
  
  -- バーを描画
  draw_bar()
end

-- アニメーションを開始
function M.start()
  if M.config.running then
    return
  end
  
  M.config.running = true
  setup_bar()
  
  -- タイマーを設定
  animation.timer = vim.loop.new_timer()
  animation.timer:start(0, M.config.animation_interval, vim.schedule_wrap(function()
    if not M.config.running then
      return
    end
    update_animation()
  end))
  
  vim.api.nvim_echo({{"Box Breathing開始", "Normal"}}, false, {})
end

-- アニメーションを停止
function M.stop()
  if not M.config.running then
    return
  end
  
  M.config.running = false
  
  -- タイマーを停止
  if animation.timer then
    animation.timer:stop()
    animation.timer:close()
    animation.timer = nil
  end
  
  -- ウィンドウを閉じる
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
    win = nil
  end
  
  vim.api.nvim_echo({{"Box Breathing停止", "Normal"}}, false, {})
end

-- プラグインの初期化
function M.setup(opts)
  -- 設定をマージ
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  
  -- バー用のハイライトグループを定義（メインバーと残像用）
  vim.cmd([[
    highlight BoxBreathingBarMain guifg=#ffffff guibg=#ffffff gui=none
    highlight BoxBreathingBarTrail2 guifg=#eeeeee guibg=#eeeeee gui=none
    highlight BoxBreathingBarTrail3 guifg=#dddddd guibg=#dddddd gui=none
    highlight BoxBreathingBarTrail4 guifg=#bbbbbb guibg=#bbbbbb gui=none
    highlight BoxBreathingBarTrail5 guifg=#999999 guibg=#999999 gui=none
  ]])
  
  -- コマンド登録
  vim.api.nvim_create_user_command('BoxBreathingStart', M.start, {})
  vim.api.nvim_create_user_command('BoxBreathingStop', M.stop, {})
  vim.api.nvim_create_user_command('BoxBreathingToggle', function()
    if M.config.running then
      M.stop()
    else
      M.start()
    end
  end, {})
  
  -- デバッグメッセージ
  vim.api.nvim_echo({{"Box Breathingプラグインが初期化されました", "Normal"}}, false, {})
end

return M

