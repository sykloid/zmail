#! /usr/bin/env zsh
# Objectives:
#   - A counting function.
#   - A display function.
#   - Allow ignoring of mailboxes

# Declare arrays to hold the names of mailboxes with new mail, and the
# corresponding count of new mail.
typeset -TU MAILBOXES mailboxes
typeset -TU MAILCOUNT mailcount

typeset MAILDIR=~/.mail
typeset MAILIGNORE=${MAILDIR}/ignore

zmail_count() {
    typeset -U boxes
    typeset -U ignore
    boxes=($MAILDIR/**/*~*(new|cur|tmp)*(/N))
    ignore=$(for box in $(cat ${MAILIGNORE}); print ${MAILDIR}/$box)

    final_list=$(sort <(for i in $boxes; print -l $i) <(for i in $ignore; print -l $i) | uniq -u) 
    print $final_list

}
