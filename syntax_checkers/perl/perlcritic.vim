"============================================================================
"File:        perlcritic.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  LCD 47 <lcd047 at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
"
" For details about perlcritic see:
"
" - http://perlcritic.tigris.org/
" - https://metacpan.org/module/Perl::Critic
"
" Checker options:
"
" - g:syntastic_perl_perlcritic_options (string; default: "--severity 3")
"   options to pass to perlcritic
"
" - g:syntastic_perl_perlcritic_thres (integer; default: 5)
"   error thresholdi: policy violations with a severity above this
"   value are highlighted as errors, the others are warnings

if !exists('g:syntastic_perl_perlcritic_options')
    let g:syntastic_perl_perlcritic_options = '--severity 3'
endif

if !exists('g:syntastic_perl_perlcritic_thres')
    let g:syntastic_perl_perlcritic_thres = 5
endif

function! SyntaxCheckers_perl_perlcritic_IsAvailable()
    return executable('perlcritic')
endfunction

function! SyntaxCheckers_perl_perlcritic_GetLocList()
    let makeprg = syntastic#makeprg#build({
                \ 'exe': 'perlcritic',
                \ 'args': '--quiet --nocolor --verbose "\%s:\%f:\%l:\%c:(\%s) \%m (\%e)\n" '.g:syntastic_perl_perlcritic_options,
                \ 'subchecker': 'perlcritic' })
    let errorformat='%t:%f:%l:%c:%m'
    let loclist = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat, 'subtype': 'Style' })

    " change error types according to the prescribed threshold
    let n = len(loclist) - 1
    while n >= 0
        let loclist[n]['type'] = loclist[n]['type'] < g:syntastic_perl_perlcritic_thres ? 'W' : 'E'
        let n -= 1
    endwhile

    return loclist
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'perl',
    \ 'name': 'perlcritic'})
