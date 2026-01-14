-- 42Header plugin for Neovim
-- Automatically generates and manages 42 school headers

local M = {}

-- Default configuration
local default_config = {
    user = "your_username",
    mail = "your_email@student.42.fr",
    auto_update = false,
    header_format = "full" -- "full" or "minimal"
}

-- Configuration store
local config = default_config

-- Header templates
local headers = {
    full = {
        "/* ************************************************************************** */",
        "/*                                                                            */",
        "/*                                                        :::      ::::::::   */",
        "/*   %-46.46s :+:      :+:    :+:   */",
        "/*                                                    +:+ +:+         +:+     */",
        "/*   By: %-20.20s <%-30.30s> +#+  +:+       +#+        */",
        "/*                                                +#+#+#+#+#+   +#+           */",
        "/*   Created: %19s by %-20.20s #+#    #+#             */",
        "/*   Updated: %19s by %-20.20s ###   ########.fr       */",
        "/*                                                                            */",
        "/* ************************************************************************** */",
        ""
    },
    minimal = {
        "/* ************************************************************************** */",
        "/*   %-45.45s :+:      :+:    :+:   */",
        "/*   By: %-20.20s <%-30.30s> +#+  +:+       +#+        */",
        "/*                                                +#+#+#+#+#+   +#+           */",
        "/*   Created: %19s by %-20.20s #+#    #+#             */",
        "/*   Updated: %19s by %-20.20s ###   ########.fr       */",
        "/* ************************************************************************** */",
        ""
    }
}

-- Get current date and time
local function get_datetime()
    return os.date("%Y/%m/%d %H:%M:%S")
end

-- Check if current buffer already has a 42 header
local function has_header()
    local line1 = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ""
    return line1:match("/%*+%s+%*+/%*+%s+%*+/%*+%s+%*+/%*+%s+%*+/%*+%s+%*+/%*+%s+%*+/%*+%s+%*+/") ~= nil
end

-- Generate header content
local function generate_header(filename, create_time, update_time)
    local template = headers[config.header_format]
    local header_content = {}
    local created_time = create_time or get_datetime()
    local updated_time = update_time or created_time
    
    if config.header_format == "full" then
        header_content = {
            template[1],
            template[2],
            template[3],
            template[4]:format(filename),
            template[5],
            template[6]:format(config.user, config.mail),
            template[7],
            template[8]:format(created_time, config.user),
            template[9]:format(updated_time, config.user),
            template[10],
            template[11],
            template[12]
        }
    else
        header_content = {
            template[1],
            template[2]:format(filename),
            template[3]:format(config.user, config.mail),
            template[4],
            template[5]:format(created_time, config.user),
            template[6]:format(updated_time, config.user),
            template[7]
        }
    end
    
    return header_content
end

-- Get first function line number
local function get_first_function_line()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    for i, line in ipairs(lines) do
        if line:match("^%s*[a-zA-Z_][a-zA-Z0-9_]*%s*%([^)]*%)%s*{?$") or 
           line:match("^%s*int%s+main%s*%(") or
           line:match("^%s*static%s+") or
           line:match("^%s*void%s+") then
            return i - 1  -- Convert to 0-based indexing
        end
    end
    return 0
end

-- Insert header at beginning of file
local function insert_header()
    if has_header() then
        vim.notify("42 header already exists", vim.log.levels.WARN)
        return false
    end
    
    local filename = vim.fn.expand("%:t")
    local datetime = get_datetime()
    local header_lines = generate_header(filename, datetime, datetime)
    
    -- Insert at beginning of file
    vim.api.nvim_buf_set_lines(0, 0, 0, false, header_lines)
    
    vim.notify("42 header inserted!", vim.log.levels.INFO)
    return true
end

-- Update existing header
local function update_header()
    if not has_header() then
        vim.notify("No 42 header found, inserting new one", vim.log.levels.INFO)
        return insert_header()
    end
    
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local filename = vim.fn.expand("%:t")
    local new_datetime = get_datetime()
    
    -- Find and update the Updated line
    for i, line in ipairs(lines) do
        if line:match("Updated:") then
            if config.header_format == "full" then
                lines[i] = ("/*   Updated: %s by %-20.20s ###   ########.fr       */"):format(new_datetime, config.user)
            else
                lines[i] = ("/*   Updated: %s by %-20.20s ###   ########.fr       */"):format(new_datetime, config.user)
            end
            break
        end
    end
    
    -- Update the entire buffer
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.notify("42 header updated!", vim.log.levels.INFO)
    return true
end

-- Insert/update header
local function insert_or_update_header()
    if has_header() then
        update_header()
    else
        insert_header()
    end
end

-- Setup function for user configuration
function M.setup(user_config)
    config = vim.tbl_deep_extend("force", default_config, user_config or {})
    
    -- Create user commands
    vim.api.nvim_create_user_command("Stdheader", insert_or_update_header, { 
        desc = "Insert or update 42 header" 
    })
    
    vim.api.nvim_create_user_command("StdheaderInsert", insert_header, { 
        desc = "Insert new 42 header" 
    })
    
    vim.api.nvim_create_user_command("StdheaderUpdate", update_header, { 
        desc = "Update existing 42 header" 
    })
    
    vim.api.nvim_create_user_command("42SetUser", function(opts)
        if opts.args and #opts.args > 0 then
            config.user = opts.args
            vim.notify("42 user set to: " .. config.user, vim.log.levels.INFO)
        else
            vim.notify("Current 42 user: " .. config.user, vim.log.levels.INFO)
        end
    end, { 
        nargs = "?",
        desc = "Set or show 42 username" 
    })
    
    vim.api.nvim_create_user_command("42SetMail", function(opts)
        if opts.args and #opts.args > 0 then
            config.mail = opts.args
            vim.notify("42 email set to: " .. config.mail, vim.log.levels.INFO)
        else
            vim.notify("Current 42 email: " .. config.mail, vim.log.levels.INFO)
        end
    end, { 
        nargs = "?",
        desc = "Set or show 42 email" 
    })
    
    vim.api.nvim_create_user_command("42Format", function(opts)
        if opts.args and (opts.args == "full" or opts.args == "minimal") then
            config.header_format = opts.args
            vim.notify("42 header format set to: " .. config.header_format, vim.log.levels.INFO)
        else
            vim.notify("Current 42 header format: " .. config.header_format, vim.log.levels.INFO)
        end
    end, { 
        nargs = "?",
        desc = "Set or show header format (full/minimal)" 
    })
    
    -- Set default key bindings
    vim.keymap.set('n', '<F1>', insert_or_update_header, { desc = "Insert/update 42 header" })
    vim.keymap.set('n', '<leader>h', insert_or_update_header, { desc = "Insert/update 42 header" })
    vim.keymap.set('n', '<leader>hi', insert_header, { desc = "Insert new 42 header" })
    vim.keymap.set('n', '<leader>hu', update_header, { desc = "Update existing 42 header" })
    
    -- Set global variables for compatibility
    vim.g.user42 = config.user
    vim.g.mail42 = config.mail
end

-- Export functions for external use
M.insert_header = insert_header
M.update_header = update_header
M.insert_or_update_header = insert_or_update_header
M.has_header = has_header

return M