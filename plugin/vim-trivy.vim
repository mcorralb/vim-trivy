""
" @usage {}
" Run Trivy against the current directory and populate the QuickFix list
command! Trivy call s:Trivy()

""
" @usage {}
" Install the latest version of Trivy to %GOPATH/bin/Trivy
command! TrivyInstall call s:TrivyInstall()


" Trivy runs Trivy and prints adds the results to the quick fix buffer
function! s:Trivy() abort
  try
    " capture the current error format
    let errorformat = &g:errorformat
    
    let s:template = '@' . expand('$HOME') . '/.vim/plugged/vim-trivy/csv.tpl'
    let s:command = 'trivy fs -q --security-checks vuln,config --exit-code 0 -f template --template ' . s:template . ' . | sort -u | sed -r "/^\s*$/d"'
    
     " set the error format for use with Trivy
    let &g:errorformat = '%f\,%l\,%m'
    " get the latest Trivy comments and open the quick fix window with them
    cgetexpr system(s:command) | cw
    call setqflist([], 'a', {'title' : ':Trivy'})
    copen
  finally
    " restore the errorformat value
    let &g:errorformat = errorformat
  endtry
endfunction

" TrivyInstall runs the go install command to get the latest version of Trivy
function! s:TrivyInstall() abort
  try
    " Check if Trivy already installed
    if executable('trivy')
      echom "Trivy is already installed"
      return
    endif

    echom "Installing Trivy..."

    " Detect OS
    let s:uname = system('uname')

    " Prefer Homebrew if installed
    if executable('brew')
      let installResult = system('brew install trivy')
    elseif s:uname =~? 'Darwin'
      echom "Homebrew not found. Please install Homebrew first: https://brew.sh"
      return
    else
      " Linux or other systems: install using the official installer
      let installResult = system('curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin')
    endif

    if v:shell_error != 0
      echom "❌ Trivy installation failed:"
      echom installResult
    else
      echom "✔ Trivy installed successfully"
    endif

  endtry
endfunction
