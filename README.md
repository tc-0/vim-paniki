# vim-paniki

Enable clickable links in pandoc for personal wiki.

## Overview

`vim-paniki` is a plugin for `vim` that builds on [vim-pandoc](https://github.com/vim-pandoc/vim-pandoc) and [vim-pandoc-syntax](https://github.com/vim-pandoc/vim-pandoc-syntax). `vim-paniki` is automatically loaded when editing files that have `filetype = pandoc`. It provides four keymappings that are currently not customizable:

* `<localleader>gl` and `<localleader>sl` expect the cursor to be on a markdown link `[title](target)`. The link target is extracted and the plugin tries to determine whether the link should be opened in an external application (e.g. targets starting with `http://`, `mailto:` or `file://`. In this case, `xdg-open` is executed on the link target. Otherwise, the link is opened in the current window (`<localleader>gl`) or a new split window (`<localleader>sl`).

* `<BS>`, i.e. backspace, opens the previous file that was edited in the current window before following a link.

* `<localleader>wh` converts the current file to HTML. This is probably broken.
## Configuration

There is currently only one option, `g:paniki_autowrite`. If `g:paniki_autowrite` is nonzero, `vim-paniki` will automatically save modified files when following a link or returning from a link.

## Documentation

There is currently no other documentation available.
