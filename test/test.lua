h5tk = loadfile("../h5tk.lua")().init(true, 4)

io.write("<!DOCTYPE html>\n")
io.write(h5tk.emit(h5tk.html{
	h5tk.head{
		h5tk.style{
			"table, th, td { border: 1px solid black; }"
		},

		h5tk.title{
			"Geiler ",
			"Titel!!"
		}
	},
	
	h5tk.body{
		h5tk.p{
			style = "bold!"
		},
		
		h5tk.table{
			h5tk.tr{
				(function () 
					return h5tk.th{"foo" }
				end),
				h5tk.th{"foo"},
				h5tk.th{"boo"}
			},
			
			h5tk.tr{
				h5tk.td{"foo1"},
				h5tk.th{"foo2"},
				h5tk.th{"boo3"},
				h5tk.td{"boo4"}
			}
		}
	}
}))
io.write("\n")

io.write(h5tk.emit(
	h5tk.tr{
		h5tk.th{
			"foo",
			"bar"
		}
}))

io.write("\n")

io.write(h5tk.emit(
	h5tk.tr{
		someatt = "someval",
		someattr = {"foo", "bar"},
		(function() return h5tk.td{"funcgenfoo0"} end),
		h5tk.td{true, false},
		true, false, true, true,
		{"nested1", "nested2", {"snest23", "foooooo"}},
		h5tk.td{"foo1"},
		h5tk.td{"foo2"},
		h5tk.td{"foo3"},
	}
))

io.write("\n")

h5tk = loadfile("../h5tk.lua")().init(false)

io.write(
	h5tk.tr{
		someatt = "someval",
		someattr = {"foo", "bar"},
		(function() return h5tk.td{"funcgenfoo0"} end),
		h5tk.td{true, false},
		true, false, true, true,
		{"nested1", "nested2", {"snest23", "foooooo"}},
		h5tk.td{"foo1"},
		h5tk.td{"foo2"},
		h5tk.td{"foo3"},
	}
)
