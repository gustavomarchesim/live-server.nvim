🌐 live-server.nvim

A professional, multi-instance development server manager for Neovim, built specifically for web developers. This plugin acts as a powerful wrapper for the [live-server](https://github.com/tapio/live-server) binary.

## ✨ Features

* 🚀 **Multi-Instance Support**: Run multiple servers simultaneously on different ports.
* 📂 **Project Picker**: Use a fuzzy finder interface to select any HTML file in your project as an entry point.
* 🔢 **Automatic Port Management**: Automatically suggests available ports (8080, 8081, etc.) or allows custom ones.
* 🎨 **Modern UI**: Fully integrated with `vim.ui.select` (looks amazing with [Telescope](https://github.com/nvim-telescope/telescope.nvim) and [Noice](https://github.com/folke/noice.nvim)).
* 🧹 **Auto-Cleanup**: Automatically kills all background processes when you close Neovim.
* 📊 **Lualine Integration**: Built-in support to show active server status in your statusline.

## 📦 Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "gustavomarchesim/live-server.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" }, -- Optional, for better UI
  opts = {
    key = "<leader>ls", -- Custom keybinding to open the menu
  },
  config = function(_, opts)
    require("live-server").setup(opts)
  end,
}
```

## ⌨️ Usage

The plugin uses a central control panel for all operations.

| Action | Description |
| :--- | :--- |
| **Start Current File** | Launches a server for the file you are currently editing. |
| **Pick File & Start** | Fuzzy find any HTML file in the project to host. |
| **Manage/Stop Servers** | Lists all active servers with their ports and files for individual shutdown. |
| **Kill Everything** | Emergency command to stop all instances and clean the system. |

### Command
You can also open the menu via command line:

```vim
:LiveServer```


## 🛠️ Requirements
live-server must be installed globally:
```bash
npm install -g live-server
```
