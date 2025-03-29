---@type ns.api.mp
local module = {
  mode = "standalone",
  valid = false
};

local pack = "not_survival";

---@class voxelonline.classes.account
---@field username string
---@field active boolean
---@field is_logger boolean
---@field role string

---@class voxelonline.classes.player
---@field username string
---@field active boolean
---@field pid number

---@class voxelonline.classes.client
---@field active boolean
---@field account voxelonline.classes.account
---@field player voxelonline.classes.player

---@class voxelonline.libs.bson
---@field serialize fun(tbl: table): table Writes data from tbl into buffer
---@field deserialize fun(buf: any): table Reads data from buffer

---@class voxelonline.api.server
---@field rpc { emitter: { create_tell: (fun(pack: string, event: string): fun(client: voxelonline.classes.client, ...)), create_echo: (fun(pack: string, event: string): fun(...)) } }
---@field events { tell: fun(pack: string, event: string, client: voxelonline.classes.client, bytes: table), echo: fun(pack: string, event: string, bytes: table), on: fun(pack: string, event: string, func: fun(Client: voxelonline.classes.client, bytes: table)) }
---@field accounts { get_account_by_name: (fun(username: string): voxelonline.classes.account), get_client: (fun(account: voxelonline.classes.account): voxelonline.classes.client) }
---@field console { add_command: fun(scheme: string, roles: string[], func: fun(args: table<string, any>, client: voxelonline.classes.client), tell: fun(message: string, client: voxelonline.classes.client), echo: fun(message: string), execute: fun(message: string, client: voxelonline.classes.client), colors: {red:string,yellow:string,blue:string,black:string,green:string,white:string}) }
---@field sandbox { get_all: (fun():table<string, voxelonline.classes.player>), get_in_radius: (fun(pos: number[], radius: number): table<string, voxelonline.classes.player>) }
---@field bson voxelonline.libs.bson

---@class voxelonline.api.client
---@field rpc { emitter: { create_send: fun(pack: string, event: string): fun(...) } }
---@field events { send: fun(pack:string,event:string,bytes:table), on: fun(pack:string,event:string,func:fun(bytes:table)) }
---@field bson voxelonline.libs.bson

if _G["$VoxelOnline"] then
  module.mode = _G["$VoxelOnline"];
  module.valid = true;

  local temp = {};

  temp.server = function()
    ---@type voxelonline.api.server
    local server_api = require("server:api/api").server;

    module.server = {
      send = function(event, username, ...)
        local account = server_api.accounts.get_account_by_name(username);
        local client = server_api.accounts.get_client(account);
        local bytes = server_api.bson.serialize({ ... });
        server_api.events.tell(pack, event, client, bytes);
      end,
      echo = function(event, ...)
        local bytes = server_api.bson.serialize({ ... });
        server_api.events.echo(pack, event, bytes);
      end,
      on = function(event, callback)
        server_api.events.on(pack, event, function(Client, bytes)
          local args = server_api.bson.deserialize(bytes);
          callback(Client.player, unpack(args));
        end)
      end
    }
  end

  temp.client = function()
    ---@type voxelonline.api.client
    local client_api = require("multiplayer:api/api").client

    module.client = {
      send = function(event, ...)
        local bytes = client_api.bson.serialize({ ... });
        client_api.events.send(pack, event, bytes);
      end,
      on = function(event, callback)
        client_api.events.on(pack, event, function(bytes)
          local args = client_api.bson.deserialize(bytes);
          callback(unpack(args));
        end)
      end
    }
  end

  temp[module.mode]();
  temp = nil;
end

return module;
