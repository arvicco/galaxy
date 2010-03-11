#TAG report.rb tasks are on
require 'galaxy/section.rb'

# Module Gamedata provides G+ game-related data elements and collections 
# and defines basic accessors to them for any Class including this module
module Gamedata
  require 'galaxy/utils.rb'
  require 'galaxy/models/models.rb'
  
  attr_accessor :order  # Order (Object?) associated with this report
  attr_accessor :owner  # Report owner race
  attr_accessor :game   # Report game name
  attr_accessor :turn   # Report turn number
  attr_accessor :time   # Report time (from server)
  attr_accessor :server # Report server version (string)
  
  # Establish Data Collections 
  attr_accessor :races # Races in Report
  attr_accessor :products # Sciences in Report
  attr_accessor :bombings # Bombings in Report
  attr_accessor :planets # Planets in Report
  attr_accessor :routes # Routes in Report
  attr_accessor :fleets # Fleets in Report
  attr_accessor :groups # Groups in Report
  attr_accessor :battles #FIXME Add Battles (based on Battle Protocols) later
  
  def initialize *args
    # When object of any including Class is instantiated (and calling super),
    # modify ActiveRecord:Base and point @@dataset attribute to this object
    ActiveRecord::Base.establish_dataset(self)
    
    # Initialize G+ collections
    @races = HashArray.new
    @bombings = HashArray.new 
    @planets = HashArray.new 
    @routes = HashArray.new 
    @fleets = HashArray.new 
    @groups = HashArray.new 
    @products = HashArray.new
    
    # Generate Products that are present in each G+ report by default
    @products['Drive_Research'] = Product.new [], {:name=>'Drive', :prod_type=>'research'}
    @products['Weapons_Research'] = Product.new [], {:name=>'Weapons', :prod_type=>'research'}
    @products['Shields_Research'] = Product.new [], {:name=>'Shields', :prod_type=>'research'}
    @products['Cargo_Research'] = Product.new [], {:name=>'Cargo', :prod_type=>'research'}
    @products['Capital'] = Product.new [], {:name=>'Capital', :prod_type=>'cap'}
    @products['Materials'] = Product.new [], {:name=>'Materials', :prod_type=>'mat'}
    
    super *args
  end
  
  def sciences 
    @products.find_all {|p| p and p.race and p.science?} || [] #redefine find_all in HashArray?
  end
  
  def ships 
    @products.find_all {|p| p and p.race and p.ship?} || [] #redefine find_all in HashArray?
  end
  alias designs ships
  
  def battle_groups
    @groups.find_all {|g| g and g.from_battle?} || []
  end
  
  def incoming_groups
    @groups.find_all {|g| g and g.incoming?} || []
  end
  
  def your_groups
    @groups.find_all {|g| g and g.your?} || []
  end
  
  def your_active_groups
    @groups.find_all {|g| g and g.your_active?} || []
  end
  
  def unidentified_groups
    @groups.find_all {|g| g and g.unidentified?} || []
  end
  alias unknown_groups unidentified_groups 
  
  def your_planets
    @planets.find_all {|p| p and p.your?} || []
  end
  
  def uninhabited_planets
    @planets.find_all {|p| p and p.uninhabited? } || []
  end
  
  def unidentified_planets
    @planets.find_all {|p| p and p.unidentified? } || []
  end
  alias unknown_planets unidentified_planets 
end

# Describes Galaxy Plus Report (as received from server) data structures and provides
# 'parse' method for extracting data it.
# Initially, Report "contains" extracted data (through included module Gamedata), 
# but later on these data containers should be moved to new Game class
class Report < Section
  include Gamedata
  
  # Describes G+ Report data structure, opens report file if given a valid file name
  def initialize (*args)
    
    # Define Proc for Report Header processing TODO 
    report_proc = lambda do |match, state|
      @owner = state[:owner] = match[1]
      @game = state[:game] = match[2]
      @turn = state[:turn] = match[3].to_i
      @time = state[:time] = match[4]
      @server = state[:server] = match[5]
    end
    
    # Define G+ Report Sections
    @sections = [ 
    :races,
    {:name=>:science_products, :mult=>true}, 
    {:name=>:ship_products, :mult=>true}, 
    {:name=>:battle_planets, :footer => 'Battle Protocol', 
      :sections => [Section.new(:name=>:battle_groups, :mult=>true)], :mult=>true },
    :bombings, 
    {:header => 'Maps_header', :skip=>true},
    :incoming_groups,
    :your_planets,
    :production_planets, 
    :routes,
    {:name=>:planets, :mult=>true},
    :uninhabited_planets,
    :unidentified_planets,
    :fleets,
    :your_groups,
    {:name=>:groups, :mult=>true},  
    :unidentified_groups
    ].map do |init| Section.new init end
    
    # Initialize main Section and data Collections (from module Gamedata)
    super :name=>:reports, :header_proc=>report_proc, :sections => @sections
    
    # Checking arguments
    case args.size 
      when 0 then # Do nothing
      when 1 then open *args
    else  # Wrong number of arguments, initializer failed
      puts "Usage: Report.new or Report.new(file_name)"
      raise ArgumentError, "Wrong number of arguments in Report initialization"
    end
  end
  
  # Validates file name and reads everything from file into Report's @text property
  def open file_name
    if file_name =~ /\A[[:punct:]\w\d]+.rep\z/ and File.exists? file_name
      # This is a valid and existing rep file name
    elsif file_name += '.rep' and file_name =~ /\A[[:punct:]\w\d]+.rep\z/ and File.exists? file_name
      # This is a valid and existing rep file (without rep suffix)
    else
      raise ArgumentError, "Can't open: Invalid Report file #{file_name}"
    end
    # puts "Initializing Report from rep file: " + file_name
    # Open file and pass file stream into block to read from it into Report's @text property
    # File closing is automatic upon execution of the block
    File.open(file_name, "r") do |f| @text = f.read end 
  end
  
  # Method returns status string of the Report
  def status
    return "
Report: #@owner #@game #@turn #@time #@server 
Races: #{@races.size} Sciences: #{sciences.size} Types: #{designs.size} BattleGroups: #{battle_groups.size} \
Bombings: #{@bombings.size} Incomings: #{incoming_groups.size} Your Planets: #{your_planets.size} \
Ships in Production: #{@productions} Routes: #{@routes.size}
Planets: #{@planets.size} Uninhabited Planets: #{uninhabited_planets.size} Unidentified Planets: #{unidentified_planets.size} \
Fleets: #{@fleets.size} Your Groups: #{your_groups.size} Groups: #{@groups.size} Unidentified Groups: #{unidentified_groups.size}"  
  end
  
end #class Report
