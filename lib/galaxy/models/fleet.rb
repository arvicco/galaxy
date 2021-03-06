require 'galaxy/models/models'

class Fleet < ActiveRecord::Base
  virtual
  tableless :columns => [
  [ :num, :integer ],
  [ :name, :string ],
  [ :num_groups, :integer ],
  [ :range, :float ],
  [ :speed, :float ],
  [ :status, :string ] # May cause problems with AR?
  ]  
  belongs_to :race 
  belongs_to :planet
  belongs_to :from, :class_name => 'Planet'
  has_many_linked :groups 
  
  def initialize match, state
    super :num=>match[0].to_i, :name=>match[1], :num_groups=>match[2].to_i, :range=>match[5].to_f, 
    :speed=>match[6].to_f, :status=>match[7]
    
    planet = Planet.new_or_update[match[3]], state.merge({:race=>nil,:product=>nil,:created_by=>self}) unless planet = Planet.lookup(match[3])
    from = Planet.new_or_update [match[4]], state.merge({:race=>nil,:product=>nil,:created_by=>self}) unless from = Planet.lookup(match[4]) unless match[4] == '-'
    race = Race.lookup(state[:owner])
    
    planet.fleets << self
    from.sent_fleets << self if from
    race.fleets << self
    add if self.class.dataset # Add instantiated model to dataset if it is defined
  end
  
  def eta ; from ? range/speed : 0 end
  
  def destination ; planet end
  
  def source ; from end
  alias origin source
  
  def key ; race.name + '.' + name end
  
  def <=>(other)
    case other
      when nil then 1
      when Fleet then key <=> other.key
      when Race then race <=> other
      when Planet then
      return 0 if from and from == other
      self.planet <=> other
      when Group then groups.any? {|g| g == other} ? 0 : 1 # Fleet always bigger than Group
      when Integer then num_groups <=> other
      when String then self <=> other.downcase.to_sym
      when Symbol then 
      return 0 if race and race == other
      return 0 if planet and planet == other
      return 0 if from and from == other
      return 0 if status.downcase.include? other.to_s
      return 0 if key.downcase.include? other.to_s
      key.downcase <=> other.to_s
    else raise ArgumentError, 'Comparison with a wrong type'
    end
  end
end #Fleet
