local h = loadfile("../h5tk.lua")().init(true)
local f = loadfile("../h5tk.lua")().init(false)

io.write("<!DOCTYPE html>")
io.write(h.emit(h.html{
	h.head{
		h.title{ "This is a nice title!" },
		h.link{rel="icon", href="foo", type="image/vnd.microsoft.icon"},
		h.link{rel="stylesheet", href="/style.css", type="text/css"},
		h.meta{charset="utf-8"}
	}, 
	h.body{
		h.h1{"This is a level 1 heading"},
		h.h2{"some foo"},
		h.p{"blablabla"},
		h.h2{"some morefoo"},
		
		h.form{
			action="foo.lua",
			{h.input{type="radio", name="cb1", unchecked=""}, "label foo cb1"},
			{h.input{type="radio", name="cb2", unchecked=""}, "label foo cb2"},
			{h.input{type="text", name="s"}, "label foo text"},
			{h.input{type="submit", value="bam"}, "label bam"}
		},

		h.h1{"this is very cool. Look!!!"},
		h.pre{
			"foo"
		},

		h.h1{"A list"},
		h.ul{
			(function()
				local tmp = {}
				for i=1,10 do
					tmp[i] = h.li{
						h.a{
							href="http://static-link.com/foo"..i..".png", 
							"look at my " .. tostring(i).."-th picture"
						}
					}
				end
				return tmp
			end)
		}
	}
}))

io.write("<!DOCTYPE html>")
io.write(f.emit(f.html{
	"foo"
}))
