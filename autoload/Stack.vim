" SALMAN: Add support to push, pop and peek multiple entries
function! Stack#Push( element ) dict
  let self.data += [ a:element ]
endfunction

function! Stack#Pop() dict
  return remove( self.data, - 1 )
endfunction

function! Stack#Peek() dict
  return self.data[ -1 ]
endfunction

function! Stack#NewStack()
  return { 'data' : [],
        \ 'push' : function( 'Stack#Push' ),
        \ 'pop' : function( 'Stack#Pop' ),
        \ 'peek' : function( 'Stack#Peek' ) }
endfunction
