--- YaGames - Yandex Games for Defold.
-- @module sitelock

local M = {}

M.domains = { "yandex.net", "localhost", "544727.selcdn.ru" }

local function ends_with(s, substr)
    return s:sub(-#substr) == substr
end

--- Adds a domain to the list
-- @tparam string domain
function M.add_domain(domain)
    table.insert(M.domains, domain)
end

--- Compares the current hostname to the domains from the list.
-- @treturn boolean
function M.verify_domain(domains)
   -- if (not M.is_release_build()) then return true end
    if not html5 then
        return true
    end
    local current_domain = html5.run("window.location.hostname")
    for key, value in ipairs(domains or M.domains) do
        if value == current_domain or ends_with(current_domain, "." .. value) then
            return true
        end
    end
    return false
end

function M.verify_domains_crazy()
    if not html5 then
        return true
    end
    local current_domain = html5.run("window.location.hostname")
    return ends_with(current_domain,".1001juegos.com") or string.find(current_domain, ".crazygames.")
end

function M.verify_domains_yandex()
    return M.verify_domain({"yandex.net"})
end


function M.verify_domain_match(domains)
    if (not M.is_release_build()) then return true end
    if not html5 then
        return true
    end
    local current_domain = html5.run("window.location.hostname")
    for key, value in ipairs(domains or M.domains) do
        if value == current_domain or string.match(current_domain,value) then
            return true
        end
    end
    return false
end

--- Returns the current domain name (hostname).
-- @treturn string
function M.get_current_domain()
    if html5 then
        return html5.run("window.location.hostname")
    else
        return ""
    end
end

--- Checks the build type
-- @treturn boolean
function M.is_release_build()
    return not sys.get_engine_info().is_debug
end

return M
