
# Ultimate git prompt by Zik
#
# Based on git support functions for Evil Tomato by Mohit Cheppudira <mohit@muthanna.com>


# Returns "*" if the current git branch is dirty.
function git_dirty {
	git status --porcelain 2>/dev/null | egrep "^(\?\?| [MD])" > /dev/null && echo "\[\033[01;31m\]*"
}


# Returns "*" if the current git branch has staged changes.
function git_staged {
	git status --porcelain 2>/dev/null | egrep "^[MADRC]" > /dev/null && echo "\[\033[01;32m\]*"
}


# Returns "|stashed:N" where N is the number of stashed states (if any).
function evil_git_stash {
  local stash=`expr $(git stash list 2>/dev/null| wc -l)`
  if [ "$stash" != "0" ]
  then
    echo "\[\033[0;30m\]|s$stash"
  fi
}

# Returns "|unmerged:N" where N is the number of unmerged local and remote branches (if any).
function evil_git_unmerged_branches {
  local unmerged=`expr $(git branch --no-color -a --no-merged | grep -v HEAD | wc -l)`
  if [ "$unmerged" != "0" ]
  then
    echo "\[\033[0;30m\]|unmerged:\[\033[01;31m\]$unmerged"
  fi
}

# Returns "|unpushed:N" where N is the number of unpushed local and remote branches (if any).
function evil_git_unpushed_branches {
  local unpushed=`expr $( (git branch --no-color -r --contains HEAD; \
    git branch --no-color -r) | grep -v HEAD | sort | uniq -u | wc -l )`
  if [ "$unpushed" != "0" ]
  then
    echo "\[\033[0;30m\]|unpushed:\[\033[01;31m\]$unpushed"
  fi
}

function git_unpushed_commits {
	if [ -z "$1" ]; then
		return 0;
	fi
	local unpushed=`expr $( git log --oneline $1.. | wc -l )`
	if [ "$unpushed" != "0" ]; then
		echo "\[\033[0;30m\]|\[\033[01;31m\]>$unpushed"
	fi
	
}

function git_unmerged_commits {
	if [ -z "$1" ]; then
		return 0;
	fi
	local unmerged=`expr $( git log --oneline ..$1 | wc -l )`
	if [ "$unmerged" != "0" ]; then
		echo "\[\033[0;30m\]|\[\033[01;35m\]<$unmerged"
	fi
}


# Get the current git branch name (if available)
git_prompt() {
	# local ref=$(git symbolic-ref HEAD 2>/dev/null | cut -d'/' -f3)
	local ref=$(git branch 2>/dev/null | grep '^\*' | cut -b 3- | sed 's/[\(\)]//g')

	if [ "$ref" != "" ]; then
		if [ "$ref" != "no branch" ]; then
			local remote=`git config branch.$ref.remote`
			local merge=`git config branch.$ref.merge`
			local remotebranch=${remote}/`expr "$merge" : '^refs/heads/\(.*\)$'`
			echo "\n\[\033[0;30m\](\[\033[01;34m\]$ref$(git_dirty)$(git_staged)$(evil_git_stash)$(git_unmerged_commits $remotebranch)$(git_unpushed_commits $remotebranch)\[\033[0;30m\])"
		else
			echo "\n\[\033[0;30m\](\[\033[01;34m\]$ref\[\033[0;33m\](`git describe`)$(git_dirty)$(git_staged)$(evil_git_stash)\[\033[0;30m\])"
		fi
	fi
}

zgitprompt() {
	export PS1="\[\033[01;32m\]\u@\h\[\033[01;34m\] \w$(git_prompt)\[\033[01;34m\] \$\[\033[00m\] "

}

# Attempt at preserving previous PROMPT_COMMAND(s) while not appending zgitprompt again on further invocations
echo $PROMPT_COMMAND | grep -v zgitprompt > /dev/null && export PROMPT_COMMAND="$PROMPT_COMMAND;zgitprompt"

