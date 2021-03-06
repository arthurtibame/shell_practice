#!/bin/bash
#author: arthurtibame
#github: https://github.com/arthurtibame

unformat_folder=$1
search_dir=$(pwd)/$1
output_dir=$(pwd)/output
combine_dir=$(pwd)/combined

#STEP0. check argument
if [ $# -eq 0 ]; then
	echo "please input extract file (.tar)"
    exit 1
fi

#STEP0. extract file
mkdir $1 && \
tar -xvzf $1.tar -C $search_dir > /dev/null 2>&1

#STEP1. format json file in first argument
python3 $(pwd)/utils/json_formatter.py $1

#STEP2. prepare output dir
[ ! -d "$output_dir" ] && mkdir -p "$output_dir"

#STEP3. filter all json files
function filter_json2csv (){
	for entry in "$search_dir"/*.json	
	
	do
		a=$(basename $entry)	  
		jq -r '.[] | select(.cars[].cm=="vios_2000") | [.iot_id, .timestamp, .gps_time, .lat, .lon, .cars[].cm, .cars[].cm_conf, .cars[].lp, .cars[].lp_cof, .cars[].xywh[0], .cars[].xywh[1], .cars[].xywh[2], .cars[].xywh[3], .cars[].color] | @csv' ${entry} > $(pwd)/output/${entry##*/}-vios.csv
		jq -r '.[] | select(.cars[].cm=="yaris_2006") | [.iot_id, .timestamp, .gps_time, .lat, .lon, .cars[].cm, .cars[].cm_conf, .cars[].lp, .cars[].lp_cof, .cars[].xywh[0], .cars[].xywh[1], .cars[].xywh[2], .cars[].xywh[3], .cars[].color] | @csv' ${entry} > $(pwd)/output/${entry##*/}-yaris.csv
		jq -r '.[] | select(.cars[].cm=="tiida_2013") | [.iot_id, .timestamp, .gps_time, .lat, .lon, .cars[].cm, .cars[].cm_conf, .cars[].lp, .cars[].lp_cof, .cars[].xywh[0], .cars[].xywh[1], .cars[].xywh[2], .cars[].xywh[3], .cars[].color] | @csv' ${entry} > $(pwd)/output/${entry##*/}-tida.csv
		jq -r '.[] | select(.cars[].cm=="rav4_2013") | [.iot_id, .timestamp, .gps_time, .lat, .lon, .cars[].cm, .cars[].cm_conf, .cars[].lp, .cars[].lp_cof, .cars[].xywh[0], .cars[].xywh[1], .cars[].xywh[2], .cars[].xywh[3], .cars[].color] | @csv' ${entry} > $(pwd)/output/${entry##*/}-rav4.csv
		jq -r '.[] | select(.cars[].cm=="crv_2017") | [.iot_id, .timestamp, .gps_time, .lat, .lon, .cars[].cm, .cars[].cm_conf, .cars[].lp, .cars[].lp_cof, .cars[].xywh[0], .cars[].xywh[1], .cars[].xywh[2], .cars[].xywh[3], .cars[].color] | @csv' ${entry} > $(pwd)/output/${entry##*/}-crv.csv
		jq -r '.[] | select(.cars[].cm=="altis_2014") | [.iot_id, .timestamp, .gps_time, .lat, .lon, .cars[].cm, .cars[].cm_conf, .cars[].lp, .cars[].lp_cof, .cars[].xywh[0], .cars[].xywh[1], .cars[].xywh[2], .cars[].xywh[3], .cars[].color] | @csv' ${entry} > $(pwd)/output/${entry##*/}-altis.csv
		jq -r '.[] | select(.cars[].cm=="fit_2015") | [.iot_id, .timestamp, .gps_time, .lat, .lon, .cars[].cm, .cars[].cm_conf, .cars[].lp, .cars[].lp_cof, .cars[].xywh[0], .cars[].xywh[1], .cars[].xywh[2], .cars[].xywh[3], .cars[].color] | @csv' ${entry} > $(pwd)/output/${entry##*/}-fit.csv
		jq -r '.[] | select(.cars[].cm=="livina_2014") | [.iot_id, .timestamp, .gps_time, .lat, .lon, .cars[].cm, .cars[].cm_conf, .cars[].lp, .cars[].lp_cof, .cars[].xywh[0], .cars[].xywh[1], .cars[].xywh[2], .cars[].xywh[3], .cars[].color] | @csv' ${entry} > $(pwd)/output/${entry##*/}livina.csv	
	done
	echo "Filtered json and saved to csv file"
}

filter_json2csv
#STEP4. clean empty csv files
find $output_dir -size  0 -print -delete > /dev/null 2>&1
#STEP5. remove dir
rm -rf $1

function all_cars(){
	# get all cars from cars.txt to list 
	IFS=$'\r\n' GLOBIGNORE='*' command eval  'ALL_CARS=($(cat $(pwd)/utils/cars.txt))'	
	printf "%s\n" ${ALL_CARS[*]}
}

mkdir $1;

#STEP6. combine .csv	
for car in $(all_cars);
do
	ls -v $output_dir/*$car.csv | xargs cat >> $1/$car.csv ||  echo "catch $car"
done
find $1 -size  0 -print -delete > /dev/null 2>&1

rm -rf $output_dir


#STEP7. push to hadoop 
hadoop fs -put $search_dir hdfs://master/user/spark/test_shell