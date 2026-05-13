# Workflow:
# jj-features init
# jj-features new -m "feature 1"
# jj-feaures extend
# jj-features pr
# jj-features land
# jj-features land

post_command_fixup() {
    # If we removed the last change
    # of a stack, edit tip
    if [ -z "$(jj get-change-ids '@+:: & tip')" ]
    then
        jj edit tip
    fi

    # We don't want to keep the extra edge from
    # tip to master if there are more features
    if [ -n "$(jj get-change-ids 'parents(tip) & mutable()')" ]
    then
        jj rebase -r tip --onto 'parents(tip) & mutable()'
    fi
}

abandon() {
    CHANGE_ID="@"
    if [ $# -gt 1 ] && [ "$1" = "-r" ]
    then
        CHANGE_ID="$2"
        shift
        shift
    fi

    jj spr close -r "feature_stack($CHANGE_ID ~ tip)" --all || true
    jj abandon "feature_stack($CHANGE_ID ~ tip)"
}

extend() {
    CHANGE_ID="@"
    if [ $# -gt 1 ] && [ "$1" = "-r" ]
    then
        CHANGE_ID="$2"
        shift
        shift
    fi
    jj new --insert-after "heads(feature_stack($CHANGE_ID ~ tip))" "$@"
}

init() {
    jj git colocation enable
    jj spr init
    jj bookmark c tip -r 'heads(tracked_remote_bookmarks()::)'
}

land() {
    CHANGE_ID="@"
    if [ $# -gt 1 ] && [ "$1" = "-r" ]
    then
        CHANGE_ID="$2"
        shift
        shift
    fi
    BASE=$(jj get-change-ids "feature_base($CHANGE_ID ~ tip)")

    # Land change, rebasing features and removing
    # the feature which is now in master
    jj spr land -r "$BASE"
    rebase
    jj abandon "$BASE"
}

new() {
    jj new --insert-after 'guestimate_master()' --insert-before 'tip' "$@"
}

pr() {
    CHANGE_ID="@"
    if [ $# -gt 1 ] && [ "$1" = "-r" ]
    then
        CHANGE_ID="$2"
        shift
        shift
    fi
    jj spr diff -r "feature_stack($CHANGE_ID ~ tip)" --all "$@"
}

rebase() {
    jj rebase -s 'features()' --onto 'guestimate_master()'
}

COMMAND="$1"
shift
set -e

if [ "$COMMAND" = "abandon" ]
then
    abandon "$@"
elif [ "$COMMAND" = "extend" ]
then
    extend "$@"
elif [ "$COMMAND" = "init" ]
then
    init "$@"
elif [ "$COMMAND" = "land" ]
then
    land "$@"
elif [ "$COMMAND" = "new" ]
then
    new "$@"
elif [ "$COMMAND" = "pr" ]
then
    pr "$@"
elif [ "$COMMAND" = "rebase" ]
then
    rebase "$@"
else
    echo "Subcommand not found: $1"
    echo "try abandon, extend, init, land, new, pr, or rebase"
    exit 1
fi

post_command_fixup
