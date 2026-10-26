### Запуск инкрементальных бэкапов greenplum по расписанию

#### Шаг 1: Клонировать репозиторий в папку gpadmin с сервисным ключом на master:

```
sudo su gpadmin && cd ~
```

```
git clone <corporate repo>:dp-data-platform/ASKONA_GP/gp_backup_scripts.git
```

```
cd gp_backup_scripts
```

#### Шаг 2: Записать своего пользователя в git config:

```
make env
```

```
nano .env
```

Ввести своё имя пользователя и корпоративную почту. Сохранить.

Заполнить конфиг git:

```
make git
```

#### Шаг 3: Создать systemd unit и systemd timer:

```
make service
```

```
make timer
```
# tuneller
