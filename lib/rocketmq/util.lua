local function search(k, plist)
    for i = 1, #plist do
        local v = plist[i][k]
        if v then return v end
    end
end

return {
    search = search
}