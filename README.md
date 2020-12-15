# E5SubBot For SQLite

![](https://img.shields.io/github/go-mod/go-version/rainerosion/E5SubBot?style=flat-square)
![](https://img.shields.io/badge/license-GPL-lightgrey.svg?style=flat-square)
![](https://img.shields.io/github/v/release/rainerosion/E5SubBot?color=green&style=flat-square)

English | [简体中文](https://github.com/rainerosion/E5SubBot/blob/master/README_zhCN.md)

A Simple Telebot for E5 Renewal

`Golang` + `SQLite`

DEMO: https://t.me/raindev_bot (This DEMO is agesor testing only)

Communication: [Telegram Group](https://t.me/e5subbot)
## Introduction
The project was modified from [iyear/E5SubBot](https://github.com/iyear/E5SubBot).


## Feature

- Automatically Renew E5 Subscription(Customizable Frequency)
- Manageable Simple Account System
- Available Task Execution Feedback
- Convenient Authorization


## Principle

E5 subscription is a subscription for developers, as long as the related API is called, it may be renewed

Calling [Outlook ReadMail API](https://docs.microsoft.com/en-us/graph/api/user-list-messages?view=graph-rest-1.0&tabs=http) to renew, does not guarantee the renewal effect.

## Usage

1. Type `/bind` in the robot dialog
2. Click the link sent by the robot and register the Microsoft application, log in with the E5 master account or the same domain account, and obtain `client_secret`. **Click to go back to Quick Start**, get `client_id`
3. Copy `client_secret` and `client_id` and reply to bot in the format of `client_id(space)client_secret`
   (Pay attention to spaces)
4. Click on the authorization link sent by the robot and log in with the `E5` master account or the same domain account
5. After authorization, it will jump to `http://localhost/e5sub……` (will prompt webpage error, just copy the link)
6. Copy the link, and reply `link(space)alias (used to manage accounts)` in the robot dialog
   For example: `http://localhost/e5sub/?code=abcd MyE5`, wait for the robot to bind and then complete

## Deploy Your Own Bot

Bot creation tutorial : [Microsoft](https://docs.microsoft.com/en-us/azure/bot-service/bot-service-channel-connect-telegram?view=azure-bot-service-4.0)

### Docker
```bash
wget --no-check-certificate -O /root/config.yml https://raw.githubusercontent.com/rainerosion/E5SubBot/master/config.yml.example
# Modify configuration file
vim /root/config.yml
docker run -d -v /root/config.yml:/root/config.yml --restart=always --name e5bot rainerosion/e5subbot-sqlite
```


### Binary Deployment

Download the binary files of the corresponding system on the [Releases](https://github.com/rainerosion/E5SubBot/releases) page and upload it to the server

Windows: Start `E5SubBot.exe` in `cmd`

Linux:

```bash
chmod a+x E5SubBot
nohup ./E5SubBot > /tmp/e5sub.log &
```
Linux Systemd:

- download file

```bash
wget https://github.com/rainerosion/E5SubBot/releases/download/0.2.1/E5SubBot_linux_x64.tar.gz
# Unzip file
tar xvjf E5SubBot_linux_x64.tar.gz
# create folder
mkdir /opt/e5sub
# move file
mv ./E5SubBot /opt/e5sub/E5SubBot
# Add execution permission
chmod a+x /opt/e5sub/E5SubBot
# Modify configuration file
vim /opt/e5sub/config.yml
```

- Edit service file

```bash
vim /etc/systemd/system/e5sub.service
```

- Copy the following text

```reStructuredText
[Unit]
Description=Telegram E5Sub Bot

[Service]
Type=simple
WorkingDirectory=/opt/e5sub
ExecStart=/opt/e5sub/E5SubBot
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
```

- Start service

```bash
# Load configuration file
systemctl daemon-reload
# Start up automatically
systemctl enable e5sub
# Start service
systemctl start e5sub
```

### Compile

Download the source code and install the GO environment

```shell
go env -w CGO_ENABLED=1
go build
```

## Configuration

Create `config.yml` in the same directory, encoded as `UTF-8`

Configuration Template:

```yaml
bot_token: YOUR_BOT_TOKEN
socks5: 127.0.0.1:1080
notice: "first line\nsecond line"
admin: 66666,77777,88888
errlimit: 5
cron: "1 */3 * * *"
bindmax: 3
dbfile: "e5sub.db"
```

`bindmax`, `notice`, `admin`, `errlimit` can be hot updated, just update `config.yml` to save.
|  Configuration   | Explanation|
|  ----  | ----  |
| bot_token  | Change to your own `BotToken` |
| socks5  | `Socks5` proxy,if you do not need ,you should delete it. For example: `127.0.0.1:1080` |
|notice|Announcement. Merged into `/help`|
|admin|The administrator's `tgid`, go to https://t.me/userinfobot to get it, separated by `,`; Administrator permissions: manually call the task, get the total feedback of the task|
|errlimit|The maximum number of errors for a single account, automatically unbind the single account and send a notification when it is full, without limiting the number of errors, change the value to a negative number `(-1)`; all errors will be cleared after the bot restarts|
|cron|API call frequency, using `cron` expression|
|bindmax|Maximum number of bindable|
|dbfile|Database file|
|lang|Simplified Chinese(default)：`zh_CN` English:`en_US`|
### Command
```
/my View bound account information
/bind Bind new account
/unbind Unbind account
/export Export account information (JSON format)
/help help
/task Manually execute a task (Bot Administrator)
/log Get the most recent log file (Bot Administrator)
```

## Convert data from mysql to sqlite

If this command does not exist on your operating system.

```bash
# Centos
sudo yum install sqlite
# Archlinux
sudo pacman -S sqlite3 
# Ubuntu
sudo apt-get install sqlite3
```

Export data

```bash
# Export MYSQL data
mysqldump -h localhost -P 3306 -u root -p -t dbname users > e5sub.sql
# Filtering data
grep "INSERT" e5sub.sql > e5sqlite.sql
# Open sqlite database
sqlite3 /opt/e5sub/e5sub.db
# Create table and import data.
sqlite3> CREATE TABLE `users` (
  `tg_id` int(11) DEFAULT NULL,
  `refresh_token` text,
  `ms_id` varchar(255) DEFAULT NULL,
  `uptime` int(11) DEFAULT NULL,
  `alias` varchar(255) DEFAULT NULL,
  `client_id` varchar(255) DEFAULT NULL,
  `client_secret` varchar(255) DEFAULT NULL,
  `other` text);
sqlite3> .read e5sqlite.sql
sqlite3> .quit
# Delete file
rm -f e5sqlite.sql e5sub.sql
```

## Others
> Feedback time is not as expected

Change the server time zone, use `/task` to manually perform a task to refresh time.

> Long running crash

Suspected memory leak. Not yet resolved, please run the daemon or restart Bot regularly.

> Unable to create application via bot

https://t.me/e5subbot/5201

## License

GPLv3 
