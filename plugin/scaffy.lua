require("scaffy")

vim.api.nvim_create_user_command("CreateProject", function(opts)
  require("scaffy").create_project(opts.args)
end, {
  nargs = 1,
  complete = "file",
})

vim.api.nvim_create_user_command("CreateProjectSelect", function()
  require("scaffy").select_template()
end, {})
