# ssh using a new window when we are in TMUX
SSHEXEC=$(which ssh)
ssh() {
    if [ -n "$TMUX" ]
    then
        title="ssh $*"
        if [ "$1" = -t ]
        then
            title="$2"
            shift 2
        fi
        tmux new-window -n "$title" "$SSHEXEC $@"
    else
        $SSHEXEC $@
    fi
}
