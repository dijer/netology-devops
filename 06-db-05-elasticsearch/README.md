# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [elasticsearch:7](https://hub.docker.com/_/elasticsearch) как базовый:

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib` 
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения
- обратите внимание на настройки безопасности такие как `xpack.security.enabled` 
- если докер образ не запускается и падает с ошибкой 137 в этом случае может помочь настройка `-e ES_HEAP_SIZE`
- при настройке `path` возможно потребуется настройка прав доступа на директорию

Далее мы будем работать с данным экземпляром elasticsearch.

```docker
FROM centos:7

EXPOSE 9200 9300

USER 0

RUN export ES_HOME="/var/lib/elasticsearch" && \
    yum -y install wget && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.17.0-linux-x86_64.tar.gz && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.17.0-linux-x86_64.tar.gz.sha512 && \
    sha512sum -c elasticsearch-7.17.0-linux-x86_64.tar.gz.sha512 && \
    tar -xzf elasticsearch-7.17.0-linux-x86_64.tar.gz && \
    rm -f elasticsearch-7.17.0-linux-x86_64.tar.gz* && \
    mv elasticsearch-7.17.0 ${ES_HOME} && \
    useradd -m -u 1000 elasticsearch && \
    chown elasticsearch:elasticsearch -R ${ES_HOME} && \
    yum -y remove wget && \
    yum clean all

COPY --chown=elasticsearch:elasticsearch config/elasticsearch.yml /var/lib/elasticsearch/config/

USER 1000
ENV ES_HOME="/var/lib/elasticsearch" \
    ES_PATH_CONF="/var/lib/elasticsearch/config"

WORKDIR ${ES_HOME}
CMD ["sh", "-c", "${ES_HOME}/bin/elasticsearch"]
```

```
docker build . -t dijer/devops-elasticsearch
docker run --rm -d --name elasticsearch -p 9200:9200 -p 9300:9300 dijer/devops-elasticsearch
```

```json
// http://127.0.0.1:9200/
{
  "name" : "953e935f94da",
  "cluster_name" : "netology_test",
  "cluster_uuid" : "_na_",
  "version" : {
    "number" : "7.17.0",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "bee86328705acaa9a6daede7140defd4d9ec56bd",
    "build_date" : "2022-01-28T08:36:04.875279988Z",
    "build_snapshot" : false,
    "lucene_version" : "8.11.1",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

```
curl --location --request PUT 'localhost:9200/ind-1?pretty' \
--header 'Content-Type: application/json' \
--data-raw '{
    "settings": {
        "number_of_shards": 1,
        "number_of_replicas": 0
    }
}'

{
    "acknowledged": true,
    "shards_acknowledged": true,
    "index": "ind-1"
}
```

```
curl --location --request PUT 'http://127.0.0.1:9200/ind-2?pretty' \
--header 'Content-Type: application/json' \
--data-raw '{
    "settings": {
        "number_of_shards": 2,
        "number_of_replicas": 1
    }
}'

{
    "acknowledged": true,
    "shards_acknowledged": true,
    "index": "ind-2"
}
```

```
curl --location --request PUT 'http://127.0.0.1:9200/ind-3?pretty' \
--header 'Content-Type: application/json' \
--data-raw '{
  "settings": {
    "number_of_shards": 4,
    "number_of_replicas": 2
  }
}'

{
    "acknowledged": true,
    "shards_acknowledged": true,
    "index": "ind-3"
}
```

Получите состояние кластера `elasticsearch`, используя API.

```
http://localhost:9200/_cat/indices?v

health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases bMSUrgCvTZeRMKqWJTi1BQ   1   0         40            0     38.2mb         38.2mb
green  open   ind-1            7vE51qzlRjOdPQhUMKVm-A   1   0          0            0       226b           226b
yellow open   ind-3            aJzLWwJ2S1Oo4Q03k0-7ng   4   2          0            0       904b           904b
yellow open   ind-2            NiZ-8vtcSZyIgDk3smfrrQ   2   1          0            0       452b           452b
```

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

```
т.к. у этих индексов указаны реплики, но нет узлов для них
```

Удалите все индексы.
```
curl --location --request DELETE 'http://127.0.0.1:9200/_all' \
--data-raw ''

{
    "acknowledged": true
}
```

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

```
curl --location --request PUT 'http://127.0.0.1:9200/_snapshot/netology_backup?pretty' \
--header 'Content-Type: application/json' \
--data-raw '{
  "type": "fs",
  "settings": {
    "location": "/var/lib/elasticsearch/snapshots",
    "compress": true
  }
}'

{
    "acknowledged": true
}
```

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

```
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  }
}

{
    "acknowledged": true,
    "shards_acknowledged": true,
    "index": "test"
}

http://localhost:9200/_cat/indices?v

health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases Blv5ANchQWmuMfpvGmn5Bg   1   0         40            0     38.2mb         38.2mb
green  open   test             t_J7iZXWTwyZcxYozIP6OQ   1   0          0            0       226b           226b
```

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

```
curl --location --request PUT 'http://127.0.0.1:9200/_snapshot/netology_backup/snapshot4?wait_for_completion=true&pretty' \
--header 'Content-Type: application/json' \
--data-raw '{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  }
}'

{
    "snapshot": {
        "snapshot": "snapshot4",
        "uuid": "Dasb5UWrTRGH8HoQIfxCNQ",
        "repository": "netology_backup",
        "version_id": 7170099,
        "version": "7.17.0",
        "indices": [
            "test",
            ".geoip_databases",
            ".ds-ilm-history-5-2022.06.05-000001",
            ".ds-.logs-deprecation.elasticsearch-default-2022.06.05-000001"
        ],
        "data_streams": [
            "ilm-history-5",
            ".logs-deprecation.elasticsearch-default"
        ],
        "include_global_state": true,
        "state": "SUCCESS",
        "start_time": "2022-06-05T19:38:41.566Z",
        "start_time_in_millis": 1654457921566,
        "end_time": "2022-06-05T19:38:41.766Z",
        "end_time_in_millis": 1654457921766,
        "duration_in_millis": 200,
        "failures": [],
        "shards": {
            "total": 4,
            "failed": 0,
            "successful": 4
        },
        "feature_states": [
            {
                "feature_name": "geoip",
                "indices": [
                    ".geoip_databases"
                ]
            }
        ]
    }
}

docker exec -it elasticsearch ls /var/lib/elasticsearch/snapshots
---
index-3                          meta-yW9kmf75RuikpnXvVt4n0Q.dat
index.latest                     snap-ALpzUjXHS1edqRWZSo9oRg.dat
indices                          snap-Dasb5UWrTRGH8HoQIfxCNQ.dat
meta-ALpzUjXHS1edqRWZSo9oRg.dat  snap-k0eF2QpHRLK4lf4P8lOPAg.dat
meta-Dasb5UWrTRGH8HoQIfxCNQ.dat  snap-yW9kmf75RuikpnXvVt4n0Q.dat
meta-k0eF2QpHRLK4lf4P8lOPAg.dat
```

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

```
curl --location --request DELETE 'http://127.0.0.1:9200/test?pretty'

{
    "acknowledged": true
}

curl --location --request PUT 'http://127.0.0.1:9200/test-2?pretty' \
--header 'Content-Type: application/json' \
--data-raw '{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  }
}'

{
    "acknowledged": true,
    "shards_acknowledged": true,
    "index": "test-2"
}

http://localhost:9200/_cat/indices?v
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases Blv5ANchQWmuMfpvGmn5Bg   1   0         40            0     38.2mb         38.2mb
green  open   test-2           HaRKfcbGTwirxjSNBLYCNw   1   0          0            0       226b           226b
```

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

```
curl --location --request POST 'http://127.0.0.1:9200/_snapshot/netology_backup/snapshot4/_restore' \
--header 'Content-Type: application/json' \
--data-raw '{
  "indices": "my-index-*,my-other-index-*",
  "ignore_unavailable": true,
  "include_global_state": true
}'

{
    "accepted": true
}
```


Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`
