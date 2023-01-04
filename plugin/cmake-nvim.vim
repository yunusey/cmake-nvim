	

" Title:        cmake-nvim
" Description:  A fancy sleep screen for neovim.
" Last Change:  12/28/2022
" Maintainer:   yunusey <https://github.com/yunusey>

if exists("g:loaded_cmake_nvim")
    finish
endif
let g:loaded_cmake_nvim = 1

let s:lua_rocks_deps_loc =  expand("<sfile>:h:r") . "/../lua/cmake-nvim/deps"
exe "lua package.path = package.path .. ';" . s:lua_rocks_deps_loc . "/lua-?/init.lua'"
exe "lua require('cmake-nvim').user_commands()"
