require 'galaxy/models/models'

class Group < ActiveRecord::Base
  virtual
  tableless :columns => [
  [:num, :integer],
  [:xx, :float], 
  [:yy, :float], 
  [:num_ships, :integer ],
  [:num_before, :integer], # Number of ships BEFORE battle (for Battle Groups only)
  [:drive, :float], 
  [:weapons, :float], 
  [:shields, :float], 
  [:cargo, :float],
  [:cargo_type, :string],
  [:qty, :float],
  [:range, :float],
  [:speed, :float],
  [:mass, :float],
  [:status, :string] # May cause problems with AR?
  ]  
  belongs_to :race 
  belongs_to :product 
  belongs_to :planet
  belongs_to :fleet
  belongs_to :from, :class_name => 'Planet'
  
  attr_accessor :battles
  
  def initialize match, state
    super()
    update_group match, state
  end
  
  # Update information on this Group (based on match size and state hash given)
  def update_group match, state
    race = product = planet = from = fleet = nil
    # Make attributes hash based on match size (many constructors)
    hash = case match.size
      when 16 # Your Group 
      race = state[:race]
      p 'No planet!', match, state unless planet = Planet.lookup(match[9])
      p 'No from!', match, state unless from = Planet.lookup(match[10]) unless match[10] == '-'
      p 'No fleet!', match, state unless fleet = Fleet.lookup(race.name + '.' + match[14]) unless match[14] == '-'
      product = Product.lookup(race.name + '.' + match[2])
      product = Product.lookup(race.name + '.' + match[2])
      {:num=>match[0].to_i, :num_ships=>match[1].to_i, :drive=>match[3].to_f, :weapons=>match[4].to_f, 
        :shields=>match[5].to_f, :cargo=>match[6].to_f, :cargo_type=>match[7], :qty=>match[8].to_f, 
        :range=>match[11].to_f, :speed=>match[12].to_f, :mass=>match[13].to_f, :status=>match[15]}
      
      when 11 # (known) * Group 
      race = state[:race]
      p 'No planet!', match, state unless planet = Planet.lookup(match[8])
      p 'No product!', match, state unless product = Product.lookup(race.name + '.' + match[1])
      {:num_ships=>match[0].to_i, :drive=>match[2].to_f, :weapons=>match[3].to_f, :shields=>match[4].to_f, 
        :cargo=>match[5].to_f, :cargo_type=>match[6], :qty=>match[7].to_f, :speed=>match[9].to_f, :mass=>match[10].to_f}
      
      when 10 # Battle Group
      race = state[:race]
      planet = state[:planet]
      product = Product.lookup(race.name + '.' + match[1])
      @battles = state[:battles]
      {:num_before=>match[0].to_i, :drive=>match[2].to_f, :weapons=>match[3].to_f, 
        :shields=>match[4].to_f, :cargo=>match[5].to_f, :cargo_type=>match[6], :qty=>match[7].to_f,
        :num_ships=>match[8].to_i, :status=>match[9]}
      
      when 5 # Incoming Group
      planet = Planet.new [match[1]], state.merge({:race=>nil,:product=>nil,:created_by=>self}) unless planet = Planet.lookup(match[1])
      from = Planet.new [match[0]], state.merge({:race=>nil,:product=>nil,:created_by=>self}) unless from = Planet.lookup(match[0])
      {:range=>match[2].to_f, :speed=>match[3].to_f, :mass=>match[4].to_f}
      
      when 2 # Unidentified Group - TODO implement track calculation
      {:xx=>match[0].to_f, :yy=>match[1].to_f}
      
      when 0 # All init data given in a state hash
      state 
    else {}
    end 
    # Set all the attributes given in hash    
    hash.each do |key, value| 
      setter = key.to_s.concat('=').to_sym
      if self.respond_to? setter then self.send setter, value else raise ArgumentError end
    end
    # Add this Group to appropriate collections it belongs to
    # auto-delete from previous collection should be handled by Owner class through collection callbacks
    race.groups << self if race
    product.groups << self if product
    planet.groups << self if planet
    fleet.groups << self if fleet
    from.sent_groups << self if from
    add if self.class.dataset # Add instantiated model to dataset if it is established
  end
  
  # Accessor methods
  def eta ; from ? range/speed : 0 end
  
  def x 
    return xx if xx 
    return planet.x if planet and !from
    return 0 if planet and from # game.geometry.group_pos(self)[0]
    nil
  end
  
  def y 
    return yy if yy 
    return planet.y if planet and !from
    return 0 if planet and from # game.geometry.group_pos(self)[0]
    nil
  end
  
  def destination ; planet end
  
  def origin ; from end
  alias source origin
  
  def key 
    if num # Your Group or other known race from additional reports
      race.name + '.' + num.to_s 
    else # Impossible to define primary key (no combination of parameters is unique)
      nil
    end
  end
  
  def distance planet
    #game.geometry.distance (self, planet2)
    0 
  end
  
  # Boolean tests on Groups
  def from_battle? ; @battles and @battles > 0 end # This Group is known from Battle
  
  def incoming? ; !your? and from and planet and planet.your? end
  
  def unidentified? ; !race end
  alias unknown? unidentified?
  
  def active?
    return true unless from_battle? # All Groups are "real", unless they are known only from Battle
    !your? and num_ships > 0 and planet.unknown? and planet.battles == self.battles # Not killed Groups from LAST Battle on UNKNOWN PLanet are "real" too
  end  
  alias real? active?
  
  def your_active? ; active? and your? end # Only includes your "active" (NOT from_battle) groups

  def drone? ; (product and product.drone?) or (incoming? and mass == 1) end
  
  def <=>(other) # Default comparable is num_ships
    case other
      when nil then 1
      when Group then # key <=> other.key
      return 0 if key and self.key == other.key
      if num_ships and other.num_ships then num_ships <=> other.num_ships else -1 end
      # Meaningful comparison only possible for groups with known num_ships
      when Race then race ? race <=> other : -1
    when Planet then
      return 0 if from and from == other
      planet ? planet <=> other : -1
      when Product then product ? product <=> other : -1
      when Fleet then fleet ? fleet <=> other : -1
      when Integer then num_ships ? num_ships <=> other : -1
      when String then self <=> other.downcase.to_sym
      when Symbol then 
      return active? ? 0 : 1 if other == :active or other == :real or other == :alive
      return from_battle? ? 0 : 1 if other == :from_battle or other == :battle 
      return incoming? ? 0 : 1 if other == :incoming
      return unidentified? ? 0 : 1 if other == :unidentified or other == :unknown
      return 0 if race and race == other 
      return 0 if product and product == other
      return 0 if planet and planet == other 
      return 0 if from and from == other 
      return 0 if fleet and fleet == other 
      return 0 if status and status.downcase.include? other.to_s
      return 0 if key and key.downcase.include? other.to_s
      -1
    else raise ArgumentError, 'Comparison with a wrong type'
    end
  end
end #Group
