

def nested [] {
    mut extra = ""
    if (direnv status | rg "Loaded RC" | is-not-empty) {
        $extra = " (direnv)"
    } else if ($env.PATH | rg "/nix/store" | is-not-empty) {
        if ("IN_NIX_SHELL" in $env) {
            $extra = " (dev)"
        } else {
            $extra = " (shell)"
        }
    }
    $extra
}

$env.PROMPT_COMMAND = {|| [ (ansi white) (whoami) "@" (ansi u) (hostname -s) (ansi reset) (ansi white) (nested) "> " (ansi reset) ] | str join }
$env.PROMPT_INDICATOR = {||}

def rprompt [] {
    mut dir = pwd
    if ((pwd) starts-with $env.HOME) {
        $dir = [ "~/" (pwd | path relative-to $env.HOME) ] | str join
    }
    $dir
}
$env.PROMPT_COMMAND_RIGHT = {|| rprompt }
$env.TRANSIENT_PROMPT_COMMAND_RIGHT = null
