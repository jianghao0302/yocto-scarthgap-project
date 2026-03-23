is_dash_shell()
{
    [ "$(readlink "$SHELL" 2>/dev/null)" = "dash" ]
}