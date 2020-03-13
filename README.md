# ProGeSer API

[![Build Status](https://travis-ci.org/Progeser/progeser-api.svg?branch=master)](https://travis-ci.org/Progeser/progeser-api)
[![Dependabot](https://api.dependabot.com/badges/status?host=github&repo=Progeser/progeser-api)](https://api.dependabot.com/badges/status?host=github&repo=Progeser/progeser-api)
[![Maintainability](https://api.codeclimate.com/v1/badges/34144c727e5098090c39/maintainability)](https://codeclimate.com/github/Progeser/progeser-api/maintainability)
[![Coverage](https://api.codeclimate.com/v1/badges/34144c727e5098090c39/test_coverage)](https://codeclimate.com/github/Progeser/progeser-api/test_coverage)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Made With Love <3](https://img.shields.io/badge/Made%20With-Love-ff69b4.svg)](https://github.com/Progeser)

# Presentation

ProGeSer API is part of the ProGeSer project, an application to manage greenhouses.
You can find the front part [here](https://github.com/Progeser/progeser-front).

# Run the application

You can run the application in 2 ways.

## With Ruby

### Requirements
* Ruby v 2.6.5
* Bundler v. >= 1.2.0, < 3
* Postgresql v. 10

### How to run

#### Installation
At the root of the project, run the following: 

`gem install bundler`

`bundle install`

#### Run
To launch the application run the following: 

`bundle exec rails s`

Then, to populate database and some fake datas, run the following: 

`bundle exec rake db:create db:migrate db:seed`

You can call the API on port 3000 by default.

To see the endpoints documentation, you can go to: 

http://localhost:3000/apidoc

### Run tests

To run smoke tests, run the following : 

`bundle exec rails test`

To run integration tests, run the following : 

`bundle exec rails spec`

## With Docker

### Requirements

* Docker v. >=17.0.3
* Docker Compose v. >= 1.20.0

### How to run

At the root of the project, run the following: 

`docker-compose up -d`

To populate database and some fake data, run the following: 

`docker-compose run web bundle exec rake db:create`

`docker-compose run web bundle exec rake db:migrate`

`docker-compose run web bundle exec rake db:seed`

You can call the API on:

http://localhost:3000

To see the endpoints documentation, you can go to: 

http://localhost:3000/apidoc

# Deploy the full application

You only need docker-compose to run the full application, and a .env file.

First, create a docker-compose.yml file to deploy the full application:

```Dockerfile
version: '3.6'
 
 services:
   db:
     restart: unless-stopped
     networks:
       - progeser-network
     image: postgres:10
     environment:
       POSTGRES_HOST_AUTH_METHOD: trust
     volumes:
       - db_data:/var/lib/postgresql/data
 
   redis:
     restart: unless-stopped
     networks:
       - progeser-network
     image: redis:5.0.7
 
   web:
     restart: unless-stopped
     networks:
       - progeser-network
     image: progeser/progeser-api-web
     ports:
       - "3000:3000"
     env_file: .env
     environment:
       RAILS_ENV: development
     depends_on:
       - db
       - redis
 
   sidekiq:
     restart: unless-stopped
     networks:
       - progeser-network
     image: progeser/progeser-api-sidekiq
     depends_on:
       - web
       - db
       - redis
     env_file: .env
     environment:
       RAILS_ENV: development
 
   front:
     restart: unless-stopped
     image: progeser/progeser-front-dev
     ports:
     - "8888:80"
 
 networks:
   progeser-network:
     driver: bridge
 
 volumes:
   db_data:
```
Then, create a .env file. You can find an exemple [here](https://github.com/Progeser/progeser-api/blob/master/.env.example).

Finally, run the following : 

`docker-compose run -d`

To populate database and some fake data, run the following: 

`docker-compose run web bundle exec rake db:create`

`docker-compose run web bundle exec rake db:migrate`

`docker-compose run web bundle exec rake db:seed`

You can now navigate to http://localhost:8888
