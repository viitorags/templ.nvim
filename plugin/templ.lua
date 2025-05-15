require("templ")

vim.api.nvim_create_user_command("CreateProject", function(opts)
  require("templ").create_project(opts.args)
end, {
  nargs = 1,
  complete = "file",
})

vim.api.nvim_create_user_command("CreateProjectSelect", function()
  require("templ").select_template()
end, {})
