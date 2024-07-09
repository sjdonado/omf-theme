function fish_right_prompt
  # Show Node.js version if the option is enabled
  if test "$theme_show_node_version" = 'yes'
      set -l node_version (node -v | tr -d '\n')
      set_color green
      echo -n "$node_version "
  end

  set_color $fish_color_autosuggestion 2> /dev/null; or set_color 555
  date "+%H:%M:%S"

  set_color normal
end
