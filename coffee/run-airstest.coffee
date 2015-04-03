coffee_file = './airstest.coffee'
process.stdout.write = (d)->
  process.stderr.write '+++'+d+'+++'
require coffee_file
delete require.cache[require.resolve coffee_file]

