local constants = require('constants')

local draw = {}

-- Decides whether to draw the skills-tab or the inventory tab based on tab_index.
-- inv_selected is used for draw.context_menu to let it know which option the mouse is on.
draw.tabs = function(tab_index, inv_selected, player, inventory)
    love.graphics.draw(imgs.inventoryIcon, 785, 280)
    love.graphics.draw(imgs.skillsIcon, 905, 280)
    love.graphics.setColor(constants.tabs.selected_color)
    love.graphics.line(795 + (120 * tab_index), 314, 890 + (120 * tab_index), 314)
    love.graphics.setColor(1, 1, 1, 1)
    
    if tab_index == 0 then
        draw.inventory(inventory)
        draw.context_menu(inv_selected)
    elseif tab_index == 1 then
        draw.skills(player.attributes)
    elseif tab_index == 2 then
        draw.equipment(player.equipment)
    end
end

-- Will only be drawn if tab_index is set to 0. Is called by draw.tabs(tab_index).
draw.inventory = function(inventory)
    for i = 0,3,1 do
        for j = 0,2,1 do
            love.graphics.draw(imgs.invslot, constants.inventory.origin_x + (j * constants.inventory.slot_width),
                                constants.inventory.origin_y + (i * constants.inventory.slot_height))
                                
            local item = inventory.inv[1 + j + i * 3]
            if item then
                local x, y = 800 + (j * 80), 337 + (i * 80)
                local offset = item.quantity > 9 and 4 or 0
                love.graphics.draw(item.image, x, y)
                if not item.is_wearable then
                    love.graphics.print(item.quantity, 841 - offset + (j * 80), 335 + (i * 80))
                end
            end
        end
    end
end

-- Draws a context_menu if a player right-clicks on a slot in the inventory tab.
draw.context_menu = function(inv_selected)
    if inv_selected.clicked then
        local x
        local y = inv_selected.y
        
        if inv_selected.mirror then
            x = inv_selected.x - constants.context_menu.width
        else
            x = inv_selected.x
        end
        
        love.graphics.rectangle("fill", x, y, constants.context_menu.width, constants.context_menu.height)
        
        love.graphics.setColor(constants.context_menu.hover_color)
        if inv_selected.hover[1] then
            love.graphics.rectangle("fill", x, y, constants.context_menu.width, constants.context_menu.sub_height)
        elseif inv_selected.hover[2] then
            love.graphics.rectangle("fill", x, y + constants.context_menu.sub_height, constants.context_menu.width, constants.context_menu.sub_height)
        elseif inv_selected.hover[3] then
            love.graphics.rectangle("fill", x, y + constants.context_menu.sub_height * 2, constants.context_menu.width, constants.context_menu.sub_height)
        end
        love.graphics.setColor(1, 1, 1, 1)
        
        x = x + 5
        love.graphics.print({{0, 0, 0, 255}, "Use"}, x, y + 2, 0, 0.8)
        love.graphics.print({{0, 0, 0, 255}, "Drop"}, x, y + 19, 0, 0.8)
        love.graphics.print({{0, 0, 0, 255}, "Cancel"}, x, y + 36, 0, 0.8)
    end
end

-- Will only be drawn if tab_index is set to 1. Is called by draw.tabs(tab_index).
draw.skills = function(ply_attr)
    love.graphics.draw(imgs.skillsslot, 785, 320)
    local old_font = love.graphics.getFont()
    love.graphics.setFont(constants.fonts.default)
    love.graphics.setColor(constants.tabs.selected_color)
    love.graphics.print("Strength:", 815, 345)
    love.graphics.print(ply_attr.strength, 940, 345)
    love.graphics.print("Intellect:", 815, 390)
    love.graphics.print(ply_attr.intellect, 940, 390)
    love.graphics.print("Speed:", 815, 435)
    love.graphics.print(ply_attr.speed, 940, 435)
    love.graphics.print("Charisma:", 815, 480)
    love.graphics.print(ply_attr.charisma, 940, 480)
    love.graphics.print("Agility:", 815, 525)
    love.graphics.print(ply_attr.agility, 940, 525)
    love.graphics.print("Spirit:", 815, 570)
    love.graphics.print(ply_attr.spirit, 940, 570)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(old_font)
end

draw.bars = function(health, mana)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("line", 250, 540, 400, 40)
    local health_length = 398 * (health/100)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.rectangle("fill", 251, 541, health_length, 38)
    love.graphics.setColor(0, 0, 0, 1)
    
    love.graphics.rectangle("line", 250, 590, 400, 40)
    local mana_length = 398 * (mana/100)
    love.graphics.setColor(0, 0, 1, 1)
    love.graphics.rectangle("fill", 251, 591, mana_length, 38)
    
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(health.."/100", 440, 552)
    love.graphics.print(mana.."/100", 440, 602)
    
    love.graphics.setColor(1, 1, 1, 1)
end

draw.equipment = function(equipment)
    local points = {{x=785+90, y=320+10}, {x=785+90, y=320+90}, {x=785+90, y=320+170},
                    {x=800, y=320+130}, {x=950, y=320+130}, {x=785+90, y=320+250}}

    love.graphics.draw(imgs.skillsslot, 785, 320)
    
    for k, v in ipairs(points) do
        love.graphics.draw(imgs.invslot, v.x, v.y, 0, 0.75, 0.75)
        local armor = equipment[equipment.slots[k]]
        if armor then
            love.graphics.draw(equipment[equipment.slots[k]].image, v.x + 12, v.y + 12, 0, 0.75, 0.75)
        end
    end
end

draw.init_particles = function()
    psystem = love.graphics.newParticleSystem(imgs.fireparticle, 5)
    psystem:setParticleLifetime(1, 2) -- Particles live at least 2s and at most 5s.
    psystem:setEmissionRate(4)
    psystem:setSizeVariation(1)
    psystem:setLinearAcceleration(-20, -20, 20, 20) -- Random movement in all directions.
    psystem:setColors(1, 1, 1, 1, 1, 1, 1, 0) -- Fade to transparency.
    return psystem
end

return draw
