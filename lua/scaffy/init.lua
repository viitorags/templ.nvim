local M = {}

local config = {
  templates_path = vim.fn.stdpath("config") .. "/templ_templates",
}

local function get_plugin_root()
  local source = debug.getinfo(1, "S").source:sub(2)
  local lua_dir = vim.fn.fnamemodify(source, ":h")
  return vim.fn.fnamemodify(lua_dir, ":h:h")
end

local function read_file(path)
  local lines = vim.fn.readfile(path)
  if not lines then
    return nil
  end
  return table.concat(lines, "\n")
end

local function write_file(path, content)
  local fd = io.open(path, "w")
  if not fd then
    return false
  end
  fd:write(content)
  fd:close()
  return true
end

local function create_structure(base_path, structure)
  for _, entry in ipairs(structure) do
    local full_path = base_path .. "/" .. entry.path
    if entry.content then
      local dir = full_path:match("(.*/)")
      if dir then
        vim.fn.mkdir(dir, "p")
      end
      write_file(full_path, entry.content)
    else
      vim.fn.mkdir(full_path, "p")
    end
  end
end

function M.create_project(template_path)
  local template_file = vim.fn.expand(template_path)
  local json_text = read_file(template_file)
  if not json_text then
    print("Error: I couldn't read the template " .. template_file)
    return
  end

  local ok, template = pcall(vim.fn.json_decode, json_text)
  if not ok or type(template) ~= "table" then
    print("Error: Invalid JSON TEMPLATE")
    return
  end

  local cwd = vim.fn.getcwd()
  local project_name = vim.fn.input("Project name: ", "")
  local final_path = cwd .. "/" .. project_name
  vim.fn.mkdir(final_path, "p")

  create_structure(final_path, template.structure or {})
  print("Project created in: " .. final_path)
end

function M.select_template()
  local has_telescope, telescope = pcall(require, "telescope.builtin")
  if not has_telescope then
    print("Telescope is not installed")
    return
  end

  local templates_path = vim.fn.expand(config.templates_path)
  vim.fn.mkdir(templates_path, "p")

  telescope.find_files({
    prompt_title = "Select a template",
    cwd = templates_path,
    attach_mappings = function(prompt_bufnr, map)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      local function on_select()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if selection then
          M.create_project(templates_path .. "/" .. selection.value)
        end
      end

      map("i", "<CR>", on_select)
      map("n", "<CR>", on_select)
      return true
    end,
  })
end

function M.setup(opts)
  opts = opts or {}

  if not opts.templates_path then
    opts.templates_path = get_plugin_root() .. "/template"
  end

  config = vim.tbl_deep_extend("force", config, opts)
  vim.fn.mkdir(vim.fn.expand(config.templates_path), "p")
end

return M
