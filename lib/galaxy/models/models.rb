# First, 'models.rb' serves as 'super-class-equivalent' for Models, activating all the 
# VirtualBase enhancements that can be used in Model classes (macros, class methods, instance methods)
require 'rubygems'
require 'active_record'
require 'galaxy/virtual_base.rb'
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ":memory:", :timeout => 500)
ActiveRecord::Base.send(:include, ActiveRecord::VirtualBase)

# Second, 'models.rb' serves as collector, allowing clients to require 'models.rb' instead of individual Model files
require 'galaxy/models/race'
require 'galaxy/models/product'
require 'galaxy/models/planet'
require 'galaxy/models/bombing'
require 'galaxy/models/route'
require 'galaxy/models/fleet'
require 'galaxy/models/group'
