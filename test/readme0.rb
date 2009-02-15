
require 'rubygems'
require 'rufus/tokyo'

db = Rufus::Tokyo::Cabinet.new('data.tch')

db['nada'] = 'surf'

p db['nada'] # => 'surf'
p db['lost'] # => nil

5000.times { |i| db[i.to_s] = "x" }

p db.inject { |r, (k, v)| k } # => 4999

db.close

