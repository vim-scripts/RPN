" Examples:
"
" echo Rpn#Eval( '2 3 +' )
" Or
" echo Rpn#Eval( 2, 3, '+' )
"
" Suggested command:
" com! -nargs=+ Rpn echo Rpn#Eval( <f-args> )
"
" Then, Rpn 2 3 + echoes the result.
"
" Operators:
" +
" -
" *
" /
" %
" ^
"
" Commands:
" d: duplicate last entry
" r: reverse last two entries
" v: square root the last entry
"
" Special:
" ans: Replaces with the answer from the last entry

function! Rpn#IsNumber( expression )
  try
    let typeToCheck = type( eval( a:expression ) )

    return typeToCheck == type( 0 ) || typeToCheck == type( 0.0 )
  catch
    return 0
  endtry
endfunction

function! Rpn#IsOperator( entry )
  return match( '+-*/^%', a:entry ) >= 0
endfunction

" Not using str2float() because eval leaves integers as integers; converting everything to a float would cause some operations, such as the modulus, to fail.
function! Rpn#MakeNumber( entry )
  return type( a:entry ) == type( '' ) ? eval( a:entry ) : a:entry
endfunction

function! Rpn#Eval( ... )
  let operands = Stack#NewStack()
  let entries  = len( a:000 ) > 1 ? a:000 : split( a:1, '\s\+' )

  for entry in entries
    if ( Rpn#IsNumber( entry ) )
      call operands.push( entry )
    elseif Rpn#IsOperator( entry )
      " Must be popped in the opposite order.
      let op2 = Rpn#MakeNumber( operands.pop() )
      let op1 = Rpn#MakeNumber( operands.pop() )

      if ( entry == '^' )
        let result = pow( op1, op2 )
      else
        let result = eval( string( op1 ) . entry . string( op2 ) )
      endif

      call operands.push( result )

      unlet! op1 op2
    else
      " SALMAN: Add support for logs, etc., if needed.
      if ( entry == 'd' )
        " Duplicate entry.
        call operands.push( operands.peek() )
      elseif ( entry == 'v' )
        " Square root of entry.
        call operands.push( sqrt( Rpn#MakeNumber( operands.pop() ) ) )
      elseif ( entry == 'r' )
        " Reverse last two entries.
        let first  = operands.pop()
        let second = operands.pop()

        call operands.push( first )
        call operands.push( second )
      elseif ( entry == 'ans' )
        " The answer returned from the last call to this function.
        call operands.push( s:Rpn_lastAnswer )
      else
        " SALMAN: Is a command; not handled yet
        echo "Unimplemented command: " . entry
      endif
    endif
  endfor

  " Save the antwer here.
  unlet! s:Rpn_lastAnswer
  let s:Rpn_lastAnswer = operands.peek()

  return s:Rpn_lastAnswer
endfunction
