
`ttserver -dmn -port 45006 tmp/data.tct`

require 'rubygems'
require 'rufus/tokyo'

t = Rufus::Tokyo::TyrantTable.new('localhost', 45006)

t['pk0'] = { 'name' => 'alfred', 'age' => '22' }
t['pk1'] = { 'name' => 'bob', 'age' => '18' }
t['pk2'] = { 'name' => 'charly', 'age' => '45' }
t['pk3'] = { 'name' => 'doug', 'age' => '77' }
t['pk4'] = { 'name' => 'ephrem', 'age' => '32' }

p t.query { |q|
  q.add_condition 'age', :numge, '32'
  q.order_by 'age'
}
  # => [ {"name"=>"ephrem", :pk=>"pk4", "age"=>"32"},
  #      {"name"=>"charly", :pk=>"pk2", "age"=>"45"} ]

t.close

