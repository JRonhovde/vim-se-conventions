# vim-se-conventions
Sycamore code conventions made easy.

Version 1.04(9/25/15)    
## Installation/Setup

If you don't have a preferred installation method, I recommend
installing [pathogen.vim](https://github.com/tpope/vim-pathogen), and
then simply copy and paste:

    cd ~/.vim/bundle
    git clone git://github.com/JRonhovde/vim-se-conventions 
    
If not using the Pathogen plugin manager, just create a directory called `plugin` in your `~/.vim/` folder and place the `.vim` file from this repo there: 

    cd ~/.vim
    mkdir plugin

Include a visual mode remap for the SEConventions command:

    vnoremap ;sec <esc>:SEConventions<CR>   

Use this command by visually selecting a block of code (pressing `v` while in command mode) and the pressing `;sec`.

This command will update most of the HTML contained within visually selected `print()` statements to Sycamore standards.    

Alternatively, the :SEConventions(:SEC) command accepts line numbers. `:SEConventions 100 200` will modify lines 100 to 200, inclusive. Given only one argument, it will modify from that line to the end of the file.

If you encounter any problems, try updating the plugin from git:    

    cd ~/.vim/bundle/vim-se-conventions    
    git fetch -p    
    git merge origin/master    

If the problem persists, it can be brought to my attention by creating an issue on [GitHub](https://github.com/JRonhovde/vim-se-conventions)    


### Comprehensive list:
* Add
 * `table` class to all `TABLE` elements
 * `se-bold` class to all `TR` elements that have gray backgrounds (`#cfcfcf` or `se-bg-gray`)
* Remove
 * `width=100%` or `width:100%` from TABLE
 * `background-color:white;` or `#ffffff;`
 * `bgcolor=white` or `#ffffff;`
 * `border=0`
 * `cellpadding=#`
 * `cellspacing=#`
 * newline chars `\n`preceding the end of a print statement `");`
 * `href=''` and `return false;`
 * HTML `width=` or CSS `width:` from `TR` elements
 * `<font>` and `</font>` tags that contain `face=$titlefont` and `size=1 or 2` when 
 the `TABLE` element has the cooresponding font class (`size=1` -> `se-font-small` and `size=2` -> `se-font`)
 * `<B>` tags and `se-bold` classes contained within `TR` elements with the `se-bold` class
 * Left text alignment (HTML, CSS, or `se-left` class) on `TD` elements
 * Empty `style` and `class` attributes
 * Extra spaces within HTML elements and around opening and closing parentheses for `print()` statements
* Replace/Change
 * Gray(`#cfcfcf`), light gray(`#efefef`), pink(`#ffcfcf`), and school color(`$titlefont`) background colors to 
 their respective `se-bg` classes
 * `<font>` tags with `face=$titlefont` and `size=1 or 2` (opposite of the font class on the `TABLE` element) to
 an appropriate class on the `TD`
 * `width` attributes on `TD` and `TABLE` elements to CSS properties
 * Right and center text alignment (HTML or CSS) to appropriate `se-` class
* Unchanged
 * TR `height` attributes
 * `<font>` tags that contain attributes other than `face=$titlefont` and `size=1 or 2`
 * `<font>` tags not preceded by a `TD` element on the same line
 * Anything that would normally be replaced by:
```php
        .se-red
        .se-tall-row
        .se-font-title
        .se-top
        .se-nowrap
        .se-nobold
        .se-wrap
        .se-striped-green    
        printf() lines
```


