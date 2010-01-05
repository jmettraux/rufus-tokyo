
require 'rubygems'
require 'rufus/tokyo'

def show_memory
 3.times { GC.start }  # try to clean up
 mem = `ps -o rss -p #{Process.pid}`[/\d+/]
 puts "Current memory:  #{mem}"
end

p :before_put
show_memory


db = Rufus::Tokyo::Cabinet.new('test.tch')
db['some_key'] = "X" * 1024

p :after_put
show_memory

p :first_round

10.times do
  5000.times do
    db["some_key"]  # reading causes the memory leak
  end
  show_memory
end

sleep 1
show_memory

p :second_round

10.times do
  5000.times do
    db["some_key"]  # reading causes the memory leak
  end
  show_memory
end

db.close

sleep 1
show_memory

