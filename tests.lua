local io = require("io")

-- The test runner
local runner = {
    tests = {},
    _writeFn = io.write,
    _writeLineFn = function(...)
        io.write(...)
        io.write("\n")
    end,
}
runner.write = runner._writeFn
runner.writeln = runner._writeLineFn


function runner.run_single(_test)
    -- local status, err = pcall(_test.operand)
    local fn = function()
        local success, err = xpcall(_test.operand, function(err)
            return debug.traceback(err, 9) -- Due to all the function calls to get here, we need to skip 9 frames of the stack
        end)

        return success, err
    end

    local time, success, err = runner.benchmark(fn)

    local msg = ""

    if success then
        msg = string.format("Test '%s' passed (%ims).\n", _test.descriptor, time)
    else
        msg = string.format("Test '%s' failed with error: \n\t%s\n", _test.descriptor, err)
    end

    return success, err, msg
end


function runner.run_tests()
    local test_count = #runner.tests
    local passing = 0
    local failing = 0

    runner.writeln(
        string.format("Running (%i) tests:", test_count)
    )

    -- TODO: Get output width?
    runner.writeln(
        string.rep('=', 80)
    )

    for _, test in ipairs(runner.tests) do
        -- local time, success, err, msg = runner.benchmark(runner.run_single, test)
        local success, err, msg = runner.run_single(test)

        if success then
            passing = passing + 1
        else
            failing = failing + 1
        end

        runner.write(msg)
        runner.writeln()
    end

    runner.writeln(
        string.rep('=', 80)
    )

    runner.writeln(string.format("Tests passed: %i", passing))
    runner.writeln(string.format("Tests failed: %i", failing))

    return failing == 0
end


function runner.benchmark(fn, ...)
    local start = os.clock()
    local results = {fn(...)}
    local stop = os.clock()
    return math.floor((stop - start) * 1000), table.unpack(results)
end


local function test(descriptor, operand)
    table.insert(
        runner.tests,
        {
            descriptor = descriptor,
            operand = operand
        }
    )
end








local Class = require("class")


local Set = Class.create("Set")
Set.ctor = function(self, values)
    self._values = {}
    for _, v in ipairs(values) do
        self._values[v] = true
    end
end

function Set.has(self, value)
    return self._values[value] ~= nil
end

function Set.add(self, value)
    self._values[value] = true
end

function Set.remove(self, value)
    self._values[value] = nil
end


test("Sanity", function()
    assert(true, "true isn't true!!!")
    assert(1 == 1, "1 does not equal 1!!!")
end)

test("Class creation: Set", function()

    local s1 = Set.new({ 10, 20, 30, 50 })

    assert(s1);
    assert(s1:has(10))
    s1:add("key")
    assert(s1:has("key"))

end)

test("Class.get", function()
    assert(false, "Class.get not implemented")
end)

test("Class.exists", function()
    assert(false, "Class.exists not implemented")
end)

test("Class.is_a", function()
    assert(false, "Class.is_a not implemented")
end)

test("Class.typeof", function()
    assert(false, "Class.typeof not implemented")
end)

test("Class.baseclass", function()
    assert(false, "Class.baseclass not implemented")
end)

test("Class.create", function()
    assert(false, "Class.create not implemented")
end)

test("Class.inherits", function()
    assert(false, "Class.inherits not implemented")
end)

test("Class.implements", function()
    assert(false, "Class.implements not implemented")
end)

test("Class.interface", function()
    assert(false, "Class.interface not implemented")
end)

test("Class.interface prototype", function()
    assert(false, "Class.interface.prototype not implemented")
end)

test("Class.fields", function()
    assert(false, "Class.fields not implemented")
end)

test("Class.methods", function()
    assert(false, "Class.methods not implemented")
end)


local total_time = runner.benchmark(runner.run_tests)
runner.writeln(string.format("Total time: %ims", total_time))


runner.writeln()


-- Determine the covereage of the tests for the Class module
-- Collect the functions that are in a table
local coverage = {}
for k, v in pairs(Class) do
    if type(v) == "function" then
        coverage[k] = false
    end
end

-- Find all tests with a name that matches a Class function
for _, test in ipairs(runner.tests) do
    local name = test.descriptor
    if not name:find(" ") then
        local s, e = string.find(name, "%.")
        if s then
            local key = string.sub(name, e+1, -1)
            coverage[key] = true
        end
    end
end

-- Then print out the coverage
local covered = 0
local uncovered = 0
for k, v in pairs(coverage) do
    if not v then
        runner.writeln(string.format("Test for '%s' not implemented", k))
        uncovered = uncovered + 1
    else
        covered = covered + 1
    end
end

local total = covered + uncovered
runner.writeln(string.format("Covered %i/%i (%02i%%)", covered, total, math.floor((covered / total) * 100)))