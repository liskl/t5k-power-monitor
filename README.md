t5k-power-monitor
=================

using rrdtool to graph the data from the TED 5000 Power Monitoring Tool

Add to crontab
	* * * * * /home/liskl/TED5000.sh $IP_OF_TED_GATEWAY 0

create initial rrd database
	rrdtool create /var/www/power/ted5000.rrd --start now --step 60 DS:watts:GAUGE:120:0:20 RRA:MAX:0.5:1:525949

update script TED5000.sh

BASE_IMAGE_DIR="/var/www/power"
RRD_FILE_PATH="/var/www/power/ted5000.rrd";
