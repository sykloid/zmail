#! /usr/bin/env zsh
# A light framework to notify of new mail in zsh.
# P.C. Shyamshankar <sykora@lucentbeing.com>
# Objectives:
#   - A counting function.
#   - A display function.
#   - Allow ignoring of mailboxes

# Declare arrays to hold the names of mailboxes with new mail, and the
# corresponding count of new mail.
typeset -TU MAILBOXES mailboxes
typeset -TU MAILCOUNTER mailcount

export MAILBOXES
export MAILCOUNTER

typeset MAILDIR=~/.mail
typeset MAILIGNORE=${MAILDIR}/ignore

zmail_count() {
    MAILBOXES=
    MAILCOUNTER=

    typeset -U boxes
    typeset -U ignore

    integer box_count total_count

    all_mailboxes=($MAILDIR/**/*~*(new|cur|tmp)*(/N))
    ignored_mailboxes=($(cat $MAILIGNORE))

    final_boxes=$(sort <(for i in $all_mailboxes; print -l $i) <(for i in $ignored_mailboxes; print -l "$MAILDIR/$i") | uniq -u)

    for i in ${=final_boxes}; do
        ((box_count = 0))

        for mail in ${i}/new/*(.N); do
            ((++box_count))
            ((++total_count))
        done
        if (( box_count > 0 )); then
            mailboxes=($mailboxes $i:t)
            mailcount=($mailcount $box_count)
        fi
    done

    export MAILBOXES
    export MAILCOUNTER
}

zmail_display() {
    for i in {1..${#mailboxes}}; do
        print $mailboxes[$i] $mailcount[$i]
    done
}
