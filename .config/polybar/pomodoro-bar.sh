#!/bin/sh

pomo_message=$(emacsclient -e '(kd/org-pomodoro-time)' | cut -d '"' -f 2)
pomo_pts=$(emacsclient -e '(kd/pmd-today-point-display)' | cut -d '"' -f 2)
echo ${pomo_message}${pomo_pts}
