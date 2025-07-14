# Anysphere for Neovim

Colorscheme for Neovim inspired by Anysphere Dark for Cursor AI.

## Installing

### Using `packer`

```lua
use { "brendon-felix/anysphere.nvim" }
```

### Using `lazy.nvim`

```lua
{ "brendon-felix/anysphere.nvim", priority = 1000 , config = true, opts = ...}
```

### Using `vim-plug`

```vim
Plug 'brendon-felix/anysphere.nvim'
```

## Basic Usage

Inside `init.vim`

```vim
colorscheme anysphere
```

Inside `init.lua`

```lua
vim.cmd([[colorscheme anysphere]])
```

