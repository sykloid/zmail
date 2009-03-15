#! /usr/bin/env zsh
# A light framework to notify of new mail in zsh.
# P.C. Shyamshankar <sykora@lucentbeing.com>
# March 2009
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Requirements:
#   - Must store mail in the maildir format (mailbox/{new,cur,tmp})
# Objectives:
#   - A counting function.
#   - A display function.
#   - Allow ignoring of mailboxes

# Variable declarations can be held here, or in a central place of your
# choosing, like zshenv or something else.
#
# Declare arrays to hold the names of mailboxes with new mail, and the
# corresponding count of new mail.
typeset -TU MAILBOXES mailboxes
typeset -T MAILCOUNTS mailcounts
integer MAILTOTAL

export MAILBOXES
export MAILCOUNTS
export MAILTOTAL

# Set these variables to your actual directories.
typeset MAILDIR=~/.mail
typeset MAILIGNORE=${MAILDIR}/ignore

zmail_count() {
    MAILBOXES=
    MAILCOUNTS=

    typeset -U all_mailboxes ignored_mailboxes
    integer box_count

    box_count=0
    MAILTOTAL=0

    all_mailboxes=($MAILDIR/**/*~*(new|cur|tmp)*(/N))
    ignored_mailboxes=($(cat $MAILIGNORE))

    # The hackiest part, I still haven't found a way to do this elegantly.
    # What it does, is find the set difference of all_mailboxes - ignored_mailboxes.
    final_boxes=$(sort <(for i in $all_mailboxes; print -l $i) <(for i in $ignored_mailboxes; print -l "$MAILDIR/$i") | uniq -u)

    for i in ${=final_boxes}; do
        ((box_count = 0))

        for mail in ${i}/new/*(.N); do
            ((++box_count))
            ((++MAILTOTAL))
        done
        if (( box_count > 0 )); then
            mailboxes=($mailboxes $i:t)
            mailcounts=($mailcounts $box_count)
        fi
    done

    export MAILBOXES
    export MAILCOUNTS
    export MAILTOTAL
}

zmail_display() {
    if (( ${#MAILCOUNTS} == 0 )); then
        return
    fi

    # Color specifications. Set all of them to $reset_color, or blank, to have a
    # colorless output. Eventually, I should put a switch in here to control
    # that.
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
