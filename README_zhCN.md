# E5SubBot For SQLite

![](https://img.shields.io/github/go-mod/go-version/rainerosion/E5SubBot?style=flat-square)
![](https://img.shields.io/badge/license-GPL-lightgrey.svg?style=flat-square)
![](https://img.shields.io/github/v/release/rainerosion/E5SubBot?color=green&style=flat-square)

[English](https://github.com/rainerosion/E5SubBot) | 简体中文

A Simple Telebot for E5 Renewal

`Golang` + `SQLite`

DEMO: https://t.me/raindev_bot (仅用于测试DEMO测试)

[e5subbot交流群组](https://t.me/e5subbot)
## 说明
该项目是基于[iyear/E5SubBot](https://github.com/iyear/E5SubBot)进行简单的修改，将`github.com/go-sql-driver/mysql`替换为`github.com/mattn/go-sqlite3`实现使用SQLite数据库保存数据的。

## 特性

- 自动续订E5订阅(可自定义的调用频率)
- 可管理的简易账户系统
- 完善的任务执行反馈
- 极为方便的授权方式


## 原理

E5订阅为开发者订阅，只要调用相关API就有可能续期

调用 [Outlook ReadMail API](https://docs.microsoft.com/zh-cn/graph/api/user-list-messages?view=graph-rest-1.0&tabs=http) 实现玄学的续订方式，不保证续订效果。

## 使用方法

1. 在机器人对话框输入 **/bind**
2. 注册应用，使用E5主账号或同域账号登录，跳转页面获得client_secret。**点击回到快速启动**,获得client_id
3. 复制client_secret和client_id，以 `client_id client_secret`格式回复
4. 获得授权链接，使用E5主账号或同域账号登录
5. 授权后会跳转至`http://localhost/e5sub……`  (会提示网页错误，复制链接即可)
6. 复制整个浏览框内容，在机器人对话框回复 `链接+空格+别名(用于管理账户)`
   例如：`http://localhost/e5sub/?code=abcd MyE5`，等待机器人绑定后即完成

## 自行部署

Bot创建教程:[Google](https://www.google.com/search?q=telegram+Bot%E5%88%9B%E5%BB%BA%E6%95%99%E7%A8%8B)

### Docker部署
```bash
wget --no-check-certificate -O /root/config.yml https://raw.githubusercontent.com/rainerosion/E5SubBot/master/config.yml.example
# 修改配置文件中的信息
vim /root/config.yml
docker run -d -v /root/config.yml:/root/config.yml --restart=always --name e5bot rainerosion/e5subbot-sqlite
```

### 二进制文件

在[Releases](https://github.com/rainerosion/E5SubBot/releases)页面下载对应系统的二进制文件，上传至服务器

Windows: 在`cmd`中启动 `E5SubBot.exe`

Linux(方法一):

```bash
chmod a+x E5SubBot
nohup ./E5SubBot > /tmp/e5sub.log &
```
Linux守护进程(适用于Centos)：

- 下载文件

```bash
wget https://github.com/rainerosion/E5SubBot/releases/download/0.2.1/E5SubBot_linux_x64.tar.gz
# 解压文件
tar xvjf E5SubBot_linux_x64.tar.gz
# 创建文件夹
mkdir /opt/e5sub
# 移动文件
mv ./E5SubBot /opt/e5sub/E5SubBot
# 添加执行权限
chmod a+x /opt/e5sub/E5SubBot
# 编辑配置文件(文件内容请阅读部署配置)
vim /opt/e5sub/config.yml
```

- 编辑systemd文件

```bash
vim /etc/systemd/system/e5sub.service
```

- 复制以下内容填入上述文件

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

- 重载配置启动服务

```bash
# 重载配置文件
systemctl daemon-reload
# 开机自启
systemctl enable e5sub
# 启动服务
systemctl start e5sub
```

### 编译

若你的系统无法正常运行，请clone源代码进行编译，需要先安装GO环境

```shell
go env -w CGO_ENABLED=1
go build
```

## 部署配置

在同目录下创建`config.yml`，编码为`UTF-8`

配置模板:

```yaml
bot_token: YOUR_BOT_TOKEN
socks5: 127.0.0.1:1080
notice: "第一行\n第二行"
admin: 66666,77777,88888
errlimit: 5
cron: "1 */3 * * *"
bindmax: 3
dbfile: "e5sub.db"
```

`bindmax`,`notice`,`admin`,`errlimit`可热更新，直接更新`config.yml`保存即可
|  配置项   | 说明  |
|  ----  | ----  |
| bot_token  | 更换为自己的`BotToken` |
| socks5  | `Socks5`代理,不需要删去即可.例如:`127.0.0.1:1080` |
|notice|公告.合并至`/help`|
|admin|管理员`tgid`，前往 https://t.me/userinfobot 获取，用`,`隔开;管理员权限: 手动调用任务，获得任务总反馈|
|errlimit|单账户最大出错次数，满后自动解绑单账户并发送通知，不限制错误次数将值改为负数`(-1)`即可;bot重启后会清零所有错误次数|
|cron|API调用频率，使用cron表达式|
|bindmax|最大可绑定数|
|dbfile|sqlite数据库文件名|
|lang|简体中文(默认)：`zh_CN` English:`en_US`|

### 命令
```
/my 查看已绑定账户信息  
/bind  绑定新账户  
/unbind 解绑账户  
/export 导出账户信息(JSON格式) 
/help 帮助  
/task 手动执行一次任务(Bot管理员)  
/log 获取最近日志文件(Bot管理员)  
```

## MYSQL数据库转SQLITE

如果没有sqlite3命令请使用下列命令安装

```bash
sudo yum install sqlite -y
```

导出数据

```bash
# 导出mysql数据
mysqldump -h localhost -P 3306 -u root -p -t 数据库名 users > e5sub.sql
# 过滤数据
grep "INSERT" e5sub.sql > e5sqlite.sql
# 使用sqlite3打开数据库文件
sqlite3 /opt/e5sub/e5sub.db
# 创建表，导入数据
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
# 清除文件
rm -f e5sqlite.sql e5sub.sql
```

## 注意事项
> 更新时间与北京时间不符

更改服务器时区为`Asia/Shanghai`，然后使用`/task`手动执行一次任务刷新时间

> 绑定格式错误

不要带"+"号

> 长时间运行崩溃

疑似内存泄露，尚未解决，请自行采用守护进程运行或定时重启`Bot`

> 无法通过Bot创建应用程序

https://t.me/e5subbot/5201
## License

GPLv3 
