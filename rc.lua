-- {{{ Required libraries
local gears = require("gears")
awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
wibox = require("wibox")
local beautiful = require("beautiful")
naughty = require("naughty")
local lain = require("lain")
local rd = require("rodentbane")
local drop = require("scratchdrop")
local emacs_browser = require("emacs-browser")
-- }}}

-- awful.util.spawn_with_shell("xcompmgr -cF &")

-- {{{ Error handling


if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Default modkey
modkey      = "Mod4"
altkey      = "Mod1"

-- User defined
terminal    = "urxvt"
editor      = os.getenv("EDITOR") or "gvim"
graphics    = "gimp"
chris_filebrowser = "filebrowser"
editor_cmd  = terminal .. " -e " .. editor
volume      = terminal .. " -name 'alsamixer' -e alsamixer -c 0"
ncm         = terminal .. " -name 'ncmpcpp' -e ncmpcpp"

gray = "#474747"
naughty.config.defaults.border_color = gray

home = os.getenv("HOME")
confdir = home .. "/.config/awesome"
themes = confdir .. "/themes"

-- Load active themes
active_theme = themes .. "/holo"
--active_theme = themes .. "/solarized-powerarrow"
beautiful.init(active_theme .. "/theme.lua")

local pomodoro = require("pomodoro")

pomodoro.init()


-- Custome function
local mymodule = require "mymodule"

-- mymodule.run_once("xcompmgr",'xcompmgr -CcfF -I "20" -O "10" -D "1" -t "-5" -l "-5" -r "4.2" -o ".82" &')

-- Load layouts
local layouts = {
    awful.layout.suit.floating, -- 1
    lain.layout.cascade, -- 2
    lain.layout.centerwork, -- 3
    lain.layout.termfair, -- 4
    lain.layout.uselesstile, -- 5
    awful.layout.suit.tile, -- 6
    awful.layout.suit.max, -- 7
    awful.layout.suit.tile.left, -- 8
    awful.layout.suit.tile.bottom, -- 9
    awful.layout.suit.tile.top, -- 10
    awful.layout.suit.fair, -- 11
    awful.layout.suit.fair.horizontal, -- 12
    emacs_browser
}
-- }}}


lain.layout.cascadetile.cascade_offset_x = 2 
lain.layout.cascadetile.cascade_offset_y = 32
lain.layout.cascadetile.extra_padding = 5    
lain.layout.cascadetile.nmaster = 5          
lain.layout.ncol = 1                         


lain.layout.centerwork.top_left = 0
lain.layout.centerwork.top_right = 1
lain.layout.centerwork.bottom_left = 2
lain.layout.centerwork.bottom_right = 3

-- {{{ Tag list
tags = {
    names = { "Ƅ", "ƀ", "Ɵ", "ƈ", "Ɗ", "⌘", "☭", "⌥", "✇" },
    layout = { layouts[5], layouts[7], layouts[5], layouts[13], layouts[7], layouts[12], layouts[9],layouts[9], layouts[9] }
}
for s = 1, screen.count() do
    tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Switch windows
local titlin = function()
        clients = client.get()
        dmenu_in = ""
        for i, line in ipairs(clients) do
                dmenu_in = dmenu_in ..i ..", ".. line.name
                if (i ~= #clients) then
                        dmenu_in = dmenu_in .. "\n"
                end
        end
        selected = awful.util.pread("echo '" .. dmenu_in .. "'|dmenu -i -y 14 -l 5 -w 800 -h 15 -nb '" .. beautiful.menu_bg_normal ..
        "' -fn '" .. beautiful.font_alt ..
        "' -nf '" .. beautiful.menu_fg_normal ..
        "' -sb '" .. beautiful.menu_bg_focus .. "' ")
        if selected ~= "" then
                _,_,n = string.find(selected, "(%d+),")
                awful.client.jumpto(clients[tonumber(n)])
        end
end
-- }}}

-- {{{ Menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "ncmpcpp", ncm },
                                    { "alsamixer", volume}
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
-- menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
markup = lain.util.markup
space2 = markup.font("Tamsyn 2", " ")
white   = "#93A1A1"
yellow  = "#F0C674"
red     = "#FF6C5C"
green   = "#B7CE42"


-- Textclock
clockicon = wibox.widget.imagebox(beautiful.widget_clock)
mytextclock = awful.widget.textclock(markup(white, space2 .. "%I:%M %p" .. space2))

-- Calendar
lain.widgets.calendar:attach(mytextclock, { font_size = 9 })

-- Volume
volicon = wibox.widget.imagebox(beautiful.widget_vol)
volumewidget = lain.widgets.alsa({
    settings = function()
        if volume_now.status == "off" then
            widget:set_markup(markup(red, space2 .. volume_now.level .. "M "))
            volicon:set_image(beautiful.widget_vol_mute)
        elseif tonumber(volume_now.level) == 0 then
            widget:set_markup(markup(white, space2 .. volume_now.level .. "% "))
            volicon:set_image(beautifu.widget_vol_no)
        elseif tonumber(volume_now.level) <= 30 then
            widget:set_markup(markup(white, space2 .. volume_now.level .. "% "))
            volicon:set_image(beautiful.widget_vol_low)
        elseif tonumber(volume_now.level) <= 60 then
            widget:set_markup(markup(white, space2 .. volume_now.level .. "% "))
            volicon:set_image(beautiful.widget_vol_med)
        else
            volicon:set_image(beautiful.widget_vol)
            widget:set_markup(markup(white, space2 .. volume_now.level .. "% "))
        end
    end
})

-- Battery
baticon = wibox.widget.imagebox(beautiful.widget_battery)
batwidget = lain.widgets.bat({
    battery = "BAT0",
    settings = function()
        if bat_now.watt == "N/A" or bat_now.perc == "122" then
            widget:set_markup(markup(white, space2 .. "AC "))
            baticon:set_image(beautiful.widget_ac)
            return
        elseif bat_now.status == "Charging" then
            widget:set_markup(markup(green, space2 ..  bat_now.perc .. "+ "))
            baticon:set_image(beautiful.widget_bat_charge)
        elseif tonumber(bat_now.perc) <= 30 then
            widget:set_markup(markup(red, space2 .. bat_now.perc .. "% "))
            baticon:set_image(beautiful.widget_bat_low)
        elseif tonumber(bat_now.perc) <= 50 then
            widget:set_markup(markup(yellow, space2 .. bat_now.perc .. "% "))
            baticon:set_image(beautiful.widget_bat_half)
        elseif tonumber(bat_now.perc) <= 90 then
            widget:set_markup(markup(white, space2 ..  bat_now.perc .. "% "))
            baticon:set_image(beautiful.widget_bat_med)
        else
            widget:set_markup(markup(white, space2 ..  bat_now.perc .. "% "))
            baticon:set_image(beautiful.widget_bat)
        end
    end
})

-- Memory
memicon = wibox.widget.imagebox(beautiful.widget_mem)
memwidget = lain.widgets.mem({
    settings = function()
        widget:set_markup(markup(white, space2 .. mem_now.used .. "M "))
    end
})

-- Coretemp
tempicon = wibox.widget.imagebox(beautiful.widget_temp)
tempwidget = lain.widgets.temp({
    settings = function()
        widget:set_markup(markup(white, space2 .. coretemp_now .. "°C "))
    end
})

-- CPU
cpuicon = wibox.widget.imagebox()
cpuicon:set_image(beautiful.widget_cpu)
cpuwidget = lain.widgets.cpu({
    settings = function()
        widget:set_markup(markup(white, space2 .. cpu_now.usage .. "% "))
    end
})

-- Wifi checker
-- wifiicon = wibox.widget.imagebox(beautiful.widget_wifi)
-- wifiwidget = lain.widgets.net({
--     settings = function()
--         if net_now.state == "up" then
--             net_state = "On"
--         else
--             net_state = "Off"
--         end
--         widget:set_markup(markup("#859900", net_state))
--     end
-- })

-- Net
netdownicon = wibox.widget.imagebox(beautiful.widget_netdown)
netdowninfo = wibox.widget.textbox()
netupicon = wibox.widget.imagebox(beautiful.widget_netup)
netupinfo = lain.widgets.net({
    settings = function()
        widget:set_markup(markup(white, space2 .. net_now.sent .. " "))
        netdowninfo:set_markup(markup(white, space2 .. net_now.received .. " "))
    end
})

-- MPD notification
mpdicon = wibox.widget.imagebox(beautiful.widget_note)
mpdwidget = lain.widgets.mpd({
    settings = function()
        mpd_notification_preset = {
            title = "Now playing",
            timeout = 3,
            text = string.format("%s - %s\n%s", mpd_now.artist,
                   mpd_now.album, mpd_now.title)
        }

        if mpd_now.state == "play" then
            artist = mpd_now.artist .. " - "
            title  = mpd_now.title .. " "
            mpdicon:set_image(beautiful.widget_play)
        elseif mpd_now.state == "pause" then
            artist = mpd_now.artist .. " - "
            title  = mpd_now.title .. " "
            mpdicon:set_image(beautiful.widget_pause)
        else
            artist = ""
            title  = "stopped"
            mpdicon:set_image(beautiful.widget_note)
        end
        widget:set_markup(markup(white, space2 .. artist) .. markup(white, title))
    end
})

-- Create a wibox for each screen and add it
mywibox = {}
mybottomwibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({
                                                      theme = { width = 250 }
                                                  })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)
    -- mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.focused, mytasklist.buttons)

    -- Create the upper wibox
    mywibox[s] = awful.wibox({ position = "top", height = "18", screen = s })

    -- Widgets that are aligned to the upper left
    local left_layout = wibox.layout.fixed.horizontal()
    -- left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
--    left_layout:add(mypromptbox[s])
    left_layout:add(mpdicon)
    left_layout:add(mpdwidget)

    -- Widgets that are aligned to the upper right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then
        -- right_layout:add(mpdwidget)
        -- right_layout:add(mpdicon)
        right_layout:add(netdownicon)
        right_layout:add(netdowninfo)
        right_layout:add(netupicon)
        right_layout:add(netupinfo)
        right_layout:add(cpuicon)
        right_layout:add(cpuwidget)
        right_layout:add(tempicon)
        right_layout:add(tempwidget)
        right_layout:add(memicon)
        right_layout:add(memwidget)
        right_layout:add(baticon)
        right_layout:add(batwidget)
        right_layout:add(volicon)
        right_layout:add(volumewidget)
        right_layout:add(clockicon)
        right_layout:add(mytextclock)

        right_layout:add(wibox.widget.systray())
    end

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    -- layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)

    -- Create the bottom wibox
    mybottomwibox[s] = awful.wibox({ position = "bottom", border_width = "0", height = "16", screen = s, })

    -- Widgets that are aligned to the bottom left
    bottom_left_layout = wibox.layout.fixed.horizontal()

    -- Widgets that are aligned to the bottom right
    bottom_right_layout = wibox.layout.fixed.horizontal()
    bottom_right_layout:add(mypromptbox[s])
    
    bottom_right_layout:add(pomodoro.icon_widget)
    
    bottom_right_layout:add(pomodoro.widget)


    bottom_right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklit in the middle)
    bottom_layout = wibox.layout.align.horizontal()
    bottom_layout:set_left(bottom_left_layout)
    bottom_layout:set_middle(mytasklist[s])
    bottom_layout:set_right(bottom_right_layout)
    mybottomwibox[s]:set_widget(bottom_layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- Standard program
    awful.key({ modkey,           }, "\\", function () awful.util.spawn(terminal) end),

    awful.key({ modkey, "Shift" }, "r", rodentbane.start),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Control", "Shift"   }, "q", awesome.quit),

--    awful.key({ modkey,	          }, "z",      function () drop(terminal) end),


    -- Tag browsing
    awful.key({ modkey }, "Left", awful.tag.viewprev),
    awful.key({ modkey }, "Right", awful.tag.viewnext),
    awful.key({ modkey }, "Escape", awful.tag.history.restore),
    
    -- SCreen focus
    
    awful.key({modkey,            }, "F1",     function () awful.screen.focus(1) end),
    awful.key({modkey,            }, "F2",     function () awful.screen.focus(2) end),
    
    -- Move client to screen 2
    awful.key({ modkey, "Shift"   }, "F1", function (c) awful.client.movetoscreen(c, 1) end),
    awful.key({ modkey, "Shift"   }, "F2", function (c) awful.client.movetoscreen(c, 2) end),

    -- Client focus
    awful.key({ modkey }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- Client reorder
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),

    -- Jump to urgent client
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),

    -- Switch mouse screen
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),

    -- Layout manipulation
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),
    awful.key({ modkey, "Control" }, "n", awful.client.restore),
    awful.key({ altkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),

    -- Resize floaters
    awful.key({ modkey }, "Next",  function () awful.client.moveresize( 20,  20, -40, -40) end),
    awful.key({ modkey }, "Prior", function () awful.client.moveresize(-20, -20,  40,  40) end),

    -- Move floaters
    awful.key({ modkey, "Control" }, "Down",  function () awful.client.moveresize(  0,  20,   0,   0) end),
    awful.key({ modkey, "Control" }, "Up",    function () awful.client.moveresize(  0, -20,   0,   0) end),
    awful.key({ modkey, "Control" }, "Left",  function () awful.client.moveresize(-20,   0,   0,   0) end),
    awful.key({ modkey, "Control" }, "Right", function () awful.client.moveresize( 20,   0,   0,   0) end),

    -- Show menu
    awful.key({ modkey }, "w",
        function () mymainmenu:show() end),

    -- Toggle wibox
    awful.key({ modkey }, "b", function ()
        mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
    end),

    -- Change usesless gap
    awful.key({ modkey }, "=", function () lain.util.useless_gaps_resize(1) end),
    awful.key({ modkey }, "-", function () lain.util.useless_gaps_resize(-1) end),

    -- dmenu2
    -- awful.key({ modkey }, "d", function ()
    -- awful.util.spawn( "dmenu_run -i -y 14 -q -l 5 -w 250 -h 15 -nb '" .. beautiful.menu_bg_normal ..
    --         "' -fn '" .. beautiful.font ..
    --         "' -nf '" .. beautiful.menu_fg_normal ..
    --         "' -sb '" .. beautiful.menu_bg_focus ..
    --         "' -p 'Run:' ")
    -- end),
    

    
    -- Tag/client switching
    awful.key({ altkey, }, "Tab", titlin),
    
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),
    
    awful.key({ "Control" }, "Escape",
       function () awful.util.spawn("gmrun") 
    end),
    
    awful.key({ modkey, "Shift" }, "d", function () 
          awful.util.spawn( "dmenu_run -b  -nb black -nf green -p Run -fn 'Monaco-8'")
    end),

    
    -- Toggle Touchpad
    awful.key({ }, "#199", -- Xf86touchpadtoggle
       function () awful.util.spawn("/home/chris/.bin/switchTouchpad") end),
    
    -- Volume keyboard control
    awful.key({ }, "XF86AudioRaiseVolume",
    function ()
        awful.util.spawn("amixer -D pulse sset Master '2%+'")
        volumewidget.update()
    end),
    awful.key({ }, "XF86AudioLowerVolume",
    function ()
        awful.util.spawn("amixer -D pulse sset Master '2%-'")
        volumewidget.update()
    end),
    awful.key({ }, "XF86AudioMute",
    function ()
        awful.util.spawn("amixer set Master playback toggle")
        volumewidget.update()
    end),
    
    awful.key({ }, "XF86AudioNext",
       function ()
          awful.util.spawn_with_shell("mpc next")
          volumewidget.update()
    end),
    
    awful.key({ }, "XF86AudioPrev",
       function()
          awful.util.spawn_with_shell("mpc prev")
          volumewidget.update()
       end
    ),
    
    awful.key({ }, "XF86AudioPlay",
       function()
          awful.util.spawn_with_shell("mpc pause")
          volumewidget.update()
       end
    ),
    
    awful.key({ modkey }, "Return",
       function (c)
          keygrabber.run(
             function (mod, key, event)
                if string.find(key, "Super") then
                   mymodule.showNotification(
                      "Application mode",
                      "Press a key to start an application...")
                end

                if event == "release" then
                   return true
                end

                if not string.find(key, "Shift") then
                   keygrabber.stop()
                end

                if appKeys[key] then
                   appKeys[key]()
                end
                return true
             end
          )
    end),

    

    -- Printscreens
    awful.key({ }, "#107",
    function ()
        awful.util.spawn("scrot -d 1 -e 'mv $f /home/chris/Pictures/Screenhosts/post 2>/dev/null'")
    end)
)


clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "q",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey, "Shift"   }, "t",      awful.titlebar.toggle                            ),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     size_hints_honor = false } },
    -- urxvt gaps fixes
    -- { rule = { name = "urxvt" }, properties = { size_hints_honor = false } },
    -- floating apps
    { rule = { instance = "plugin-container" },
     properties = { floating = true } },
    { rule = { instance = "exe" },
     properties = { floating = true } },
    { rule_any = { class = {"mpv", "MPlayer", "pinentry", "feh", "Vlc"} },
      properties = { floating = true } },
    -- apps tags
    { rule = { class = "Firefox" },
      properties = { tag = tags[1][2] } },
    
    { rule = { class = "Nautilus" },
      properties = { tag = tags[1][5] } },
    
    { rule = { class = "Chromium-browser" },
      properties = { tag = tags[1][3] } },
    { rule = { class = "Viewnior" },
      properties = { tag = tags[1][6] } },
    { rule = { class = "Okular" },
      properties = { tag = tags[1][7] } },
    
    { rule = { class = "Gvim" },
      properties = { tag = tags[1][5] } },

    -- { rule = { class = "Emacs", instance = "emacs" }, 
    --   properties = {tag = tags[1][4]}},
    
    -- { rule = { class = "Sublime Text" },
    --   properties = { tag = tags[1][8]}  },
    
    { rule = { class = "Skype" },
      properties = { tag = tags[1][6] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    if not awesome.startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = true
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- Buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c,{size=16}):set_widget(layout)
    end
end)

-- Enable sloppy focus
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
