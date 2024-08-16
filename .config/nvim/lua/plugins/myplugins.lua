return {
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- choose your flavour
      })
      vim.cmd([[colorscheme catppuccin]])
    end,
  },
}
