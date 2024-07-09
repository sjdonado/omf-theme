# You can override some default options with config.fish:
#
#  set -g theme_short_path yes
#  set -g theme_stash_indicator yes
#  set -g theme_ignore_ssh_awareness yes

function fish_prompt
  set -l last_command_status $status
  set -l cwd

  if test "$theme_short_path" = 'yes'
    set cwd (basename (prompt_pwd))
  else
    set cwd (prompt_pwd)
  end

  set -l fish     "⋊> "
  set -l ahead    "↑"
  set -l behind   "↓"
  set -l diverged "⥄"
  set -l dirty    "±"
  set -l stash    "≡"
  set -l none     " "
  set -l git_s    "["
  set -l git_e    "]"

  set -l normal_color     (set_color normal)
  set -l success_color    (set_color cyan)
  set -l error_color      (set_color $fish_color_error 2> /dev/null; or set_color red --bold)
  set -l directory_color  (set_color $fish_color_quote 2> /dev/null; or set_color brown)
  set -l repository_color (set_color $fish_color_cwd 2> /dev/null; or set_color green)

  set -l prompt_string ""

  # add SSH awareness if applicable
  if test "$theme_ignore_ssh_awareness" != 'yes' -a -n "$SSH_CLIENT$SSH_TTY"
    set prompt_string (whoami)"@"(hostname -s)" "
  end

  # add current working directory
  set prompt_string $prompt_string$directory_color$cwd$normal_color

  # add Git information if in a repository
  if git_is_repo
    # Adjust cwd for short path if needed
    if test "$theme_short_path" = 'yes'
      set root_folder (command git rev-parse --show-toplevel 2> /dev/null)
      set parent_root_folder (dirname $root_folder)
      set cwd (echo $PWD | sed -e "s|$parent_root_folder/||")
    end

    # add Git branch
    set prompt_string $prompt_string" "$git_s$repository_color(git_branch_name)$normal_color" "

    # Add Git status symbols
    set -l list
    if test "$theme_stash_indicator" = yes; and git_is_stashed
      set list $list $stash
    end
    if git_is_touched
      set list $list $dirty
    end
    set prompt_string $prompt_string$list

    # add Git ahead/behind/diverged status if no other symbols
    if test -z "$list"
      set prompt_string $prompt_string(git_ahead $ahead $behind $diverged $none)
    end

    set prompt_string $prompt_string"$git_e "
  end

  if test $last_command_status -eq 0
    set prompt_string $prompt_string$success_color$fish$normal_color
  else
    set prompt_string $prompt_string$error_color$fish$normal_color
  end

  echo -n -s $prompt_string
end
