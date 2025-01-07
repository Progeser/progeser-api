# ProGeSer API

[![Build Status](https://travis-ci.org/Progeser/progeser-api.svg?branch=master)](https://travis-ci.org/Progeser/progeser-api)
[![Dependabot](https://api.dependabot.com/badges/status?host=github&repo=Progeser/progeser-api)](https://api.dependabot.com/badges/status?host=github&repo=Progeser/progeser-api)
[![Maintainability](https://api.codeclimate.com/v1/badges/34144c727e5098090c39/maintainability)](https://codeclimate.com/github/Progeser/progeser-api/maintainability)
[![Coverage](https://api.codeclimate.com/v1/badges/34144c727e5098090c39/test_coverage)](https://codeclimate.com/github/Progeser/progeser-api/test_coverage)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Made With Love <3](https://img.shields.io/badge/Made%20With-Love-ff69b4.svg)](https://github.com/Progeser)

# Presentation

ProGeSer API is part of the ProGeSer project, an application to manage greenhouses.
You can find the front part [here](https://github.com/Progeser/progeser-front-rework).

# Run the application

You can run the application in 2 ways.

## With Ruby

### Requirements
* Ruby v 3.3.5
* Bundler v. >= 2.5.18
* Postgresql v. 15.0.0

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

To run smoke tests, run the following: 

`bundle exec rails test`

To run integration tests, run the following: 

`bundle exec rails spec`

## With Docker

### Requirements

* Docker v. >=24.0.7
* Docker Compose v. >= 2.23.0

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