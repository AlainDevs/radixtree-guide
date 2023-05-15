local _M = {}

_M.routes00_GET = function()
    return {type = "json", data = {testing = "ok"}}
end

_M.routes = {
    {
        paths = {"/internal/test/01"},
        metadata = function()
            return _M.routes00_GET()
        end,
    },
}

return _M