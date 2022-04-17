# Домашнее задание к занятию "4.3. Языки разметки JSON и YAML"


## Обязательная задача 1
Мы выгрузили JSON, который получили через API запрос к нашему сервису:
```json
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            }
            { "name" : "second",
            "type" : "proxy",
            "ip : 71.78.22.43
            }
        ]
    }
```
  Нужно найти и исправить все ошибки, которые допускает наш сервис

### Ваш скрипт:
```json
{ "info" : "Sample JSON output from our service\t",
  "elements" :[
      { "name" : "first",
      "type" : "server",
      "ip" : 7175 
      },
      { "name" : "second",
      "type" : "proxy",
      "ip" : "71.78.22.43"
      }
  ]
}

```

## Обязательная задача 2
В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: `{ "имя сервиса" : "его IP"}`. Формат записи YAML по одному сервису: `- имя сервиса: его IP`. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import socket
import json
import yaml

services = {
  "drive.google.com": "64.233.164.19",
  "mail.google.com": "142.250.74.133",
  "google.com": "142.250.74.46"
}

for key in services:
  ip = socket.gethostbyname(key)
  if (services[key] != ip):
    print('[ERROR] ' + key + ' IP mismatch: ' + services[key] + ' ' + ip)
    services[key] = ip
  else:
    print(key + ': ' + socket.gethostbyname(key))

jsonFile = './services.json'
with open(jsonFile, 'w') as outfile:
  outfile.write(json.dumps(services))

yamlFile = './services.yml'
with open(yamlFile, 'w') as outfile:
  outfile.write(yaml.dump(services))

```

### Вывод скрипта при запуске при тестировании:
```
[ERROR] drive.google.com IP mismatch: 64.233.164.19 64.233.164.194
mail.google.com: 142.250.74.133
google.com: 142.250.74.46
```

### json-файл(ы), который(е) записал ваш скрипт:
```json
{"drive.google.com": "64.233.164.194", "mail.google.com": "142.250.74.133", "google.com": "142.250.74.46"}
```

### yml-файл(ы), который(е) записал ваш скрипт:
```yaml
drive.google.com: 64.233.164.194
google.com: 142.250.74.46
mail.google.com: 142.250.74.133
```

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Так как команды в нашей компании никак не могут прийти к единому мнению о том, какой формат разметки данных использовать: JSON или YAML, нам нужно реализовать парсер из одного формата в другой. Он должен уметь:
   * Принимать на вход имя файла
   * Проверять формат исходного файла. Если файл не json или yml - скрипт должен остановить свою работу
   * Распознавать какой формат данных в файле. Считается, что файлы *.json и *.yml могут быть перепутаны
   * Перекодировать данные из исходного формата во второй доступный (из JSON в YAML, из YAML в JSON)
   * При обнаружении ошибки в исходном файле - указать в стандартном выводе строку с ошибкой синтаксиса и её номер
   * Полученный файл должен иметь имя исходного файла, разница в наименовании обеспечивается разницей расширения файлов

### Ваш скрипт:
```python
#!/usr/bin/env python3

import socket
import json
import yaml
import sys
import pathlib

file = None

if len(sys.argv) > 1:
  file = sys.argv[1]
else:
  print('no file in args!')
  quit()

def getFilePath(filepath, extension):
  p = pathlib.Path(filepath)
  return p.with_name(p.name.split('.')[0]).with_suffix('.' + extension)

if file.lower().endswith('.json'):
  with open(file, 'r') as jsonfile:
    jsonObject = json.load(jsonfile)
    with open(getFilePath(file, 'yml'), 'w') as yamlFile:
      yamlFile.write(yaml.dump(jsonObject))
      quit()
elif file.lower().endswith('.yml'):
  with open(file, 'r') as yamlfile:
    yamlObject = yaml.load(yamlfile)
    with open(getFilePath(file, 'json'), 'w') as jsonFile:
      jsonFile.write(json.dumps(yamlObject))
      quit()
else:
  print('only yml or json extension')
  quit()

```

### Пример работы скрипта:
```
services.json:
{"drive.google.com": "64.233.164.194", "google.com": "142.250.74.46", "mail.google.com": "142.250.74.133"}

my.py ./services.json

writes to services.yml:

drive.google.com: 64.233.164.194
google.com: 142.250.74.46
mail.google.com: 142.250.74.133
```
