# box-breathing.nvim

Box Breathingを視覚的にサポートする Neovim プラグイン

A Neovim plugin that visually supports Box Breathing technique

## 概要 / Overview

box-breathing.nvim は、ストレス軽減や集中力向上に効果的なボックスブリージングをサポートするプラグインです。画面の周囲に移動するバーを表示し、呼吸のリズムを視覚的にガイドします。

box-breathing.nvim is a plugin that supports box breathing which is effective for stress reduction and concentration improvement. It displays a moving bar around the screen to visually guide your breathing rhythm.

## インストール方法 / Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim) を使用した場合

```lua
{
  "ishiooon/box-breathing.nvim",
  config = {
    -- オプションの設定（省略可能）
    -- Optional configuration
    duration = 4,  -- 各辺の移動時間（秒） / Movement duration per edge (seconds)
    animation_interval = 50,  -- アニメーションの更新間隔（ミリ秒） / Animation update interval (milliseconds)
  }
}
```

## 特徴 / Features

- エディタ画面の周囲を移動するバーで呼吸のリズムを視覚化
- 各辺4秒間のデフォルトタイミングで、息を吸う・止める・吐く・止めるのサイクルをガイド
- 透明度の高いオーバーレイで編集作業を妨げません
- 簡単に開始/停止が可能なコマンド

---

- Visualizes breathing rhythm with a bar moving around the editor screen
- Guides the inhale-hold-exhale-hold cycle with default timing of 4 seconds per edge
- High-transparency overlay that doesn't interfere with editing
- Easy-to-use commands to start/stop

## 使い方 / Usage

以下のコマンドを使用して操作できます：

The following commands are available:

```
:BoxBreathingStart  - ボックスブリージングを開始 / Start box breathing
:BoxBreathingStop   - ボックスブリージングを停止 / Stop box breathing
:BoxBreathingToggle - ボックスブリージングの開始/停止を切り替え / Toggle box breathing
```

## カスタマイズ / Customization

`setup()`関数で以下の設定をカスタマイズできます：

You can customize the following settings with the `setup()` function:

```lua
require("box-breathing").setup({
  -- バーの移動速度（各辺の移動時間、秒）
  -- Movement duration per edge (seconds)
  duration = 4,
  
  -- バーのハイライトグループ（色設定）
  -- Highlight group for the bar (color settings)
  highlight_group = "BoxBreathingBar",
  
  -- アニメーションのタイマー間隔（ミリ秒）
  -- Animation timer interval (milliseconds)
  animation_interval = 50,
})
```

ハイライトグループをカスタマイズする例：

Example of customizing highlight groups:

```lua
vim.cmd([[
  highlight BoxBreathingBarMain guifg=#00ff00 guibg=#00ff00 gui=none
  highlight BoxBreathingBarTrail2 guifg=#00ee00 guibg=#00ee00 gui=none
  highlight BoxBreathingBarTrail3 guifg=#00dd00 guibg=#00dd00 gui=none
  highlight BoxBreathingBarTrail4 guifg=#00bb00 guibg=#00bb00 gui=none
  highlight BoxBreathingBarTrail5 guifg=#009900 guibg=#009900 gui=none
]])
```

## 今後の開発予定 / Future Development

- カスタムキーマッピングのサポート
- バーの色や形状のさらなるカスタマイズオプション
- 残像エフェクトのオン/オフ切り替え機能

---

- Support for custom key mappings
- More customization options for bar color and shape
- Toggle function for afterimage effects

## ライセンス / License

MIT
