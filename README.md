# stack-trace.nvim
This plugin allows you to easily create a trace of your code stack as you go-to-definition
your way through a codebase. Each line item in the stack is called a "stop."

For example, if you have code like:

```python
# api/handlers/LoginHandler.py
from services.auth import authorization_service
from services.analytics import analytics_service

class LoginHandler:
    def post(self, request):
        authorization_service.check_user(user)
        user.last_login = Time.now()
        user.save()
        analytics_service.trigger_event_for(user)
        ...

# services/auth/authorization_service.py
from services.auth import compliance_service

def check_user(user):
    compliance_service.validate_loginable(user)


# services/auth/compliance_service.py
def validate_loginable(user):
    return True

# services/analytics/analytics_service.py
def trigger_event_for(user):
    pass
```

your stack trace might have the following stops:

```
LoginHandler
    post
        authorization_service.check_user
            compliance_service.validate_loginable
        analytics_service.trigger_event_for
```


## Installation
Use your favorite plugin manager. For example, Lazy
```lua
-- init.lua
require("lazy").setup {
    {
        "AyMeeko/stack-trace.nvim",
        event = "VeryLazy"
        dependencies = "nvim-treesitter/nvim-treesitter",
    },
}
```

## Additional Configuration
In my configuration, I've updated the LSP callback for go-to-definition like [this](https://github.com/AyMeeko/dotfiles/blob/main/nvim/lua/plugins/lsp/callbacks.lua) so that it opens the new file in a new tab.

This allows me to additionally configure my `add_stop` and `return_stop` methods to go-to-definition
and close tab, respectively, making the tracing experience marginally different than if I weren't
using this plugin.

Using [Legendary.nvim](https://github.com/mrjones2014/legendary.nvim), this looks like the following
```lua
{"ta", function()
  require("stack-trace").add_stop()
  vim.lsp.buf.definition()
end, description = "[T]race [a]dd"},
{"ts", function()
  require("stack-trace").show_stops()
end, description = "[T]race [s]how"},
{"tc", function()
  require("stack-trace").clear_stops()
end, description = "[T]race [c]lear"},
{"tr", function()
  require("stack-trace").return_stop()
  if (vim.fn.tabpagenr() > 1) then
    vim.cmd.tabclose()
  end
end, description = "[T]race [r]eturn"},
```

## Available Commands

There are 4 available methods in this plugin.

### Add Stop
When this method is called, the plugin will look at the node under the cursor and add it to a list.

```lua
require("stack-trace").add_stop()
```

### Return Stop
As you traverse your code, you can add a stop to indicate walking up the stack with
```lua
require("stack-trace").return_stop()
```


### Show Stops
This method allows you to see which stops you've added to your list.

```lua
require("stack-trace").show_stops()
```

### Clear Stops
This method clears out the list of stops.

```lua
require("stack-trace").clear_stops()
```

## Creating Hotkeys

No mappings are shipped by default. If you'd like to configure them, something like this will work:
```lua
vim.keymap.set("n", "<leader>ta", require("stack-trace").add_stop(), {})
vim.keymap.set("n", "<leader>tr", require("stack-trace").return_stop(), {})
vim.keymap.set("n", "<leader>ts", require("stack-trace").show_stops(), {})
vim.keymap.set("n", "<leader>tc", require("stack-trace").clear_stops(), {})
```
