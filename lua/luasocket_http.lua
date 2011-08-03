-- http request test

require 'luarocks.loader'
local http = require 'socket.http'
local md5  = require 'md5'

local function getscore() -- assume this will be generated else where.
  return "id='exa8'&name='Incredible Guy'&score=1234&time="..tostring(os.time())
end

local function generate_chunk(s) -- this must come from C binary side
  return md5.sum(s)
end

local res = http.request(
  'http://services.moaicloud.com/hello_moon',
  getscore().."&chunk="..generate_chunk(getscore())
)

print(res)
