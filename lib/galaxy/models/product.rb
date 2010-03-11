require 'galaxy/models/models'

class Product < ActiveRecord::Base
  virtual
  tableless :columns => [
  [:name, :string], 
  [:drive, :float], 
  [:weapons, :float], 
  [:shields, :float], 
  [:cargo, :float],
  [:guns, :integer],
  [:mass, :float],
  [:prod_type, :string]
  ]
  belongs_to :race
  has_many_linked :bombings
  has_many_linked :groups 
  has_many_linked :planets 
  
  def initialize match, state
    case match.size
      when 7 then # This is a ship design
      super({:name=>match[0], :drive=>match[1].to_f, :guns=>match[2].to_i, :weapons=>match[3].to_f, 
        :shields=>match[4].to_f, :cargo=>match[5].to_f, :mass=>match[6].to_f, :prod_type=>'ship'})
      
      when 5 then # This is a science
      super({:name=>match[0], :drive=>match[1].to_f, :weapons=>match[2].to_f, :shields=>match[3].to_f, 
        :cargo=>match[4].to_f, :prod_type=>'research'})
      
      when 0 then # This is Cap/Mat/Col/Drive/Weapon/Shields/Cargo init, all init data given in a hash
      super state # :name=>state[:name], :prod_type=>state[:prod_type]
    end
    # Add this Product to appropriate Race collections it belongs to
    # auto-delete from previous collection should be handled by Race class through collection callbacks
    state[:race].products << self if state[:race]
    add if self.class.dataset # Add instantiated model to dataset if it is defined
  end
  
  def key
    full_name = research? ? name + '_Research' : name
    full_name = race.name + '.' + full_name if race 
    full_name
  end
  
  # Boolean tests on Products
  def cap? ; prod_type == 'cap' end
  
  def mat? ; prod_type == 'mat' end
  
  def terraforming? ; research? and name == '_TerraForming' end
  
  def moving? ; name[0..3].downcase == 'move' end
  
  def ship? ; mass != nil end
  
  def drone? ; drive == 1 and mass == 1 end
  
  def research? ; prod_type == 'research' end
  
  def in_use? ; !bombings.empty? or !planets.empty? or !groups.empty?  end
  alias science? research?
  
  def <=>(other)
    case other
      when nil then 1
      when Race then race ? race <=> other : -1
      when Product then (ship? and mass != other.mass) ? mass <=> other.mass : key <=> other.key
      when Bombing then bombings.any? {|r| r == other} ? 0 : 1 #Product is bigger than Bombing
      when Planet then planets.any? {|r| r == other} ? 0 : 1 #Product is bigger than Planet
      when Integer then ship? ? mass <=> other : 1 #Science is bigger than anything
      when Float then ship? ? mass <=> other : 1 #Science is bigger than anything
      when String then self <=> other.downcase.to_sym
      when Symbol then 
      return drone? ? 0 : 1 if other == :drone or other == :dron
      return research? ? 0 : 1 if other == :research or other == :science or other == :tech 
      return moving? ? 0 : 1 if other == :move or other == :moving 
      return terraforming? ? 0 : 1 if other == :terraform or other == :terraforming
      return 0 if prod_type.downcase.to_sym == other
      return 0 if key.downcase.include? other.to_s
      key <=> other.to_s
    else raise ArgumentError, 'Comparison with a wrong type'
    end
  end
end
