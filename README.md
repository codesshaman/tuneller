### Local SSH Tunnel with user service

#### Cloning:

```
git clone https://github.com/codesshaman/tuneller.git
```

```
cd tuneller
```

#### Create environment:

```
make env
```

```
nano .env
```

Change all necessary variables and parameters.

#### Create ssh tunnel script

```
make
```

Check your script name file in ``/usr/local/bin/``.

#### Create user service

```
make service
```

It's all. Service will be created and launch ssh tunnel every time after your first login.

#### Checing

```
systemctl --user status <your script name>.service
```

#### Remove tuneller script

```
make clean
```

#### Remove service

```
systemctl --user stop <your script name>.service
systemctl --user disable --now <your script name>..service
systemctl --user daemon-reload
```