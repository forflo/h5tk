local h5tk = loadfile("../h5tk.lua")().init(true, 4, false)

io.write(h5tk.emit(
	h5tk.tr{
		someatt = "someval",
		someattr = {"foo", "bar"},
		{
			(function() 
					return h5tk.td{"funcgenfoo0"} 
			end),
			(function() 
					return h5tk.td{"funcgenfoo0"} 
			end),
			(function() 
					return h5tk.td{"funcgenfoo0"} 
			end),
		},

		-- some fancy shit
		(function() 
			return h5tk.td{"blagenfunc"} 
		end),
		(function() 
			return function ()
				return h5tk.td{"blagenfunc Closure"} 
			end
		end),
		
		(function() 
			local new = {}
			for i=1,5 do
				new[i] = function ()
					return h5tk.td{"extreme func foo"} 
				end
			end
			return new
		end),
		
		h5tk.td{true, false},
		true, false, true, true,
		{"nested1", "nested2", {"snest23", "foooooo"}},
		{"2nested1", {"2nested2", {"2nested3", {"2nested4"}}}},
		h5tk.td{"foo1"},
		h5tk.td{"foo2"},
		h5tk.img{src = "foo.bra.com"},
		h5tk.area{fuck = "you"},
		h5tk.input{Foo = "bar"},
		h5tk.td{"foo3"},
		h5tk.html{
			h5tk.head{
				h5tk.title{
					[[This is a nice Title!!]]
				}
			},
			h5tk.body{
				h5tk.h1{
					[[This is a heading level 1]]
				},
				h5tk.p{
					[[Here is some text]],
					h5tk.a{
						href = "http://youareanidiot.org",
						[[And a weblink]]
					}
				},
				h5tk.h2{
					[[Another heading]]
				},
				h5tk.h2{
					[[The second heading with level 2]]
				},
			}
		}
	}
))

local h5tk = loadfile("../h5tk.lua")().init()

io.write(h5tk.emit(h5tk.html{
	h5tk.table{
		h5tk.style{"foo"}
	}
}))
