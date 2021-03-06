#TAG bombing.rb tasks are on
require 'galaxy/models/models'

class Bombing < ActiveRecord::Base
  virtual
  tableless :columns => [
  [ :pop, :float ],
  [ :ind, :float ],
  [ :cap, :float ],
  [ :mat, :float ],
  [ :col, :float ],
  [ :attack, :float ],
  [ :status, :string ]
  ]  
  
  belongs_to :planet
  belongs_to :product #special syntax(no _Research for sciences)!
  belongs_to :race
  belongs_to :victim, :class_name => "Race"
  
  def initialize match, state
    super :pop=>match[4].to_f, :ind=>match[5].to_f, :cap=>match[7].to_f, :mat=>match[8].to_f, :col=>match[9].to_f,
    :attack=>match[10].to_f, :status=>match[11]
    
    num = '#' + match[2]
    unless planet = Planet.lookup(num)
      args = match[3] == num ? [num] : [match[2], match[3]]
      planet = Planet.new_or_update args, state.merge({:race=>nil,:product=>nil,:created_by=>self})
    end
    race = Race.lookup(match[0])
    victim = Race.lookup(match[1])
    prod_name = match[6]
    product = Product.lookup(prod_name) || Product.lookup(prod_name+'_Research') || Product.lookup(victim.name + '.' + prod_name) || Product.lookup(victim.name + '.' + prod_name+'_Research')
    
    # Add this Bombing to appropriate collections it belongs to
    product.bombings << self
    planet.bombings << self
    race.bombings << self
    victim.incoming_bombings << self
    add if self.class.dataset # Add instantiated model to dataset if it is established
  end
  
  def key ; [race.name, victim.name, planet.num].join('.') end  
  
  def <=>(other)
    case other
      when nil then 1
      when Bombing then key <=> other.key
      when Planet then planet <=> other
      when Product then product <=> other
      when Race then victim == other ? 0 : race <=> other
      when Integer then attack <=> other
      when String then self <=> other.downcase.to_sym
      when Symbol then 
      return 0 if planet == other
      return 0 if product == other
      return 0 if race == other
      return 0 if victim == other
      return 0 if status.downcase.include? other.to_s
      key.downcase <=> other.to_s
    else raise ArgumentError, 'Comparison with a wrong type'
    end
  end
end #Bombing