--[[

Author: tochonement
Email: tochonement@gmail.com

23.07.2021

--]]

sap.webicon = sap.webicon or {}
sap.webicon.cache = sap.webicon.cache or {}
sap.webicon.queue = sap.webicon.queue or {}
sap.webicon.nameCache = sap.webicon.nameCache or {}
sap.webicon.proxy = "https://proxy.duckduckgo.com/iu/?u="

local webicon = sap.webicon
local dirName = "webicons"
local basePath = dirName .. "/"

if not file.Exists(dirName, "DATA") then
    file.CreateDir(dirName)
end

function webicon.GetName(url)
    if (webicon.nameCache[url]) then
        return webicon.nameCache[url]
    else
        local crc = util.CRC(url)
        local format = string.match(url, ".%w+$")
        local name = crc .. format

        webicon.nameCache[url] = name

        return name
    end
end

function webicon.FindInQueue(name)
    for index, data in ipairs(webicon.queue) do
        if (data.name == name) then
            return data, index
        end
    end
end

function webicon.Create(url, parameters)
    local name = webicon.GetName(url)
    local successToLoad = webicon.Load(name, parameters)
    local foundInQueue = webicon.FindInQueue(name)

    if not successToLoad and not foundInQueue then
        table.insert(webicon.queue, {
            url = url,
            name = name,
            parameters = parameters
        })
    end

    return name
end

function webicon.Download(url, name, successCallback, failCallback)
    url = webicon.proxy .. url
    http.Fetch(url, function(body)
        file.Write(basePath .. name, body)

        if successCallback then
            successCallback()
        end
    end, function(error)
        if failCallback then
            failCallback(error)
        end
    end)
end

function webicon.Load(name, parameters)
    if webicon.cache[name] then
        return true
    end

    local path = "data/" .. basePath .. name

    if file.Exists(path, "GAME") then
        webicon.cache[name] = Material(path, parameters)

        return true
    end

    return false
end

function webicon.Get(name)
    return webicon.cache[name]
end

function webicon.Draw(name, x, y, w, h, color)
    local material = webicon.Get(name)
    if material then
        surface.SetDrawColor(color or color_white)
        surface.SetMaterial(material)
        surface.DrawTexturedRect(x, y, w, h)
    end
end

function webicon.DrawRotated(name, x, y, w, h, color, rotation)
    local material = webicon.Get(name)
    if material then
        surface.SetDrawColor(color or color_white)
        surface.SetMaterial(material)
        surface.DrawTexturedRectRotated(x, y, w, h, rotation)
    end
end

timer.Create("sap.webicon.ProcessQueue", 0.2, 0, function()
    if (#webicon.queue > 0) then
        local data = table.remove(webicon.queue, 1)
        local url = data.url
        local name = data.name

        webicon.Download(url, name, function()
            webicon.Load(name, data.parameters)
        end, function(error)
            print("Failed to load: ", url, "\n", error)
        end)
    end
end)

concommand.Add("sap_webicon_clearcache", function()
    sap.webicon.cache = {}
end)