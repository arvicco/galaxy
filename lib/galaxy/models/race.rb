require 'galaxy/models/models'

class Race < ActiveRecord::Base
  #:string, :text, :integer, :float, :decimal, :datetime, :timestamp, :time, :date, :binary, :boolean. 
  virtual
  tableless :columns => [
  [ :name, :string ], 
  [ :drive, :float ], 
  [ :weapons, :float ], 
  [ :shields, :float ], 
  [ :cargo, :float ], 
  [ :pop, :float ], 
  [ :ind, :float ], 
  [ :num_planets, :integer ], 
  [ :relation, :string ], 
  [ :vote, :float ]
  ]  
  has_many_linked :products 
  has_many_linked :planets
  has_many_linked :fleets 
  has_many_linked :routes 
  has_many_linked :groups 
  has_many_linked :bombings
  has_many_linked :incoming_bombings, :class_name => 'Bombing', :foreign_key => 'victim_id'
  
  attr_accessor :order
  
  def kill
    products.each {|m| m.kill}    
    planets.each {|m| m.kill}    
    fleets.each {|m| m.kill}    
    routes.each {|m| m.kill}    
    groups.each {|m| m.kill}    
    bombings.each {|m| m.kill}    
    incoming_bombings.each {|m| m.kill}  
    super #puts "Warning: kill attempt failed for #{self}" unless 
  end
  
  def initialize match, state
    case match.size
      when 10 then
      super({:name=>match[0], :drive=>match[1].to_f, :weapons=>match[2].to_f, :shields=>match[3].to_f, :cargo=>match[4].to_f, 
        :pop=>match[5], :ind=>match[6].to_f, :num_planets=>match[7].to_i, :relation=>match[8], :vote=>match[9].to_f})
      when 0 then # All init data must be given in a state hash
      super state 
    end
    add if self.class.dataset # Add instantiated model to dataset if it is defined
    @order = Order.new self, 'zelikaka', state[:game], state[:turn] if your?
  end
  
  def key; name end
  
  # Special collection accessors
  def sciences; products.find_all {|p| p and p.science?} || [] end # TODO redefine find_all in HashArray? 
  def ships; products.find_all {|p| p and p.ship?} || [] end 
  alias designs ships
  alias ship_types ships
  
  
  def battle_groups ; groups.find_all {|g| g and g.from_battle?} || [] end
  
  # Boolean tests on Races
  def rip? ; name.split("_")[-1] == 'RIP' end
  
  def enemy? ; relation == 'War' end
  alias war? enemy?  
  
  def friend? ; not enemy? end
  alias ally? friend?  
  alias peace? friend?  
  
  def your? ; relation == '-' end # Redefining TODO or test if this is your other controlled Race (aka 3ombies)
  
  def <=>(other)
    case other
      when nil then 1
      when Race then num_planets == other.num_planets ? key <=> other.key : num_planets <=> other.num_planets
      when Product, Planet, Group, Bombing, Route, Fleet then - other <=> self 
      when Integer then num_planets <=> other
      when String then self <=> other.downcase.to_sym
      when Symbol then 
      return rip? ? 0 : 1 if other == :rip or other == :dead
      return !rip? ? 0 : 1if other == :alive or other == :active
      return enemy? ? 0 :1 if other == :enemy or other == :war 
      return friend? ? 0 : 1 if other == :friend or other == :ally or other == :peace
      return your? ? 0 : 1 if other == :your or other == :yours or other == :controlled or other == :my or other == :mine
      return 0 if name.downcase.include? other.to_s
      key <=> other.to_s
    else raise ArgumentError, 'Comparison with a wrong type'
    end
  end
end

class Order
  attr_accessor :race, :text
  
  def initialize( race, password, game, turn )
    @race = race
    @password = password
    @game = game
    @turn = turn
    @text = "#order #@game #{@race.name}_#@password turn #@turn\n#end\n"
  end
  
  def add_line line
    @text[-6] = "\n" + line + "\n"
  end
  
  def recalc_order
    puts "Unable to recalculate: method under construction!"
  end
end
