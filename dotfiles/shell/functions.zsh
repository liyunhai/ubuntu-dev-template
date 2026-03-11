# Helper shell functions.

mkcd() {
  # Create a directory and enter it.
  mkdir -p "$1" && cd "$1"
}

extractf() {
  # Convenience extractor for common archive types.
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "file not found: $file" >&2
    return 1
  fi

  case "$file" in
    *.tar.bz2) tar xjf "$file" ;;
    *.tar.gz)  tar xzf "$file" ;;
    *.bz2)     bunzip2 "$file" ;;
    *.rar)     unrar x "$file" ;;
    *.gz)      gunzip "$file" ;;
    *.tar)     tar xf "$file" ;;
    *.tbz2)    tar xjf "$file" ;;
    *.tgz)     tar xzf "$file" ;;
    *.zip)     unzip "$file" ;;
    *.7z)      7z x "$file" ;;
    *) echo "cannot extract: $file" >&2; return 1 ;;
  esac
}
