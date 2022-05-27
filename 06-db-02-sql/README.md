# Домашнее задание к занятию "6.2. SQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

```yaml
version: "3.9"
services:
  db:
    image: postgres:12
    restart: always
    container_name: postgres
    volumes:
      - ./v1:/var/lib/postgresql/data
      - ./v2:/var/lib/postgresql/dump
    environment:
      POSTGRES_USER: root
      POSTGRES_PASSWORD: password
      POSTGRES_DB: test_db
    ports:
      - 5432:5432
  adminer:
    image: adminer
    restart: always
    ports:
      - 8080:8080
```

`docker-compose up -d`

## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
    - `CREATE USER "test-admin-user";`
    - `CREATE DATABASE test_db;`
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
    ```sql
        CREATE TABLE orders (
            id SERIAL PRIMARY KEY,
            name TEXT,
            price INT
        );
    ```
    ```sql
        CREATE TABLE clients (
            id SERIAL PRIMARY KEY,
            lastname TEXT,
            country TEXT,
            order_id INT,
            FOREIGN KEY (order_id) REFERENCES orders(id)
        );
    ```
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
    - `ALTER USER "test-admin-user" SUPERUSER;`
- создайте пользователя test-simple-user
    - `CREATE USER "test-simple-user";`
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db
    ```sql
        GRANT SELECT, INSERT, UPDATE, DELETE ON clients TO "test-simple-user";
        GRANT SELECT, INSERT, UPDATE, DELETE ON orders TO "test-simple-user";
    ```

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,
```sql
    SELECT *
        FROM pg_catalog.pg_tables
        WHERE schemaname != 'pg_catalog' AND 
        schemaname != 'information_schema';
```
```
schemaname|tablename|tableowner|tablespace|hasindexes|hasrules|hastriggers|rowsecurity|
----------+---------+----------+----------+----------+--------+-----------+-----------+
public    |orders   |root      |          |true      |false   |true       |false      |
public    |clients  |root      |          |true      |false   |true       |false      |
```
- описание таблиц (describe)
```sql
    SELECT column_name, data_type from information_schema.columns WHERE table_name = 'orders';
```
```
column_name|data_type|
-----------+---------+
id         |integer  |
name       |text     |
price      |integer  |
```
```sql
    SELECT column_name, data_type from information_schema.columns WHERE table_name = 'clients';
```
```
column_name|data_type|
-----------+---------+
id         |integer  |
lastname   |text     |
country    |text     |
order_id   |integer  |
```
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
```sql
SELECT * 
	FROM information_schema.role_table_grants 
	WHERE grantee='test-simple-user';
```
```
grantor|grantee         |table_catalog|table_schema|table_name|privilege_type|is_grantable|with_hierarchy|
-------+----------------+-------------+------------+----------+--------------+------------+--------------+
root   |test-simple-user|test_db      |public      |orders    |INSERT        |NO          |NO            |
root   |test-simple-user|test_db      |public      |orders    |SELECT        |NO          |YES           |
root   |test-simple-user|test_db      |public      |orders    |UPDATE        |NO          |NO            |
root   |test-simple-user|test_db      |public      |orders    |DELETE        |NO          |NO            |
root   |test-simple-user|test_db      |public      |clients   |INSERT        |NO          |NO            |
root   |test-simple-user|test_db      |public      |clients   |SELECT        |NO          |YES           |
root   |test-simple-user|test_db      |public      |clients   |UPDATE        |NO          |NO            |
root   |test-simple-user|test_db      |public      |clients   |DELETE        |NO          |NO            |
```
- список пользователей с правами над таблицами test_db
```sql
SELECT * 
	FROM information_schema.role_table_grants;
```

## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|
```sql
INSERT INTO orders (id, name, price) VALUES
	('Шоколад', 10),
	('Принтер', 3000),
	('Книга', 500),
	('Монитор', 7000),
	('Гитара', 4000);
```

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

```sql
INSERT INTO clients (lastname, country) VALUES
	('Иванов', 'USA'),
	('Петров', 'Canada'),
	('Бах', 'Japan'),
	('Дио', 'Russia'),
	('Blackmore', 'Russia');
```

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.
```sql
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM clients;
```
```
count|
-----+
    5|
```

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.
```sql
UPDATE clients
	SET order_id = (SELECT id FROM orders WHERE name = 'Книга')
	WHERE lastname = 'Иванов';

UPDATE clients
	SET order_id = (SELECT id FROM orders WHERE name = 'Монитор')
	WHERE lastname = 'Петров';

UPDATE clients
	SET order_id = (SELECT id FROM orders WHERE name = 'Гитара')
	WHERE lastname = 'Бах';
```

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.

```sql
    SELECT *
	FROM clients
	WHERE order_id IS NOT NULL;
```
```
id|lastname|country|order_id|
--+--------+-------+--------+
 1|Иванов  |USA    |       3|
 2|Петров  |Canada |       4|
 3|Бах     |Japan  |       5|
```
 
Подсказк - используйте директиву `UPDATE`.

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).
```sql
EXPLAIN SELECT *
	FROM clients
	WHERE order_id IS NOT NULL;
```

Приведите получившийся результат и объясните что значат полученные значения.
```
Seq Scan on clients  (cost=0.00..18.10 rows=806 width=72)
  Filter: (order_id IS NOT NULL)
```
```
    отображает информацию выполнения запроса:
    - приблизительную стоимость запуска
    - приблизительная общая стоимость
    - ожидаемое число строк для данного узла
    - ожидаемый средний размер строк (в байтах)
```

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

```
docker exec -t postgres pg_dump -h localhost test_db -f /var/lib/postgresql/dump/dump.sql
```

Остановите контейнер с PostgreSQL (но не удаляйте volumes).
```
docker-compose down
```

Поднимите новый пустой контейнер с PostgreSQL.
```
docker-compose -f docker-compose-2.yaml up -d
```

Восстановите БД test_db в новом контейнере.

```
docker exec -t postgres2 psql -U root -d test_db -f /var/lib/postgresql/dump/dump.sql
```

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 
