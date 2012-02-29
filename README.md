This project is still in early alpha development stages. The instructions below are not for general consumption.

# Installation

First, watch the [Railscast on mountable engines](http://railscasts.com/episodes/277-mountable-engines?autoplay=true).

## Setting Up

Since this is a mountable engine, you need somewhere to mount it. You
can either generate a new project or, for demo purposes, use the test
project that ships with the git repo:

```bash
$ cd test/dummy
$ rake checkout:install:migrations
$ rake db:migrate
```

## dBx Data Migration

Grab a SQL dump of dbx2 and restore it:

```bash
$ mysql -u root -p dbx2 < dbx2_dumpfile.sql
$ mysql -u root -p dbx2
mysql> grant all privileges on dbx2.* to webapp@localhost identified by 'webapp';
mysql> flush privileges;
```

Run the dbx2 rake task to copy the data over from the restored dbx2 database to the checkout database:

```bash
$ cd checkout/test/dummy
$ rake dbx2
```
Note: the migration is handled by the following 2 files:
    test/dummy/lib/tasks/legacy_classes.rb
    test/dummy/lib/tasks/legacy_migration.rake
