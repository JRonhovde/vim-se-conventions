" Version 1.02 
" Updated: 9/2/15
" git@github.com:JRonhovde/vim-se-conventions.git
if exists('g:loaded_code_conventions_plugin')
    finish
endif
let g:loaded_code_conventions_plugin = 1

function! SEConventions()
    let start = line("'<")
    let stop = line("'>")
    let current = start
    let boldRow = 0
    let tableClass = 0
    let fontSize = 0
    let a = "'"

    while current <= stop 
        let leader = 'silent! ' . current . ',' . current
        let line = getline(current)
        " only modify lines in print statments
        let startPos = match(line, '\c\v%(^[\t\s ]*)@<=print\( *"')
        if startPos > -1  

            " MISC. REMOVAL {
            "border cellpadding cellshading bgcolor=white
            "background-color:#ffffff
            let nuke = '(((background-color *: *|bgcolor\=)(#ffffff;=|white;=))|border\=0|cellpadding\=\d*|cellspacing\=\d*)'
            execute leader . 's/\v'.nuke.'*//gi'

            " newline characters
            execute leader . 's/\v\\n( *" *\);)@=//g'

            " add apostrophes to all class attributes
            execute leader . 's/\v%(class\=)@<=([^'.a.' ][^ ]*)%( )@=/'.a.'\1'.a.'/gi'

            " add semicolons to end of all style attributes, if not already
            " present
            execute leader . 's/\v%(style\='.a.'[^'.a.']*[^; ])@<= *'.a.'/;'.a.'/gi'

            "empty hrefs + return false
            execute leader . 's/\v(<A[^>]*)@<=(href\='.a.' *'.a.'|return false;=)*//gi' 

            " }


            " TABLE CLASS/FONTSIZE {
            " check if line has <table> element
            let line = getline(current)
            let tablePos = match(line, '\c\v\<table')
            if tablePos > -1  
                " add the 'table' class to a TABLE that already has a class
                " attribute, but no 'table' class
                execute leader . 's/\v(\<table[^>]+)@<=(class\=)'.a.'=(.*table(-)@![^ '.a.']*)@!'.a.'=/class='.a.'table /gi'
                " add class='table' to TABLE element that has no class
                " attribute
                execute leader . 's/\v(^.*\<table[^>]=)%(.* class\='.a.'[^'.a.']*'.a.'.*$)@!/\1 class='.a.'table'.a.' /gi'
                let tableClass = 1 " flag for lines inside a table

                " check for font classes, if none exist, add the se-font class
                " and set fontSize for future reference
                if match(line, '\v\<table[^>]+se-font(-)@!') > -1
                    let fontSize = 2
                elseif match(line, '\v\<table[^>]+se-font-small') > -1
                    let fontSize = 1
                else
                    execute leader.'s/\v%(\<table[^>]+class\=)@<='.a.'=/'.a.'se-font /gi'
                    let fontSize = 2
                endif
            endif

            " if line has <\table> turn off table and font flags
            if match(line, '\v\c\</ *table *\>') > -1
                let tableClass = 0
                let fontSize = 0
            endif
            " }
           

            " FONT TAGS {
            if fontSize != 0
                "remove font tags with size=fontSize and optional closing font tag
                let fontList = matchlist(line, '\c\v(\<font *%(face\=\$titlefont *|size\='.fontSize.' *){2} *\>)%(.*(\<\/font\>)|.*$)')
                if len(fontList) > 2
                    let fontTag = fontList[1]
                    let closeFont = fontList[2]
                    " escape special chars
                    let fontTag = escape(fontTag, '<$>=/')
                    let closeFont = escape(closeFont, '<$>=/')
                    if strlen(closeFont) > 0
                        execute leader . 's/\v'.fontTag.'|'.closeFont.'//gi'
                    else
                        execute leader . 's/\v'.fontTag.'//i'
                    endif
                endif

                let line = getline(current)
                " set otherFontClass to be opposite of what is on the TABLE
                " element and remove TABLE font class from TD/TR elements
                if fontSize == 2
                    let otherFontClass = 'se-font-small'
                    execute leader . 's/\v(\<(td|tr)[^>]*)@<=se-font(-)@!//gi'
                elseif fontSize == 1
                    let otherFontClass = 'se-font'
                    execute leader . 's/\v(\<(td|tr)[^>]*)@<=se-font-small//gi'
                endif

                " only remove 'otherFont' font tags if there is a TD on the
                " same line
                if match(line, '\c\v\<td') > -1
                    "get other font size e.g. abs(2 - 3) = 1
                    let otherFont = abs(fontSize - 3)
                    let line = getline(current)
                    "position of class attribute, if there is one
                    let classList = matchlist(line, '\c\v%(\<td)@<=%([^>]*(class\='.a.')([^'.a.']*)'.a.'.{-}|.{-})(\<font *%(face\=\$titlefont *|size\='.otherFont.' *){2} *\>)%(.*(\<\/font\>)|.*$)')
                    if len(classList) > 0 
                        let classAttr = classList[1]
                        let classes = classList[2]
                        let fontTag = classList[3]
                        let closeFont = classList[4]
                        " escape special chars
                        let fontTag = escape(fontTag, '<$>=/')
                        let closeFont = escape(closeFont, '<$>=/')
                        if strlen(classAttr) > 0
                            let classes = substitute(classes, '\v(\$)', '\\\1', 'g')
                            if classes !~ otherFontClass
                                execute leader . 's/\v%(class\=)@<='.a.'/'.a.otherFontClass.' /i'
                            endif
                        else
                            execute leader . 's/\v(\<td)@<=[ >]/ class='.a.otherFontClass.a.'\0/i'
                        endif
                        if strlen(closeFont) > 0
                            execute leader . 's/\v'.fontTag.'|'.closeFont.'//gi'
                        else
                            execute leader . 's/\v'.fontTag.'//i'
                        endif
                    endif
                endif
            endif
            " }


            " BACKGROUND COLORS {
            " background colors and <B> tags contained within the se-bg-gray table
            " rows
            " list background colors to catch
            let bgColorList = '#cfcfcf|#ffcfcf|#efefef|\$titlecolor'
            " list html tags to replace background colors in
            let bgTags = 'tr|td|table|div'
            let line = getline(current)
            " match html tag and background color
            let bgList = matchlist(line, '\c\v\<@<=('.bgTags.')%([^>]+%(background-color *: *|bgcolor\=))('.bgColorList.')')
            if len(bgList) > 2
                let tagName = tolower(bgList[1])
                let bgcolor = bgList[2]
                if bgcolor == '#cfcfcf'
                    let bgClass = 'se-bg-gray'
                    let boldRow = 1
                    " if TR and doesn't have se-bold class, add se-bold class
                    if match(line, '\v\c<tr[^>]+se-bold') == -1
                        let bgClass = 'se-bg-gray se-bold'
                    endif
                elseif bgcolor == '#efefef'
                    let bgClass = 'se-bg-lgray'
                elseif bgcolor == '#ffcfcf'
                    let bgClass = 'se-bg-pink'
                elseif bgcolor == '$titlecolor'
                    " add slash for correct escaping
                    let bgcolor = '\$titlecolor'
                    let bgClass = 'se-bg'
                endif

                " remove replaced background color
                execute leader.'s/\v(background-|bg)color( *: *|\=)'.bgcolor.';=//i'

                let line = getline(current)
                " insert bgClass into class attribute, create attribute if
                " none present
                if match(line, '\c\v<'.tagName.'[^>]+class\=') > -1
                    execute leader . 's/\v%('.tagName.'[^>]*)@<=class\=%('.a.'([^'.a.']*)'.a.'|([\$A-Za-z0-9-_]*))/class='.a.bgClass.' \1'.a.' /i'
                else
                    execute leader . 's/\v%('.tagName.')@<= / class='.a.bgClass.a.' /i'
                endif
            endif

            let line = getline(current)
            " if closing TR turn off bold flag
            if match(line, '\v\c\</ *tr *\>') > -1
                let boldRow = 0
            endif

            " if TR has se-bg-gray class and no se-bold class, add se-bold
            " class
            let rowClasses = matchstr(line, '\v%(\<tr[^>]*class\='.a.')@<=([^'.a.']*)%('.a.')@=')
            if rowClasses =~ 'se-bg-gray' && rowClasses !~ 'se-bold'
                let rowClasses = substitute(rowClasses, '\v(\$)', '\\\1', 'g')
                execute leader . 's/\v('.rowClasses.')/se-bold \1/i'
            endif

            let line = getline(current)

            " check if TR has se-bold class
            if match(line, '\v\c(\<tr[^>]*)@<=se-bold') > -1
                let boldRow = 1
            endif

            " Remove bold tag from TD lines
            if match(line, '\v\c(\<td.*)@<=\<\/= *b *\>') > -1
                " if current TR has se-bold class, remove se-bold and <B>
                if boldRow == 1
                    execute leader . 's/\v(\<\/= *b *\>|(\<td[^>]*)@<=se-bold)//gi'
                " else, add se-bold class to TD
                else
                    " if se-bold not present on TD, add it
                    if match(line, '\v\c(\<td[^>]*)@<=se-bold') == -1
                        " Add se-bold to existing class attribute, or create
                        " class attribute with se-bold included
                        if match(line, '\v\c(\<td[^>]*)@<=class') > -1
                            execute leader . 's/\v(\<td[^>]*class\='.a.')@<=([^'.a.']*'.a.')@=/se-bold /i'
                        else
                            execute leader . 's/\v(\<td[^>]*)@<=/ class='.a.'se-bold'.a.' /i'
                        endif
                    endif
                    "remove <B> and </B> tags
                    execute leader . 's/\v\<\/= *b *\>//gi'
                endif
            endif
            " }


            " WIDTH ATTRIBUTES {
            " remove all width attr from table rows
            execute leader . 's/\v(\<tr[^>]*)@<=width\=[^ >]*//gi'

            "modify width attributes for these elements
            let widthTags = 'td|table|div'

            let line = getline(current)
            " get list containing html tag name and width amount
            let widthList = matchlist(line, '\c\v\<@<=('.widthTags.')%([^>]*width\='.a.'=)([\$a-zA-Z0-9\%\-\_]+)')

            if len(widthList) > 2
                let widthTag = widthList[1]
                let width = widthList[2]
                " convert width attribute to css property 
                if match(line, '\v\<'.widthTag.'[^>]*style\=') > -1
                    execute leader . 's/\vwidth\='.a.'=[^> ]+'.a.'=//gi'
                    execute leader . 's/\v%(\<'.widthTag.'[^>]*)@<=style\=('.a.')([^'.a.']+;='.a.')/style=\1width:'.width.';\2/gi'
                else
                    execute leader . 's/\v%(\<'.widthTag.'[^>]*)@<=width\='.a.'=[$a-zA-Z0-9%\-_]+'.a.'=/style='.a.'width:'.width.';'.a.'/gi'
                endif
            endif
            " }


            " ALIGN ATTRIBUTES {
            if tableClass == 1
                " if inside a TABLE with 'table' class, remove all left text
                " align syntax on TD elements
                execute leader . 's/\v(\<td[^>]+)@<=((text-)=align( *: *|\=)|se-)left//gi'
            endif
            let line = getline(current)
            let alignList = matchlist(line, '\c\v%(\<td[^>]*)@<=(align\=|text-align *: *)(center|right)')
            if len(alignList) > 2
                " build pattern of alignment syntax to remove
                let removeStr = alignList[1] . alignList[2]
                let removeStr = escape(removeStr,'=')
                let alignClass = 'se-'.alignList[2]
                let classPos = match(line, '\c\v(\<td[^>]+)@<=class\=')
                if  classPos > -1
                    execute leader . 's/\%>'.classPos.'c\v%(class\=)@<=%('.a.'([^'.a.']*)'.a.'|([\$A-Za-z0-9-_]*))/'.a.alignClass.' \1'.a.' /i'
                    execute leader . 's/\v(\<td[^>]+)@<='.removeStr.';=//i'
                else
                    execute leader . 's/\v(\<td )([^>]*)'.removeStr.';=/\1class='.a.alignClass.a.' \2/i'
                endif
            endif
            " }


            " CLEANUP {
            " empty style attributes
            execute leader.'s/\vstyle\='."''".'//gi'
            execute leader.'s/\vstyle\= //gi'
            " force style attributes to take the left-most position
            execute leader . 's/\v%(\<td )@<=([^>]*)(style\='.a.'.{-}'.a.')/ \2 \1/i'
            " empty class attributes
            execute leader.'s/\vclass\='.a.' *'.a.'//gi'
            execute leader.'s/\vclass\= //gi'
            " remove consecutive spaces
            execute leader . 's/\%>'.startPos.'c\v ( +[^$]*)@=//gi'
            " remove extra spaces before or after quotes
            execute leader . 's/\%>'.startPos.'c\v((\()@<= *" *| *" *(\))@=)/"/gi'
            " remove extra spaces after '>' or before '<'
            execute leader . 's/\%>'.startPos.'c\v((\>)@<= +| +(\<)@=)([^$]*)@=//gi'
            " }
        endif

        let current += 1
    endwhile
endfunction

command! SEConventions call SEConventions()
