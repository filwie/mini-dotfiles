# env {{{
export TMUX_ALWAYS=0
export VIRTUAL_ENV_DISABLE_PROMPT 0

export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"

export EDITOR=nvim
export VIM_SHELL="$(command -v zsh)"
export TMUX_SHELL="$(command -v zsh)"

export ZSH_DATA_HOME="${XDG_DATA_HOME}/zsh"
export ZSH_CONFIG_HOME="${XDG_CONFIG_HOME}/zsh"
export ZDOTDIR="${ZDOTDIR:-${ZSH_CONFIG_HOME}}"
export ZSHRC="${ZDOTDIR}/.zshrc"
# /env }}}

# path {{{

path_candidates=("${HOME}/.local/bin"
                 "${HOME}/bin"
                 "${CARGO_HOME}/bin"
                 "${GOROOT}/bin"
                 "${GOPATH}/bin"
                 "${JAVA_BIN}")

for path_candidate in "${path_candidates[@]}"; do
    [[ -d "${path_candidate}" ]] && path+=("${path_candidate}")
done

# /path }}}

# aliases {{{
command -v nvim &> /dev/null && alias vim=nvim
alias e $EDITOR
alias o xdg-open
command -v ranger &> /dev/null && alias r ranger


# /aliases }}}

# functions {{{
function gitr () {git rev-parse --show-toplevel}
function cdr () {pushd $(git rev-parse --show-toplevel)}
function start_attach_tmux () {
    command -v tmux &> /dev/null || return
    if [[ -z "${TMUX}" ]]; then
        local session_id="$(tmux ls 2>&1 | grep -vm1 attached | cut -d: -f1)"
        if [[ -z "${session_id}" ]]; then tmux new-session
        else tmux attach-session -t "${session_id}"
        fi
    fi
}
function main () {
    test "${TMUX_ALWAYS}" = 1 && start_attach_tmux
}
# /functions }}}

# history {{{
HISTFILE="${ZSH_DATA_HOME}/zsh_history"
HISTSIZE=100000000
SAVEHIST=100000000
setopt appendhistory inc_append_history
setopt append_history extended_history
setopt hist_expire_dups_first hist_ignore_dups
setopt hist_verify
setopt share_history
# /history }}}

# zsh config {{{
setopt autocd beep extendedglob nomatch notify
setopt autopushd pushdminus pushdsilent pushdtohome pushdignoredups
unsetopt correct_all
setopt multios
setopt cdablevars
setopt prompt_subst
setopt auto_menu         # show completion menu on succesive tab press
setopt complete_in_word
setopt completealiases
setopt always_to_end
zstyle ':completion:*' menu select
zmodload zsh/complist
# /zsh config }}}

# keyboard {{{
bindkey "$terminfo[kRIT5]" forward-word
bindkey "$terminfo[kLFT5]" backward-word
# }}}

# zplugin configuration {{{
declare -A ZPLGM
ZPLGM[HOME_DIR]="${ZSH_DATA_HOME}/zplugin_plugins"
ZPLGM[BIN_DIR]="${ZSH_DATA_HOME}/zplugin"

function install_zplugin () {
    local zplugin_repo_url="https://github.com/zdharma/zplugin.git"
    if ! [[ -d "${zplugin_dir}" ]]; then
        mkdir "${zplugin_dir}"
        git clone "${zplugin_repo_url}" "${zplugin_dir}"
    fi
}

[[ -f "${ZPLGM[BIN_DIR]}/zplugin.zsh" ]] || install_zplugin
source "${ZPLGM[BIN_DIR]}/zplugin.zsh"
# /zplugin configuration }}}

# zplugin plugins {{{
zplugin ice silent wait"0" atinit"zpcompinit; zpcdreplay"
zplugin light zsh-users/zsh-autosuggestions
zplugin light zdharma/fast-syntax-highlighting

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zplugin ice silent wait"0" blockf
zplugin light zsh-users/zsh-completions
zplugin ice silent wait"0" atload"_zsh_autosuggest_start"
zplugin light zsh-users/zsh-autosuggestions


zplugin snippet PZT::modules/directory/init.zsh
zplugin snippet OMZ::plugins/git/git.plugin.zsh
# /zplugin plugins }}}

# theming {{{

zplugin light subnixr/minimal
# /theming }}}

# fzf {{{
fzf_candidates=("${XDG_DATA_HOME}/fzf" "${XDG_CONFIG_HOME}/fzf" "${HOME}/.fzf" "/usr/share/fzf" "/usr/local/opt/fzf")
for fzf_candidate in "${fzf_candidates[@]}"; do
    if [[ -d "${fzf_candidate}" ]]; then
        [[ -d "${fzf_candidate}/bin" ]] && path+=("${fzf_candidate}/bin")
        if ! [[ -f "${fzf_candidate}/fzf.zsh" ]]; then
            "${fzf_candidate}/install" --xdg --all --no-bash --no-fish --no-update-rc
        fi
        source ${fzf_candidate}/fzf.zsh
        export FZF_BASE="${fzf_candidate}"
        break
    fi
done
# /fzf }}}

main
