#!/usr/bin/env bash
# lib/tui.sh — SPECTRA TUI Rendering Engine
# Pure-bash ANSI terminal UI: headers, menus, spinners, summaries.
# Requires core.sh to be sourced first (colors, box chars, utilities).
#
# SPECTRA v4.2.0 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

[[ -n "${_SPECTRA_TUI_LOADED:-}" ]] && return 0
readonly _SPECTRA_TUI_LOADED=1

# ─── Header ───────────────────────────────────────────────────────────────────
# tui_header [subtitle]
tui_header() {
  local subtitle="${1:-Intelligent Planning for AI-Assisted Development}"
  local width=60
  local inner=$((width - 2))

  local title="SPECTRA v${SPECTRA_VERSION}"
  local t_pad=$(( (inner - ${#title}) / 2 ))
  local s_pad=$(( (inner - ${#subtitle}) / 2 ))

  echo ""
  echo -e "${BOLD}${CYAN}${BOX_TL}$(repeat_char "$BOX_H" $inner)${BOX_TR}${NC}"
  printf "${BOLD}${CYAN}${BOX_V}${NC}%*s${BOLD}${CYAN}%s${NC}%*s${BOLD}${CYAN}${BOX_V}${NC}\n" \
    "$t_pad" "" "$title" $(( inner - t_pad - ${#title} )) ""
  printf "${BOLD}${CYAN}${BOX_V}${NC}%*s${DIM}%s${NC}%*s${BOLD}${CYAN}${BOX_V}${NC}\n" \
    "$s_pad" "" "$subtitle" $(( inner - s_pad - ${#subtitle} )) ""
  echo -e "${BOLD}${CYAN}${BOX_BL}$(repeat_char "$BOX_H" $inner)${BOX_BR}${NC}"
  echo ""
}

# ─── Section divider ──────────────────────────────────────────────────────────
# tui_section <title>
tui_section() {
  local title=" $1 "
  local width
  width=$(term_width)
  [[ $width -gt 70 ]] && width=70
  local line_len=$(( (width - ${#title}) / 2 ))
  echo ""
  echo -e "${BOLD}$(repeat_char "$BOX_DIV_H" $line_len)${CYAN}${title}${NC}${BOLD}$(repeat_char "$BOX_DIV_H" $line_len)${NC}"
  echo ""
}

# ─── Numbered selection menu ──────────────────────────────────────────────────
# tui_select <result_var> <prompt> <option1> <option2> ...
# Sets result_var to the selected option string.
# Non-interactive: reads from SPECTRA_SELECT_<RESULT_VAR> env var or picks option 1.
tui_select() {
  local result_var="$1"
  local prompt="$2"
  shift 2
  local options=("$@")
  local count=${#options[@]}

  # Non-interactive fast-path
  if [[ ! -t 0 || "${SPECTRA_YES}" == "1" ]]; then
    local env_var="SPECTRA_SELECT_${result_var^^}"
    local env_val="${!env_var:-}"
    if [[ -n "$env_val" ]]; then
      printf -v "$result_var" '%s' "$env_val"
    else
      printf -v "$result_var" '%s' "${options[0]}"
    fi
    log_dim "Auto-selected: ${!result_var}"
    return 0
  fi

  echo -e "${BOLD}${prompt}${NC}"
  echo ""
  local i
  for (( i=0; i<count; i++ )); do
    echo -e "  ${CYAN}$((i+1))${NC}. ${options[$i]}"
  done
  echo ""

  local choice
  while true; do
    printf "  ${DIM}Enter number [1-${count}]:${NC} "
    read -r choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= count )); then
      printf -v "$result_var" '%s' "${options[$((choice-1))]}"
      break
    fi
    log_warn "Please enter a number between 1 and ${count}."
  done
  echo ""
}

# ─── Yes/No confirmation ──────────────────────────────────────────────────────
# tui_confirm <prompt> [default=y]
# Returns 0 for yes, 1 for no.
tui_confirm() {
  local prompt="$1"
  local default="${2:-y}"

  if [[ ! -t 0 || "${SPECTRA_YES}" == "1" ]]; then
    log_dim "Auto-confirmed: yes"
    return 0
  fi

  local hint
  [[ "$default" == "y" ]] && hint="[Y/n]" || hint="[y/N]"

  printf "  ${BOLD}${prompt}${NC} ${DIM}${hint}${NC} "
  local answer
  read -r answer
  answer="${answer:-$default}"
  echo ""

  [[ "${answer,,}" == "y" ]]
}

# ─── Spinner ──────────────────────────────────────────────────────────────────
# Usage:
#   tui_spinner_start "Scanning project..."
#   <do work>
#   tui_spinner_stop
_SPINNER_PID=""
_SPINNER_MSG=""

tui_spinner_start() {
  _SPINNER_MSG="${1:-Working...}"
  if [[ ! -t 1 ]]; then
    log_info "$_SPINNER_MSG"
    return 0
  fi
  local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  (
    local i=0
    while true; do
      printf "\r  ${CYAN}${frames[$i]}${NC} ${_SPINNER_MSG}" >&2
      i=$(( (i+1) % ${#frames[@]} ))
      sleep 0.1
    done
  ) &
  _SPINNER_PID=$!
  disown "$_SPINNER_PID" 2>/dev/null || true
}

tui_spinner_stop() {
  if [[ -n "$_SPINNER_PID" ]]; then
    kill "$_SPINNER_PID" 2>/dev/null || true
    wait "$_SPINNER_PID" 2>/dev/null || true
    _SPINNER_PID=""
    printf "\r\033[K" >&2
  fi
}

# ─── Key-value summary box ────────────────────────────────────────────────────
# tui_summary <title> <key1> <val1> <key2> <val2> ...
tui_summary() {
  local title="$1"
  shift
  local pairs=("$@")

  local width=62
  local inner=$((width - 2))
  local key_width=20

  echo -e "${BOX_TL_THIN}$(repeat_char "$BOX_H_THIN" $inner)${BOX_TR_THIN}"
  local t_pad=$(( (inner - ${#title}) / 2 ))
  printf "${BOX_V_THIN}%*s${BOLD}%s${NC}%*s${BOX_V_THIN}\n" \
    "$t_pad" "" "$title" $(( inner - t_pad - ${#title} )) ""
  echo -e "${BOX_DIV_L}$(repeat_char "$BOX_DIV_H" $inner)${BOX_DIV_R}"

  local i
  for (( i=0; i<${#pairs[@]}; i+=2 )); do
    local key="${pairs[$i]}"
    local val="${pairs[$((i+1))]}"
    local key_disp
    key_disp=$(printf "%-${key_width}s" "$key")
    # Truncate val if too long
    local val_max=$(( inner - key_width - 5 ))
    if (( ${#val} > val_max )); then
      val="${val:0:$((val_max-3))}..."
    fi
    printf "${BOX_V_THIN}  ${DIM}%s${NC}  ${val}%*s${BOX_V_THIN}\n" \
      "$key_disp" $(( inner - key_width - 4 - ${#val} )) ""
  done

  echo -e "${BOX_BL_THIN}$(repeat_char "$BOX_H_THIN" $inner)${BOX_BR_THIN}"
  echo ""
}

# ─── Success banner ───────────────────────────────────────────────────────────
tui_success() {
  local message="${1:-Installation complete!}"
  local width=62
  local inner=$((width - 2))
  local m_pad=$(( (inner - ${#message}) / 2 ))

  echo ""
  echo -e "${BOLD}${GREEN}${BOX_TL}$(repeat_char "$BOX_H" $inner)${BOX_TR}${NC}"
  printf "${BOLD}${GREEN}${BOX_V}${NC}%*s${BOLD}${GREEN}%s${NC}%*s${BOLD}${GREEN}${BOX_V}${NC}\n" \
    "$m_pad" "" "$message" $(( inner - m_pad - ${#message} )) ""
  echo -e "${BOLD}${GREEN}${BOX_BL}$(repeat_char "$BOX_H" $inner)${BOX_BR}${NC}"
  echo ""
}

# ─── Error banner ─────────────────────────────────────────────────────────────
tui_error() {
  local message="${1:-Something went wrong.}"
  echo ""
  echo -e "${BOLD}${RED}✗ ${message}${NC}"
  echo ""
}

# ─── File list display ────────────────────────────────────────────────────────
# tui_file_list <title> <file1> <desc1> <file2> <desc2> ...
tui_file_list() {
  local title="$1"
  shift
  echo -e "  ${BOLD}${title}${NC}"
  local i
  for (( i=0; i<$#; i+=2 )); do
    local f="${!i}"
    local d
    local j=$((i+1))
    d="${!j}"
    echo -e "    ${GREEN}▸${NC} ${CYAN}${f}${NC}  ${DIM}${d}${NC}"
  done
  echo ""
}

# ─── Progress step indicator ──────────────────────────────────────────────────
# tui_progress <current> <total> <label>
tui_progress() {
  local current="$1" total="$2" label="$3"
  echo -e "  ${DIM}[${current}/${total}]${NC} ${label}"
}
