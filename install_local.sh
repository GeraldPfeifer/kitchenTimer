#!/bin/bash

ME=$(basename $0)
MD=$(dirname $0)
ED=kitchentimer@blackjackshellac.ca
USR_SHARE=~/.local/share
ICONS=$USR_SHARE/icons/hicolor
EXTENSIONS=$USR_SHARE/gnome-shell/extensions
SCHEMAS=schemas

declare -i DEBUG=${KITCHENTIMER_DEBUG:=0}

puts() {
	echo -e $*
}

log() {
	puts $*
}

info() {
	log "INFO" $*
}

warn() {
	log "WARN" $*
}

die() {
	log "FATAL" $*
	exit 1
}

run() {
	info $*
	$*
	[ $? -ne 0 ] && die "Run command failed: $*"
}

[ $DEBUG -ne 0 ] && warn "DEBUG is enabled"

run cd $MD

[ "$1" == "debug" ] && DEBUG=1

if [ $DEBUG -ne 0 ]; then
	run ./bin/pot_create.sh
fi

run cd $ED

#run mkdir -p $SCHEMAS
#run cp -puv schemas/*.xml $SCHEMAS/
run glib-compile-schemas --strict $SCHEMAS

ldir="$(pwd)"

if [ $DEBUG -ne 0 ]; then
  warn "DEBUG is enabled"
  info "Creating symlink to $ldir"
  run cd $EXTENSIONS
  [ ! -L "$ED" ] && run rm -rfv $ED
  run ln -sf $ldir .
else
  info "Installing extension in $EXTENSIONS/$ED"
  [ -L "$EXTENSIONS/$ED" ] && rm -v $EXTENSIONS/$ED
  run rsync -av . $EXTENSIONS/$ED
fi
run cd $EXTENSIONS/$ED
pwd

info "Alt-F2 'r' to restart gnome shell"

