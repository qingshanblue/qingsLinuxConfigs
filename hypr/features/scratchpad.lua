-- 特殊工作区 / 便签页 (SCRATCHPAD / SPECIAL WORKSPACES)
-- 提供 magic / maho / mofa 三个特殊工作区的层开关、点名呼出与轮换逻辑
-- 供快捷键与触控板手势共用

local specialOrder = { "magic", "maho", "mofa" }
local lastSpecial  = "magic"

-- 将"最近使用的特殊区"镜像到文件, 供外部脚本读取
local LAST_SPECIAL_FILE = "/dev/shm/hypr-last-special"
local function rememberSpecial(name)
    lastSpecial = name
    local f = io.open(LAST_SPECIAL_FILE, "w")
    if f then
        f:write(name)
        f:close()
    end
end

-- 从工作区对象/字符串里取出特殊区名 (去掉 "special:" 前缀)
local function specialNameOf(ws)
    if ws == nil then return nil end
    local name
    if type(ws) == "string" then
        name = ws
    else
        -- 兜底防 API 差异: userdata __index 属性或 tostring
        local ok, n = pcall(function() return ws.name end)
        if ok and n ~= nil then
            name = tostring(n)
        else
            name = tostring(ws):match("special:([%w_%-]+)")
        end
    end
    if name ~= nil then name = name:gsub("^special:", "") end
    return name
end

-- 当前聚焦显示器激活的特殊区名; 没开则返回 nil
local function getActiveSpecialName()
    return specialNameOf(hl.get_active_special_workspace())
end

-- 找到正在显示特殊区 name 的显示器对象
local function specialHolder(name)
    for _, m in ipairs(hl.get_monitors()) do
        local sp = m.active_special_workspace
        if sp ~= nil and specialNameOf(sp) == name then
            return m
        end
    end
    return nil
end

-- 获取相邻特殊区 (首尾循环)
local function adjacentSpecial(cur, dir)
    local idx = 0
    for i, name in ipairs(specialOrder) do
        if cur == name then idx = i break end
    end
    if idx == 0 then return nil end
    return specialOrder[((idx - 1 + dir) % #specialOrder) + 1]
end

-- 让指定特殊区出现并聚焦
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

-- 点名/层开关: 已在当前屏 → 关闭; 已在别屏 → 聚焦该屏; 未开 → 当前屏打开
local function invokeSpecial(name)
    local cur = hl.get_active_monitor()
    local holder = specialHolder(name)
    if holder ~= nil and holder.name == cur.name then
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

-- 工作区导航: dir=1 下一个, -1 上一个
-- 有特殊区开着时在 magic/maho/mofa 之间循环; 未开时导航常规工作区
local function navWorkspace(dir)
    local cur = getActiveSpecialName()
    if cur == nil then
        if dir == 1 then
            hl.dispatch(hl.dsp.focus({ workspace = "e+1" }))
        else
            hl.dispatch(hl.dsp.focus({ workspace = "e-1" }))
        end
        return
    end
    local nxt = adjacentSpecial(cur, dir)
    if nxt == nil then return end
    activateSpecial(nxt)
end

-- 将窗口跨工作区转移
-- 有特殊区开着时扔到相邻特殊区(人跟随过去); 未开时转移到相邻常规工作区
local function moveWindowNav(dir)
    local cur = getActiveSpecialName()
    if cur == nil then
        if dir == 1 then
            hl.dispatch(hl.dsp.window.move({ workspace = "e+1" }))
        else
            hl.dispatch(hl.dsp.window.move({ workspace = "e-1" }))
        end
        return
    end
    local nxt = adjacentSpecial(cur, dir)
    if nxt == nil then return end
    activateSpecial(nxt)
    hl.dispatch(hl.dsp.window.move({ workspace = "special:" .. nxt }))
end

-- 点名开关 (Z / X / C 对应 magic / maho / mofa)
local function toggleSpecialNamed(name)
    invokeSpecial(name)
end

-- 特殊区总开关 (Super + ` / Super + 中键 / 四指手势): 开着则收起; 否则呼出最近使用的
local function toggleSpecialLayer()
    local cur = getActiveSpecialName()
    if cur ~= nil then
        hl.dispatch(hl.dsp.workspace.toggle_special(cur))
    else
        invokeSpecial(lastSpecial)
    end
end

return {
    navWorkspace         = navWorkspace,
    moveWindowNav        = moveWindowNav,
    toggleSpecialLayer   = toggleSpecialLayer,
    toggleSpecialNamed   = toggleSpecialNamed,
    getActiveSpecialName = getActiveSpecialName,
    last                 = function() return lastSpecial end,
}
