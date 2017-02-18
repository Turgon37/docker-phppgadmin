# Docker phpPgAdmin

[![](https://images.microbadger.com/badges/image/turgon37/phppgadmin.svg)](https://microbadger.com/images/turgon37/phppgadmin "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/turgon37/phppgadmin.svg)](https://microbadger.com/images/turgon37/phppgadmin "Get your own version badge on microbadger.com")

This images contains an instance of phppgadmin web application served by nginx on port 80

## Docker Informations

* This image expose the following port

| Port           | Usage                |
| -------------- | -------------------- |
| 80             | HTTP web application |

 * This image takes theses environnements variables as parameters

| Environment                 | Usage                                                           |
| --------------------------- | ----------------------------------------------------------------|
| POSTGRES_HOST               | The hostname of the PostGreSQL database server                  |
| POSTGRES_PORT               | The port on which join the postgressql server (default to 5432) |
| POSTGRES_NAME               | The name of the connection profil in phpPgAdmin profile         |
| POSTGRES_DEFAULTDB          | The name of default database to show                            |
| PHPPGADMIN_LOGIN_SECURITY   | If true enable restrictions on login and empty passwords        |
| PHPPGADMIN_OWNED_ONLY       | If true, filter databases owned by the logged user              |
| PHPPGADMIN_SHOW_COMMENTS    | If true, show comments fields                                   |
| PHPPGADMIN_SHOW_ADVANCED    | If true, display advanced objects like types, aggregations      |
| PHPPGADMIN_SHOW_SYSTEM      | If true, display systems objects                                |
| PHPPGADMIN_SHOW_OIDS        | If true, show objects OIDs                                      |
| PHPPGADMIN_USE_XHTML_STRICT | If true, send XHTML strict headers                              |
| PHPPGADMIN_THEME            | Set here the name of the theme to use                           |
| PHPPGADMIN_PLUGINS          | Set here the comma separated list of plugins name to enable     |


## Installation

* Manual

```
git clone
docker build -t turgon37/phppgadmin .
```

* or Automatic

```
docker pull turgon37/phppgadmin
```


## Usage

```
docker run -p 8000:80 -e "POSTGRES_HOST=127.0.0.1" -e "POSTGRES_PORT=5432" -e "POSTGRES_NAME=Intranet" turgon37/phppgadmin
```
