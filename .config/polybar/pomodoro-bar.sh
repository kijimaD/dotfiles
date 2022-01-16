#!/bin/sh

underline_color="%{u#99c2ff}%{+u}"
pomo_message=$(emacsclient -e '(kd/org-pomodoro-time)' | cut -d '"' -f 2)
pomo_pts=$(emacsclient -e '(kd/pmd-today-point-display)' | cut -d '"' -f 2)
echo ${underline_color}${pomo_message}${pomo_pts}
