### Asterisk Redmine Integration

Проект по интеграции Asterisk в систему Redmine, используя голосовое распознавание от Yandex.

Asterisk integration project in Redmine system using voice recognition by Yandex.

Делается с помощью костылей, bash-скриптинга (от скрипт-кидди) и прочего. Just for fun...

### Руководство по установке

Для корректной работы устанавливаем jq и sox (для конвертации файлов записи из asterisk)

```sh
apt install -y gq sox
```
И Yandex Speech Kit Cloud (я взял версию на python'e)

https://github.com/yandex/speechkitcloud/tree/master/python
