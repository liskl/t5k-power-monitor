#!/bin/bash



BASE_URL=`curl -sm 1 http://$1/history/minutehistory.csv?MTU=$2 | grep -m 1 / | awk -F "," '{print "DATE:"$2" POWER:"$3" COST:"$4" VOLTAGE:"$5"\r\n"}'`
POWER_OF_DATA=`echo $BASE_URL | sed 's/^DATE:.* POWER:\(.*\) COST:.* VOLTAGE:.*$/\1/'`;
#DATE_OF_DATA=`echo $BASE_URL | sed 's/^DATE:\(.*\) POWER:.* COST:.* VOLTAGE:.*$/\1/'`;
#COST_OF_DATA=`echo $BASE_URL | sed 's/^DATE:.* POWER:.* COST:\(.*\) VOLTAGE:.*$/\1/'`;
#VOLTAGE_OF_DATA=`echo $BASE_URL | sed 's/^DATE:.* POWER:.* COST:.* VOLTAGE:\(.*\)$/\1/'`;

#echo `date -d "$DATE_OF_DATA" +%s`;
#echo $POWER_OF_DATA;
#echo $COST_OF_DATA;
#echo $VOLTAGE_OF_DATA;

BASE_IMAGE_DIR="/var/www/power"
RRD_FILE_PATH="/var/www/power/ted5000.rrd";
EXTRA_ARGS="--slope-mode --vertical-label KW/h --lower-limit 0"

rrdtool update $RRD_FILE_PATH N:"$POWER_OF_DATA"

for i in "power-10m.png -600 10-minute"    \
	 "power-1h.png -3600 1-hour"       \
	 "power-4h.png -14400 4-hour"      \
	 "power-8h.png -28800 8-hour"      \
         "power-12h.png -43200 12-hour"    \
         "power-1d.png -86400 1-day"       \
         "power-7d.png -604800 7-day"      \
         "power-30d.png -2592000 30-day"   \
         "power-365d.png -31536000 1-year" \
	 "power.png 1391898592 All-Time" ; do
	set -- $i
	rrdtool graph $BASE_IMAGE_DIR/$1 --title $3 --start $2 --end now \
	$EXTRA_ARGS \
	DEF:watts=$RRD_FILE_PATH:watts:MAX                 \
	VDEF:wattsmax=watts,MAXIMUM                        \
	VDEF:wattsavg=watts,AVERAGE                        \
	VDEF:wattslast=watts,LAST                          \
	VDEF:wattsmin=watts,MINIMUM                        \
	HRULE:wattsavg#00FF00:"Average Usage"              \
	GPRINT:wattsavg:"\: %1.2lf Kw/H\n"                 \
	HRULE:wattsmax#000000:"Maximum Usage"              \
	GPRINT:wattsmax:"\: %1.2lf Kw/H\n"                 \
	HRULE:wattsmin#0000FF:"Minimum Usage"              \
	GPRINT:wattsmin:"\: %1.2lf Kw/H\n"                 \
	AREA:watts#FF0000:"Current Usage"		   \
	GPRINT:wattslast:"\: %1.2lf Kw/H\n"                \
	> /dev/null 2>&1;
done
