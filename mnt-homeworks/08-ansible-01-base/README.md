# Домашнее задание к занятию "08.01 Введение в Ansible"

## Основная часть
1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте какое значение имеет факт `some_fact` для указанного хоста при выполнении playbook'a.
  ```
ansible-playbook -i ./inventory/test.yml site.yml 
PLAY [Print os facts] ************************************************************************************************************************************
TASK [Gathering Facts] ***********************************************************************************************************************************ok: [localhost]

TASK [Print OS] ******************************************************************************************************************************************ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ****************************************************************************************************************************************ok: [localhost] => {
    "msg": 12
}

PLAY RECAP ***********************************************************************************************************************************************localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
  ```
2. Найдите файл с переменными (group_vars) в котором задаётся найденное в первом пункте значение и поменяйте его на 'all default fact'.
  ```
ansible-playbook -i ./inventory/test.yml site.yml 

TASK [Print fact] ****************************************************************************************************************************************ok: [localhost] => {
  "msg": "all default fact"
}
  ```
3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.
  ```
docker run --name centos7 -d centos:7 sleep 60000000
docker run --name ubuntu -d ubuntu:latest sleep 60000000
  ```
4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.
  ```
ansible-playbook -i ./inventory/prod.yml site.yml 

PLAY [prepare deb host] **********************************************************************************************************************************
TASK [Install python] ************************************************************************************************************************************changed: [ubuntu]

PLAY [Print os facts] ************************************************************************************************************************************
TASK [Gathering Facts] ***********************************************************************************************************************************ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ******************************************************************************************************************************************ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ****************************************************************************************************************************************ok: [centos7] => {
    "msg": "el"
}
ok: [ubuntu] => {
    "msg": "deb"
}

PLAY RECAP ***********************************************************************************************************************************************centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
  ```
5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились следующие значения: для `deb` - 'deb default fact', для `el` - 'el default fact'.
  ```
done
  ```
6.  Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.
  ```
ansible-playbook -i ./inventory/prod.yml site.yml 

PLAY [prepare deb host] **********************************************************************************************************************************
TASK [Install python] ************************************************************************************************************************************changed: [ubuntu]

PLAY [Print os facts] ************************************************************************************************************************************
TASK [Gathering Facts] ***********************************************************************************************************************************ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ******************************************************************************************************************************************ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ****************************************************************************************************************************************ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP ***********************************************************************************************************************************************centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
  ```
7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.
  ```
ansible-vault encrypt group_vars/deb/examp.yml 
New Vault password: 
Confirm New Vault password: 
Encryption successful

ansible-vault encrypt group_vars/el/examp.yml
New Vault password: 
Confirm New Vault password: 
Encryption successful
  ```
8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.
  ```
ansible-playbook -i ./inventory/prod.yml site.yml --ask-vault-pass
Vault password: 

PLAY [prepare deb host] **********************************************************************************************************************************
TASK [Install python] ************************************************************************************************************************************changed: [ubuntu]

PLAY [Print os facts] ************************************************************************************************************************************
TASK [Gathering Facts] ***********************************************************************************************************************************ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ******************************************************************************************************************************************ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ****************************************************************************************************************************************ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP ***********************************************************************************************************************************************centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
  ```
9. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.
  ```
ansible-doc -t connection -l
...
local        execute on controller
...

ansible-doc -t connection local
  ```
10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.
  ```
local:
    hosts:
      localhost:
        ansible_connection: local
  ```
11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь что факты `some_fact` для каждого из хостов определены из верных `group_vars`.
  ```
 ansible-playbook -i ./inventory/prod.yml site.yml --ask-vault-pass
Vault password: 

PLAY [prepare deb host] **********************************************************************************************************************************
TASK [Install python] ************************************************************************************************************************************changed: [ubuntu]

PLAY [Print os facts] ************************************************************************************************************************************
TASK [Gathering Facts] ***********************************************************************************************************************************ok: [localhost]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ******************************************************************************************************************************************ok: [localhost] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ****************************************************************************************************************************************ok: [localhost] => {
    "msg": "all default fact"
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP ***********************************************************************************************************************************************centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
  ```
12. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.
<br>
[playbook](../playbook/)
<br>

## Необязательная часть

1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.
  ```
ansible-vault decrypt group_vars/deb/examp.yml 
Vault password: 
Decryption successful

ansible-vault decrypt group_vars/el/examp.yml
Vault password: 
Decryption successful
  ```
2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.
  ```
ansible-vault encrypt_string "PaSSw0rd" --ask-vault-passNew Vault password: 
Confirm New Vault password: 
!vault |
          $ANSIBLE_VAULT;1.1;AES256
          30323430303062623030323135636266316237336330623138613730346631323361646561333434
          3066656536343461373931633635333933326239376561360a316561386464383635653833323330
          37643338346237356564353735326236373634613439653538313931653166383762346531616139
          3537643766323236620a646232383937366631373930613465653832316332343137383161346462
          6466
Encryption successful
  ```
3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.
  ```
ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
Vault password: 

PLAY [prepare deb host] **********************************************************************************************************************************
TASK [Install python] ************************************************************************************************************************************changed: [ubuntu]

PLAY [Print os facts] ************************************************************************************************************************************
TASK [Gathering Facts] ***********************************************************************************************************************************ok: [ubuntu]
ok: [centos7]
ok: [localhost]

TASK [Print OS] ******************************************************************************************************************************************ok: [localhost] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ****************************************************************************************************************************************ok: [localhost] => {
    "msg": "PaSSw0rd"
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP ***********************************************************************************************************************************************centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
  ```
4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот](https://hub.docker.com/r/pycontribs/fedora).
  ```
docker run --name fedora -d pycontribs/fedora sleep 60000000

ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
Vault password: 

PLAY [prepare deb host] **********************************************************************************************************************************
TASK [Install python] ************************************************************************************************************************************changed: [ubuntu]

PLAY [Print os facts] ************************************************************************************************************************************
TASK [Gathering Facts] ***********************************************************************************************************************************ok: [localhost]
ok: [ubuntu]
ok: [fedora]
ok: [centos7]

TASK [Print OS] ******************************************************************************************************************************************ok: [localhost] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}
ok: [fedora] => {
    "msg": "Fedora"
}

TASK [Print fact] ****************************************************************************************************************************************ok: [localhost] => {
    "msg": "PaSSw0rd"
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [fedora] => {
    "msg": "omg!"
}

PLAY RECAP ***********************************************************************************************************************************************centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
fedora                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
  ```
5. Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.
<br>
[bash.sh](../playbook/bash.sh)
<br>
6. Все изменения должны быть зафиксированы и отправлены в вашей личный репозиторий.
```
  done
```
