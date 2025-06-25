#!/bin/sh

nt_rate=$(jq -r '.nt_rate' /data/options.json)
vt_rate=$(jq -r '.vt_rate' /data/options.json)
nt_hours=$(jq -r '.nt_hours[]' /data/options.json)
MQTT_HOST=$(jq -r '.mqtt_host' /data/options.json)
MQTT_PORT=$(jq -r '.mqtt_port' /data/options.json)
MQTT_USER=$(jq -r '.mqtt_user' /data/options.json)
MQTT_PASS=$(jq -r '.mqtt_pass' /data/options.json)

spot_price=$(curl -s "https://api.nanogreen.energy/spot" | jq '.current_price')
now=$(date +%H:%M)
is_nt=0
for range in $nt_hours; do
    start=$(echo $range | cut -d'-' -f1)
    end=$(echo $range | cut -d'-' -f2)
    if [ "$now" \> "$start" ] && [ "$now" \< "$end" ]; then
        is_nt=1
        break
    fi
done

if [ "$is_nt" -eq 1 ]; then
    tarif="NT"
    total_price=$(echo "$spot_price + $nt_rate" | bc -l)
else
    tarif="VT"
    total_price=$(echo "$spot_price + $vt_rate" | bc -l)
fi

mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASS" -t "elektro/cena_total" -m "$total_price" -r
mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASS" -t "elektro/tarif" -m "$tarif" -r
