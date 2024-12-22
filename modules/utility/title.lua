local PACK_ID = PACK_ID or "not_survival"; local function resource(name) return PACK_ID .. ":" .. name end;

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

function title.utils.fade_out_cycle(name, data, curr_time, fade_start_time, total_time)
  if curr_time > fade_start_time then
    local step = 255 / (20 * (total_time - fade_start_time));
    local opacity = data.opacity or 255;
    opacity = opacity - step;
    title.utils.set_opacity(name, math.floor(opacity));
    data.opacity = opacity;
  end
end

function title.utils.fade_in_cycle(name, data, curr_time, fade_start_time, total_time)
  if curr_time > fade_start_time then
    local step = 255 / (20 * (total_time - fade_start_time));
    local opacity = data.opacity or 0;
    opacity = opacity + step;
    title.utils.set_opacity(name, math.floor(opacity));
    data.opacity = opacity;
  end
end

local function new_title_component(name)
  return setmetatable(
    { name = name, is_shown = false, break_show = false },
    {
      __index = {
        show = function(self, text)
          if self.is_shown then self.break_show = true end;
          not_utils.create_coroutine(function()
            self.is_shown = true;

            title.document[self.name .. "-root"].hidden = false;
            title.document[self.name].text = text;
            title.utils.set_opacity(self.name, 255);

            not_utils.sleep_with_break(5,
              function() return self.break_show; end,
              function(data, time)
                title.utils.fade_out_cycle(name, data, time, 4, 5);
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
