#!/bin/bash

get_count ()
{
    if [ -z "$1" ]
    then
        echo "$0: usage: $0 COURSE_CODE"
        return 0
    fi

    course_code=$1
    course_type=$2

    while read counts
    do
        set $counts
        code=$1
        coursetype=$2
        count=$3

        if [ "$code $coursetype" = "$(echo $course_code $course_type)" ]
        then
            return $count
        fi
    done < .count
    return 0
}

set_count ()
{
    if [ -z "$1" ]
    then
        echo "$0: usage: $0 COURSE_CODE"
        return 0
    fi

    course_code=$1
    course_type=$2
    count=$3
    count=$((count+1))

    sed -i "s,\\($course_code $course_type\\).*,\\1 $count,g" .count

    return 0
}


echo "Starting the lecture recording process"

# Weekday and hour of lecture
# date --date="$(stat --format=%w "$FILE")" +"%A %I"

# Check if the recording needs to be renamed
find . -regextype sed -regex '.*-[0-9]\{5\}.amr' |
{
    while read -r path
    do
        FILE=${path##*/}
        DATE=$(date --date="$(stat --format=%w "$FILE")" +"%A %H")

        while read line
        do
            set $line
            day=$1
            hour=$2
            code=$3
            classtype=$4

            get_count $code $classtype
            count=$(printf '%02d' "$?")

            if [[ "$DATE" = $(echo $day $hour) ]]
            then
                NEW_FILE=$(echo $FILE | sed "s,VN-\\([0-9]\\{8\\}\\)-.*,\\1-$code-$classtype$count.amr,")
                mv -v $FILE $NEW_FILE
                set_count $code $classtype $((10#$count))
                break
            fi
        done < .classes
    done
}

echo "Ending the lecture renaming process"

exit 0
