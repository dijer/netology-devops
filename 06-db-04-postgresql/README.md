# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

```yaml
version: "3.9"
services:
  db:
    image: postgres:13
    restart: always
    container_name: postgres
    volumes:
      - ./test_data:/etc/test_data
      - ./data:/var/lib/postgresql/data
    environment:
      POSTGRES_USER: root
      POSTGRES_PASSWORD: password
      POSTGRES_DB: test_database
    ports:
      - 5432:5432

```

Подключитесь к БД PostgreSQL используя `psql`.

`psql -d test_database`

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
  - `\l`
- подключения к БД
  - `-d`
- вывода списка таблиц
  - `\dt`
- вывода описания содержимого таблиц
  - `\dS+ [TABLE_NAME]`
- выхода из psql
  - `\q`

## Задача 2

Используя `psql` создайте БД `test_database`.
`CREATE DATABASE test_database;`

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

`docker exec -t postgres psql -U root -d test_database -f /etc/test_data/test_dump.sql`

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.
```
test_database=# ANALYZE VERBOSE orders;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
ANALYZE
```

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

```
test_database=# SELECT MAX(avg_width) FROM pg_stats WHERE tablename = 'orders';
 max 
-----
  16
```

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.
```sql
BEGIN;
ALTER TABLE orders RENAME TO orders_old;

CREATE TABLE orders (
	id serial4 NOT NULL,
	title varchar(80) NOT NULL,
	price int4 NULL DEFAULT 0
) PARTITION BY RANGE (price);

CREATE TABLE orders_1 PARTITION OF orders FOR VALUES FROM (499) TO (MAXVALUE);

CREATE TABLE orders_2
	PARTITION OF orders FOR VALUES FROM (0) TO (499);

INSERT INTO orders 
	(SELECT * FROM orders_old);

DROP TABLE orders_old;
COMMIT;
```

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

```
Можно было сразу заложить шардирование
```

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.
`pg_dump -d test_database -f /etc/test_data/dump.sql`

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?
```
добавил бы unique, но unique не применяются к шардированной таблице
ALTER TABLE orders
	ADD CONSTRAINT unique_title UNIQUE (title);
```
