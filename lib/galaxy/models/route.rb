require 'galaxy/models/models'

class Route < ActiveRecord::Base
  virtual
  tableless :columns => [
  [ :cargo, :string ]
  ]  
  belongs_to :race 
  belongs_to :planet
  belongs_to :target, :class_name => "Planet"
  
  def initialize match, state # match is not really used, remains for consistency with other models
    
    return if match.join == 'N$MCE' # Skip header
    match[1..4].each_with_index do |m,i|
      if m != '-'
        super :cargo => ['cap', 'mat', 'col', 'empty'][i]
        self.target = Planet.new_or_update [m], state.merge({:race=>nil,:product=>nil,:created_by=>self}) unless self.target = Planet.lookup(m)
      end
    end
    planet = Planet.new_or_update [match[0]], state.merge({:race=>nil,:product=>nil,:created_by=>self}) unless planet = Planet.lookup(match[0])
    race = Race.lookup(state[:owner])
    
    race.routes << self
    planet.routes << self
    target.incoming_routes << self
    add if self.class.dataset # Add instantiated model to dataset if it is defined
  end
  
  def kill
    if result = super
      race.routes.delete self if race
      planet.routes.delete self if planet and planet == self
      target.incoming_routes.delete self if target and target == self
      self.planet = nil
      self.target = nil
    end
    result
  end
  
  def key ; [planet.num, target.num, cargo].join('.') end
  
  def <=>(other)
    case other
      when nil then 1
      when Route then key <=> other.key
      when Race then race <=> other
      when Planet then planet == other ? 0 : target <=> other
      when Integer, Float then planet.distance(target) <=> other
      when String then self <=> other.downcase.to_sym
      when Symbol then 
      return 0 if race == other
      return 0 if planet == other
      return 0 if target == other
      return 0 if cargo.downcase.include? other.to_s
      key.downcase <=> other.to_s
    else raise ArgumentError, 'Comparison with a wrong type'
    end
  end
end #Route
