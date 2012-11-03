{exec} = require 'child_process'

catchFailures = (err, stdout, stderr) ->
  throw err if err
  console.log stdout + stderr

task 'build:compile:coffee', 'Compiles ./src *.coffee files into complimentary *.js files in ./lib', ->
  catchFailures = (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr

  exec 'coffee --compile index.coffee', catchFailures
  exec 'coffee --compile --output lib/ src/', catchFailures

task 'build:compile:coffee:watch', 'Continously Compiles ./src *.coffee files into complimentary *.js files in ./lib', ->
  exec 'coffee --compile --watch --output lib/ src/', catchFailures

task 'build:clean', 'Remove compiled JS files', ->
  exec 'rm -rf index.js ./lib', catchFailures
