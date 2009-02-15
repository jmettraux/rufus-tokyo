
`ttserver -dmn -port 45001 tmp/data.tch`

require 'rubygems'
require 'rufus/tokyo'

db = Rufus::Tokyo::Tyrant.new('tyrant.example.com', 45001)

db['nada'] = 'surf'

p db['nada'] # => 'surf'
p db['lost'] # => nil

db.close

