#!/bin/sh

# Usage: ./changelog.sh '1 week' 2018-07-01' > changelog.txt

INTERVAL=$1 #"1 week"
START_DATE=$2 # "2018-07-01"
LAST_DATE=$(date +%Y-%m-%d -d "+1 day")
FIRST_DATE=$(date +%Y-%m-%d -d "$LAST_DATE - $INTERVAL")

echo "# CHANGELOG\n\n"

display_changelog()
{
	FIRST_DATE=$1
	LAST_DATE=$2
	
	OLD_IFS="$IFS"
	IFS=$'^' 
	
	COMMITS=$(git log --since="$FIRST_DATE" --until="$LAST_DATE" --no-merges --oneline --pretty=format:"^%s")
	COMMITS_COUNT=$(echo $COMMITS | wc -l)
	if [ $COMMITS_COUNT -gt 1 ]; then

		echo "## c $FIRST_DATE по $LAST_DATE\n"

		for COMMIT in $COMMITS
		do
		    COMMIT=$COMMIT | tr -d "\\n\\r"
		    if [ "$COMMIT" != '' ]; then
		    	echo "- $COMMIT" | tr -d "\\n\\r"
		    	echo ''
		    fi
		done

		echo "\n\n"
	fi

	IFS="$OLD_IFS"
}


DAY_OF_WEEK=$(date +%u -d "$LAST_DATE")
if ! [ $DAY_OF_WEEK -eq 1 ]; then
	FIRST_DATE=$LAST_DATE
	while ! [ $DAY_OF_WEEK -eq 1 ]; do
		FIRST_DATE=$(date +%Y-%m-%d -d "$FIRST_DATE - 1 day")
		DAY_OF_WEEK=$(date +%u -d "$FIRST_DATE")
	done

	display_changelog $FIRST_DATE $LAST_DATE
	LAST_DATE=$(date +%Y-%m-%d -d "$FIRST_DATE")
	FIRST_DATE=$(date +%Y-%m-%d -d "$LAST_DATE - $INTERVAL")
fi

while [ $(date +%Y%m%d -d "$FIRST_DATE") -gt $(date +%Y%m%d -d "$START_DATE") ]
do
	display_changelog $FIRST_DATE $LAST_DATE

	LAST_DATE=$(date +%Y-%m-%d -d "$FIRST_DATE")
	FIRST_DATE=$(date +%Y-%m-%d -d "$LAST_DATE - $INTERVAL")
done


if [ $(date +%Y%m%d -d "$FIRST_DATE") -lt $(date +%Y%m%d -d "$START_DATE") ] && [ $(date +%Y%m%d -d "$LAST_DATE") -gt $(date +%Y%m%d -d "$START_DATE") ]; then
	display_changelog $START_DATE $LAST_DATE
fi

