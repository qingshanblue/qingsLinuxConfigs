-- 特殊工作区 (scratchpad) 辅助逻辑:供快捷键与手势共用

-- ═══ 特殊工作区辅助逻辑(供下面快捷键/手势共用)═══

-- 三个特殊工作区的顺序(用于循环)
local specialOrder = { "magic", "maho", "mofa" }
-- 最近使用的特殊工作区(呼出类操作的目标)
local lastSpecial = "magic"

-- 把"最近使用的特殊区"镜像到文件,供外部脚本读取(Super+` 的语义)
local LAST_SPECIAL_FILE = "/dev/shm/hypr-last-special"
local function rememberSpecial(name)
    lastSpecial = name
    local f = io.open(LAST_SPECIAL_FILE, "w")
    if f then
        f:write(name)
        f:close()
    end
end

-- 从工作区对象/字符串里取出特殊区名(去掉 "special:" 前缀);取不到返回 nil
local function specialNameOf(ws)
    if ws == nil then return nil end
    local name
    if type(ws) == "string" then
        name = ws
    else
        -- 实测返回 userdata(HL.Workspace 对象),属性经 __index 暴露;多重兜底防 API 差异
        local ok, n = pcall(function() return ws.name end)
        if ok and n ~= nil then
            name = tostring(n)
        else
            -- 兜底:从 "HL.Workspace(-97:special:mofa)" 里提取 mofa
            name = tostring(ws):match("special:([%w_%-]+)")
        end
    end
    if name ~= nil then name = name:gsub("^special:", "") end
    return name
end

-- 当前(聚焦屏)激活的特殊区名;没开则返回 nil
local function getActiveSpecialName()
    return specialNameOf(hl.get_active_special_workspace())
end

-- 找到正在显示特殊区 name 的显示器对象;没有则返回 nil
local function specialHolder(name)
    for _, m in ipairs(hl.get_monitors()) do
        local sp = m.active_special_workspace
        if sp ~= nil and specialNameOf(sp) == name then
            return m
        end
    end
    return nil
end

-- 当前特殊区的相邻项(首尾相接);cur 不在 specialOrder 内则返回 nil
local function adjacentSpecial(cur, dir)
    local idx = 0
    for i, name in ipairs(specialOrder) do
        if cur == name then idx = i break end
    end
    if idx == 0 then return nil end
    return specialOrder[((idx - 1 + dir) % #specialOrder) + 1]
end

-- 让特殊区 name "出现并聚焦":已在别的屏 → 聚焦那屏;否则在当前屏打开
local function activateSpecial(name)
    local cur = hl.get_active_monitor()
    local holder = specialHolder(name)
    if holder ~= nil and holder.name ~= cur.name then
        hl.dispatch(hl.dsp.focus({ monitor = holder.name }))
    else
        hl.dispatch(hl.dsp.workspace.toggle_special(name))
    end
    rememberSpecial(name)
end

-- 点名/层开关:已在当前屏 → 关闭;已在别的屏 → 聚焦那屏;都没开 → 当前屏打开
local function invokeSpecial(name)
    local cur = hl.get_active_monitor()
    local holder = specialHolder(name)
    if holder ~= nil and holder.name == cur.name then
        -- 当前屏已开 → 关闭(不改"最近使用")
        hl.dispatch(hl.dsp.workspace.toggle_special(name))
        return
    end
    rememberSpecial(name)
    if holder ~= nil then
        hl.dispatch(hl.dsp.focus({ monitor = holder.name }))
    else
        hl.dispatch(hl.dsp.workspace.toggle_special(name))
    end
end

-- 切工作区:dir=1 下一个,-1 上一个。有特殊区开着时在 magic/maho/mofa 之间循环;未开时切常规工作区
local function navWorkspace(dir)
    local cur = getActiveSpecialName()
    if cur == nil then
        if dir == 1 then
            -- 常规:下一个工作区
            hl.dispatch(hl.dsp.focus({ workspace = "e+1" }))
        else
            -- 常规:上一个工作区
            hl.dispatch(hl.dsp.focus({ workspace = "e-1" }))
        end
        return
    end
    local nxt = adjacentSpecial(cur, dir)
    if nxt == nil then return end
    activateSpecial(nxt)
end

-- 扔窗口:有特殊区开着时扔到相邻特殊区(人跟过去);未开时扔到相邻常规工作区
local function moveWindowNav(dir)
    local cur = getActiveSpecialName()
    if cur == nil then
        if dir == 1 then
            -- 常规:下一个工作区
            hl.dispatch(hl.dsp.window.move({ workspace = "e+1" }))
        else
            -- 常规:上一个工作区
            hl.dispatch(hl.dsp.window.move({ workspace = "e-1" }))
        end
        return
    end
    local nxt = adjacentSpecial(cur, dir)
    if nxt == nil then return end
    -- 先让目标特殊区出现/聚焦(已在别屏则聚焦那屏),再把窗口移进去
    activateSpecial(nxt)
    hl.dispatch(hl.dsp.window.move({ workspace = "special:" .. nxt }))
end

-- 点名 toggle(Z/X/C 用)
local function toggleSpecialNamed(name)
    invokeSpecial(name)
end

-- 特殊区层开关:当前屏开着则收起;否则呼出最近使用的(已在别屏则聚焦那屏)
local function toggleSpecialLayer()
    local cur = getActiveSpecialName()
    if cur ~= nil then
        hl.dispatch(hl.dsp.workspace.toggle_special(cur))
    else
        invokeSpecial(lastSpecial)
    end
end

return {
    navWorkspace          = navWorkspace,
    moveWindowNav         = moveWindowNav,
    toggleSpecialLayer    = toggleSpecialLayer,
    toggleSpecialNamed    = toggleSpecialNamed,
    getActiveSpecialName  = getActiveSpecialName,
    -- 最近使用的特殊区(手势等模块读取)
    last                  = function() return lastSpecial end,
}
