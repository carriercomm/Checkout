This project is still in early alpha development stages. The instructions below are not for general consumption.

# Installation

The app is no longer a mountable engine. It's pretty much ready to go
as soon as you get the database set up.

## Setting Up

Configure your config/database.yml file so it connects to your
preferred database.

```bash
$ rake db:setup
$ rake db:migrate
```

## dBx Data Migration

Grab a SQL dump of dbx2 and restore it:

```bash
$ mysql -u root -p dbx2 < dbx2_dumpfile.sql
$ mysql -u root -p
mysql> grant all privileges on dbx2.* to webapp@localhost identified by 'webapp';
mysql> flush privileges;
```

Run the dbx2 rake task to copy the data over from the restored dbx2 database to the checkout database:

```bash
$ rake dbx2
```
Note: the migration is handled by the following 2 files:
    lib/tasks/legacy_classes.rb
    lib/tasks/legacy_migration.rake
