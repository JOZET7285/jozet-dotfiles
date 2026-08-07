#!/bin/bash
# Carrusel de workspaces especiales: normal -> music -> terminal -> special -> normal
# Uso: carrusel.sh {up|next|prev}
DIR="${1:-up}"

hyprctl eval "local DIR = '$DIR'
local ORDER = { 'music', 'terminal', 'special' }
local current = hl.get_active_special_workspace()

local function strip(n)
    return n:sub(1, 8) == 'special:' and n:sub(9) or n
end

if not current then
    -- Workspace normal
    if DIR == 'up' then
        hl.dispatch(hl.dsp.workspace.toggle_special(ORDER[1]))
    elseif DIR == 'next' then
        hl.dispatch(hl.dsp.focus({ workspace = 'm+1' }))
    else
        hl.dispatch(hl.dsp.focus({ workspace = 'm-1' }))
    end
else
    local name = strip(current.name)
    local idx = 0
    for i, n in ipairs(ORDER) do
        if n == name then idx = i end
    end
    if DIR == 'prev' then
        if idx <= 1 then
            -- Primer especial: cerrarlo y volver a normal
            hl.dispatch(hl.dsp.workspace.toggle_special(name))
        else
            hl.dispatch(hl.dsp.workspace.toggle_special(ORDER[idx - 1]))
        end
    elseif idx == 0 or idx == #ORDER then
        -- Último especial (o desconocido): cerrarlo y volver a normal
        hl.dispatch(hl.dsp.workspace.toggle_special(name))
    else
        hl.dispatch(hl.dsp.workspace.toggle_special(ORDER[idx + 1]))
    end
end"
