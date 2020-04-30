minetest.get_node_above = function ( pos, off )
        return minetest.get_node( { x = pos.x, y = pos.y + ( off or 1 ), z = pos.z } )
end

vector.offset = function ( pos, x, y, z )
        return { x = pos.x + x, y = pos.y + y, z = pos.z + z }
end

vector.offset_y = function ( pos, y )
        return { x = pos.x, y = pos.y + ( y or 1 ), z = pos.z }
end

vector.origin = { x = 0, y = 0, z = 0 }

math.clamp = function ( val, min, max )
        return val < min and min or val > max and max or val
end
