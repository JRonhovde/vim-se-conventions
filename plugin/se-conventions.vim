" Version 1.0
" set up a vnoremap in your .vimrc to run :SE_Conventions
"
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
        let class = 'none'
        let leader = 'silent! ' . current . ',' . current
        let line = getline(current)
        " only modify lines in print statments
        let startPos = match(line, '\c\v%(^[\t\s ]*)@<=print\("')
        if startPos > -1  

            "border cellpadding cellshading bgcolor=white
            "background-color:#ffffff
            let nuke = '(((background-color *: *|bgcolor\=)(#ffffff;=|white;=))|border\=0|cellpadding\=\d*|cellspacing\=\d*)'
            execute leader . 's/\v'.nuke.'*//gi'

            "give all tables the table class
            let line = getline(current)

            " newline characters
            execute leader . 's/\v\\n( *" *\);)@=//g'

            "empty hrefs + return false
            execute leader . 's/\v(<A[^>]*)@<=href\='.a.' *'.a.' (.*onClick[^;]*;)[^r]*(return false;)/\2/gi' 

            " check if line has <table> element
            let line = getline(current)
            let tablePos = match(line, '\c\v\<table')
            if tablePos > -1  
                execute leader . 's/\v(\<table[^>]+)@<=(class\=)(.*table(-)@!)@!/class='.a.'table /gi'
                execute leader . 's/\v(\<table[^>])%(.*class\=.*$)@!/\1 class='.a.'table'.a.' /gi'
                let tableClass = 1
                if match(line, '\v\<table[^>]+se-font(-)@!') > -1
                    let fontSize = 2
                elseif match(line, '\v\<table[^>]+se-font-small') > -1
                    let fontSize = 1
                else
                    execute leader.'s/\v%(\<table[^>]+class\=)@<='.a.'=/'.a.'se-font /gi'
                    let fontSize = 2
                endif
            endif

            " if line has <\table>
            if match(line, '\v\c\</ *table *\>') > -1
                let tableClass = 0
                let fontSize = 0
            endif
           
            if fontSize != 0
                "remove font tags with size=fontSize and closing font tag
                execute leader . 's/\v\<font *%(face\=\$titlefont *|size\='.fontSize.' *){2} *\>%((.*)%(\<\/font\>)|(.*;))/\1/gi'
                "get other font size e.g. abs(2 - 3) = 1
                let otherFont = abs(fontSize - 3)
                if otherFont == 1
                    let fontClass = 'se-font-small'
                    execute leader . 's/\v(\<(td|tr)[^>]*)@<=se-font(-)@!//gi'
                elseif otherFont == 2
                    let fontClass = 'se-font'
                    execute leader . 's/\v(\<(td|tr)[^>]*)@<=se-font-small@!//gi'
                endif
                let line = getline(current)
                let fontPos = match(line, '\c\v(\<td[^>]*\>)@<=\<font([^>]+size\='.otherFont.')@=')
                let classPos = match(line, '\c\v(\<td[^>]+)@<=class\=')
                if classPos > -1 && fontPos > classPos
                    let positionStr = '\%>'.classPos.'c\%<'.fontPos.'\c'
                    execute leader . 's/'positionStr.'\v%(class\=)@<=([^a-zA-Z])=/\1'.fontClass.' /gi'
                else
                    execute leader . 's/\%<'.fontPos.'c\v(\<td)@<= =/ class='.a.fontClass.a.' /gi'
                endif
                    execute leader . 's/\v\<font *%(face\=\$titlefont *|size\='.otherFont.' *){2} *\>%((.*)%(\<\/font\>)|(.*;))/\1/gi'
            endif

            " background color  <B> tags contained within the se-bg-gray table
            " rows
            let bgColorList = '#cfcfcf|#ffcfcf|#efefef|\$titlecolor'
            let bgTags = 'tr|td|table|div'
            let line = getline(current)
            let bgList = matchlist(line, '\c\v\<@<=('.bgTags.')%([^>]+%(background-color:|bgcolor\=))('.bgColorList.')')
            if len(bgList) > 2
                let tagName = tolower(bgList[1])
                let bgcolor = bgList[2]
                if bgcolor == '#cfcfcf'
                    let class = 'se-bg-gray'
                    let boldRow = 1
                    if match(line, '\v\c<tr[^>]+se-bold') == -1
                        let class = 'se-bg-gray se-bold'
                    endif
                elseif bgcolor == '#efefef'
                    let class = 'se-bg-lgray'
                elseif bgcolor == '#ffcfcf'
                    let class = 'se-bg-pink'
                elseif bgcolor == '$titlecolor'
                    let bgcolor = '\$titlecolor'
                    let class = 'se-bg'
                endif

                execute leader.'s/\v(background-color:'.bgcolor.';=|bgcolor\='.bgcolor.')//gi'
                execute leader.'s/\vstyle\='."''".'//gi'
                execute leader.'s/\vstyle\= //gi'

                let line = getline(current)
                if match(line, '\c\v<'.tagName.'[^>]+class\=') > -1
                    execute leader . 's/\v%('.tagName.'[^>]*)@<=class\=%('.a.'([^'.a.']*)'.a.'|([^'.a.'][^ ]*))/class='.a.class.' \1'.a.' /gi'
                else
                    execute leader . 's/\v%('.tagName.')@<= / class='.a.class.a.' /i'
                endif
            endif

            let line = getline(current)
            if match(line, '\v\c\</ *tr *\>') > -1
                let boldRow = 0
            endif
            execute leader . 's/\v%(\<tr[^>]*)@<=%(%([^>]*se-bold[^'.a.'])@<!(se-bg-gray)%([^'.a.']*se-bold.*$)@!/\1 se-bold/i'

            let line = getline(current)
            if match(line, '\v\c(\<tr[^>]*)@<=se-bold') 
                let boldRow = 1
            endif
            if boldRow == 1
                execute leader . 's/\v(\<\/= *b *\>|(\<td[^>]*)@<=se-bold)//gi'
            endif
            " end bg color and bold tags

            " WIDTH ATTRIBUTES vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
            " remove all width attr from table rows
            execute leader . 's/\v(\<tr[^>]*)@<=width\=[^ >]*//gi'

            "modify width attributes for these elements
            let widthTags = 'td|table|div'

            " get list containing html tag name and width amount
            let line = getline(current)
            let widthList = matchlist(line, '\c\v\<@<=('.widthTags.')%([^>]+width\='.a.'=)([\$a-zA-Z0-9\%\-\_]+)')

            if len(widthList) > 2
                let width = widthList[2]
                let widthTag = widthList[3]
                if match (line, '\v\<('.widthTag.')[^>]+style\=') > -1
                    execute leader . 's/\vwidth\='.a.'=[\$a-zA-Z0-9\%\-\_]+'.a.'=//gi'
                    execute leader . 's/\v%(\<'.widthTag.'[^>]+)@<=style\=('.a.')([^'.a.']+;='.a.')/style=\1width:'.width.';\2/gi'
                else
                    execute leader . 's/\v%(\<'.widthTag.'[^>]+)@<=width\='.a.'=[\$a-zA-Z0-9\%\-\_]+'.a.'=/style='.a.'width:'.width.';'.a.'/gi'
                endif
            endif
            " WIDTH ATTRIBUTES ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

            " ALIGN ATTRIBUTES vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
            if tableClass == 1
                execute leader . 's/\v(\<td[^>]* )@<=align\=left =//gi'
            endif
            let line = getline(current)
            let alignList = matchlist(line, '\c\v%(\<td[^>]*)@<=(align\=|text-align *: *)(center|right)')
            if len(alignList) > 2
                let removeStr = alignList[1] . alignList[2]
                let removeStr = substitute(removeStr,'=','\\=',"")
                let alignClass = 'se-'.alignList[2]
                let classPos = match(line, '\c\v(\<td[^>]+)@<=class\=')
                if  classPos > -1
                    execute leader . 's/\%>'.classPos.'c\v%(class\=)@<=([^a-zA-Z])=/\1'.alignClass.' /gi'
                    execute leader . 's/\v(\<td[^>]+)@<='.removeStr.';=//i'
                else
                    execute leader . 's/\v(\<td )([^>]*)'.removeStr.';=/\1class='.a.alignClass.a.' \2/i'
                endif
            endif

            execute leader . 's/\%>'.startPos.'c\vse-left//gi'
            execute leader.'s/\vstyle\='."''".'//gi'
            execute leader.'s/\vstyle\= //gi'
            execute leader.'s/\vclass\='.a.' *'.a.'//gi'
            execute leader.'s/\vclass\= //gi'
            execute leader . 's/\%>'.startPos.'c\v  +/ /gi'
            execute leader . 's/\%>'.startPos.'c\v +('.a.')@=//gi'
        endif
        let current += 1
    endwhile
endfunction

command! SEConventions call SEConventions()
