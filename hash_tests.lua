local profiler = require("profile")
local http_request = require("http.request")
local json = require("lunajson")

--- Generate a short string of all the arguments
local function hash(...)
    local args = {...}
    local str = ""
    local _hash = 8129

    -- Given a series of string(able) arguments, generate a hash where each character is converted to the ASCII value of the character

    for i = 1, #args do
        local arg = tostring(args[i])

        for j = 1, #arg do
            local char = string.sub(arg, j, j)
            local byte = string.byte(char)

            -- hash = ((hash << 5) + hash) + j
            _hash = (31 * _hash + byte) % 2^32
        end
    end

    -- Then, convert the hash to a base64 string
    local base64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local base64_str = ""

    while _hash > 0 do
        local remainder = _hash % 64
        _hash = math.floor(_hash / 64)

        base64_str = string.sub(base64, remainder, remainder) .. base64_str
    end

    return base64_str
end


profiler.start()

local apiUrl = "https://random-word-api.herokuapp.com/word?number=100"

-- Get a list of english words from the api
local headers, stream = http_request.new_from_uri(apiUrl):go()
local body = stream:get_body_as_string()
local words = json.decode(body)

-- Generate a hash for random combinations of words
for j = 1, 100 do
    local word1 = words[math.random(1, #words)]
    local word2 = words[math.random(1, #words)]
    local word3 = words[math.random(1, #words)]
    local word4 = words[math.random(1, #words)]
    local word5 = words[math.random(1, #words)]

    local hsh = hash(word1, word2, word3, word4, word5)
    print(string.format("%s %s %s %s %s = %s", word1, word2, word3, word4, word5, hsh))
end

profiler.stop()

local result = profiler.report(20)
print(result)