#!/bin/sh
# Helper script for common maintenance tasks
# Author: Radosław Józwik <timeshift@spelunca.net>

NAME=gerrit
DEFAULT=/etc/default/$NAME
PIDFILE=/run/$NAME.pid

# Use settings from default file
if [ -f "$DEFAULT" ]; then
    . "$DEFAULT"
fi

JAVA_CMD=${JAVA_CMD:=/usr/bin/java}

GERRIT_USER=gerrit
GERRIT_GROUP=gerrit
GERRIT_SITE=/var/lib/gerrit
GERRIT_CACHE=/var/cache/gerrit

GERRIT_WAR="$GERRIT_SITE/bin/gerrit.war"

# Exit if the package is not installed (might not be if it was removed, not purged)
[ -f "$GERRIT_WAR" ] || { echo "$NAME package not installed"; exit 1; }

[ -x "$JAVA_CMD" ] || { echo "java executable not found"; exit 1; }

is_running() {
	[ -f $PIDFILE ] || return 1
    pid=`cat $PIDFILE`
    ps --pid $pid > /dev/null 2>&1 || return 1
    return 0
}


case "$1" in
	site-init)
		if is_running; then
			echo "$NAME is still running, exiting."
			exit 1
		fi

		echo -n "Initializing Gerrit site under $GERRIT_SITE ..."
		GERRIT_TMP="$GERRIT_CACHE/tmp" java -jar "$GERRIT_WAR" init \
			--site-path "$GERRIT_SITE" --batch --no-auto-start > /dev/null 2>&1
		echo " OK"

		# Fix permissions of plugin files as "gerrit.war init" modified them
		chmod 644 "$GERRIT_SITE"/plugins/*

		# Recreate link, because "gerrit.war init" will overwrite it with gerrit.sh
		ln -sf /etc/init.d/gerrit "$GERRIT_SITE"/bin/gerrit.sh

		chown -R $GERRIT_USER:$GERRIT_GROUP /etc/gerrit "$GERRIT_SITE" "$GERRIT_CACHE"
	;;

	site-reindex)
		if is_running; then
			echo "$NAME is still running, exiting."
			exit 1
		fi

		echo -n "Rebuilding Gerrit secondary index ..."
		GERRIT_TMP="$GERRIT_CACHE/tmp" java -jar "$GERRIT_WAR" reindex \
			--site-path "$GERRIT_SITE" > /dev/null 2>&1
		echo " OK"

		chown -R $GERRIT_USER:$GERRIT_GROUP "$GERRIT_SITE" "$GERRIT_CACHE"
	;;

	*)
		script_name="$(basename $0)"
		echo "Usage: $script_name {site-init|site-reindex}" >&2
		exit 3
	;;
esac

exit 0

