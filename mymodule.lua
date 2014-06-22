local mymodule = {}

function mymodule.foo()
   print("hello world")
end

function runApp(cmd)
   return function () awful.util.spawn(cmd) end
end

appKeys = {
--   e = runApp("emacs-chris"),
   x = runApp("xterm"),
   e = runApp("emacs-chris"),
   g = runApp(graphics),
   d = runApp("okular"),
   s = runApp("skype"),
   t = runApp("sublime3"),
--   m = runApp("run_alpine"),
--   s = runApp("monitor_off"),
--   d = runApp("stardict"),
--   r = runApp("gksudo emacs"),
--   t = runApp("thunar"),
--   i = runApp("tim_im"),
   b = runApp(chris_filebrowser),
--   n = runApp("nautilus"),
   f = runApp("firefox -no-remote"),
   F = runApp("firefox -private"),
   c = runApp("chromium"),
   o = runApp("libreoffice"),
   a = runApp("gnome-alsamixer"),
   u = runApp(terminal)
}


function mymodule.run_once(prg, args)
   if not prg then
	  do return nil end
   end
   if not args then
	  args=""
   end
   awful.util.spawn_with_shell('pgrep -f -u $USER -x ' .. prg .. ' || (' .. prg .. ' ' .. args ..')')
end


function mymodule.showNotification(title, msg)
   naughty.notify({
         text = msg,
         title = title,
         fg = "#0099cc",
         bg = "#000000",
         opacity = 0.8,
         ontop = false,
         timeout = 1
   })
end

return mymodule
