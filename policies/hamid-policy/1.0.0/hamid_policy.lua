local _M = require('apicast.policy').new('Hamid Policy', '1.0.0')

local new = _M.new
local http_ng = require('resty.http_ng')
local ipairs = ipairs
local insert = table.insert

function _M.new(configuration)
  local self = new()


 local ops = {}
 local httpc = require("resty.http").new()
 local res, err = httpc:request_uri("http://location-service-dil-proj2.apps.cluster.ocp-hamid.com/locations", {
    method = "GET",
    body = "",
    headers = {
        ["Content-Type"] = "application/json",
    },
})
if not res then
    ngx.log(ngx.ERR, "request failed: ", err)
    -- return
end
  --if res then
    --  ngx.log(ngx.ERR, "request success: ", res.body)
  --end   

-- At this point, the entire request / response is complete and the connection
-- will be closed or back on the connection pool.

-- The `res` table contains the expeected `status`, `headers` and `body` fields.
local status = res.status
local length = res.headers["Content-Length"]
local body   = res.body 
  local config = configuration or {}
  local set_header = config.set_header or {}
  
  for _, header in ipairs(set_header) do
    insert(ops, function()
      ngx.log(ngx.ERR, 'setting header V1: ', x, ' to: ', header.value)
      ngx.req.set_header(x, header.value)
    end)
  end

  self.ops = ops
  self.author_rest_endpoint=config.author_rest_endpoint
  self.JWT_claim_name=config.JWT_claim_name
  self.error_message=config.error_message
  
  return self
end

local function isempty(s)
  return s == nil or s == ''
end

local function check_authorization(auth_endpoint,role,method,resource)
      local is_authorized=false
      if isempty(auth_endpoint) or isempty(role) or isempty(method) or isempty(resource) then
       return is_authorized
      end
      local ops = {}
      local query={}
      query.role=role
      query.method=method
      query,resource=resource
      local httpc = require("resty.http").new()
      local res, err = httpc:request_uri(auth_endpoint, {
        method = "GET",
        body = "",
        query=query,
        headers = {
            ["Content-Type"] = "application/json",
        },
      })
if not res then
    ngx.log(ngx.ERR, "request failed: ", err)
    return is_authorized 
end
  if res then
      ngx.log(ngx.ERR, "request success: ", res.body)
      if not isempty(res.body) and string.find(res.body, "Kamarhati") then
          return true
      end
  end      
      return is_authorized
end

function _M:rewrite()
ngx.log(ngx.ERR,'rewrite start')
  for _,op in ipairs(self.ops) do
    op()
  end
end
function _M:access(context)
  ngx.log(ngx.ERR,'access start')
  ngx.log(ngx.ERR,"self.JWT_claim_name=",self.JWT_claim_name)
  ngx.log(ngx.ERR,"self.JWT_claim_name value=",context.jwt[self.JWT_claim_name])
    local uri = ngx.var.uri
  local request_method =  ngx.req.get_method()
  local is_auth=check_authorization( self.author_rest_endpoint,context.jwt[self.JWT_claim_name],request_method,uri)
  ngx.log(ngx.ERR, "is_auth= ", is_auth)
  --local uri = context:get_uri()

  --ngx.log(ngx.ERR, "context.jwt= ", context.jwt)
  if context.jwt then
     print("esthaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
  end
  ngx.log(ngx.ERR, "context.jwt.user_group= ", context.jwt.user_group)
  
  ngx.log(ngx.ERR, "uri=: ", uri)
  ngx.log(ngx.ERR, "type of request_method= ", type(request_method))
  ngx.log(ngx.ERR, "request_method=: ", request_method)
  ngx.log(ngx.ERR, "client=: ", request_method.client)
  return is_auth
end  
return _M
