--[[
    pseudo code :

    struct_t = {
        [VoteStart] = {
            'unique_id' = fn,
            'another_id' = fn2
        },
        ...
    }

    usage :

    local event_handler = function( proton )
    local id, data_bits, data_bytes = proton:GetID(), proton:GetDataBits(), proton:GetDataBytes()

    local s = struct_t[id]
    if not (type(s) == "table") then return end  -- check if table exists
    for k, v in pairs(s) do
        local fn = type( s[k] ) == "function" and s[k] -- call every fnc in its table
        local ret = fn()
        proton:Reset()
    end

    end

    --[[ why this? 
    syntax sugar
    can invoke multiple callbacks without function chain hell
    
    + method in binding event :
    struct_t.bind( VoteStart, 'unique_id', fn )
    struct_t.unbind( VoteStart, 'unique_id')

    - no oop, metamethod / reason : more complicated than it already should have been

    if you have better idea, go pr, i would like to know --
]] -- 
local insert_name_callback = {}

insert_name_callback.unbind = function( id, unique )
    local s = insert_name_callback[id]
    if type( s ) ~= "table" then
        print(
            table.concat( { ".unbind fails to remove callback:", tostring( unique ), "table: ", tostring( id ) }, " " ) )
        return
    end
    s[unique] = undef
    return true
end

insert_name_callback.bind = function( id, unique, callback )
    local s = insert_name_callback[id]
    if type( s ) ~= "table" then
        print( table.concat( { ".bind fails to create callback:", tostring( unique ), "table: ", tostring( id ) }, " " ) )
        return
    end
    if (type( unique ) == 'function') then
        callback = unique
        unique = tostring( math.randomseed( os.time() ) )
    end
    s[unique] = callback

    return unique
end

-- test
