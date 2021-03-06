require 'galaxy/models/models'

class Planet < ActiveRecord::Base
  virtual
  tableless :columns => [
  [ :num, :integer],
  [ :x, :float ], 
  [ :y, :float ], 
  [ :name, :string ], 
  [ :size, :float ], 
  [ :pop, :float ], 
  [ :ind, :float ], 
  [ :res, :float ], 
  [ :cap, :float ], 
  [ :mat, :float ], 
  [ :col, :float ], 
  [ :l, :float ]
  ]
  belongs_to :race 
  belongs_to :product 
  has_many_linked :bombings 
  has_many_linked :fleets  
  has_many_linked :groups 
  has_many_linked :sent_fleets, :class_name => 'Fleet', :foreign_key => 'from_id'
  has_many_linked :sent_groups, :class_name => 'Group', :foreign_key => 'from_id'
  has_many_linked :routes, :before_add => :add_route, :after_remove => :remove_route #, after_remove => :remove_hmt 
  has_many_linked :incoming_routes, :foreign_key => 'target_id', :class_name => 'Route', :after_remove => :remove_route #, :after_remove => :remove_hmt 
  
  attr_accessor :battles, :progress, :created_by
  
  def add_route(route)
    # Find if target Route of this cargo type already exist, remove previous Route if found
    routes.each do |r|
      remove_route r if r == route.cargo 
    end
  end
  
  def remove_route(route)
    route.kill
  end
  
  def targets
    routes.map {|r| r.target}
  end
  
  def suppliers
    incoming_routes.map {|r| r.planet}
  end
  
  def Planet.new_or_update match, state
    # Lookup by both num and name is necessary since Routes/Fleets/Bombings create planets by name only
    num = match[0][0,1] == '#' ? match[0] : '#' + match[0].to_s
    name = match[3]
    planet = Planet.lookup(num)
    planet ||= Planet.lookup(name) if name 
    if planet
      planet.update_planet match, state
    else
      new match, state
    end
  end
  
  def initialize match, state
    super()
    update_planet match, state
  end
  
  # Update information on Planet (based on match size and state hash given)
  def update_planet match, state
    # Make attributes hash based on match size (4 possible constructors
    hash = case match.size
      when 13 # Your Planet/ * Planet
      prod_name = match[8]
      prod_key = state[:race] ? state[:race].name + '.' + prod_name : nil 
      product = Product.lookup(prod_name)
      product ||= Product.lookup(prod_key) if prod_key 
      product.planets << self if product
      {:num=>match[0].to_i, :x=>match[1].to_f, :y=>match[2].to_f, :name=>match[3], :size=>match[4].to_f, 
        :pop=>match[5].to_f, :ind=>match[6].to_f, :res=>match[7].to_f, :cap=>match[9].to_f, 
        :mat=>match[10].to_f, :col=>match[11].to_f, :l=>match[12].to_f}
      
      when 8 # Uninhabited Planet
      {:num=>match[0].to_i, :x=>match[1].to_f, :y=>match[2].to_f, :name=>match[3], :size=>match[4].to_f, 
        :res=>match[5].to_f, :cap=>match[6].to_f, :mat=>match[7].to_f}
      
      when 6 # Ships In Production
      total_mass = match[3].to_f / 10 # Mass values given in "Material units", divide by 10
      produced_mass = match[4].to_f / 10
      percentage = produced_mass/total_mass # Calculate ship production progress
      {:progress=>percentage}
      
      when 3 # Unidentified Planet
      {:num=>match[0].to_i, :x=>match[1].to_f, :y=>match[2].to_f}
      
      when 2 # Battle/Bombing generated Planet (known num and name)
      if state[:section] = 'Battle_planets'
        self.battles = state[:battles] = self.battles ? self.battles + 1 : 1 
        state[:planet] = self
      end
      {:num=>match[0].to_i, :name=>match[1]}
      
      when 1 # Route/Fleet/Bombing generated Planet (given EITHER #num or name)
      match[0][0,1] == '#' ?  
      {:num=>match[0][1..-1].to_s} : 
      {:name=>match[0]}
      
      when 0 # All init data given in a state hash
      state 
    else {}
    end 
    # Set all the attributes given in hash    
    hash.each do |key, value| 
      setter = key.to_s.concat('=').to_sym
      if self.respond_to? setter then self.send setter, value else raise ArgumentError end
    end
    state[:race].planets << self if state[:race]
    num ? add(numkey) : add if self.class.dataset # Add instantiated/updated model to dataset if dataset established
    @created_by = state[:created_by]
    self
  end
  
  def key ; name ? name : numkey end
  def numkey ; num ? '#' + num.to_s : nil end
  
  def distance planet
    #game.geometry.distance (planet1, planet2)
    0 
  end
  
  def produced_full_mat
    @progress end
  
  def produced_by_mat
    return nil unless self.product and self.product.ship?
    produced_mass = @progress*self.product.mass 
    available_mass = self.mat/10
    missing_mass = self.product.mass - produced_mass - available_mass
    if missing_mass < 0
      @progress
    else
      missing_l = (1/self.res+10)*missing_mass #
      return 1-(available_mass + missing_l/10)/(produced_mass+available_mass+missing_l/10)
    end
  end
  alias produced produced_by_mat
  
  # Boolean tests on Planets
  def aster? ; size and size < 1 end
  
  def max_size? ; size and size == 2500 end
  
  def uninhabited? ; !race and size end
  alias free? uninhabited?
  
  def unidentified? ; !race and !size end
  alias unknown? unidentified?
  
  def <=>(other)
    case other
      when nil then 1
      when Planet then num <=> other.num
      when Race then race ? race <=> other : -1
      when Product then product ? product <=> other : -1
      when Bombing then bombings.any? {|r| r == other} ? 0 : 1 #Planet is bigger than Bombing
      when Fleet then fleets.any? {|r| r == other} ? 0 : sent_fleets.any? {|r| r == other} ? 0 : 1 #Planet is bigger than Fleet
      when Route then routes.any? {|r| r == other} ? 0 : incoming_routes.any? {|r| r == other}? 0 : 1 #Planet is bigger than Route
      when Integer then num <=> other
      when String then self <=> other.downcase.to_sym
      when Symbol then 
      return aster? ? 0 : 1 if other == :aster or other == :asteroid or other == :min
      return max_size? ? 0 : 1 if other == :max_size or other == :max 
      return uninhabited? ? 0 : 1 if other == :uninhabited or other == :free or other == :empty
      return unidentified? ? 0 : 1 if other == :unidentified or other == :unid or other == :unknown
      return 0 if name and name.downcase.to_sym == other
      return 0 if race and race == other 
      return 0 if product and product == other
      key <=> other.to_s
    else raise ArgumentError, 'Comparison with a wrong type'
    end
  end
end #Planet
