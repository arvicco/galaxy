#TAG section.rb tasks are on 
#require 'oniguruma'

# Regexen module provides pattern Constants that are used by Sections to describe its data structure
module Regexen
  #Defining basic regex patterns...
  Name = '([[:punct:]\w]+)'
  Sname = ' +?' + Name
  Fname = '^ *?' + Name        #first Name in line (may be preceded by spaces, or not)
  Num = '(\d+(?:\.\d+)?)(?=\s)'
  Snum = ' +?' + Num
  Fnum = '^ *?' + Num
  Int = '(\d+)'
  Sint = ' +?' + Int
  Fint = '^ *?' + Int          #first int in line (may be preceded by spaces, or not)
  Line = '([[:punct:]\w ]+)'
  Scargo = ' +?(COL|CAP|MAT|-)'
  Sstatus = ' +?(War|Peace|-|In_Battle|Out_Battle|In_Space|In_Orbit|Upgrade|Launched|Transfer_Status|Damaged|Wiped)' #may need further refining for productivity
  Group = Sname + Snum * 4 + Scargo + Snum #Different from actual Groups?! Have to check...
  Header = '\n\n\s*?([PIRVNDAWSCM#TQLOXY$EGF]\s+?)' 
  
  #Defining section header/footer patterns
  Reports_header = Name + ' Report for Galaxy PLUS' + Sname + ' Turn' + Sint + ' ' + Line + '$\s*' + Line 
  #+    '$$\s*Size:' + Snum + '\s*Planets:' + Snum + '\s*Players:'+ Snum
  Races_header =  '^\s*?Status of Players .+?' + Snum + ' votes\)' + Header
  Science_products_header =  '^\s*?' + Name + ' Sciences' + Header
  Ship_products_header =  '^\s*?' + Name + ' Ship Types' + Header
  Battle_planets_header =  '^\s*?Battle at \(#' + Int + '\) ' + Name
  Bombings_header =  '^\s*?Bombings' + Header
  Maps_header = '^\s*Map around'
  Incoming_groups_header =  '^\s*?(Incoming) Groups' + Header
  Your_planets_header =  '^\s*?(Your) Planets' + Header
  Planets_header =  '^\s*?' + Name + ' Planets' + Header
  Production_planets_header = '^\s*?Ships In Production' + Header
  Routes_header = '^\s*?(Your) Routes' + Header
  Uninhabited_planets_header =  '^\s*?(Uninhabited) Planets' + Header
  Unidentified_planets_header =  '^\s*?(Unidentified) Planets' + Header
  Fleets_header = '^\s*?(Your) Fleets' + Header
  Your_groups_header = '^\s*?(Your) Groups' + Header
  Groups_header = '^\s*?' + Name + ' Groups(?<!Your Groups)(?<!Unidentified Groups)\s+?' #' Groups(?<!Your Groups)(?<!Unidentified Groups)\s+?' + Header
  Battle_groups_header = Groups_header
  Unidentified_groups_header = '^\s*(Unidentified) Groups' + Header
  Default_footer ='(\n\n)|(\z)'
  
  #Defining data record patterns
  Races_record =  Fname + Snum * 7 + Sstatus + Snum
  Science_products_record =  Fname + Snum * 4
  Ship_products_record =  Fname + Snum * 6
  #Battles_line = '^' + Line + '(fires on)' + Line + '($)'
  Battle_planets_record = Battle_planets_header
  Battle_groups_record = Fint + Group + Sint + Sstatus
  Bombings_record = Fname + Sname + Sint + Sname + Snum * 2 + Sname + Snum * 4 + Sstatus
  Incoming_groups_record = Fname + Sname + Snum * 3
  Unidentified_planets_record = Fint + Snum * 2
  Uninhabited_planets_record = Unidentified_planets_record + Sname + Snum * 4 
  Planets_record = Uninhabited_planets_record + Sname + Snum * 4
  Your_planets_record = Planets_record
  Production_planets_record = Fint + Sname * 2 + Snum * 3
  Routes_record = Fname + Sname * 4         #Attention! routes_record captures column headers line
  Fleets_record = Fint + Sname + Sint + Sname * 2 + Snum * 2 + Sstatus
  Your_groups_record = Fint + Sint + Group + Sname * 2 + Snum * 3 + Sname + Sstatus 
  Groups_record = Fint + Group + Sname + Snum * 2
  Unidentified_groups_record = Fnum + Snum
  # FIXME Broadcasts not defined
  
  #Defining data processing Procs
  Default_header_proc = lambda do |match, state| 
    state[:race] = match[1] == 'Your' ? Race.lookup(state[:owner]) : Race.lookup(match[1]) if match[1]
  end
end

# Section is a piece of text that contains data structured in a certain way (possibly with sub-sections),
# Section describes this data structure and provides methods for parsing the text and extracting data records
# By default, Section calls new_or_update method on class defined by Section name
# Example: Section(:name=>:battle_groups) calls Group.new_or_update(match, state) on each found /Battle_group_record/ match
# by default, unless :record_proc is provided to Section
# 'state' hash is used to provide context for multi-section parsing
class Section
  include Regexen
  
  attr_accessor :name       # Name of this Section (also used to auto-generate properties)
  attr_accessor :text       # Source text of this Section (raw material for data extraction)
  attr_accessor :header     # Regex identifying start of this Section (obligatory!)
  attr_accessor :footer     # Regex identifying end of this Section (end of EACH Multisections)
  attr_accessor :record     # Regex matching data Record (or an array of such regexen)
  attr_accessor :header_proc # Proc object to be run on Header match
  attr_accessor :footer_proc # Proc object to be run on Footer match
  attr_accessor :record_proc # Proc object to be run on each Record match (or an array of Procs) 
  attr_accessor :sections   # (Sub)sections (possibly) contained inside this Section 
  attr_accessor :skip       # Flag indicating that this Sections contains no data (should be skipped) 
  attr_accessor :mult       # Flag indicating that this is a "Multisection" (several Sections with similar headers one after another) 
  
  # New Section is created by using the following syntax:
  #  Section.new {:header => header, :footer => footer, :record =>[rec1,rec2], :sections => [sec1,sec2,sec3]}
  #  Section.new {:name => name}  -> extracted as {:header => Name_header, :footer => Name_footer, :record =>Name_record }
  #  Section.new :symbol  -> extracted as {:header => Symbol_header, :footer => Symbol_footer, :record =>Symbol_record }
  def initialize args
    case args       # Parsing (named) arguments
      when Symbol, String # Symbol represents Section name, appropriately named Constants MUST be defined in Regexen module
      @name = args.to_s.downcase.capitalize
      when Hash
      @name = args[:name].to_s.downcase.capitalize if args[:name]
      @text = args[:text]
      @skip = args[:skip]
      @mult = args[:mult]
      @sections = args[:sections]
      
      # Header/footer/record patterns and appropriate processing Procs can be: 
      # 1) given as a Constant name (should be defined in Regexen module), 
      # 2) given as a direct value (escaped pattern string literal or Proc, respectively), or
      # 3) not given at all, appropriate values should be inferred from :name argument 
      @header = Regexen.const_get(args[:header]) rescue args[:header]
      @footer = Regexen.const_get(args[:footer]) rescue args[:footer]
      @record = Regexen.const_get(args[:record]) rescue args[:record]
      @header_proc = Regexen.const_get(args[:header_proc]) rescue args[:header_proc]
      @footer_proc = Regexen.const_get(args[:footer_proc]) rescue args[:footer_proc]
      @record_proc = Regexen.const_get(args[:record_proc]) rescue args[:record_proc]
    end #case  
    
    # Try to auto-generate Section's Patterns and Procs from @name (if they are not already given)
    # First we try to find Regexen constants derived from name, if not found then we look for defaults
    @header = @header || Regexen.const_get(@name + '_header') rescue 
    if Regexen.const_defined?('Default_header') then Regexen.const_get('Default_header') end
    @footer = @footer || Regexen.const_get(@name + '_footer') rescue 
    if Regexen.const_defined?('Default_footer') then Regexen.const_get('Default_footer') end  
    @record = @record || Regexen.const_get(@name + '_record') rescue 
    if Regexen.const_defined?('Default_record') then Regexen.const_get('Default_record') end
    @header_proc = @header_proc || Regexen.const_get(@name + '_header_proc') rescue 
    if Regexen.const_defined?('Default_header_proc') then Regexen.const_get('Default_header_proc') end
    @footer_proc = @footer_proc || Regexen.const_get(@name + '_footer_proc') rescue 
    if Regexen.const_defined?('Default_footer_proc') then Regexen.const_get('Default_footer_proc') end  
    @record_proc = @record_proc || Regexen.const_get(@name + '_record_proc') rescue 
    if Regexen.const_defined?('Default_record_proc') then Regexen.const_get('Default_record_proc') end
    
    # This is a G+ specific piece of code overriding general Section functionality (Default_record_proc)
    # Needed to speed up calculations and avoid class evaluations on each record
    # Class name of the Object (described by Record), e.g "Group"
    if @name and not @record_proc 
      klass_name = @name.split("_")[-1][0..-2].capitalize
      if Object.const_defined?(klass_name) 
        klass = Object.const_get(klass_name) 
        @record_proc ||= lambda do |match, state| 
          klass.new_or_update match[1..-1], state
        end 
      end 
    end
  end #initialize
  
  # Returns (relatively) deep copy of self
  def copy
    secs = @sections ? @sections.map {|s| s.copy} : nil
    Section.new :name=>@name, :header=>@header, :footer=>@footer, :record=>@record, :header_proc=>@header_proc, 
    :footer_proc=>@footer_proc, :record_proc=>@record_proc, :sections=>secs, :skip=>@skip, :mult=>@mult, :text=>@text
  end
  
  # Recursively parse Section, extract data records
  def parse state={}
    state[:section] = @name
    if @mult
      #puts "Mults: #{self.name} #{self.header}"
      # Multisection: Find out if this Section is actually a collection of sections with similar headers
      # If it is, clone an Array of multisections and call parse on each (data extraction happens downstream)
      scan_text(@header) do |match|
        start = match.begin
        finish = -1 unless finish = find_text(@footer, match.end) # Find end of Section (after Header END)
        s = self.copy # Create a copy of Section (to be used as child multisection template)
        s.mult = false
        s.text = @text[start..finish] # Set text property for found multisection
        s.parse state # Recursively call parse on each found multisection
      end
    else
      # Process Section Header, Records and Footer (if any)
      find_text(@header) {|match| @header_proc.call match, state} if @header and @header_proc
      scan_text(@record) {|match| @record_proc.call match, state} if @record and @record_proc
      find_text(@footer) {|match| @footer_proc.call match, state} if @footer and @footer_proc
      
      if @sections
        #puts "Sections: #{self.name} #{self.header}"
        # Process Sections array against @text, skipping empty/skippable Sections, recursively 
        # calling parse on found Sections and moving forward position cursor pos 
        # TODO Generalize for UNORDERED Sections (position cursor should not work in this case)
        finish = 0
        @sections.each_with_index do |s, i|
          next if s.skip #Skip non-data Section
          if start = find_text(s.header, finish)  # Find Section Header
            finish = nil # Needed for last Section (no next section to find)
            @sections[i+1..-1].each do |sn| # Find finish by cycling through next Section Headers
              break if finish = find_text(sn.header, start) # Find first of next Section Header 
            end 
            finish = -1 unless finish # If finish not found, set it to the end of @text
            #Start and finish defined, assign text to this Section and recursively parse it
            s.text = @text[start..finish]
            s.parse state 
          end 
        end 
      end 
    end   
  end #parse
  
  # Safely matches given regex to @text (starting at position pos),
  # returns initial offset of match or nil if regex not found, yield match to given block (if any)
  def find_text regex, pos=0
    return nil if @text == nil
    return nil if regex == nil
    text = pos == 0 ? @text : @text[pos..-1]
    match = Oniguruma::ORegexp.new(regex).match(text)
    return nil unless match 
    yield match if block_given?
    pos + match.begin # Return initial match offset (corrected for position pos)
  end #find_text
  
  # Scans @text for Data Records matching given regex pattern, returns array of matching Data Records 
  # (as MatchData or String array), yields each found match object to given block (if any)
  def scan_text regex, pos=0
    text = pos == 0 ? @text : @text[pos..-1]
    if block_given?
      # Scan Section for regex matches, yield each match to given block, return array of MATCH objects
      Oniguruma::ORegexp.new(regex).scan(text) {|match| yield match }
    else
      # Scan Section for regex matches, return array of matches converted into string arrays
      results=[]
      Oniguruma::ORegexp.new(regex).scan(text) {|match| results << match[1..-1].to_a }
      results
    end
  end #scan_text
end #class Section