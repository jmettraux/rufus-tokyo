
# ttserver -port 45001 tmp/data.tch

require 'rubygems'
require 'rufus/tokyo/tyrant'

db = Rufus::Tokyo::Tyrant.new('localhost', 45001)

db['nada'] = 'surf'

p db['nada'] # => 'surf'
p db['lost'] # => nil

db.close

