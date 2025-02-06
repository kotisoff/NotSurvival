local resource = require "utility/resource_func"

local not_utils = require "utility/utils";

local title = {};
title.utils = {};
title.document = {};

events.on(resource("hud_open"), function()
  title.document = Document.new(resource("title"));
  hud.open_permanent(resource("title"));
end)

function title.utils.set_opacity(name, opacity)
  local el = title.document[name];
  local elcolor = el.color;
  el.color = { elcolor[1], elcolor[2], elcolor[3], opacity };
end

local function new_title_component(name)
  return setmetatable(
    { name = name, is_shown = false, break_show = false },
    {
      __index = {
        ---@param text string
        ---@param show_time number | nil
        ---@param breakfunc (fun(tempdata:any): boolean) | nil True stops function.
        show = function(self, text, show_time, breakfunc)
          show_time = show_time or 5;
          breakfunc = breakfunc or function(temp) return false end;

          if self.is_shown then self.break_show = true end;
          not_utils.create_coroutine(function()
            self.is_shown = true;

            title.document[self.name .. "-root"].hidden = false;
            title.document[self.name].text = text;
            title.utils.set_opacity(self.name, 255);

            not_utils.sleep_with_break(show_time,
              function(data) return self.break_show or breakfunc(data); end,
              function(data, time)
                if time > (show_time - 1) then
                  local step = 255 / 20;
                  local opacity = data.opacity or 255;
                  opacity = opacity - step;
                  title.utils.set_opacity(name, math.floor(opacity));
                  data.opacity = opacity;
                end
              end
            );

            title.utils.set_opacity(self.name, 0);

            self.is_shown = false;
            self.break_show = false;

            title.document[self.name .. "-root"].hidden = true;
          end)
        end
      }
    })
end

title.types = {
  actionbar = "actionbar",
  title = "title",
  subtitle = "subtitle"
}

title.actionbar = new_title_component("actionbar");
title.title = new_title_component("title");
title.subtitle = new_title_component("subtitle");

return title;
