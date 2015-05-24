# h5tk

This module can be used to generate html5 code.
It is very similar to the erector framework
(http://erector.rubyforge.org/).

# Installation
It's on luarocks => https://luarocks.org/modules/forflo/h5tk
Just execute

    $ sudo luarocks install h5tk

# Usage
All Functions take one table as input. Each value whose
key is of type string is interpreted as an attribute for
the current html tag. Every value whose key is of type number
is considered to be the data that should be enclosed between 
the specified html tags.

h5tk can be used to produce unformatted and formatted html markup.
In formatting mode, the number of intendation spaces can be adjusted. 

## Initialization

	local h5tk = require[[h5tk]].init(true, 4)
	-- init accepts two arguments, the first should be
	-- of type bool, the other of type number.
	-- The first argument toggles formatting of the html code
	-- The number represents the intendation spaces per nesting level

## Basic workings

	h5tk.emit(h5tk.tr{
		someattr = "attrvalue"
		h5tk.td{"foo1"},
		h5tk.td{"foo2"},
		h5tk.td{"boo3"},
		h5tk.td{"boo4"}
	})
	
After the first evaluation step, the table that h5tk.tr gets would
look like this

	h5tk.emit(h5tk.tr{someattr = "attrvalue", 
		"<td>foo1</td>", 
		"<td>foo2</td>", 
		"<td>boo3</td>", 
		"<td>boo4</td>"})
		
Now, since someattr is a string key, the call to h5tk.tr produces the
following code:

	<tr someattr="attrvalue">
	<td>foo1</td>
	<td>foo2</th>
	<td>boo3</th>
	<td>boo4</td>
	</tr>
	
This also works if you don't put all attrname = "attrvalue" pairs
on top of you table.

		
## Function evaluation
Lets put some more data in our table.

	h5tk.emit(h5tk.tr{someattr = "attrvalue",
		(function () return h5tr.td{"funcgenfoo"} end),
		h5tr.td{true},
		{"nested1", "nested2", {"subnested1", "foonested2"}},
		"<td>foo1</td>", 
		"<td>foo2</td>", 
		"<td>boo3</td>",  
		"<td>boo4</td>"
	})
	
Lets tackle that step-by-step
* The function gets evaluated and calls h5tr.td... which, in turn generates a string that'll be put into the table
* Pure boolean values will be interpreted as "true" for true and "false" for false
* Sub-tables will act, as if they were not present, meaning that the contained strings or values
  will be put directly into the table that h5tr.tr gets

## Basic table generation
Just imagine you would want to emit html code
that represents a table. 
With h5tk it's as simple as the following snippet:

	h5tk.emit(h5tk.table{
            h5tk.tr{
			h5tk.th{"First"},
			h5tk.th{"Second"},
                h5tk.th{"3"},
                h5tk.th{"4"}
            },
    
            h5tk.tr{
                h5tk.td{"foo1"},
                h5tk.td{"foo2"},
                h5tk.td{"boo3"},
                h5tk.td{"foo4"}
            }
        })

This would genreate the following code:
		
		<table>
			<tr>
				<th> First <th> <th> Second <th> <th> 3 <th> <th> 4 <th>
			</tr>
			<tr>
				<th> foo1 <th> <th> foo2 <th> <th> boo3 <th> <th> foo4 <th>
			</tr>
		</table>

## Full example
For a more complex example, consider this:
	
		local h5tk = require[[h5tk]]

		io.write("<!DOCTYPE html>")
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
						h5tk.td{"foo2"},
						h5tk.td{"boo3"},
						h5tk.td{"boo4"}
					}
				}
			}
		}))

The code above emits a valid html5 page and _could_ be used
as cgi script for dynamic webcontent. Here is the generated output:

	<!DOCTYPE html>
	<html>
	<head>
	<style>table, th, td { border: 1px solid black; }</style>
	<title>Geiler Titel!!</title>
	</head>
	<body>
	<p style=bold!></p>
	<table>
	<tr>
	<th>foo1</th>
	<th>foo2</th>
	<th>foo</th>
	<th>boo</th>
	</tr>
	<tr>
	<td>foo1</td>
	<td>foo2</th>
	<td>boo3</th>
	<td>boo4</td>
	</tr>
	</table>
	</body>
	</html>
