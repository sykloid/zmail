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
typeset -TU MAILCOUNTS mailcounts
integer MAILTOTAL

export MAILBOXES
export MAILCOUNTS
export MAILTOTAL

typeset MAILDIR=~/.mail
typeset MAILIGNORE=${MAILDIR}/ignore

zmail_count() {
    MAILBOXES=
    MAILCOUNTS=

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
            mailcounts=($mailcounts $box_count)
        fi
    done

    export MAILBOXES
    export MAILCOUNTS
    export MAILTOTAL=$total_count
}

zmail_display() {
    if (( MAILTOTAL == 0 )); return
    mail_header_color=$bold_color$fg256[15]

    mailbox_name_color=$bold_color$fg256[214]
    mailbox_count_color=$bold_color
    mailbox_text_color=$reset_color

    mail_bar_color=$reset_color

    mail_total_count_color=$bold_color
    mail_total_text_color=$reset_color
    mail_total_color=$reset_color

    printf "${mail_header_color}Zsh Mailman: ${reset_color}\n"
    printf "${mail_bar_color}--------------------------------------------------${reset_color}\n"

    for i in {1..${#mailboxes}}; do
        # print $mailboxes[$i] $mailcounts[$i]
        printf "${mailbox_count_color}%7d${mailbox_text_color}" $mailcounts[i]

        if (( mailcounts[i] > 1 )); then
            printf " new mails in "
        else
            printf " new mail in "
        fi

        printf "${mailbox_name_color}$mailboxes[i]${reset_color}.\n"
    done
    printf "${mail_bar_color}--------------------------------------------------${reset_color}\n"
    printf "${mail_total_count_color}%7d${mail_total_text_color}" $MAILTOTAL

    if (( MAILTOTAL > 1 )); then
        printf " new mails in "
    else
        printf " new mail in "
    fi

    printf "${mail_total_color}total.${reset_color}\n"
}
