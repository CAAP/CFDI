local fd = require'carlos.fold'
local fs = require'carlos.files'
local io = require'carlos.io'

local path = 'ClaveProdServ.csv'

local isint = math.tointeger
local log = math.log
local floor = math.floor
local pow = math.pow
local function pow10(x) return pow(10, x) end
local function log10(x) return log(x, 10) end

local function ints(x)
    local a = x[1]
    if isint(a) then
	return floor(a / pow10(floor(log10(a)) - 2))
    end
    return 0
end

local tipos = fd.reduce(fs.dlmread(path,';'), fd.map(ints), fd.unique(), fd.into, {})

fs.dump('tipos.csv', table.concat(tipos, '\n'))

