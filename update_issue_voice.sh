#!/bin/bash
#Использование: update_issue.sh unique_id channel recfile
issueid=$1
channel=$2
recfile=$3
echo $channel
echo $recfile
#конвертация для yandex
sox /tmp/$issueid.wav -t wav -c 1 --rate 16000 -b 16 -e signed-integer /tmp/$issueid.sound.wav
#распознавание на сервере через клиент yandex
text=$(asrclient-cli.py -k yandex_api_key --model general --silent /tmp/$issueid.sound.wav)
echo $text > /tmp/$issueid.txt
#проверка закрытия задачи, переписать, не файл грепать, переменную )
if grep -iE 'Заявка закрыта|Задача закрыта|Заявка решена|Задача решена' /tmp/$issueid.txt; then
	echo "Заявка закрыта"
	statusid=5
else
	echo "Заявка не закрыта"
	statusid=2
fi
#кто поднял трубку?
if [ "$channel" = "inner_number" ]; then 
	assign_id=redmine_user_id1
elif [ "$channel" = "inner_number" ]; then 
	assign_id=redmine_user_id2
else 
    assign_id=redmine_user_group_id1
fi
echo $assign_id
#добавление аудиозаписи 
curl --data-binary "@$recfile" -H "Content-Type: application/octet-stream" -X POST "http://user:pasword@redmine_url/uploads.json" -v > /tmp/$issueid.audio.txt
token=$(cat /tmp/$issueid.audio.txt | jq .upload.token)
echo '{"issue": {"notes": "Добавлена запись разговора","id": '$issueid',"uploads": [{ "token": '$token',"filename": "Запись.wav","content_type": "audio/wav"}]}}' > /tmp/$issueid.recfile.raw
cat /tmp/$issueid.recfile.raw | jq . > /tmp/$issueid.recfile.json
curl -v -H "Content-Type: application/json" -X PUT --data "@/tmp/$issueid.recfile.json" "http://user:pasword@redmine_url/issues/$issueid.json" > /tmp/$issueid.recfile.log
#финальное обновление таска
echo '{"issue":{"id":'$issueid',"assigned_to_id": '$assign_id',"status_id": '$statusid',"notes": "'$text'"}}' > /tmp/$issueid.update.raw
cat /tmp/$issueid.update.raw | jq . > /tmp/$issueid.update.json
curl -v -H "Content-Type: application/json" -X PUT --data "@/tmp/$issueid.update.json" "http://user:pasword@redmine_url/issues/$issueid.json" > /tmp/$issueid.update.log
