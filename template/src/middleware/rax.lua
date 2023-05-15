-- @module rax.lua
local _M = {}
local radix = require("resty.radixtree")
local internal = require("routes.internal")
local cjson = require("cjson")
local template = require "resty.template.safe"
local ngx = ngx
local redirect = ngx.redirect
local capture = ngx.location.capture
local print = ngx.print
local exec = ngx.exec
local type = type

local function table_merge(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function _M.routes00_GET()
    -- return {type = "html", template = "", data = {}}
    return {type = "html", template = "<h1>{{message}}</h1>", data = {message = "testing ok"}}
end

local routes = {
    {
        paths = {"/"},
        metadata = function()
            return _M.routes00_GET()
        end
    },
}

routes = table_merge(routes,internal.routes)
_M.rx = radix.new(routes)

function _M.run()
    -- local rx = radix.new(routes)
    local uri = ngx.var.uri
    -- local method = ngx.req.get_method()
    local res = _M.rx:match(uri)
    if type(res) == "function" then
        local raw = res()
        if type(raw) == "table" then
            if raw["type"] == "html" then
                return template.render(raw["template"], raw["data"])
            elseif raw["type"] == "json" then
                ngx.header['Content-Type'] = 'application/json; charset=utf-8'
                return print(cjson.encode(raw["data"]))
            elseif raw["type"] == "redirect" then
                return redirect(raw["url"] or "/")
            elseif raw["type"] == "exec" then
                return exec(raw["url"] or "/")
            elseif raw["type"] == "capture" then
                return print(capture(raw["url"] or "/").body)
            end
        else
            return raw
        end
    else
        template.render("error.html", { message = "404 not found." })
    end
end

return _M