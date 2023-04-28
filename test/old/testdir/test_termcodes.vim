
source check.vim
" CheckNotGui
" CheckUnix

source shared.vim
source mouse.vim
source view_util.vim
source term_util.vim

func Test_xterm_mouse_click()
  new
  let save_mouse = &mouse
  let save_term = &term
  " let save_ttymouse = &ttymouse
  " set mouse=a term=xterm
  set mouse=a
  call setline(1, ['line 1', 'line 2', 'line 3 is a bit longer'])
  for ttymouse_val in ['sgr']
    " exe 'set ttymouse=' . ttymouse_val
    go
    call assert_equal([0, 1, 1, 0], getpos('.'))
    let row = 2
    let col = 6
    call MouseLeftClick(row, col)
    call MouseLeftRelease(row, col)
    call assert_equal([0, 2, 6, 0], getpos('.'))
  endfor

  let &mouse = save_mouse
  " let &term = save_term
  " let &ttymouse = save_ttymouse
  bwipe!
endfunc

func Test_xterm_mouse_wheel()
  new
  let save_mouse = &mouse
  let save_term = &term
  " let save_ttymouse = &ttymouse
  " set mouse=a term=xterm
  set mouse=a
  call setline(1, range(1, 100))

  for ttymouse_val in ['sgr']
    " exe 'set ttymouse=' . ttymouse_val
    go
    call assert_equal(1, line('w0'))
    call assert_equal([0, 1, 1, 0], getpos('.'))

    call MouseWheelDown(1, 1)
    call assert_equal(4, line('w0'))
    call assert_equal([0, 4, 1, 0], getpos('.'))

    call MouseWheelDown(1, 1)
    call assert_equal(7, line('w0'))
    call assert_equal([0, 7, 1, 0], getpos('.'))

    call MouseWheelUp(1, 1)
    call assert_equal(4, line('w0'))
    call assert_equal([0, 7, 1, 0], getpos('.'))

    call MouseWheelUp(1, 1)
    call assert_equal(1, line('w0'))
    call assert_equal([0, 7, 1, 0], getpos('.'))
  endfor

  let &mouse = save_mouse
  " let &term = save_term
  " let &ttymouse = save_ttymouse
  bwipe!
endfunc

func Test_xterm_mouse_drag_window_separator()
  let save_mouse = &mouse
  let save_term = &term
  " let save_ttymouse = &ttymouse
  " set mouse=a term=xterm
  set mouse=a

  for ttymouse_val in ['sgr']
    " exe 'set ttymouse=' . ttymouse_val

    " Split horizontally and test dragging the horizontal window separator.
    split
    let rowseparator = winheight(0) + 1
    let row = rowseparator
    let col = 1

    if ttymouse_val ==# 'xterm' && row > 223
      " When 'ttymouse' is 'xterm', row/col bigger than 223 are not supported.
      continue
    endif

    call MouseLeftClick(row, col)

    let row -= 1
    call MouseLeftDrag(row, col)
    call assert_equal(rowseparator - 1, winheight(0) + 1)
    let row += 1
    call MouseLeftDrag(row, col)
    call assert_equal(rowseparator, winheight(0) + 1)
    call MouseLeftRelease(row, col)
    call assert_equal(rowseparator, winheight(0) + 1)

    bwipe!

    " Split vertically and test dragging the vertical window separator.
    vsplit
    let colseparator = winwidth(0) + 1

    let row = 1
    let col = colseparator
    call MouseLeftClick(row, col)
    let col -= 1
    call MouseLeftDrag(row, col)
    call assert_equal(colseparator - 1, winwidth(0) + 1)
    let col += 1
    call MouseLeftDrag(row, col)
    call assert_equal(colseparator, winwidth(0) + 1)
    call MouseLeftRelease(row, col)
    call assert_equal(colseparator, winwidth(0) + 1)

    bwipe!
  endfor

  let &mouse = save_mouse
  " let &term = save_term
  " let &ttymouse = save_ttymouse
endfunc

func Test_xterm_mouse_drag_statusline()
  let save_mouse = &mouse
  let save_term = &term
  " let save_ttymouse = &ttymouse
  " set mouse=a term=xterm
  set mouse=a

  for ttymouse_val in ['sgr']
    " exe 'set ttymouse=' . ttymouse_val

    call assert_equal(1, &cmdheight)
    let rowstatusline = winheight(0) + 1
    let row = rowstatusline
    let col = 1

    if ttymouse_val ==# 'xterm' && row > 223
      " When 'ttymouse' is 'xterm', row/col bigger than 223 are not supported.
      continue
    endif

    call MouseLeftClick(row, col)
    let row -= 1
    call MouseLeftDrag(row, col)
    call assert_equal(2, &cmdheight)
    call assert_equal(rowstatusline - 1, winheight(0) + 1)
    let row += 1
    call MouseLeftDrag(row, col)
    call assert_equal(1, &cmdheight)
    call assert_equal(rowstatusline, winheight(0) + 1)
    call MouseLeftRelease(row, col)
    call assert_equal(1, &cmdheight)
    call assert_equal(rowstatusline, winheight(0) + 1)
  endfor

  let &mouse = save_mouse
  " let &term = save_term
  " let &ttymouse = save_ttymouse
endfunc

" Test for translation of special key codes (<xF1>, <xF2>, etc.)
func Test_Keycode_Translation()
  let keycodes = [
        \ ["<xUp>", "<Up>"],
        \ ["<xDown>", "<Down>"],
        \ ["<xLeft>", "<Left>"],
        \ ["<xRight>", "<Right>"],
        \ ["<xHome>", "<Home>"],
        \ ["<xEnd>", "<End>"],
        \ ["<zHome>", "<Home>"],
        \ ["<zEnd>", "<End>"],
        \ ["<xF1>", "<F1>"],
        \ ["<xF2>", "<F2>"],
        \ ["<xF3>", "<F3>"],
        \ ["<xF4>", "<F4>"],
        \ ["<S-xF1>", "<S-F1>"],
        \ ["<S-xF2>", "<S-F2>"],
        \ ["<S-xF3>", "<S-F3>"],
        \ ["<S-xF4>", "<S-F4>"]]
  for [k1, k2] in keycodes
    exe "nnoremap " .. k1 .. " 2wx"
    call assert_true(maparg(k1, 'n', 0, 1).lhs == k2)
    exe "nunmap " .. k1
  endfor
endfunc

" Test for terminal keycodes that doesn't have termcap entries
func Test_special_term_keycodes()
  new
  " Test for <xHome>, <S-xHome> and <C-xHome>
  " send <K_SPECIAL> <KS_EXTRA> keycode
  call feedkeys("i\<C-K>\x80\xfd\x3f\n", 'xt')
  " send <K_SPECIAL> <KS_MODIFIER> bitmap <K_SPECIAL> <KS_EXTRA> keycode
  call feedkeys("i\<C-K>\x80\xfc\x2\x80\xfd\x3f\n", 'xt')
  call feedkeys("i\<C-K>\x80\xfc\x4\x80\xfd\x3f\n", 'xt')
  " Test for <xEnd>, <S-xEnd> and <C-xEnd>
  call feedkeys("i\<C-K>\x80\xfd\x3d\n", 'xt')
  call feedkeys("i\<C-K>\x80\xfc\x2\x80\xfd\x3d\n", 'xt')
  call feedkeys("i\<C-K>\x80\xfc\x4\x80\xfd\x3d\n", 'xt')
  " Test for <zHome>, <S-zHome> and <C-zHome>
  call feedkeys("i\<C-K>\x80\xfd\x40\n", 'xt')
  call feedkeys("i\<C-K>\x80\xfc\x2\x80\xfd\x40\n", 'xt')
  call feedkeys("i\<C-K>\x80\xfc\x4\x80\xfd\x40\n", 'xt')
  " Test for <zEnd>, <S-zEnd> and <C-zEnd>
  call feedkeys("i\<C-K>\x80\xfd\x3e\n", 'xt')
  call feedkeys("i\<C-K>\x80\xfc\x2\x80\xfd\x3e\n", 'xt')
  call feedkeys("i\<C-K>\x80\xfc\x4\x80\xfd\x3e\n", 'xt')
  " Test for <xUp>, <xDown>, <xLeft> and <xRight>
  call feedkeys("i\<C-K>\x80\xfd\x41\n", 'xt')
  call feedkeys("i\<C-K>\x80\xfd\x42\n", 'xt')
  call feedkeys("i\<C-K>\x80\xfd\x43\n", 'xt')
  call feedkeys("i\<C-K>\x80\xfd\x44\n", 'xt')
  call assert_equal(['<Home>', '<S-Home>', '<C-Home>',
        \ '<End>', '<S-End>', '<C-End>',
        \ '<Home>', '<S-Home>', '<C-Home>',
        \ '<End>', '<S-End>', '<C-End>',
        \ '<Up>', '<Down>', '<Left>', '<Right>', ''], getline(1, '$'))
  bw!
endfunc


" vim: shiftwidth=2 sts=2 expandtab
