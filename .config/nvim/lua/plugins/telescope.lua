return {
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>f",  function() require("telescope.builtin").find_files() end,                                 desc = "Find Files" },
      { "<leader>s",  function() require("telescope.builtin").live_grep() end,                                  desc = "Live Grep" },
      { "<leader>j",  function() require("telescope.builtin").live_grep({ glob_pattern = "!{spec,test}" }) end, desc = "Live grep code" },
      { "<leader>tr", function() require("telescope.builtin").resume() end,                                     desc = "Resume search" },
      { "<leader>tb", function() require("telescope.builtin").buffers() end,                                    desc = "Find Buffers" },
      { "<leader>th", function() require("telescope.builtin").help_tags() end,                                  desc = "Find Help Tags" },
      { "<leader>ts", function() require("telescope.builtin").lsp_document_symbols() end,                       desc = "Find Symbols" },
      { "<leader>to", function() require("telescope.builtin").oldfiles() end,                                   desc = "Find Old Files" },
      { "<leader>tw", function() require("telescope.builtin").grep_string() end,                                desc = "Find Word under Cursor" },
      { "<leader>gc", function() require("telescope.builtin").git_commits() end,                                desc = "Search Git Commits" },
      { "<leader>gb", function() require("telescope.builtin").git_bcommits() end,                               desc = "Search Git Commits for Buffer" },
      { "<leader>tk", function() require("telescope.builtin").keymaps() end,                                    desc = "Find Keymaps" },
      { "<leader>tm", function() require("telescope.builtin").colorscheme() end,                                desc = "Change theme" },
      {
        "<leader>/",
        function()
          require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
            winblend = 10,
            previewer = true,
            layout_config = { width = 0.6 },
          }))
        end,
        desc = "[/] Fuzzily search in current buffer"
      },
    },
    config = function()
      -- Load fzf native
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          layout_strategy = 'flex', -- based on width (kinda like this actually and it resizes with the window perfectly)
          -- layout_strategy = 'vertical', -- default is horizontal (files+prompt left, preview right)
          -- layout_strategy = 'horizontal', -- vertical = (preview top, files middle, prompt bottom) -- maximizes both list of files and preview content
          layout_config = {
            -- :help telescope.layout
            horizontal = { width = 0.9 },
            vertical = { width = 0.9 },
          },
        },
        pickers = {
          live_grep = {
            layout_strategy = 'vertical',
          },
          find_files = {
            theme = "dropdown",
            find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
          }
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "ignore_case",
          },
        },
      })
      telescope.load_extension("fzf")
      -- telescope.load_extension("remote-sshfs")
    end,
  },
}
