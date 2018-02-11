local fd=require'carlos.fold'
local fs=require'carlos.files'
local io=require'carlos.io'

local path='wordsFreq.csv'

local ans = fd.reduce(fs.dlmread(path, '\t'), fd.filter(function(x) return #x[1]>3 and x[2]>5 end), fd.into, {})

table.sort(ans, function(x,y) return x[2] > y[2] end)

ans = fd.reduce(ans, fd.map(function(x) return x[1]..'\t'..x[2] end), fd.into, {})

fs.dump('wordsFiltFreq.csv', table.concat(ans, '\n'))


