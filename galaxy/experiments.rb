#require 'models.rb' 
require 'report.rb'
#Default_footer = 'default'  
@name = 'Bombings'
@footer = 'Pre-value'
@footer = @footer || Regexen.const_get('rDefault_footer') rescue 'Fuck!' #if Regexen.const_defined?(:Default_footer) then Regexen.const_get(:Default_footer) end  

 p @footer

##Open Report
#start = Time.now
#rep = Report.new "rep/ArVit081.rep"
#
#printf "Length: #{rep.text.length} #{Time.now} Elapsed: #{Time.now-start}\n"
#
## Parse Report (possibly many times)
#start = Time.now
#1.times do rep.parse end
#
#printf "#{Time.now} Elapsed: #{Time.now-start}\n"
#
#puts rep.status
#
#p rep.races[5], rep.sciences[5], rep.designs[5], rep.battle_groups[5], rep.bombings[0], rep.incoming_groups[0],
#rep.your_planets[5], rep.planets[145], rep.unidentified_planets[5], rep.uninhabited_planets[5], 
#rep.routes[0], rep.fleets[0], rep.groups[5], rep.your_groups[5], rep.unidentified_groups[5]
