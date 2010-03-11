require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
#require 'report.rb'

class X_ReportTest < Test::Unit::TestCase
  
  def setup
  end
  
  def test_rep_081
    
    #Open Report
    start = Time.now
    rep = Report.new "rep/ArVit081.rep"
    
    printf "Length: #{rep.text.length} "
    assert_equal 491978, rep.text.length, 'File length is wrong'
    printf "#{Time.now} Elapsed: #{Time.now-start}\n"
    assert Time.now-start < 0.1, 'Report is loading too long'
    
    # Parse Report (possibly many times)
    start = Time.now
    1.times do rep.parse end
    
    printf "#{Time.now} Elapsed: #{Time.now-start}\n"
    assert Time.now-start < 20, 'Report is parsing too long'
    
    puts rep.status
    
    p rep.races[5], rep.sciences[5], rep.designs[5], rep.battle_groups[5], rep.bombings[0], rep.incoming_groups[0],
    rep.your_planets[5], rep.planets[145], rep.unidentified_planets[5], rep.uninhabited_planets[5], 
    rep.routes[0], rep.fleets[0], rep.groups[5], rep.your_groups[5], rep.unidentified_groups[5]
    #   rep.designs.each {|d| p d}
    #p rep.groups.find_all {|p| p.nil?}.size
    #p rep.planets.find {|p| p and not p.idx}
    #p rep.races['ArVitallian'].planets.size, rep.your_planets - rep.races['ArVitallian'].planets
    #rep.your_planets.each{|elt| print '.' ; s = rep.your_planets.find_all{|e| e==elt}.size; p s, elt if s>1}
    #rep.your_groups.each{|g| p g if g.from_battle?}
    #p rep.groups.find_all{|g| !g.from_battle? and !g.incoming? and !g.unknown?}.size
    #p rep.races.inject(0){|total, race| puts "#{race.name}  #{race.groups.size} #{race.battle_groups.size} + #{total}" if race.groups.size > 0 ; total + race.groups.size}
    
    
    # Assert report stats
    assert_equal 'ArVitallian', rep.owner
    assert_equal 'research3', rep.game
    assert_equal 81, rep.turn
    assert_equal 'Tue Aug 30 03:59:01 2005', rep.time
    assert_equal 'Galaxy PLUS version 1.7 - Dragon Galaxy (NG-edition) 3.01', rep.server
    assert_equal 140, rep.races.size #confirmed 
    assert_equal 160, rep.designs.size #confirmed
    assert_equal 2, rep.bombings.size    #confirmed
    assert_equal 8, rep.fleets.size #confirmed
    assert_equal 2, rep.routes.size #confirmed
    assert_equal 1582,rep.sciences.size #confirmed
    assert_equal 733, rep.planets.size #confirmed
    assert_equal 354, rep.your_planets.size  #confirmed
    assert_equal 70, rep.uninhabited_planets.size #confirmed
    assert_equal 144, rep.unidentified_planets.size #confirmed
    assert_equal 29, rep.incoming_groups.size #confirmed
    assert_equal 111, rep.unknown_groups.size #confirmed 82 "unidentified" + 29 "incoming"
    assert_equal 96, rep.battle_groups.size #confirmed
    assert_equal 1399, rep.your_active_groups.size #confirmed
    assert_equal 1453, rep.your_groups.size #confirmed
    assert_equal 2535+96+82+29, rep.groups.size #sum(1)=2535(*Groups)+96(Battle Groups)+82(unidentified)+29(incoming)
    assert_equal 10288, rep.planets.find_all{|p| p.num}.max{|p1,p2|p1.num<=>p2.num}.num # Max planet number
    
    # Asserting Race collections completeness
    print 'Race collections.'
    rep.races.each do |race|
      next if race.rip?
      print "d"
      assert_equal race.products, rep.products.find_all {|d| d.race==race}, 'Designs Collection broken'
      print "p"
      assert_equal race.planets.sort, rep.planets.find_all {|p| p and p.race==race}.sort, 'Planets Collection broken' 
      print "r"
      assert_equal race.routes.sort, rep.routes.find_all {|p| p and p.race==race}.sort, 'Routes Collection broken' 
      print "f"
      assert_equal race.fleets.sort, rep.fleets.find_all {|p| p and p.race==race}.sort, 'Fleets Collection broken' 
      print "b"
      assert_equal race.bombings.sort, rep.bombings.find_all {|p| p and p.race==race}.sort, 'Bombings Collection broken' 
      print "g"
      assert_equal race.groups.sort, rep.groups.find_all {|p| p and p.race==race}.sort, 'Groups Collection broken' 
      print "."
    end
    
    # Assert individual gamedata elements
    #p rep.planets[0]
    #p rep.races['Mutabor']
    
    #    p rep.groups.select{|g| g.race=='Homo_galaktikus'}.size 
    
    p rep.designs.find_all {|d| d.race==rep.races['CBuHbu']}
    p rep.races['CBuHbu'].designs
    
    # Test selection on data collections
    #sum =0
    #drons = rep.your_groups.select {|group| group[13].to_i == 1 and group[1].to_i == 1}
    #drons += rep.groups.select {|group| group[10].to_i == 1 and group[0].to_i == 1}
    #transports = rep.your_groups.select {|group| group[6].to_f != 0 }
    #transports += rep.groups.select {|group| group[5].to_f != 0 }
    
    # Test cycles on data collections
    #transports.each do |group|
    #  rep.planets.select {|planet| planet[3] == group[8]} 
    #  rep.planets.each do |planet|
    #    sum += 1 if planet[3] == group[8]
    #  end
    #end
    
    #printf "Transports: #{transports.size} Drons: #{drons.size} "
    
    printf " #{Time.now} Elapsed: #{Time.now-start}\n"
    
  end
  def no_test_rep_187
    
    #Open Report
    start = Time.now
    rep = Report.new "rep/ArVit187.rep"
    
    printf "Length: #{rep.text.length} "
    assert_equal 6025330, rep.text.length, 'File length is wrong'
    
    printf "#{Time.now} Elapsed: #{Time.now-start}\n"
    assert Time.now-start < 0.3, 'Report is loading too long'
    
    # Parse Report (possibly many times)
    start = Time.now
    1.times do rep.parse end
    
    printf "#{Time.now} Elapsed: #{Time.now-start}\n"
    assert Time.now-start < 130, 'Report is parsing too long'
    
    puts rep.status
    
    p rep.races[5], rep.sciences[5], rep.designs[5], rep.battle_groups[5], rep.bombings[0], rep.incoming_groups[0],
    rep.your_planets[5], rep.planets[145], rep.unidentified_planets[5], rep.uninhabited_planets[5], 
    rep.routes[0], rep.fleets[0], rep.groups[5], rep.your_groups[5], rep.unidentified_groups[5]

    # Assert report stats
    assert_equal 'ArVitallian', rep.owner
    assert_equal 'research3', rep.game
    assert_equal 187, rep.turn
    assert_equal 'Mon Oct 09 21:19:05 2006', rep.time
    assert_equal 'Galaxy PLUS version 1.7 - Dragon Galaxy (NG-edition) 3.04', rep.server
    assert_equal 140, rep.races.size #confirmed 
    assert_equal 9488,rep.sciences.size #confirmed
    assert_equal 1544, rep.designs.size #confirmed
    assert_equal 24, rep.bombings.size    #confirmed
    assert_equal 2515, rep.your_planets.size  #confirmed
    assert_equal 149, rep.uninhabited_planets.size #confirmed
    assert_equal 956, rep.unidentified_planets.size #confirmed
    assert_equal 6046, rep.planets.size #confirmed #sum(1)=2535  ???xxx(*Groups)+96(Battle Groups)+82(unidentified)+29(incoming)
    assert_equal 10292, rep.planets.find_all{|p| p.num}.max{|p1,p2|p1.num<=>p2.num}.num # Max planet number
    assert_equal 16, rep.fleets.size #confirmed
    assert_equal 26, rep.routes.size #confirmed
    assert_equal 3203, rep.battle_groups.size #confirmed
    assert_equal 769, rep.unknown_groups.size #confirmed ??? d 593 "unidentified" + 176 "incoming"
    assert_equal 176, rep.incoming_groups.size #confirmed
    assert_equal 9864, rep.your_active_groups.size #confirmed 
    assert_equal 10406, rep.your_groups.size #confirmed 9864 active + 542 from battle
    assert_equal 39348, rep.groups.size #sum(1)=37018
#Report: ArVitallian research3 187 Mon Oct 09 21:19:05 2006 Galaxy PLUS version 1.7 - Dragon Galaxy (NG-edition) 3.04
#Races: 140 Sciences: 9488 Types: 1544 BattleGroups: 3203 Bombings: 24 Incomings: 176 Your Planets: 2515 Ships in Production:  Routes: 26
#Planets: 6046 Uninhabited Planets: 149 Unidentified Planets: 956 Fleets: 16 Your Groups: 10406 Groups: 39348 Unidentified Groups: 769

    # Asserting Race collections completeness
    print 'Race collections.'
    rep.races.each do |race|
      next if race.rip?
      print "d"
      assert_equal race.products, rep.products.find_all {|d| d.race==race}, 'Designs Collection broken'
      print "p"
      assert_equal race.planets.sort, rep.planets.find_all {|p| p and p.race==race}.sort, 'Planets Collection broken' 
      print "r"
      assert_equal race.routes.sort, rep.routes.find_all {|p| p and p.race==race}.sort, 'Routes Collection broken' 
      print "f"
      assert_equal race.fleets.sort, rep.fleets.find_all {|p| p and p.race==race}.sort, 'Fleets Collection broken' 
      print "b"
      assert_equal race.bombings.sort, rep.bombings.find_all {|p| p and p.race==race}.sort, 'Bombings Collection broken' 
      print "g"
      assert_equal race.groups.sort, rep.groups.find_all {|p| p and p.race==race}.sort, 'Groups Collection broken' 
      print "."
    end

    printf " #{Time.now} Elapsed: #{Time.now-start}\n"
  end
end