# h5tk

This module can be used to generate HTML5 code.
It is very similar to the [erector](http://erector.rubyforge.org/) framework.

# Installation
It's on [luarocks](https://luarocks.org/modules/forflo/h5tk)!
Just execute

    $ sudo luarocks install h5tk

# Usage
All functions take a table as input. Each value whose
key is of type string is interpreted as an attribute for
the current html tag. Every value whose key is of type number
is considered to be a part of the data 
that should be enclosed between the specified html tags.

h5tk can be used to produce unformatted and formatted html markup.
In formatting mode, the number of intendation spaces can be adjusted.
The toolkit even allows you to use tabs instead of spaces!

## Initialization
Without further ado, consider the code below.

	local builder = require("h5tk")
	html_builder1 = builder(format, indent, use_tabs)
	html_builder2 = builder(true, 4, false)
	html_builder3 = builder(false)

*format* toggles formatting of the html code (must be a boolean)
*indent* specifies the number of spaces (or tabs) used for each
    indentation level (must be a number)
*use_tabs* switches the indentation character (must be a boolean)
(false: spaces, true: tabs)

You can always create new html builders with different
formatting settings. All builders will remain independent
from each other, just as they should be.
	
### Standard init Values

* *format* = true
* *indent* = 4
* *use_tabs* = false

## Motivation for h5tk
On luarocks there is another very similar package called "htk".
There are some drawbacks with this package
* No formatting (The HTML code can not automatically be indentet)
* No support for HTML5 tags
* You can only pass tables of strings to the constructor function.
  h5tk on the other hand, handles every value as expected. You can
  pass functions, tables of functions, tables of tables. All values
  will be reduced (eventually) to a string.

## Basic workings

	io.write(h5tk.emit(h5tk.tr{
		someattr = "attrvalue"
		h5tk.td{"foo1"},
		h5tk.td{"foo2"},
		h5tk.td{"boo3"},
		h5tk.td{"boo4"}
	}))
	
After the first evaluation step, the table that h5tk.tr gets would
look like this:

	h5tk.emit(h5tk.tr{someattr = "attrvalue", 
		"<td>foo1</td>", 
		"<td>foo2</td>", 
		"<td>boo3</td>", 
		"<td>boo4</td>"})
		
Now, since someattr is a string key associated with "attrvalue", 
the call to h5tk.tr would produce the following code:

	<tr someattr="attrvalue">
	<td>foo1</td>
	<td>foo2</th>
	<td>boo3</th>
	<td>boo4</td>
	</tr>
	
This would also work if we hadn't put all attrname = "attrvalue" 
pairs on top of our table.
		
## Function evaluation
Lets put some more data in our table.

	h5tk.emit(h5tk.tr{someattr = "attrvalue",
		(function () 
			return h5tr.td{"funcgenfoo"} 
		end),
		h5tr.td{true},
		{
			"nested1", 
			"nested2", 
			{
				"subnested1", 
				"foonested2"
			}
		},
		"foo1", 
		"foo2", 
		"boo",  
		"boo4"
	})
	
Lets tackle this step-by-step!
* The function gets evaluated and calls h5tr.td, which, in turn, 
  generates a result table that'll be put into the parent table (h5tk.tr{})
* Pure boolean values will be interpreted as "true" for true and "false" for false
* Sub-tables will act, as if they were not present, meaning that the contained strings or values
  will be put directly into the table that h5tr.tr gets. They also don't have any impact on the
  indentation on the resulting html markup code

## General type evaluation

	h5tk.emit(h5tk.tr{
		someattr = "attrvalue", => "someattr="attrvalue""
		(function () 
			return h5tr.td{"funcgenfoo"} 
		end), => "<td>funcgenfoo</td>"
		{"nested1", " nested2", {"snest"}}, => "nested1 nested2snest"
		"string", => "string"
		nil, => "nil"
		true, => "true"
		false, => "false"
		42 => "42"
	})
	
	The final result:
	<tr someattr="attrvalue">
		<td>
			funcgenfoo
		</td>
		nested1 nested2snest
		string
		nil
		true
		false
		42
	</tr>

## Notes
### Special tags
Some HTML5-tags have the following syntax:

	<tagname attr="attrval" moreattr="attrval" ...>

Which means, as you can see, that they don't have an end-tag, 
and don't enclose text data. h5tk handles these tags correctly.
For example:

	h5tk.img{src = "foo.bar.com"}
	-- creates without and end tag:
	<img src="foo.bar.com">
	
This is also true for every other tag that acts like this.

### Boolean attributes
The dialog tag can have an boolean attribute which is
commonly denoted as:

	<dialog open> ...

While you can't express this with h5tk,

	<dialog open="">

means the same thing, which, in fact, you can produce very
easily. This behaviour will change, though.
