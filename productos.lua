local fd=require'carlos.fold'
local fs=require'carlos.files'
local io=require'carlos.io'
local st=require'lstem'

local path='ClaveProdServ.csv'

local stemmer = st.stemmer('spanish', 'UTF_8')

local cats = {}
local oldcat = -1 -- placeholder, different from any possible value
local dict

local concat = table.concat
local isint = math.tointeger
local log = math.log
local floor = math.floor
local function log10(x) return log(x, 10) end
local pow = math.pow
local function pow10(x) return pow(10, x) end

local function ints(a)
    if isint(a) then
	return floor(a / 100)
    end
    return 0
end

local letters = {'0xc1', '0xe1', '0xc9', '0xe9', '0xcd', '0xed', '0xd1', '0xf1', '0xd3', '0xf3', '0xda', '0xfa'}
letters = fd.reduce(letters, fd.map(function(x) return utf8.char(x) end), fd.into, {})

--local esp = {[utf8.char'0xc1']='a', [utf8.char'0xe1']='a', [utf8.char'0xc9']='e', [utf8.char'0xe9']='e', [utf8.char'0xcd']='i', [utf8.char'0xed']='i', [utf8.char'0xd1']='gn', [utf8.char'0xf1']='gn', [utf8.char'0xd3']='o', [utf8.char'0xf3']='o', [utf8.char'0xda']='u', [utf8.char'0xfa']='u'}

local latins = fd.reduce(letters, fd.into, {'%a'})
latins = concat(latins, '')

local function inDict(phrase, cat)
    cat = ints(cat)
    if oldcat ~= cat then dict = {}; cats[cat] = dict; oldcat = cat end
    if tonumber(phrase) then return nil end
    for w in phrase:gmatch(string.format('[%s]+', latins)) do
	if #w > 0 then
	    w = stemmer:stem(w:lower())
	    if dict[w] then dict[w] = dict[w] + 1
	    else dict[w] = 1 end
	end
    end
end

--[[
local ans = fd.reduce(fd.keys(counts), fd.map(function(w,k) return k..'\t'..w end), fd.into, {})
fs.dump('wordsFreq.csv', table.concat(ans, '\n'))
--]]

local function dicts(d)
    return concat(fd.reduce(fd.keys(d), fd.map(function(n,k) return k..'/'..n end), fd.into, {}), ', ')
end

fd.reduce(fs.dlmread(path, ';'), function(x) inDict(x[2], x[1]); inDict(x[#x], x[1]) end) -- fill cats table
local ans = fd.reduce(fd.keys(cats), fd.map(dicts), fd.map(function(ws,k) return k..'\t'..ws  end), fd.into, {})
fs.dump('wordsFreq.csv', concat(ans, '\n'))

