# 🚁 HoverSplit

![hoversplit](https://github.com/roobert/tabtree.nvim/assets/226654/b30c6892-6f4a-4443-94ed-84c3aa75d51b)

## Overview

hoversplit.nvim is a Neovim plugin designed to enhance the Language Server Protocol (LSP) experience by providing hover information in a split window. With this plugin, you can quickly access additional context, documentation, or information related to code symbols directly within your editor without disrupting your workflow.

## Features

- **Hover Information**: Get detailed hover information about symbols, functions, types, and more in a separate split window.
- **Auto Update**: The content automatically updates as the cursor moves to new targets.
- **Flexible Display**: Choose between horizontal and vertical splits
- **Flexible Focus**: Control whether the cursor remains focused on the split or returns to the original buffer.
- **Toggle Splits**: Easily toggle the split window open and closed using configurable key bindings.

## Installation

You can install hoversplit.nvim using your preferred plugin manager. Here's an example
for LazyVim:

```lua
{
  "roobert/hoversplit.nvim",
  config = function()
    require("hoversplit").setup()
  end
}
```

## Usage

### Key Bindings

You can configure key bindings for different functionalities. Here's an example configuration:

```lua
{
  "roobert/hoversplit.nvim",
  config = function()
    require("hoversplit").setup({
      key_bindings = {
        split_remain_focused = "<leader>hs",
        vsplit_remain_focused = "<leader>hv",
        split = "<leader>hS",
        vsplit = "<leader>hV",
      },
    })
  end,
}
```

## Functions

- **split**: Opens a horizontal split with hover information, focusing on the split.
- **vsplit**: Opens a vertical split with hover information, focusing on the split.
- **split_remain_focused**: Opens a horizontal split without moving the focus from the original buffer.
- **vsplit_remain_focused**: Opens a vertical split without moving the focus from the original buffer.
