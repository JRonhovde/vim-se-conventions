# vim-se-conventions
Sycamore code conventions made easy.

Version 1.0    
## Installation/Setup

If you don't have a preferred installation method, I recommend
installing [pathogen.vim](https://github.com/tpope/vim-pathogen), and
then simply copy and paste:

    cd ~/.vim/bundle
    git clone git://github.com/JRonhovde/vim-se-conventions    

Include a visual mode remap for the SEConventions command:

    vnoremap ;sec <esc>:SEConventions<CR>   

This command will update most of the HTML contained within `print()` statements up to Sycamore standards.

### Comprehensive list:
* Add
 * `table` class to all `TABLE` elements
 * `se-bold` class to all `TR` elements that have gray backgrounds (`#cfcfcf` or `se-bg-gray`)
* Remove
 * `background-color:white;` or `#ffffff;`
 * `bgcolor=white` or `#ffffff;`
 * `border=0`
 * `cellpadding=#`
 * `cellspacing=#`
 * newline chars `\n`preceding the end of a print statement `");`
 * `href=''` and `return false;`
 * HTML `width=` or CSS `width:` from `TR` elements
 * `<font>` and `</font>` tags within a TD that contain `face=$titlefont` and `size=1 or 2` when 
 the `TABLE` element has the cooresponding font class (`size=1` -> `se-font-small` and `size=2` -> `se-font`)
 * `<B>` tags and `se-bold` classes contained within `TR` elements with the `se-bold` class
 * Left text alignment (HTML, CSS, or `se-left` class) on `TD` elements
 * Empty `style` and `class` attributes
 * Extra spaces within HTML elements
* Replace/Change
 * Gray(`#cfcfcf`), light gray(`#efefef`), pink(`#ffcfcf`), and school color(`$titlefont`) background colors to 
 their respective `se-bg` classes
 * `<font>` tags with `face=$titlefont` and `size=1 or 2` (opposite of the font class on the `TABLE` element) to
 an appropriate class on the `TD`
 * `width` attributes on `TD` and `TABLE` elements to CSS properties
 * Right and center text alignment (HTML or CSS) to appropriate `se-` class
 
**Any problems can be directed toward Jon or left as comments/issues on [GitHub](https://github.com/JRonhovde/vim-se-conventions)**
