This project is still in alpha development stages. Don't expect everything to work. In particular, reservations are very broken.

# Installation

## Prerequisites

* Ruby 1.9.2 (or higher)
* Ruby Gems
  * rake
  * bundler 
* A Rails-compatible SQL database
  * PostgreSQL (recommended)
  * MySql (works ok, too)
  

## Quick Start
Get the code either by downloading a [zip file of the latest code](https://github.com/jamezilla/Checkout/zipball/master), or cloning the git repository using [git](http://git-scm.com/).

Clone the repository:

```
$ git clone git://github.com/jamezilla/Checkout.git
```

Install all the ruby gem dependencies:

```
$ cd Checkout
$ bundle install
```

Configure your config/database.yml file so it connects to your
preferred database. Consult the [Rails database guide](http://guides.rubyonrails.org/getting_started.html#configuring-a-database) if this stuff is unfamiliar.

Set up the database:

```
$ rake db:setup
$ rake db:migrate
```
Run the web server:

```
$ rails s
```
Browse to [http://localhost:3000](http://localhost:3000).
The default login is ```admin``` with a password of ```password```. You should change this immediately on the [account settings page](http://localhost:3000/user/edit)!

## dBx Data Migration

Grab a SQL dump of dbx2 and drop it into the ```db``` directory. Rename the file so it starts with ```dbx``` and ends with ```.sql``` (e.g. ```dbx2_dump_20120912.sql```).

Run the dbx reload rake task.

```
$ rake dbx:reload
```
Run the dbx:migrate rake task to migrate the data from the restored dbx2 database to the checkout database:

```
$ rake dbx:migrate
```
Note: the migration is handled by the following 2 files:

* lib/tasks/legacy_classes.rb
* lib/tasks/legacy_migration.rake
