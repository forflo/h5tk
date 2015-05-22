h5tk = loadfile("../h5tk.lua")()

io.write("<!DOCTYPE html>")
io.write(h5tk.html{
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
					local t = {}
					for i=1,2 do
						t[i] = h5tk.th{"foo" .. i}
					end
					return t
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
})

