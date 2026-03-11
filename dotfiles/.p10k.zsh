# Minimal starter Powerlevel10k config.
#
# Run `p10k configure` interactively after first login if you want a tailored
# prompt. This file is intentionally small so it is easy to version-control.

'typeset' -g POWERLEVEL9K_INSTANT_PROMPT=quiet
'typeset' -g POWERLEVEL9K_MODE=nerdfont-complete
'typeset' -g POWERLEVEL9K_PROMPT_ON_NEWLINE=true
'typeset' -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
'typeset' -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time background_jobs)
