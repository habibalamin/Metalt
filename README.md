Metalt
======

Metalt is a daemon for macOS that rewrites key events of the form left-<kbd>⌥</kbd> + <kbd>$KEY</kbd> to the form <kbd>Esc</kbd> quickly followed by <kbd>$KEY</kbd>, but only if Terminal.app is the application which has the focus. This is useful for macOS users of Emacs on the console who use Terminal.app, instead of something like iTerm2, and would like to be able to use left-<kbd>⌥</kbd> as <kbd>META</kbd> without having to give up right-<kbd>⌥</kbd> for typing special characters or using global shortcuts.

If you use iTerm2, there is a built-in option to do the same thing only for iTerm.
