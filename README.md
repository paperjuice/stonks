[![Build Status](https://paperjuice.semaphoreci.com/badges/stonks/branches/master.svg)](https://paperjuice.semaphoreci.com/projects/stonks)

# Stonks

Stonks is an application that allows the user to input an initial financial balance, a date in the past and portfolio allocation.
The response generated will contain how much the stocks are worth today.

## Usage
### Option 1 (recommended)
### Prerequisites
The project requires you to have [Docker](https://www.docker.com/), [make](https://en.wikipedia.org/wiki/Make_(software)) and [Git](https://git-scm.com/book/en/v2/Getting-Started-The-Command-Line) installed on your machine.
The project was build using Docker version 20.10.2
```
λ docker --version
Docker version 20.10.2, build 2291f61
```

1. Clone the git project and `cd` into it
```
git clone https://github.com/paperjuice/stonks.git && cd stonks
```

2. Run the docker containers in detached mode:
```
make detached
```

3. Once the action is done you can browse to:
```
http://localhost:8080
```

4. You can stop the containers with
```
make down
```

### Option 2
### Prerequisites
The second option assumes you start each project individually. For this you will need Elixir `IEx 1.11.3`, Elm `0.19.1` and Git

1. Clone the git project and `cd` into it
```
git clone https://github.com/paperjuice/stonks.git && cd stonks
```

2. Start the elixir application either by running `iex -S mix` or by manually releasing with `MIX_ENV=prod mix release stonks --overwrite` and start the app with `_build/prod/rel/stonks/bin/stonks start`/ stop with `_build/prod/rel/stonks/bin/stonks stop`
Port used is `9900`

3. `cd` into frontend folder (inside the Main.elm file `bePort` needs to match the Elixir app port) and you can run it with `elm reactor` and browse to `http://localhost:8000/src/Main.elm`


## Misc
The commands below are strictly for the Elixir application
### Tests
At the root of the folder you can run tests: `mix coveralls`

### Lint
At the root of the folder you can check the lint: `mix credo --strict`

## Deployment
Currently I am trying to deploy the project to Heroku but I am currently stuck on an issue I am currently debugging:
```
-----> Installing Hex
/app/.platform_tools/erlang/erts-11.0.2/bin/beam.smp: error while loading shared libraries: libtinfo.so.5: cannot open shared object file: No such file or directory
-----> Installing rebar
/app/.platform_tools/erlang/erts-11.0.2/bin/beam.smp: error while loading shared libraries: libtinfo.so.5: cannot open shared object file: No such file or directory
-----> Fetching app dependencies with mix
/app/.platform_tools/erlang/erts-11.0.2/bin/beam.smp: error while loading shared libraries: libtinfo.so.5: cannot open shared object file: No such file or directory
 !     Push rejected, failed to compile Elixir app.
 !     Push failed
```

## Improvements
* move unit tests
* integration tests
* a bunch of the data strctures should be `structs` for extra validation and auto documenting code
* add `@spec` to public function
* dyalizer as part of the CI
* deployment to cloud
* rebalancing feature
* better undestanding of the `marketstack` API. They happen to return no data even if the date I am requesting is during the week
* the exact same request made by the same user will get stored in the cache every time 
