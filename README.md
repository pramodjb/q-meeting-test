## q-meeting
Q-Meeting

### Usage

Make the following changes to database.yml file if using postgres in a container

```
	.
	.
	.
  port: <%= ENV['DB_PORT_5432_TCP_PORT'] %>
  host: <%= ENV['DB_PORT_5432_TCP_ADDR'] %>
  	.
  	.
  	.
```

### Run Docker-compose with the following command

```
$ docker-compose up -d
```
 * *-d if you want to run it in background.*



To setup up the database

```
$ docker-compose run app rake db:setup
```

To run tests in the container

```
$ docker-compose run app bundle exec rspec
```