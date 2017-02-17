#!/bin/sh
#usage:
#sh issues.sh ${CALLERID(name)} ${CALLERID(num)} ${ARG1} ${UNIQUEID}
calleridname=$1
callerid=$2
arg1=$3
uniqueid=$4
echo "Parameters: NAME: '$calleridname'  NUM '$callerid'  ARG1 '$arg1' UID '$uniqueid'" #дебаг
rec=$(echo "/media/rec/rec_in_${calleridname}_${callerid}_${arg1}_${uniqueid}.wav") #получаем полный путь файла записи
echo $rec
echo '{"issue": {"project_id": project_id,"tracker_id": tracker_id,"subject": "Incoming call from '$calleridname' '$callerid'","status_id": "","description": "Заявка создана автоматически","assigned_to_id": group_id,"priority_id": priority_id}}' >> /tmp/$uniqueid.raw
cat /tmp/$uniqueid.raw | jq . >> /tmp/$uniqueid.json # конвертируем в json
curl -v -H "Content-Type: application/json" -X POST --data "@/tmp/$uniqueid.json" "http://user:pasword@redmine_url/issues.json" > /tmp/$uniqueid.log
issueid=$(cat /tmp/$uniqueid.log | jq .issue.id) # получаем номер заявки
echo "SET VARIABLE issueid $issueid" # создаем глобальные переменные - для последующего обновления таска - номер заявки
echo "SET VARIABLE recfile $rec" # создаем глобальные переменные - для последующего обновления таска - имя записи
