local json = require "libs.json"

local base_url = "https://unpkg.com"

local M = {}
M.is_initialized = false

local function vk_init(response, callback)
    if response.headers.location then
        local location = response.headers.location
        http.request(base_url .. location, 'GET', function(_, _, __response)
            vk_init(__response, callback)
        end)
    end
    if response.status == 404 then
        error("vkbridge package cannot be found (invalid version)", 2)
    end

    html5.run(response.response)
    html5.run("vkBridge.subscribe(msg => JsToDef.send(msg.detail.type, msg.detail.data))")
    M.is_initialized = true
    if callback then
        callback()
    end
end

function M.init(version, callback)
    if not html5 then
        return
    end

    local location = "/@vkontakte/vk-bridge/dist/browser.min.js"
    if version then
        location = string.format("/@vkontakte/vk-bridge@%s/dist/browser.min.js", version)
    end
    http.request(base_url .. location, 'GET', function(_, _, response)
        vk_init(response, callback)
    end)
end

function M.get_start_params()
    if not html5 then
        return
    end

    local param_string = html5.run("document.location.search")

    local params = {}
    for k, v in param_string:gmatch("([^=?&]*)=([^=?&]*)") do
        if v:find(',') then
            params[k] = {}
            for val in v:gmatch("%w+") do
                params[k][#params[k] + 1] = val
            end
        else
            params[k] = v
        end
    end

    return params
end

function M.send(method, params)
    if not M.is_initialized then
        return
    end

    if params == nil or next(params) == nil then
        params = "{}"
    else
        params = json.encode(params)
    end
    html5.run(string.format("vkBridge.send('%s', %s)", method, params))
end

function M.interstitial_native()
    print("vk interstitial_native")
    -- luacheck: push ignore
    html5.run('vkBridge.send("VKWebAppShowNativeAds", {ad_format:"interstitial"})'
            .. '.then(data => JsToDef.send("AdsResult", {success:true})).catch(error => JsToDef.send("AdsResult", {success:false,error:error}))')
    -- luacheck: pop
end

function M.reward_native()
    print("vk interstitial_native")
    -- luacheck: push ignore
    html5.run('vkBridge.send("VKWebAppShowNativeAds", {ad_format:"reward"})'
            .. '.then(data => JsToDef.send("AdsResult", {success:data.result})).catch(error => JsToDef.send("AdsResult", {success:false,error:error}))')
    -- luacheck: pop
end

function M.supports(method)
    if not M.is_initialized then
        return
    end
    local result = html5.run(string.format("vkBridge.supports('%s')", method))
    return result == "true" or result == true
end

function M.is_web_view()
    if not M.is_initialized then
        return
    end
    return html5.run("vkBridge.isWebView()")
end

function M.is_iframe()
    if not M.is_initialized then
        return
    end
    return html5.run("vkBridge.isIframe()")
end

function M.is_embedded()
    if not M.is_initialized then
        return
    end
    return html5.run("vkBridge.isEmbedded()")
end

function M.is_standalone()
    if not M.is_initialized then
        return
    end
    return html5.run("vkBridge.isStandalone()")
end

return M
