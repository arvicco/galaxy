#TAG models_test.rb tasks are on
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
#require 'report.rb'

class M_RaceTest < Test::Unit::TestCase
  def setup
    rep = Report.new 'rep/ArVit187.rep'
    @data = ActiveRecord::Base.establish_dataset(rep)
    @data.owner='ArVitallian'
  end
  
  def test_fail
    assert_equal 1, 0
  end

  def test_order #Tests new Order functionality
    av = Race.new %w[ArVitallian 13.00  11.61  11.08  5.48  2276614.82  2028341.13  2515 - 2276.61],{:game=>'research3', :turn=>187}
    rip = Race.new %w[Krot_RIP  6.54   4.22   3.45  1.83 0.00 0.00 0  War 0.00],{}
    text = "#order research3 ArVitallian_zelikaka turn 187\n#end\n"
    text1 = "#order research3 ArVitallian_zelikaka turn 187\n#Test line\n#end\n"
    
    puts av.order.text
    assert_nil rip.order, 'Newly created race should have default Order'
    assert_equal text, av.order.text, 'Newly created race should have empty Order'
    
    av.order.add_line '#Test line'
    puts av.order.text
    assert_equal text1, av.order.text, 'Newly created race should have empty Order'
  end
  
  def test_init
    av = Race.new %w[ArVitallian 13.00  11.61  11.08  5.48  2276614.82  2028341.13  2515 - 2276.61],{}
    m = Race.new %w[Krot_RIP  6.54   4.22   3.45  1.83 0.00 0.00 0  War 0.00],{}
    
    assert_equal "ArVitallian", av.key, 'Key accessor wrong'
    assert_equal "ArVitallian", av.name, 'Name attribute wrong'
    assert_equal 13.0, av.drive, 'Drive attribute wrong'
    assert_equal 11.61, av.weapons, 'Weapons attribute wrong'
    assert_equal 11.08, av.shields, 'Shields attribute wrong'
    assert_equal 5.48, av.cargo, 'Cargo attribute wrong'
    assert_equal 2276614.82, av.pop, 'Pop attribute wrong'
    assert_equal 2028341.13, av.ind, 'Ind attribute wrong'
    assert_equal 2515, av.num_planets, 'Number of planets wrong'
    assert_equal "-", av.relation, 'Relation attribute wrong'
    
    # Assert Boolean Methods
    assert m.rip?, 'Rip method wrong'
    assert ! av.rip? , 'Rip method wrong'
    assert m.war? , 'War method wrong'
    assert av.peace? , 'War method wrong'
    assert ! m.ally? , 'War method wrong'
    assert av.friend? , 'War method wrong'
  end
  
  def test_boolean_methods
    m1 = Race.new %w[ArVitallian 13.00  11.61  11.08  5.48  2276614.82  2028341.13  2515 - 2276.61],{}
    m2 = Race.new %w[1eadgen 10.00   9.94   9.31  7.75   226543.97   224300.00   166  Peace 0.00],{}
    m3 = Race.new %w[Beast 10.97  10.38   9.41  4.24    25295.06    24196.83    16  War 0.00],{}
    m4 = Race.new %w[Ace  1.00   1.00   1.00  1.00  0.00  0.00 0  War 60.53],{}
    m5 = Race.new %w[Duck_RIP 6.96 7.62 7.61  2.60 0.00 0.00 0  War 0.00],{}
    
    assert !m1.rip? , 'Boolean method failed'
    assert !m1.enemy? , 'Boolean method failed'
    assert m1.friend? , 'Boolean method failed'
    assert m1.your? , 'Boolean method failed'
    
    assert !m2.rip? , 'Boolean method failed'
    assert !m2.enemy? , 'Boolean method failed'
    assert m2.friend? , 'Boolean method failed'
    assert !m2.your? , 'Boolean method failed'
    
    assert !m3.rip? , 'Boolean method failed'
    assert m3.enemy? , 'Boolean method failed'
    assert !m3.friend? , 'Boolean method failed'
    assert !m3.your? , 'Boolean method failed'
    
    assert !m4.rip? , 'Boolean method failed'
    assert m4.enemy? , 'Boolean method failed'
    assert !m4.friend? , 'Boolean method failed'
    assert !m4.your? , 'Boolean method failed'
    
    assert m5.rip? , 'Boolean method failed'
    assert m5.enemy? , 'Boolean method failed'
    assert !m5.friend? , 'Boolean method failed'
    assert !m5.your? , 'Boolean method failed'
  end
  
  def test_comparisons
    m1 = Race.new %w[ArVitallian 13.00  11.61  11.08  5.48  2276614.82  2028341.13  2515 - 2276.61],{}
    m2 = Race.new %w[1eadgen 10.00   9.94   9.31  7.75   226543.97   224300.00   166  Peace 0.00],{}
    m3 = Race.new %w[Beast 10.97  10.38   9.41  4.24    25295.06    24196.83    16  War 0.00],{}
    m4 = Race.new %w[Ace  1.00   1.00   1.00  1.00  0.00  0.00 0  War 60.53],{}
    m5 = Race.new %w[Duck_RIP 6.96 7.62 7.61  2.60 0.00 0.00 0  War 0.00],{}
    
    assert m1==m1, 'Self-equality failed'
    assert m1>m2, 'GT model comparison failed'
    assert m3<m2, 'LT model comparison failed'
    assert m2>=m4, 'GTE model comparison failed'
    assert m4<=m3, 'LTE model comparison failed'
    
    assert m4>nil, 'nil comparison failed'
    assert m2>30, 'Integer comparison failed'
    assert m3==16, 'Integer comparison failed'
    
    assert m1=='ArVitallian', 'String comparison failed'
    assert m5=='RIP', 'String comparison failed'
    assert m5=='Duck', 'String comparison failed'
    
    assert m1==:alive, 'Symbol comparison failed'
    assert m3==:enemy, 'Symbol comparison failed'
    assert m4==:ace, 'Symbol comparison failed'
    assert m5==:duck, 'Symbol comparison failed'
    assert m5==:dead, 'Symbol comparison failed'
  end
end

class M_ProductTest < Test::Unit::TestCase
  def setup
    rep = Report.new 'rep/ArVit187.rep'
    @data = ActiveRecord::Base.establish_dataset(rep)
    @data.owner='ArVitallian'
    @av = Race.new %w[ArVitallian 13.00  11.61  11.08  5.48  2276614.82  2028341.13  2515 - 2276.61],{}
    @ace = Race.new %w[Ace  1.00   1.00   1.00  1.00        0.00        0.00     0  War      60.53],{}
    @ster = Race.new %w[Ace 1.00   1.00   1.00  1.00        0.00        0.00     0  War  60.53],{}
  end
  
  def test_init_science
    m = Product.new %w[MoveTo_6300_12504    6299.55   12503.99  0  0],{:race=>@av}
    assert_equal "ArVitallian.MoveTo_6300_12504_Research", m.key, 'Key accessor wrong'
    assert_equal "MoveTo_6300_12504", m.name, 'Name attribute wrong'
    assert_equal 6299.55, m.drive, 'Drive attribute wrong'
    assert_equal 12503.99, m.weapons, 'Weapons attribute wrong'
    assert_equal 0, m.shields, 'Shields attribute wrong'
    assert_equal 0, m.cargo, 'Cargo attribute wrong'
    assert_equal 'research', m.prod_type, 'Cargo attribute wrong'
    
    assert_equal @av, m.race, 'Race association wrong'
    assert_equal m, @av.products.first, 'Race association wrong'
    assert_equal m, @av.sciences.first, 'Race association wrong'
  end
  
  def test_init_ship
    m = Product.new %w[MAK-113-11x13      218.28    11   13.70   35.24    0.00   335.72],{:race=>@av}
    assert_equal "ArVitallian.MAK-113-11x13", m.key, 'Key accessor wrong'
    assert_equal "MAK-113-11x13", m.name, 'Name attribute wrong'
    assert_equal 218.28, m.drive, 'Drive attribute wrong'
    assert_equal 11, m.guns, 'Guns attribute wrong'
    assert_equal 13.70, m.weapons, 'Weapons attribute wrong'
    assert_equal 35.24, m.shields, 'Shields attribute wrong'
    assert_equal 0.00, m.cargo, 'Cargo attribute wrong'
    assert_equal 335.72, m.mass, 'Mass attribute wrong'
    assert_equal 'ship', m.prod_type, 'Cargo attribute wrong'
    
    assert_equal @av, m.race, 'Race association wrong'
    assert_equal m, @av.products.first, 'Race association wrong'
    assert_equal m, @av.designs.first, 'Race association wrong'
  end
  
  def test_race_association
    s1 = Product.new %w[MoveTo_6300_12504    6299.55   12503.99  0  0],{:race=>@av}
    s2 = Product.new %w[MoveTo_300_2504    300.00   2503.99  0  0],{}
    s3 = Product.new %w[MoveTo_3000_2504    3000.00   2503.99  0  0],{:race=>@ster}
    
    # Delete Model from its Race's collection
    s1.race.products.delete s1
    assert_equal [], @av.products, 'Delete association failed'
    assert_nil s1.race, 'Delete association failed'
    
    # Add no-race Model to Race collection
    @av.products << s2
    assert_equal s2, @av.products.first, 'Add association failed'
    assert_equal @av, s2.race, 'Add association failed'
    
    # Clearing collection
    @av.products.clear
    assert_nil @av.products.first, 'Add association failed'
    assert_nil s2.race, 'Add association failed'
    
    # Add Model to another Race's collection
    @av.products << s3
    assert_equal s3, @av.products.first, 'Add association failed'
    assert_equal @av, s3.race, 'Add association failed'
    assert_equal [], @ster.products, 'Add association failed'
  end
  
  def test_compare_ships
    m1 = Product.new %w[N310.f134h       30.90    1  20.00  450.00    0.00   500.90],{:race=>@ace}
    m2 = Product.new %w[MAK-113-11x13  18.28    11   13.70   35.24    0.00   335.72],{:race=>@av}
    m3 = Product.new %w[z17-.2x2         11.66    1   2.00    2.00    1.00    16.66],{:race=>@ster}
    m4 = Product.new %w[z17-2orro         11.66    1   2.00  1.00  2.00  16.66],{:race=>@ster}
    
    assert m1==m1, 'Self-equality failed'
    assert m1!=m2, 'Non-equal comparison failed'
    assert m3!=m4, 'Non-equal comparison failed, equal mass ships'
    assert m2<m1, 'LT model comparison failed'
    assert m2>=m3, 'GTE model comparison failed'
    
    assert m1>nil, 'nil comparison failed'
    assert m2=='MAK-113-11x13', 'String comparison failed'
    assert m2=='ArVitallian.MAK-113-11x13', 'String comparison failed'
  end
  
  def test_compare_sciences
    m1 = Product.new %w[MoveTo_300_2504 300.00   2503.99  0  0],{:race=>@ace}
    m2 = Product.new %w[MoveTo_6300_12504 6299.55   12503.99  0  0],{:race=>@av}
    m3 = Product.new %w[MoveTo_3000_2504 3000.00   2503.99  0  0],{:race=>@ster}
    
    assert m1==m1, 'Self-equality failed'
    assert m1!=m2, 'Non-equal comparison failed'
    assert m3<m2, 'LT model comparison failed'
    assert m2>=m3, 'GTE model comparison failed'
  end
  
  def test_compare_ships_and_sciences
    m0 = Product.new %w[_TerraForming  1.00  0.00  0  0],{:race=>@ace}
    m1 = Product.new %w[MoveTo_300_2504 300.00 2503.99  0  0],{:race=>@ace}
    m2 = Product.new %w[MAK-113-11x13  218.28 11  13.70 35.24 0.00 335.72],{:race=>@av}
    m3 = Product.new %w[DPOH 1.00 0  0.00 0.00  0.00 1.00],{:race=>@av}
    drive = Product.new [], {:name=>'Drive', :prod_type=>'research'}
    wea = Product.new [], {:name=>'Weapons', :prod_type=>'research'}
    shi = Product.new [], {:name=>'Shields', :prod_type=>'research'}
    car = Product.new [], {:name=>'Cargo', :prod_type=>'research'}
    cap = Product.new [], {:name=>'Capital', :prod_type=>'cap'}
    mat = Product.new [], {:name=>'Materials', :prod_type=>'mat'}
    
    assert m1!=m2, 'Non-equal comparison failed'
    assert m2!=m1, 'Non-equal comparison failed'
    assert m1!=drive, 'Non-equal comparison failed'
    assert m1!=wea, 'Non-equal comparison failed'
    assert shi!=m2, 'Non-equal comparison failed'
    assert car!=shi, 'Non-equal comparison failed'
    assert m1!=cap, 'Non-equal comparison failed'
    assert cap!=m2, 'Non-equal comparison failed'
    assert mat!=m1, 'Non-equal comparison failed'
    assert mat!=car, 'Non-equal comparison failed'
    
    assert cap!=:col, 'Symbol comparison failed'
    assert cap==:cap, 'Symbol comparison failed'
    assert cap==:capital, 'Symbol comparison failed'
    assert mat==:mat, 'Symbol comparison failed'
    assert mat==:materials, 'Symbol comparison failed'
    assert drive==:research, 'Symbol comparison failed'
    assert drive==:drive, 'Symbol comparison failed'
    assert wea==:weapons, 'Symbol comparison failed'
    assert shi==:shields, 'Symbol comparison failed'
    assert car==:cargo, 'Symbol comparison failed'
    assert m0 == :research, 'Symbol comparison failed'
    assert m0 == :terraform, 'Symbol comparison failed'
    assert m1==:research, 'Symbol comparison failed'
    assert m1==:tech, 'Symbol comparison failed'
    assert m1==:science, 'Symbol comparison failed'
    assert m1==:move, 'Symbol comparison failed'
    assert m1==:moveto, 'Symbol comparison failed'
    assert m1== :"300", 'Symbol comparison failed'
    assert m2 == :mak, 'Symbol comparison failed'
    assert m3 == :ship, 'Symbol comparison failed'
    assert m3 == :dron, 'Symbol comparison failed'
    
    assert cap=='Capital', 'String comparison failed'
    assert mat=='Materials', 'String comparison failed'
    assert m2 == "MAK", 'String comparison failed'
    assert shi=='Shield', 'String comparison failed'
  end
  
  def test_compare_all
    m0 = Product.new %w[_TerraForming  1.00  0.00  0  0],{:race=>@ace}
    m1 = Product.new %w[MoveTo_300_2504 300.00 2503.99  0  0],{:race=>@ace}
    m2 = Product.new %w[MAK-113-11x13  218.28 11  13.70 35.24 0.00 335.72],{:race=>@av}
    m3 = Product.new %w[DPOH 1.00 0  0.00 0.00  0.00 1.00],{:race=>@av}
    drive = Product.new [], {:name=>'Drive', :prod_type=>'research'}
    cap = Product.new [], {:name=>'Capital', :prod_type=>'cap'}
    mat = Product.new [], {:name=>'Materials', :prod_type=>'mat'}
    
    p1 = Planet.new %w[9802 10483.56 10512.20 N-A4 2500.00 2349.00 2200.00 0.03 DPOH 49.75 5214.30  2005.14  2300.00], {:race=>@av}
    p2 = Planet.new %w[7261  15768.34  11160.36], {} #MoveTo_300_2504
    
    b = Bombing.new %w[Ace ArVitallian 7261 #7261 0.01 0.01 DPOH 3.19 1.75 0.09 26.82 Wiped],{}
    
    assert m0 > nil, 'nil comparison failed'
    assert m1 == m1, 'Self-equality failed'
    assert m1 != m3, 'Equality failed'
    assert m2 > m3, 'GT model comparison failed'
    assert m1 != drive, 'LTE model comparison failed'
    assert m1 != cap, 'LTE model comparison failed'
    assert m1 != mat, 'LTE model comparison failed'
    
    assert m2 == @av, 'Race comparison failed'
    assert m1 != @av, 'Race comparison failed'
    assert m3 == p1, 'Planet comparison failed'
    assert m0 != p1, 'Planet comparison failed'
    assert m3 == b, 'Bombing comparison failed'
    assert m2 != b, 'Bombing comparison failed'
    assert m1 > b, 'Bombing comparison failed'
    # Add group comparison
    
    assert m2 > 300, 'Integer comparison failed'
    assert m2 > 335.7, 'Float comparison failed'
    assert drive > 30000, 'Integer comparison failed'
    assert m3 == 1, 'Integer comparison failed'
    assert m2 == 'ArVitallian', 'String comparison failed'
    assert m1 == 'research', 'String comparison failed'
    assert m1 != :ship, 'Symbol comparison failed'
    assert m0 != :move, 'Symbol comparison failed'
    assert m0 == :terraform, 'Symbol comparison failed'
  end
  
  def test_boolean_methods
    m0 = Product.new %w[_TerraForming  1.00  0.00  0  0],{:race=>@ace}
    m1 = Product.new %w[MoveTo_300_2504 300.00 2503.99  0  0],{:race=>@ace}
    m2 = Product.new %w[MAK-113-11x13  218.28 11  13.70 35.24 0.00 335.72],{:race=>@av}
    m3 = Product.new %w[DPOH 1.00 0  0.00 0.00  0.00 1.00],{:race=>@av}
    drive = Product.new [], {:name=>'Drive', :prod_type=>'research'}
    wea = Product.new [], {:name=>'Weapons', :prod_type=>'research'}
    shi = Product.new [], {:name=>'Shields', :prod_type=>'research'}
    car = Product.new [], {:name=>'Cargo', :prod_type=>'research'}
    cap = Product.new [], {:name=>'Capital', :prod_type=>'cap'}
    mat = Product.new [], {:name=>'Materials', :prod_type=>'mat'}
    
    p = Planet.new %w[9802 10483.56 10512.20 N-A4 2500.00 2349.00 2200.00 0.03 DPOH 49.75 5214.30  2005.14  2300.00], {:race=>@av}
    b = Bombing.new %w[Ace ArVitallian 7261 #7261 0.01 0.01 DPOH 3.19 1.75 0.09 26.82 Wiped], {}
    [p,b] #weird way to say that p, b are "used" without using them
    
    assert cap.cap?, 'Boolean method failed'
    assert !cap.mat?, 'Boolean method failed'
    assert !cap.research?, 'Boolean method failed'
    assert !cap.terraforming?, 'Boolean method failed'
    assert !cap.moving?, 'Boolean method failed'
    assert !cap.ship?, 'Boolean method failed'
    assert !cap.drone?, 'Boolean method failed'
    assert !cap.your?, 'Boolean method failed'
    assert !cap.in_use?, 'Boolean method failed'
    
    assert !mat.cap?, 'Boolean method failed'
    assert mat.mat?, 'Boolean method failed'
    assert !mat.research?, 'Boolean method failed'
    assert !mat.terraforming?, 'Boolean method failed'
    assert !mat.moving?, 'Boolean method failed'
    assert !mat.ship?, 'Boolean method failed'
    assert !mat.drone?, 'Boolean method failed'
    assert !mat.your?, 'Boolean method failed'
    assert !mat.in_use?, 'Boolean method failed'
    
    assert !m0.cap?, 'Boolean method failed'
    assert !m0.mat?, 'Boolean method failed'
    assert m0.research?, 'Boolean method failed'
    assert m0.terraforming?, 'Boolean method failed'
    assert !m0.moving?, 'Boolean method failed'
    assert !m0.ship?, 'Boolean method failed'
    assert !m0.drone?, 'Boolean method failed'
    assert !m0.your?, 'Boolean method failed'
    assert !m0.in_use?, 'Boolean method failed'
    
    assert !m1.cap?, 'Boolean method failed'
    assert !m1.mat?, 'Boolean method failed'
    assert m1.research?, 'Boolean method failed'
    assert !m1.terraforming?, 'Boolean method failed'
    assert m1.moving?, 'Boolean method failed'
    assert !m1.ship?, 'Boolean method failed'
    assert !m1.drone?, 'Boolean method failed'
    assert !m1.your?, 'Boolean method failed'
    assert !m1.in_use?, 'Boolean method failed'
    
    assert !m2.cap?, 'Boolean method failed'
    assert !m2.mat?, 'Boolean method failed'
    assert !m2.research?, 'Boolean method failed'
    assert !m2.terraforming?, 'Boolean method failed'
    assert !m2.moving?, 'Boolean method failed'
    assert m2.ship?, 'Boolean method failed'
    assert !m2.drone?, 'Boolean method failed'
    assert m2.your?, 'Boolean method failed'
    assert !m2.in_use?, 'Boolean method failed'
    
    assert !m3.cap?, 'Boolean method failed'
    assert !m3.mat?, 'Boolean method failed'
    assert !m3.research?, 'Boolean method failed'
    assert !m3.terraforming?, 'Boolean method failed'
    assert !m3.moving?, 'Boolean method failed'
    assert m3.ship?, 'Boolean method failed'
    assert m3.drone?, 'Boolean method failed'
    assert m3.your?, 'Boolean method failed'
    assert m3.in_use?, 'Boolean method failed'
    
    assert !drive.cap?, 'Boolean method failed'
    assert !drive.mat?, 'Boolean method failed'
    assert drive.research?, 'Boolean method failed'
    assert !drive.terraforming?, 'Boolean method failed'
    assert !drive.moving?, 'Boolean method failed'
    assert !drive.ship?, 'Boolean method failed'
    assert !drive.drone?, 'Boolean method failed'
    assert !drive.your?, 'Boolean method failed'
    assert !drive.in_use?, 'Boolean method failed'
    
    assert !wea.cap?, 'Boolean method failed'
    assert !wea.mat?, 'Boolean method failed'
    assert wea.research?, 'Boolean method failed'
    assert !wea.terraforming?, 'Boolean method failed'
    assert !wea.moving?, 'Boolean method failed'
    assert !wea.ship?, 'Boolean method failed'
    assert !wea.drone?, 'Boolean method failed'
    assert !wea.your?, 'Boolean method failed'
    assert !wea.in_use?, 'Boolean method failed'
    
    assert !shi.cap?, 'Boolean method failed'
    assert !shi.mat?, 'Boolean method failed'
    assert shi.research?, 'Boolean method failed'
    assert !shi.terraforming?, 'Boolean method failed'
    assert !shi.moving?, 'Boolean method failed'
    assert !shi.ship?, 'Boolean method failed'
    assert !shi.drone?, 'Boolean method failed'
    assert !shi.your?, 'Boolean method failed'
    assert !shi.in_use?, 'Boolean method failed'
    
    assert !car.cap?, 'Boolean method failed'
    assert !car.mat?, 'Boolean method failed'
    assert car.research?, 'Boolean method failed'
    assert !car.terraforming?, 'Boolean method failed'
    assert !car.moving?, 'Boolean method failed'
    assert !car.ship?, 'Boolean method failed'
    assert !car.drone?, 'Boolean method failed'
    assert !car.your?, 'Boolean method failed'
    assert !car.in_use?, 'Boolean method failed'
  end
end

class M_RouteTest < Test::Unit::TestCase
  def setup
    rep = Report.new 'rep/ArVit187.rep'
    @data = ActiveRecord::Base.establish_dataset(rep)
    @data.owner='ArVitallian'
    @av = Race.new %w[ArVitallian 13.00  11.61  11.08  5.48  2276614.82  2028341.13  2515 - 2276.61],{}
    @q = Product.new %w[QAK 1.00  0    0.00    2.33    0.00     3.33],{:race=>@av}
    @p1 = Planet.new %w[9802 10483.56 10512.20 N-A4 2500.00 2349.00 2200.00 0.03 QAK 49.75 5214.30  2005.14  2300.00], {:race=>@av}
    @p2 = Planet.new %w[7346 13906.25 17458.86 CYB 2500.00   0.07  0.00   3819.89], {}
    @p3 = Planet.new %w[7261  15768.34  11160.36], {}
  end
  
  def test_init
    m = Route.new %w[N-A4 -  CYB  - -], {:owner=>'ArVitallian'}
    
    assert_equal '9802.7346.mat', m.key, 'Route key wrong'
    assert_equal @p1, m.planet, 'Source accessor wrong'
    assert_equal @p2, m.target, 'Target accessor wrong'
    assert_equal 'mat', m.cargo, 'Cargo accessor wrong'
    assert m.planet == :arvitallian, 'Source accessor wrong'
    assert m.target == 'CYB', 'Target accessor wrong'
    
    assert_equal m, @p1.routes.first, 'Route association wrong'
    assert_equal @p2, @p1.targets.first, 'Route association wrong'
    assert_equal m, @p2.incoming_routes.first, 'Route association wrong'
    assert_equal @p1, @p2.suppliers.first, 'Route association wrong'
    assert_equal m, @av.routes.first, 'Route association wrong'
    assert_equal @av, m.race, 'Route association wrong'
  end
  
  def test_replace
    m = Route.new %w[N-A4 - - CYB -], {:owner=>'ArVitallian'}
    # Establishing new col Route starting from the same Planet (should replace previous Route)
    m1 = Route.new %w[N-A4 - - #7261 -], {:owner=>'ArVitallian'}
    
    # Assert nil on former col Route association
    assert_nil @p2.suppliers.first, 'Route association wrong'
    assert_nil @p2.incoming_routes.first, 'Route association wrong'
    assert_nil m.planet, 'Source accessor wrong'
    assert_nil m.target, 'Target accessor wrong'
    assert_nil m.race, 'Route association wrong'
    assert_equal 'col', m.cargo, 'Cargo accessor wrong'
    
    # Assert equality of new col Route
    assert_equal @p1, m1.planet, 'Source accessor wrong'
    assert_equal @p3, m1.target, 'Target accessor wrong'
    assert_equal 'col', m1.cargo, 'Cargo accessor wrong'
    assert_equal m1, @p1.routes.first, 'Route association wrong'
    assert_equal @p3, @p1.targets.first, 'Route association wrong'
    assert_equal m1, @p3.incoming_routes.first, 'Route association wrong'
    assert_equal @p1, @p3.suppliers.first, 'Route association wrong'
    assert m1.planet == :arvitallian, 'Source accessor wrong'
    assert m1.target == :unidentified, 'Target accessor wrong'
    assert m1.target == 7261, 'Target accessor wrong'
    assert_equal @av, m1.race, 'Route association wrong'
    assert_equal m1, @av.routes.first, 'Route association wrong'
  end
  
  def test_compare
    m1 = Route.new %w[CYB - - #7261 -], {:owner=>'ArVitallian'}
    m2 = Route.new %w[N-A4 - CYB  - -], {:owner=>'ArVitallian'}
    
    assert m1 > nil, 'Nil Comparison wrong'
    assert m1 == m1, 'Self Comparison wrong'
    assert m1 != m2, 'Route Comparison wrong'
    assert m1 == @av, 'Race Comparison wrong'
    assert m1 == @p2, 'Planet Comparison wrong'
    assert m1 == @p3, 'Planet Comparison wrong'
    assert m2 == @p1, 'Planet Comparison wrong'
    assert m2 == @p2, 'Planet Comparison wrong'
    assert m1 < 1, 'Route Distance Comparison wrong' # Should be implemented in Planet
    assert m1 < 1.0, 'Route Distance Comparison wrong' # Should be implemented in Planet
    assert m1 == :arvitallian, 'Symbol Comparison wrong'
    assert m1 == :unidentified, 'Symbol Comparison wrong'
    assert m1 == 'CYB', 'String Comparison wrong'
    assert m2 == 'CYB'.downcase.to_sym, 'Symbol Comparison wrong'
    assert m2 == 'N-A4', 'String Comparison wrong'
    assert m1 != 'Erunda', 'String Comparison wrong'
    assert m1 == :col, 'Symbol Comparison wrong'
    assert m2 == 'MAT', 'String Comparison wrong'
    assert m2 != :erunda, 'Symbol Comparison wrong'
  end
  
  def test_delete
    # Delete from planet side
    m = Route.new %w[N-A4 - - CYB -], {:owner=>'ArVitallian'}
    @p1.routes.delete m
    
    assert_nil @p1.routes.first, 'Route association wrong'
    assert_nil @p1.targets.first, 'Route association wrong'
    assert_nil @p2.incoming_routes.first, 'Route association wrong'
    assert_nil @p2.suppliers.first, 'Route association wrong'
    assert_nil m.planet, 'Source accessor wrong'
    assert_nil m.target, 'Target accessor wrong'
    assert_equal 'col', m.cargo, 'Cargo accessor wrong'
    
    # Delete from target side
    m = Route.new %w[N-A4 - - CYB -], {:owner=>'ArVitallian'}
    @p2.incoming_routes.delete m
    
    assert_nil @p1.routes.first, 'Route association wrong'
    assert_nil @p1.targets.first, 'Route association wrong'
    assert_nil @p2.incoming_routes.first, 'Route association wrong'
    assert_nil @p2.suppliers.first, 'Route association wrong'
    assert_nil m.race, 'Route association wrong'
    assert_nil @av.routes.first, 'Route association wrong'
    assert_nil m.planet, 'Source accessor wrong'
    assert_nil m.target, 'Target accessor wrong'
    assert_equal 'col', m.cargo, 'Cargo accessor wrong'
  end
  
end

class M_FleetTest < Test::Unit::TestCase
  def setup
    rep = Report.new 'rep/ArVit187.rep'
    @data = ActiveRecord::Base.establish_dataset(rep)
    @data.owner='ArVitallian'
    @av = Race.new %w[ArVitallian 13.00  11.61  11.08  5.48  2276614.82  2028341.13  2515 - 2276.61],{}
    @q = Product.new %w[QAK 1.00  0    0.00    2.33    0.00     3.33],{:race=>@av}
    @p1 = Planet.new %w[9802 10483.56 10512.20 N-A4 2500.00 2349.00 2200.00 0.03 QAK 49.75 5214.30  2005.14  2300.00], {:race=>@av}
    @p2 = Planet.new %w[7346 13906.25 17458.86 CYB 2500.00   0.07  0.00   3819.89], {}
    @p3 = Planet.new %w[7261  15768.34  11160.36], {}
  end
  
  def test_init
    m1 = Fleet.new %w[1  fgtr5  6  N-A4 -  0.00  112.50  In_Orbit], {:owner=>'ArVitallian'}
    m2 = Fleet.new %w[10  sv11 17  CYB  #7261  91.69  153.45  In_Space], {:owner=>'ArVitallian'}
    
    assert_equal 'ArVitallian.fgtr5', m1.key, 'Fleet key wrong'
    assert_equal @p1, m1.planet, 'Fleet planet wrong'
    assert_nil m1.from, 'Fleet planet wrong'
    assert_equal 1, m1.num, 'Fleet accessor wrong'
    assert_equal 'fgtr5', m1.name, 'Fleet accessor wrong'
    assert_equal 6, m1.num_groups, 'Fleet accessor wrong'
    assert_equal 0, m1.range, 'Fleet accessor wrong'
    assert_equal 112.50, m1.speed, 'Fleet accessor wrong'
    assert_equal 'In_Orbit', m1.status, 'Fleet accessor wrong'
    assert_in_delta 0.0, m1.eta, 0.00001, 'ETA calculation wrong'
    
    assert_equal 'ArVitallian.sv11', m2.key, 'Fleet key wrong'
    assert_equal @p2, m2.planet, 'Fleet planet wrong'
    assert_equal @p3, m2.from, 'Fleet planet wrong'
    assert_equal 'sv11', m2.name, 'Fleet accessor wrong'
    assert_equal 17, m2.num_groups, 'Fleet accessor wrong'
    assert_equal 91.69, m2.range, 'Fleet accessor wrong'
    assert_equal 153.45, m2.speed, 'Fleet accessor wrong'
    assert_equal 'In_Space', m2.status, 'Fleet accessor wrong'
    assert_in_delta 0.597523, m2.eta, 0.00001, 'ETA calculation wrong'
    
    assert_equal m1, @p1.fleets.first, 'Fleet association wrong'
    assert_equal m2, @p2.fleets.first, 'Fleet association wrong'
    assert_equal m2, @p3.sent_fleets.first, 'Fleet association wrong'
    assert_equal @av, m1.race, 'Fleet association wrong'
    assert_equal m1, @av.fleets.first, 'Fleet association wrong'
    assert_equal @av, m2.race, 'Fleet association wrong'
    assert_equal m2, @av.fleets.last, 'Fleet association wrong'
  end
  
  def test_compare
    m1 = Fleet.new %w[1  fgtr5  6  N-A4 -  0.00  112.50  In_Orbit], {:owner=>'ArVitallian'}
    m2 = Fleet.new %w[10  sv11 17  CYB  #7261  91.69  153.45  In_Space], {:owner=>'ArVitallian'}
    
    assert m1 > nil, 'Nil Comparison wrong'
    assert m1 == m1, 'Self Comparison wrong'
    assert m1 != m2, 'Fleet Comparison wrong'
    assert m1 == @p1, 'Planet Comparison wrong'
    assert m2 == @p3, 'Planet Comparison wrong'
    #   assert group comparison
    assert m1 < 7, 'Num groups Comparison wrong'
    assert m2 >= 13, 'Num groups Comparison wrong'
    assert m1 == :in_orbit, 'Comparison wrong'
    assert m1 == 'Orbit', 'Comparison wrong'
    assert m1 == 'fgtr5', 'Comparison wrong'
    assert m2 == 'sv11', 'Comparison wrong'
    assert m1 == :arvitallian, 'Comparison wrong'
    assert m1 != 'Erunda', 'String Comparison wrong'
    assert m2 != :erunda, 'Symbol Comparison wrong'
  end
  
  def test_change_sent_fleet_collection #weird way to test VirtualBase::has_many_linked method generator
    m1 = Fleet.new %w[1  fgtr5  6  N-A4 -  0.00  112.50  In_Orbit], {:owner=>'ArVitallian'}
    m2 = Fleet.new %w[10  sv11 17  CYB  #7261  91.69  153.45  In_Space], {:owner=>'ArVitallian'}
    
    @p1.sent_fleets << m2
    
    assert_equal 'ArVitallian.fgtr5', m1.key, 'Fleet key wrong'
    assert_equal @p1, m1.planet, 'Fleet planet wrong'
    assert_nil m1.from, 'Fleet planet wrong'
    assert_equal 1, m1.num, 'Fleet accessor wrong'
    assert_equal 'fgtr5', m1.name, 'Fleet accessor wrong'
    assert_equal 6, m1.num_groups, 'Fleet accessor wrong'
    assert_equal 0, m1.range, 'Fleet accessor wrong'
    assert_equal 112.50, m1.speed, 'Fleet accessor wrong'
    assert_equal 'In_Orbit', m1.status, 'Fleet accessor wrong'
    assert_in_delta 0.0, m1.eta, 0.00001, 'ETA calculation wrong'
    
    assert_equal 'ArVitallian.sv11', m2.key, 'Fleet key wrong'
    assert_equal @p2, m2.planet, 'Fleet planet wrong'
    assert_equal @p1, m2.from, 'Fleet planet wrong'
    assert_equal 'sv11', m2.name, 'Fleet accessor wrong'
    assert_equal 17, m2.num_groups, 'Fleet accessor wrong'
    assert_equal 91.69, m2.range, 'Fleet accessor wrong'
    assert_equal 153.45, m2.speed, 'Fleet accessor wrong'
    assert_equal 'In_Space', m2.status, 'Fleet accessor wrong'
    assert_in_delta 0.597523, m2.eta, 0.00001, 'ETA calculation wrong'
    
    assert_equal m1, @p1.fleets.first, 'Fleet association wrong'
    assert_equal m2, @p2.fleets.first, 'Fleet association wrong'
    assert_equal m2, @p1.sent_fleets.first, 'Fleet association wrong'
    assert_nil @p3.sent_fleets.first, 'Fleet association wrong'
    assert_equal @av, m1.race, 'Fleet association wrong'
    assert_equal @av, m2.race, 'Fleet association wrong'
    assert_equal m1, @av.fleets.first, 'Fleet association wrong'
    assert_equal m2, @av.fleets.last, 'Fleet association wrong'
    
  end
  
end

class M_BombingTest < Test::Unit::TestCase
  def setup
    rep = Report.new 'rep/ArVit187.rep'
    @data = ActiveRecord::Base.establish_dataset(rep)
    @data.owner='ArVitallian'
    @av = Race.new %w[ArVitallian 13.00  11.61  11.08  5.48  2276614.82  2028341.13  2515 - 2276.61],{}
    @vd = Race.new %w[Vildok 10.33 1.00 1.00 6.07 2035.74 0.00 1 War 0.00], {}
    @raz = Product.new %w[raz 1.00 0 0.00 0.00 0.00 1.00],{:race=>@vd}
    @move = Product.new %w[Move6SUN 15741.00 8699.00 0 0],{:race=>@av}
    @p1 = Planet.new %w[10190 NOVA], {}
    @p2 = Planet.new ['#3191'], {}
  end
  
  def test_init
    m1 = Bombing.new %w[ArVitallian Vildok 10190 NOVA 2500.00 268.75 raz 0.00 44877.92 0.00 615.06 Damaged], {}
    m2 = Bombing.new %w[Vildok ArVitallian 3191 #3191 0.01 0.01 Move6SUN 3.19 1.75 0.09 26.82 Wiped], {}
    
    assert_equal 'ArVitallian.Vildok.10190', m1.key, 'Bombing planet wrong'
    assert_equal 2500.00, m1.pop, 'Bombing planet wrong'
    assert_equal 268.75, m1.ind, 'Bombing planet wrong'
    assert_equal 0, m1.cap, 'Bombing planet wrong'
    assert_equal 44877.92, m1.mat, 'Bombing planet wrong'
    assert_equal 0, m1.col, 'Bombing planet wrong'
    assert_equal 615.06, m1.attack, 'Bombing planet wrong'
    assert_equal 'Damaged', m1.status, 'Bombing planet wrong'
    assert_equal @raz, m1.product, 'Bombing planet wrong'
    assert_equal @p1, m1.planet, 'Bombing planet wrong'
    assert_equal @av, m1.race, 'Bombing planet wrong'
    assert_equal @vd, m1.victim, 'Bombing planet wrong'
    
    assert_equal 'Vildok.ArVitallian.3191', m2.key, 'Bombing planet wrong'
    assert_equal 0.01, m2.pop, 'Bombing planet wrong'
    assert_equal 0.01, m2.ind, 'Bombing planet wrong'
    assert_equal 3.19, m2.cap, 'Bombing planet wrong'
    assert_equal 1.75, m2.mat, 'Bombing planet wrong'
    assert_equal 0.09, m2.col, 'Bombing planet wrong'
    assert_equal 26.82, m2.attack, 'Bombing planet wrong'
    assert_equal 'Wiped', m2.status, 'Bombing planet wrong'
    assert_equal @move, m2.product, 'Bombing planet wrong'
    assert_equal @p2, m2.planet, 'Bombing planet wrong'
    assert_equal @vd, m2.race, 'Bombing planet wrong'
    assert_equal @av, m2.victim, 'Bombing planet wrong'
    
    #Assert associations
    assert_equal m1, @p1.bombings.first, 'Bombing association wrong'
    assert_equal m1, @av.bombings.first, 'Bombing association wrong'
    assert_equal m1, @vd.incoming_bombings.first, 'Bombing association wrong'
    assert_equal m1, @raz.bombings.first, 'Bombing association wrong'
    
    assert_equal m2, @p2.bombings.first, 'Bombing association wrong'
    assert_equal m2, @av.incoming_bombings.first, 'Bombing association wrong'
    assert_equal m2, @vd.bombings.first, 'Bombing association wrong'
    assert_equal m2, @move.bombings.first, 'Bombing association wrong'
  end
  
  def test_compare
    m1 = Bombing.new %w[ArVitallian Vildok 10190 NOVA 2500.00 268.75 raz 0.00 44877.92 0.00 615.06 Damaged], 
    {:planet=>@p1, :race=>@av, :victim=>@vd, :product=>@raz}
    m2 = Bombing.new %w[Vildok ArVitallian 3191 #3191 0.01 0.01 Move6SUN 3.19 1.75 0.09 26.82 Wiped],
    {:planet=>@p2, :race=>@vd, :victim=>@av, :product=>@move}
    
    assert m1 > nil, 'Comparison wrong'
    assert m1 == @p1, 'Comparison wrong'
    assert m1 != @p2, 'Comparison wrong'
    assert m1 == @raz, 'Comparison wrong'
    assert m1 != @move, 'Comparison wrong'
    assert m1 == @av, 'Comparison wrong'
    assert m1 == @vd, 'Comparison wrong'
    assert m1 > 600, 'Comparison wrong'
    assert m1 == 'nova', 'Comparison wrong'
    assert m1 == :arvitallian, 'Comparison wrong'
    assert m1 == 'raz', 'Comparison wrong'
    assert m1 == 'Vildok', 'Comparison wrong'
    assert m1 == :damaged, 'Comparison wrong'
    assert m2 != m1, 'Comparison wrong'
    assert m2 <= 100, 'Comparison wrong'
    assert m2 == :move, 'Comparison wrong'
    assert m2 == :research, 'Comparison wrong'
  end
end

class M_PlanetTest < Test::Unit::TestCase
  def setup
    rep = Report.new 'rep/ArVit187.rep'
    @data = ActiveRecord::Base.establish_dataset(rep)
    @data.owner='ArVitallian'
    @av = Race.new %w[ArVitallian 13.00  11.61  11.08  5.48  2276614.82  2028341.13  2515 - 2276.61],{}
    @vd = Race.new %w[Vildok 10.33 1.00 1.00 6.07 2035.74 0.00 1 War 0.00], {}
    @q = Product.new %w[QAK 1.00  0    0.00    2.33    0.00     3.33],{:race=>@av}
  end
  
  def test_init_your
    m = Planet.new %w[9802 10483.56 10512.20 N-A4 2500.00 2349.00 2200.00 0.03 QAK 49.75 5214.30  2005.14  2300.00], {:race=>@av}
    assert_equal "N-A4", m.key, 'Key accessor wrong'
    assert_equal 0, m.idx, 'Idx accessor wrong'
    assert_equal 9802, m.num, 'Num attribute wrong'
    assert_equal 10483.56, m.x, 'X attribute wrong'
    assert_equal 10512.20, m.y, 'Y attribute wrong'
    assert_equal "N-A4", m.name, 'Name attribute wrong'
    assert_equal 2500.00, m.size, 'Size attribute wrong'
    assert_equal 2349.00, m.pop, 'Pop attribute wrong'
    assert_equal 2200.00, m.ind, 'Ind attribute wrong'
    assert_equal 0.03, m.res, 'Res attribute wrong'
    assert_equal 49.75, m.cap, 'Cap attribute wrong'
    assert_equal 5214.30, m.mat, 'Mat attribute wrong'
    assert_equal 2005.14, m.col, 'Col attribute wrong'
    assert_equal 2300.00, m.l, 'L attribute wrong'
    assert ! m.uninhabited?, 'Method wrong'
    assert ! m.unidentified?, 'Method wrong'
    
    assert_equal @av, m.race, 'Race association wrong'
    assert_equal m, @av.planets.first, 'Race association wrong'
    assert_equal m, @q.planets.first, 'Product association wrong'
    assert_equal @q, m.product, 'Product association wrong'
  end
  
  def test_init_uninhabited
    m = Planet.new %w[7346 13906.25 17458.86 HOLY_TERRA 2500.00 0.07 0.00 3819.89], {}
    assert_equal "HOLY_TERRA", m.key, 'Key accessor wrong'
    #assert_equal 7346, m.idx, 'Idx accessor wrong'
    assert_equal 7346, m.num, 'Num attribute wrong'
    assert_equal 13906.25, m.x, 'X attribute wrong'
    assert_equal 17458.86, m.y, 'Y attribute wrong'
    assert_equal "HOLY_TERRA", m.name, 'Name attribute wrong'
    assert_equal 2500.00, m.size, 'Size attribute wrong'
    assert_nil m.pop, 'Pop attribute wrong'
    assert_nil m.ind, 'Ind attribute wrong'
    assert_equal 0.07, m.res, 'Res attribute wrong'
    assert_nil m.product, 'Production attribute wrong'
    assert_equal 0.00, m.cap, 'Cap attribute wrong'
    assert_equal 3819.89, m.mat, 'Mat attribute wrong'
    assert_nil m.col, 'Col attribute wrong'
    assert_nil m.l, 'L attribute wrong'
    assert  m.uninhabited?, 'Method wrong'
    assert ! m.unidentified?, 'Method wrong'
    
    assert_nil m.race, 'Race association wrong'
  end
  
  def test_init_unidentified
    m = Planet.new %w[7261  15768.34  11160.36], {}
    assert_equal "#7261", m.key, 'Key accessor wrong'
    #assert_equal 7261, m.idx, 'Idx accessor wrong'
    assert_equal 7261, m.num, 'Num attribute wrong'
    assert_equal 15768.34, m.x, 'X attribute wrong'
    assert_equal 11160.36, m.y, 'Y attribute wrong'
    assert_nil m.name, 'Name attribute wrong'
    assert_nil m.size, 'Size attribute wrong'
    assert_nil m.pop, 'Pop attribute wrong'
    assert_nil m.ind, 'Ind attribute wrong'
    assert_nil m.res, 'Res attribute wrong'
    assert_nil m.product, 'Production attribute wrong'
    assert_nil m.cap, 'Cap attribute wrong'
    assert_nil m.mat, 'Mat attribute wrong'
    assert_nil m.col, 'Col attribute wrong'
    assert_nil m.l, 'L attribute wrong'
    assert m.unidentified?, 'Method wrong'
    assert ! m.uninhabited?, 'Method wrong'
    
    assert_nil m.race, 'Race association wrong'
  end
  
  def test_init_battle
    m = Planet.new %w[9032 A-S83], {}
    assert_equal "A-S83", m.key, 'Key accessor wrong'
    #assert_equal 9032, m.idx, 'Idx accessor wrong'
    assert_equal 9032, m.num, 'Num attribute wrong'
    assert_nil m.x, 'X attribute wrong'
    assert_nil m.y, 'Y attribute wrong'
    assert_equal "A-S83", m.name, 'Name attribute wrong'
    assert_nil m.size, 'Size attribute wrong'
    assert_nil m.pop, 'Pop attribute wrong'
    assert_nil m.ind, 'Ind attribute wrong'
    assert_nil m.res, 'Res attribute wrong'
    assert_nil m.product, 'Production attribute wrong'
    assert_nil m.cap, 'Cap attribute wrong'
    assert_nil m.mat, 'Mat attribute wrong'
    assert_nil m.col, 'Col attribute wrong'
    assert_nil m.l, 'L attribute wrong'
    assert m.unidentified?, 'Method wrong'
    assert !m.uninhabited?, 'Method wrong'
    
    assert_nil m.race, 'Race association wrong'
  end
  
  def test_update_planet
    # Update with your planet
    m = Planet.new %w[9802 N-A4], {}
    m.update_planet %w[9802 10483.56 10512.20 N-A4 2500.00 2349.00 2200.00 0.03 QAK 49.75 5214.30  2005.14  2300.00], {:race=>@av, :product=>@q}
    assert_equal "N-A4", m.key, 'Key accessor wrong'
    #assert_equal 9802, m.idx, 'Idx accessor wrong'
    assert_equal 9802, m.num, 'Num attribute wrong'
    assert_equal 10483.56, m.x, 'X attribute wrong'
    assert_equal 10512.20, m.y, 'Y attribute wrong'
    assert_equal "N-A4", m.name, 'Name attribute wrong'
    assert_equal 2500.00, m.size, 'Size attribute wrong'
    assert_equal 2349.00, m.pop, 'Pop attribute wrong'
    assert_equal 2200.00, m.ind, 'Ind attribute wrong'
    assert_equal 0.03, m.res, 'Res attribute wrong'
    assert_equal 49.75, m.cap, 'Cap attribute wrong'
    assert_equal 5214.30, m.mat, 'Mat attribute wrong'
    assert_equal 2005.14, m.col, 'Col attribute wrong'
    assert_equal 2300.00, m.l, 'L attribute wrong'
    assert ! m.uninhabited?, 'Method wrong'
    assert ! m.unidentified?, 'Method wrong'
    
    assert_equal @av, m.race, 'Race association wrong'
    assert_equal m, @av.planets.first, 'Race association wrong'
    assert_equal @q, m.product, 'Product association wrong'
    assert_equal m, @q.planets.first, 'Product association wrong'
    
    # Update with unidentified planet
    m = Planet.new '#7261', {}
    m.update_planet %w[7261  15768.34  11160.36], {}
    assert_equal "#7261", m.key, 'Key accessor wrong'   #should @planets['key'] position also change once a planet.key changes?!
    assert_equal 1, m.idx, 'Idx accessor wrong'
    assert_equal 7261, m.num, 'Num attribute wrong'
    assert_equal 15768.34, m.x, 'X attribute wrong'
    assert_equal 11160.36, m.y, 'Y attribute wrong'
    assert_nil m.name, 'Name attribute wrong'
    assert_nil m.size, 'Size attribute wrong'
    assert_nil m.pop, 'Pop attribute wrong'
    assert_nil m.ind, 'Ind attribute wrong'
    assert_nil m.res, 'Res attribute wrong'
    assert_nil m.product, 'Production attribute wrong'
    assert_nil m.cap, 'Cap attribute wrong'
    assert_nil m.mat, 'Mat attribute wrong'
    assert_nil m.col, 'Col attribute wrong'
    assert_nil m.l, 'L attribute wrong'
    assert m.unidentified?, 'Method wrong'
    assert ! m.uninhabited?, 'Method wrong'
    
    assert_nil m.race, 'Race association wrong'
  end
  
  def test_update_production
    m = Planet.new %w[9802 10483.56 10512.20 N-A4 33.3 33.3 33.3 0.03 QAK 49.75 5214.30  100.14  33.3], {:race=>@av}
    match = %w[9802  N-A4  QAK 33.30 15.00  33.3]
    Planet.new_or_update match, {}
    
    assert_in_delta 0.45045045, m.progress, 0.001, 'Progress calculation wrong'
    assert_in_delta 0.45045045, m.produced, 0.001, 'Progress calculation wrong'
    assert_in_delta 0.45045045, m.produced_full_mat, 0.001, 'Progress calculation wrong'
    assert_equal "N-A4", m.key, 'Key accessor wrong'
    assert_equal 0, m.idx, 'Idx accessor wrong'
    assert_equal 9802, m.num, 'Num attribute wrong'
    assert_equal 10483.56, m.x, 'X attribute wrong'
    assert_equal 10512.20, m.y, 'Y attribute wrong'
    assert_equal "N-A4", m.name, 'Name attribute wrong'
    assert_equal 33.3, m.size, 'Size attribute wrong'
    assert_equal 33.3, m.pop, 'Pop attribute wrong'
    assert_equal 33.3, m.ind, 'Ind attribute wrong'
    assert_equal 0.03, m.res, 'Res attribute wrong'
    assert_equal 49.75, m.cap, 'Cap attribute wrong'
    assert_equal 5214.30, m.mat, 'Mat attribute wrong'
    assert_equal 100.14, m.col, 'Col attribute wrong'
    assert_equal 33.3, m.l, 'L attribute wrong'
    assert ! m.uninhabited?, 'Method wrong'
    assert ! m.unidentified?, 'Method wrong'
    assert_equal @av, m.race, 'Race association wrong'
    assert_equal m, @av.planets.first, 'Race association wrong'
    assert_equal @q, m.product, 'Product association wrong'
    assert_equal m, @q.planets.first, 'Product association wrong'
    
    m = Planet.new %w[9802 10483.56 10512.20 N-A4 2500.00 2349.00 2200.00 0.03 QAK 49.75 0  2005.14  2300.00], {:race=>@av}
    match = %w[9802  N-A4  QAK 33.30 15.00  2500.00]
    Planet.new_or_update match, {}
    
    assert_in_delta 0.159066808, m.produced, 0.001, 'Progress calculation wrong'
    assert_in_delta 0.45045045, m.progress, 0.001, 'Progress calculation wrong'
    assert_in_delta 0.45045045, m.produced_full_mat, 0.001, 'Progress calculation wrong'
  end  
  
  def test_compare
    m1 = Planet.new %w[9802 10483.56 10512.20 N-A4 2500.00 2349.00 2200.00 0.03 QAK 49.75 5214.30  2005.14  2300.00], {:race=>@av}
    m2 = Planet.new %w[7346 13906.25 17458.86 HOLY_TERRA 2500.00   0.07  0.00   3819.89], {}
    m3 = Planet.new %w[7261  15768.34  11160.36], {}
    m4 = Planet.new %w[32 A-S83], {}
    
    @move = Product.new %w[Move6SUN 15741.00 8699.00 0 0],{:race=>@av}
    b = Bombing.new %w[Vildok ArVitallian 7261 #7261 0.01 0.01 Move6SUN 3.19 1.75 0.09 26.82 Wiped],
    {:planet=>m3, :race=>@vd, :victim=>@av, :product=>@move}
    f = Fleet.new %w[1  fgtr5  6  N-A4 -  0.00  112.50  In_Orbit], {:owner=>'ArVitallian'}
    r = Route.new %w[N-A4 - HOLY_TERRA - -], {:owner=>'ArVitallian'}
    
    assert m2 > nil, 'nil comparison failed'
    assert m1 == m1, 'Self-equality failed'
    assert m1 > m2, 'GT model comparison failed'
    assert m3 < m2, 'LT model comparison failed'
    assert m2 >= m4, 'GTE model comparison failed'
    assert m4 <= m3, 'LTE model comparison failed'
    
    assert m1 == @av, 'Race comparison failed'
    assert m2 != @av, 'Race comparison failed'
    assert m1 == @q, 'Product comparison failed'
    assert m1 != b, 'Bombing comparison failed'
    assert m3 == b, 'Bombing comparison failed'
    assert m2 > b, 'Bombing comparison failed'
    assert m1 == r, 'Route comparison failed'
    assert m2 == r, 'Route comparison failed'
    assert m4 > r, 'Route comparison failed'
    assert m1 == f, 'Fleet comparison failed'
    assert m4 > f, 'Fleet comparison failed'
    # Add group comparison
    
    assert m4 > 30, 'Integer comparison failed'
    assert m3 == 7261, 'Integer comparison failed'
    assert m1 == 'ArVitallian', 'String comparison failed'
    assert m1 == 'N-A4', 'String comparison failed'
    assert m1 != :aster, 'Symbol comparison failed'
    assert m1 == :max, 'Symbol comparison failed'
    assert m1 == :'n-a4', 'Symbol comparison failed'
    assert m1 == :q, 'Symbol comparison failed'
  end
  
  def test_race_association
    p1 = Planet.new %w[9802 10483.56 10512.20 N-A4 2500.00 2349.00 2200.00 0.03 QAK 49.75 5214.30  2005.14  2300.00], {:race=>@av}
    p3 = Planet.new %w[7261  15768.34  11160.36], {:race=>@vd}
    
    # Delete planet from its race's collection
    p1.race.planets.delete p1
    assert_equal [], @av.planets, 'Delete association failed'
    assert_nil p1.race, 'Delete association failed'
    
    # Add planet to another race's collection
    @av.planets << p3
    assert_equal p3, @av.planets.first, 'Add association failed'
    assert_equal @av, p3.race, 'Add association failed'
    assert_equal [], @vd.planets, 'Add association failed'
  end
end

class M_GroupTest < Test::Unit::TestCase
  def setup
    rep = Report.new 'rep/ArVit187.rep'
    @data = ActiveRecord::Base.establish_dataset(rep)
    @data.owner='ArVitallian'
    @av = Race.new %w[ArVitallian 13.00  11.61  11.08  5.48  2276614.82  2028341.13  2515 - 2276.61],{}
    @vd = Race.new %w[Vildok 10.33 1.00 1.00 6.07 2035.74 0.00 1 War 0.00], {}
    @homo = Race.new %w[Homo_galaktikus 8.10  6.04  6.04  4.50 39760.96 39026.32 45 Peace 0.00], {}
    @raz = Product.new %w[raz 1.00 0 0.00 0.00 0.00 1.00],{:race=>@vd}
    @q = Product.new %w[QAK 1.00 0 0.00 2.33 0.00 3.33],{:race=>@av}
    @dron = Product.new %w[DPOH 1.00 0 0.00 0.00 0.00 1.00],{:race=>@av}
    @mark = Product.new %w[MAPKEP 8.00 0 0.00 0.00 1.00 9.00],{:race=>@av}
    @def = Product.new %w[Def 9.17  1  6.32  15.00    1.00   31.49],{:race=>@homo}
    @p1 = Planet.new %w[9802 10483.56 10512.20 N-A4 2500.00 2349.00 2200.00 0.03 QAK 49.75 5214.30  2005.14  2300.00], {:race=>@av}
    @p2 = Planet.new %w[7346 13906.25 17458.86 CYB 2500.00   0.07  0.00   3819.89], {}
    @p3 = Planet.new %w[7261  15768.34  11160.36], {}
    @p4 = Planet.new %w[9219  A-019], {}
    @f1 = Fleet.new %w[1  fgtr5  6  N-A4 -  0.00  112.50  In_Orbit], {:owner=>'ArVitallian'}
    @f2 = Fleet.new %w[10  sv11 17  CYB  #7261  91.69  153.45  In_Space], {:owner=>'ArVitallian'}
  end
  
  def test_compare
    m1 = Group.new %w[15768.34 11160.36], {}
    m2 = Group.new %w[#9219 N-A4 828.88 69.00 1.00], {}
    m3 = Group.new %w[CYB N-A4 1420.78   50.56  2000.00], {}
    m4 = Group.new %w[13 DPOH 11.80  0.00  0  0.00  -  0.00  10  In_Battle], {:race=>@av, :planet=>@p2, :battles=>1}
    m5 = Group.new %w[1  raz  8.05  0  0  0  -  0  1  Out_Battle], {:race=>@vd, :planet=>@p4, :battles=>2}
    m6 = Group.new %w[0  1  MAPKEP 2.22   0.00   0.00  1.00 COL 0.03  N-A4 - 0.00 39.34 9.03  -  In_Orbit], {:race=>@av}
    m7 = Group.new %w[6830 1170 QAK 13.00 0.00 9.99 0.00 - 0.00 N-A4 - 0.00 78.08 3.33  fgtr5 In_Orbit], {:race=>@av}
    m8 = Group.new %w[62  raz  2.22  0  0  0  -  0 N-A4 44.40  1], {:race=>@vd}
    m9 = Group.new %w[1 Def 8.05  6.04  6.04  4.27  COL 4.48 CYB 45.37   32.54], {:race=>@homo}
    
    all = [m1,m2,m3,m4,m5,m6,m7,m8,m9]
    
    all.each do |m|
      assert m > nil, 'Nil Comparison wrong' 
      assert m == m, 'Self Comparison wrong'
      assert m != @av, 'Race comparison failed'  unless [m4,m6,m7].include? m
      assert m != @vd, 'Race comparison failed'  unless [m5,m8].include? m
      assert m != @homo, 'Race comparison failed'  unless m == m9
      assert m != @p1, 'Planet comparison failed'  unless [m2,m3,m8,m6,m7].include? m
      assert m != @p2, 'Planet comparison failed'  unless [m3,m4, m9].include? m
      assert m != @p3, 'Planet comparison failed'  
      assert m != @p4, 'Planet comparison failed'  unless [m2,m5].include? m
      assert m != @q, 'Product comparison failed'  unless [m7].include? m
      assert m != @def, 'Product comparison failed'  unless [m9].include? m
      assert m != @f1, 'Fleet comparison failed'  unless [m7].include? m
      assert m != @f2, 'Fleet comparison failed' 
      assert m != 122, 'Integer comparison failed'
      assert m == :active, 'Symbol comparison failed' unless [m4,m5].include? m
      assert m != :battle, 'Symbol comparison failed' unless [m4,m5].include? m
      assert m != :incoming, 'Symbol comparison failed' unless [m2,m3].include? m
      assert m != :unknown, 'Symbol comparison failed' unless [m1,m2,m3].include? m
      assert m != :homo, 'Symbol comparison failed'  unless [m9].include? m
      assert m != :dron, 'Symbol comparison failed'  unless [m4,m5,m8].include? m
      assert m != :cyb, 'Symbol comparison failed'  unless [m3,m4,m9].include? m
      assert m != :orbit, 'Symbol comparison failed'  unless [m6,m7].include? m
      assert m != :'6830', 'Symbol comparison failed'  unless [m7].include? m
      
       (all-[m]).each do |mm| 
        assert m != mm, 'Group Comparison wrong'
        assert mm != m, 'Group Comparison wrong'
      end 
      assert m != 'Erunda', 'String Comparison wrong'
      assert m != :erunda, 'Symbol Comparison wrong'
    end
    assert m8 > m6, 'Group Comparison wrong'
    assert m4 == @av, 'Race comparison failed' 
    assert m5 == @vd, 'Race comparison failed' 
    assert m9 == @homo, 'Race comparison failed' 
    assert m2 == @p1, 'Planet comparison failed' 
    assert m3 == @p2, 'Planet comparison failed' 
    assert m5 == @p4, 'Planet comparison failed' 
    assert m9 == @def, 'Product comparison failed'  
    assert m6 == @mark, 'Product comparison failed'  
    assert m5 == @raz, 'Product comparison failed'  
    assert m7 == @f1, 'Fleet comparison failed' 
    assert m6 == 1, 'Integer comparison failed' 
    assert m8 == 62, 'Integer comparison failed' 
    assert m9 <10, 'Integer comparison failed' 
    assert m1 <0, 'Integer comparison failed' 
    assert m4 != :active, 'Symbol comparison failed' 
    assert m5 == :battle, 'Symbol comparison failed' 
    assert m2 == :incoming, 'Symbol comparison failed' 
    assert m3 == :unknown, 'Symbol comparison failed' 
    assert m9 == :homo, 'Symbol comparison failed' 
    assert m5 == :dron, 'Symbol comparison failed' 
    assert m4 == :cyb, 'Symbol comparison failed'  
    assert m7 == :orbit, 'Symbol comparison failed'  
    assert m7 == :'6830', 'Symbol comparison failed'  
  end
  
  def test_booleans
    m1 = Group.new %w[15768.34 11160.36], {}
    m2 = Group.new %w[#9219 N-A4 828.88 69.00 1.00], {}
    m3 = Group.new %w[CYB N-A4 1420.78   50.56  2000.00], {}
    m4 = Group.new %w[13 DPOH 11.80  0.00  0  0.00  -  0.00  10  In_Battle], {:race=>@av, :planet=>@p2, :battles=>1}
    m5 = Group.new %w[1  raz  8.05  0  0  0  -  0  1  Out_Battle], {:race=>@vd, :planet=>@p4, :battles=>2}
    m6 = Group.new %w[0  1  MAPKEP 2.22   0.00   0.00  1.00 COL 0.03  N-A4 - 0.00 39.34 9.03  -  In_Orbit], {:race=>@av}
    m7 = Group.new %w[6830 1170 QAK 13.00 0.00 9.99 0.00 - 0.00 N-A4 - 0.00 78.08 3.33  fgtr5 In_Orbit], {:race=>@av}
    m8 = Group.new %w[62  raz  2.22  0  0  0  -  0 N-A4 44.40  1], {:race=>@vd}
    m9 = Group.new %w[1 Def 8.05  6.04  6.04  4.27  COL 4.48 CYB 45.37   32.54], {:race=>@homo}
    
    assert !m9.from_battle?, 'Boolean wrong'
    assert !m9.incoming?, 'Boolean wrong'
    assert !m9.unidentified?, 'Boolean wrong'
    assert m9.active?, 'Boolean wrong'
    assert !m9.your?, 'Boolean wrong'
    assert !m9.your_active?, 'Boolean wrong'
    assert !m9.drone?, 'Boolean wrong'
    
    assert !m8.from_battle?, 'Boolean wrong'
    assert !m8.incoming?, 'Boolean wrong'
    assert !m8.unidentified?, 'Boolean wrong'
    assert m8.active?, 'Boolean wrong'
    assert !m8.your?, 'Boolean wrong'
    assert !m8.your_active?, 'Boolean wrong'
    assert m8.drone?, 'Boolean wrong'
    
    assert !m7.from_battle?, 'Boolean wrong'
    assert !m7.incoming?, 'Boolean wrong'
    assert !m7.unidentified?, 'Boolean wrong'
    assert m7.active?, 'Boolean wrong'
    assert m7.your?, 'Boolean wrong'
    assert m7.your_active?, 'Boolean wrong'
    assert !m7.drone?, 'Boolean wrong'
    
    assert !m6.from_battle?, 'Boolean wrong'
    assert !m6.incoming?, 'Boolean wrong'
    assert !m6.unidentified?, 'Boolean wrong'
    assert m6.active?, 'Boolean wrong'
    assert m6.your?, 'Boolean wrong'
    assert m6.your_active?, 'Boolean wrong'
    assert !m6.drone?, 'Boolean wrong'
    
    assert m5.from_battle?, 'Boolean wrong'
    assert !m5.incoming?, 'Boolean wrong'
    assert !m5.unidentified?, 'Boolean wrong'
    assert !m5.active?, 'Boolean wrong'
    assert !m5.your?, 'Boolean wrong'
    assert !m5.your_active?, 'Boolean wrong'
    assert m5.drone?, 'Boolean wrong'
    
    assert m4.from_battle?, 'Boolean wrong'
    assert !m4.incoming?, 'Boolean wrong'
    assert !m4.unidentified?, 'Boolean wrong'
    assert !m4.active?, 'Boolean wrong'
    assert m4.your?, 'Boolean wrong'
    assert !m4.your_active?, 'Boolean wrong'
    assert m4.drone?, 'Boolean wrong'
    
    assert !m3.from_battle?, 'Boolean wrong'
    assert m3.incoming?, 'Boolean wrong'
    assert m3.unidentified?, 'Boolean wrong'
    assert m3.active?, 'Boolean wrong'
    assert !m3.your?, 'Boolean wrong'
    assert !m3.your_active?, 'Boolean wrong'
    assert !m3.drone?, 'Boolean wrong'
    
    assert !m2.from_battle?, 'Boolean wrong'
    assert m2.incoming?, 'Boolean wrong'
    assert m2.unidentified?, 'Boolean wrong'
    assert m2.active?, 'Boolean wrong'
    assert !m2.your?, 'Boolean wrong'
    assert !m2.your_active?, 'Boolean wrong'
    assert m2.drone?, 'Boolean wrong'
    
    assert !m1.from_battle?, 'Boolean wrong'
    assert !m1.incoming?, 'Boolean wrong'
    assert m1.unidentified?, 'Boolean wrong'
    assert m1.active?, 'Boolean wrong'
    assert !m1.your?, 'Boolean wrong'
    assert !m1.your_active?, 'Boolean wrong'
    assert !m1.drone?, 'Boolean wrong'
    
  end
  
  def test_init_unidentified
    m1 = Group.new %w[15768.34 11160.36], {}
    
    assert_nil m1.key, 'Group key wrong'
    assert_nil m1.race, 'Group race wrong'
    assert_nil m1.product, 'Group product wrong'
    assert_nil m1.planet, 'Group planet wrong'
    assert_nil m1.from, 'Group planet wrong'
    assert_nil m1.fleet, 'Group fleet wrong'
    assert_nil m1.num, 'Group accessor wrong'
    assert_equal 15768.34, m1.x, 'Group accessor wrong'
    assert_equal 11160.36, m1.y, 'Group accessor wrong'
    assert_nil m1.num_ships, 'Group accessor wrong'
    assert_nil m1.battles, 'Group key wrong'
    assert_nil m1.num_before, 'Group accessor wrong'
    assert_nil m1.drive, 'Group accessor wrong'
    assert_nil m1.weapons, 'Group accessor wrong'
    assert_nil m1.shields, 'Group accessor wrong'
    assert_nil m1.cargo, 'Group accessor wrong'
    assert_nil m1.cargo_type, 'Group accessor wrong'
    assert_nil m1.qty, 'Group accessor wrong'
    assert_nil m1.range, 'Group accessor wrong'
    assert_nil m1.speed, 'Group accessor wrong'
    assert_nil m1.mass, 'Group accessor wrong'
    assert_nil m1.status, 'Group accessor wrong'
    assert_in_delta 0, m1.eta, 0.00001, 'ETA calculation wrong'
  end   
  
  def test_init_incoming
    m1 = Group.new %w[#9219 N-A4 828.88 69.00 1.00], {}
    m2 = Group.new %w[CYB N-A4 1420.78   50.56  2000.00], {}
    
    assert_nil m2.key, 'Group key wrong'
    assert_nil m2.race, 'Group race wrong'
    assert_nil m2.product, 'Group product wrong'
    assert_equal @p1, m2.planet, 'Group planet wrong'
    assert_equal @p2, m2.from, 'Group planet wrong'
    assert_nil m2.fleet, 'Group fleet wrong'
    assert_nil m2.num, 'Group accessor wrong'
    assert_equal 0, m2.x, 'Group accessor wrong'
    assert_equal 0, m2.y, 'Group accessor wrong'
    assert_nil m2.num_ships, 'Group accessor wrong'
    assert_nil m2.battles, 'Group key wrong'
    assert_nil m2.num_before, 'Group accessor wrong'
    assert_nil m2.drive, 'Group accessor wrong'
    assert_nil m2.weapons, 'Group accessor wrong'
    assert_nil m2.shields, 'Group accessor wrong'
    assert_nil m2.cargo, 'Group accessor wrong'
    assert_nil m2.cargo_type, 'Group accessor wrong'
    assert_nil m2.qty, 'Group accessor wrong'
    assert_equal 1420.78, m2.range, 'Group accessor wrong'
    assert_equal 50.56, m2.speed, 'Group accessor wrong'
    assert_equal 2000.00, m2.mass, 'Group accessor wrong'
    assert_nil m2.status, 'Group accessor wrong'
    assert_in_delta 28.10087, m2.eta, 0.00001, 'ETA calculation wrong'
    assert_equal m2, @p1.groups[1], 'Group association wrong'
    assert_equal m2, @p2.sent_groups[0], 'Group association wrong'
    
    assert_nil m1.key, 'Group key wrong'
    assert_nil m1.race, 'Group race wrong'
    assert_nil m1.product, 'Group product wrong'
    assert_equal @p1, m1.planet, 'Group planet wrong'
    assert_equal @p4, m1.from, 'Group planet wrong'
    assert_nil m1.fleet, 'Group fleet wrong'
    assert_nil m1.num, 'Group accessor wrong'
    assert_equal 0, m1.x, 'Group accessor wrong'
    assert_equal 0, m1.y, 'Group accessor wrong'
    assert_nil m1.num_ships, 'Group accessor wrong'
    assert_nil m1.battles, 'Group key wrong'
    assert_nil m1.num_before, 'Group accessor wrong'
    assert_nil m1.drive, 'Group accessor wrong'
    assert_nil m1.weapons, 'Group accessor wrong'
    assert_nil m1.shields, 'Group accessor wrong'
    assert_nil m1.cargo, 'Group accessor wrong'
    assert_nil m1.cargo_type, 'Group accessor wrong'
    assert_nil m1.qty, 'Group accessor wrong'
    assert_equal 828.88, m1.range, 'Group accessor wrong'
    assert_equal 69.00, m1.speed, 'Group accessor wrong'
    assert_equal 1, m1.mass, 'Group accessor wrong'
    assert_nil m1.status, 'Group accessor wrong'
    assert_in_delta 12.0127536, m1.eta, 0.00001, 'ETA calculation wrong'
    assert_equal m1, @p1.groups[0], 'Group association wrong'
    assert_equal m1, @p4.sent_groups[0], 'Group association wrong' 
  end   
  
  def test_init_battle
    m1 = Group.new %w[13 DPOH 11.80  0.00  0  0.00  -  0.00  10  In_Battle], {:race=>@av, :planet=>@p4, :battles=>1}
    m2 = Group.new %w[1  raz  8.05  0  0  0  -  0  1  Out_Battle], {:race=>@vd, :planet=>@p4, :battles=>2}
    
    assert_nil m2.key, 'Group key wrong'
    assert_equal @vd, m2.race, 'Group race wrong'
    assert_equal @raz, m2.product, 'Group product wrong'
    assert_equal @p4, m2.planet, 'Group planet wrong'
    assert_nil m2.from, 'Group planet wrong'
    assert_nil m2.fleet, 'Group fleet wrong'
    assert_nil m2.num, 'Group accessor wrong'
    assert_nil m2.x, 'Group accessor wrong'
    assert_nil m2.y, 'Group accessor wrong'
    assert_equal 1, m2.num_ships, 'Group accessor wrong'
    assert_equal 2, m2.battles, 'Group key wrong'
    assert_equal 1, m2.num_before, 'Group accessor wrong'
    assert_equal 8.05, m2.drive, 'Group accessor wrong'
    assert_equal 0, m2.weapons, 'Group accessor wrong'
    assert_equal 0, m2.shields, 'Group accessor wrong'
    assert_equal 0, m2.cargo, 'Group accessor wrong'
    assert_equal '-', m2.cargo_type, 'Group accessor wrong'
    assert_equal 0, m2.qty, 'Group accessor wrong'
    assert_nil m2.range, 'Group accessor wrong'
    assert_nil m2.speed, 'Group accessor wrong'
    assert_nil m2.mass, 'Group accessor wrong'
    assert_equal 'Out_Battle', m2.status, 'Group accessor wrong'
    assert_in_delta 0, m2.eta, 0.00001, 'ETA calculation wrong'
    assert_equal m2, @p4.groups[1], 'Group association wrong'
    assert_equal m2, @vd.groups[0], 'Group association wrong'
    assert_equal m2, @raz.groups.first, 'Group association wrong'
    
    assert_nil m1.key, 'Group key wrong'
    assert_equal @av, m1.race, 'Group race wrong'
    assert_equal @dron, m1.product, 'Group product wrong'
    assert_equal @p4, m1.planet, 'Group planet wrong'
    assert_nil m1.from, 'Group planet wrong'
    assert_nil m1.fleet, 'Group fleet wrong'
    assert_nil m1.num, 'Group accessor wrong'
    assert_nil m1.x, 'Group accessor wrong'
    assert_nil m1.y, 'Group accessor wrong'
    assert_equal 10, m1.num_ships, 'Group accessor wrong'
    assert_equal 1, m1.battles, 'Group key wrong'
    assert_equal 13, m1.num_before, 'Group accessor wrong'
    assert_equal 11.80, m1.drive, 'Group accessor wrong'
    assert_equal 0, m1.weapons, 'Group accessor wrong'
    assert_equal 0, m1.shields, 'Group accessor wrong'
    assert_equal 0, m1.cargo, 'Group accessor wrong'
    assert_equal '-', m1.cargo_type, 'Group accessor wrong'
    assert_equal 0, m1.qty, 'Group accessor wrong'
    assert_nil m1.range, 'Group accessor wrong'
    assert_nil m1.speed, 'Group accessor wrong'
    assert_nil m1.mass, 'Group accessor wrong'
    assert_equal 'In_Battle', m1.status, 'Group accessor wrong'
    assert_in_delta 0, m1.eta, 0.00001, 'ETA calculation wrong'
    assert_equal m1, @p4.groups[0], 'Group association wrong'
    assert_equal m1, @av.groups[0], 'Group association wrong'
    assert_equal m1, @dron.groups.first, 'Group association wrong'
    
  end
  
  def test_init_yours
    m1 = Group.new %w[0  1  MAPKEP 2.22   0.00   0.00  1.00 COL 0.03  N-A4 - 0.00 39.34 9.03  -  In_Orbit], {:race=>@av}
    m2 = Group.new %w[6830 1170 QAK 13.00 0.00 9.99 0.00 - 0.00 N-A4 - 0.00 78.08 3.33  fgtr5 In_Orbit], {:race=>@av}
    m3 = Group.new %w[14 1  DPOH 2.62   0.00   0.00  0.00  -  0.00  CYB  #7261 396.10 52.40 1.00 - In_Space], {:race=>@av}
    m4 = Group.new %w[133 1  DPOH 12.62   0.00   0.00  0.00  -  0.00  CYB  #7261 4796.57 52.40 1.00 sv11 In_Space], {:race=>@av}
    
    assert_equal 'ArVitallian.133', m4.key, 'Group key wrong'
    assert_equal @av, m4.race, 'Group race wrong'
    assert_equal @dron, m4.product, 'Group product wrong'
    assert_equal @p2, m4.planet, 'Group planet wrong'
    assert_equal @p3, m4.from, 'Group planet wrong'
    assert_equal @f2, m4.fleet, 'Group fleet wrong'
    assert_equal 133, m4.num, 'Group accessor wrong'
    assert_equal 0, m4.x, 'Group accessor wrong'
    assert_equal 0, m4.y, 'Group accessor wrong'
    assert_equal 1, m4.num_ships, 'Group accessor wrong'
    assert_nil m4.num_before, 'Group accessor wrong'
    assert_equal 12.62, m4.drive, 'Group accessor wrong'
    assert_equal 0, m4.weapons, 'Group accessor wrong'
    assert_equal 0, m4.shields, 'Group accessor wrong'
    assert_equal 0, m4.cargo, 'Group accessor wrong'
    assert_equal '-', m4.cargo_type, 'Group accessor wrong'
    assert_equal 0, m4.qty, 'Group accessor wrong'
    assert_equal 4796.57, m4.range, 'Group accessor wrong'
    assert_equal 52.40, m4.speed, 'Group accessor wrong'
    assert_equal 1, m4.mass, 'Group accessor wrong'
    assert_equal 'In_Space', m4.status, 'Group accessor wrong'
    assert_in_delta 91.537595419, m4.eta, 0.00001, 'ETA calculation wrong'
    assert_equal m4, @p2.groups[1], 'Group association wrong'
    assert_equal m4, @p3.sent_groups[1], 'Group association wrong'
    assert_equal m4, @av.groups[3], 'Group association wrong'
    assert_equal m4, @dron.groups.last, 'Group association wrong'
    
    assert_equal 'ArVitallian.14', m3.key, 'Group key wrong'
    assert_equal @av, m3.race, 'Group race wrong'
    assert_equal @dron, m3.product, 'Group product wrong'
    assert_equal @p2, m3.planet, 'Group planet wrong'
    assert_equal @p3, m3.from, 'Group planet wrong'
    assert_nil m3.fleet, 'Group fleet wrong'
    assert_equal 14, m3.num, 'Group accessor wrong'
    assert_equal 0, m3.x, 'Group accessor wrong'
    assert_equal 0, m3.y, 'Group accessor wrong'
    assert_equal 1, m3.num_ships, 'Group accessor wrong'
    assert_nil m3.num_before, 'Group accessor wrong'
    assert_equal 2.62, m3.drive, 'Group accessor wrong'
    assert_equal 0, m3.weapons, 'Group accessor wrong'
    assert_equal 0, m3.shields, 'Group accessor wrong'
    assert_equal 0, m3.cargo, 'Group accessor wrong'
    assert_equal '-', m3.cargo_type, 'Group accessor wrong'
    assert_equal 0, m3.qty, 'Group accessor wrong'
    assert_equal 396.10, m3.range, 'Group accessor wrong'
    assert_equal 52.40, m3.speed, 'Group accessor wrong'
    assert_equal 1, m3.mass, 'Group accessor wrong'
    assert_equal 'In_Space', m3.status, 'Group accessor wrong'
    assert_in_delta 7.559160305, m3.eta, 0.00001, 'ETA calculation wrong'
    assert_equal m3, @p2.groups[0], 'Group association wrong'
    assert_equal m3, @p3.sent_groups[0], 'Group association wrong'
    assert_equal m3, @av.groups[2], 'Group association wrong'
    assert_equal m3, @dron.groups.first, 'Group association wrong'
    
    assert_equal 'ArVitallian.6830', m2.key, 'Group key wrong'
    assert_equal @av, m2.race, 'Group race wrong'
    assert_equal @q, m2.product, 'Group product wrong'
    assert_equal @p1, m2.planet, 'Group planet wrong'
    assert_nil m2.from, 'Group planet wrong'
    assert_equal @f1, m2.fleet, 'Group fleet wrong'
    assert_equal 6830, m2.num, 'Group accessor wrong'
    assert_equal 10483.56, m2.x, 'Group accessor wrong'
    assert_equal 10512.20, m2.y, 'Group accessor wrong'
    assert_equal 1170, m2.num_ships, 'Group accessor wrong'
    assert_nil m2.num_before, 'Group accessor wrong'
    assert_equal 13.00, m2.drive, 'Group accessor wrong'
    assert_equal 0, m2.weapons, 'Group accessor wrong'
    assert_equal 9.99, m2.shields, 'Group accessor wrong'
    assert_equal 0, m2.cargo, 'Group accessor wrong'
    assert_equal '-', m2.cargo_type, 'Group accessor wrong'
    assert_equal 0, m2.qty, 'Group accessor wrong'
    assert_equal 0, m2.range, 'Group accessor wrong'
    assert_equal 78.08, m2.speed, 'Group accessor wrong'
    assert_equal 3.33, m2.mass, 'Group accessor wrong'
    assert_equal 'In_Orbit', m2.status, 'Group accessor wrong'
    assert_in_delta 0.0, m2.eta, 0.00001, 'ETA calculation wrong'
    assert_equal m2, @p1.groups[1], 'Group association wrong'
    assert_equal m2, @av.groups[1], 'Group association wrong'
    assert_equal m2, @q.groups.first, 'Group association wrong'
    
    assert_equal 'ArVitallian.0', m1.key, 'Group key wrong'
    assert_equal @av, m1.race, 'Group race wrong'
    assert_equal @mark, m1.product, 'Group product wrong'
    assert_equal @p1, m1.planet, 'Group planet wrong'
    assert_nil m1.from, 'Group planet wrong'
    assert_nil m1.fleet, 'Group fleet wrong'
    assert_equal 0, m1.num, 'Group accessor wrong'
    assert_equal 10483.56, m1.x, 'Group accessor wrong'
    assert_equal 10512.20, m1.y, 'Group accessor wrong'
    assert_equal 1, m1.num_ships, 'Group accessor wrong'
    assert_nil m1.num_before, 'Group accessor wrong'
    assert_equal 2.22, m1.drive, 'Group accessor wrong'
    assert_equal 0, m1.weapons, 'Group accessor wrong'
    assert_equal 0, m1.shields, 'Group accessor wrong'
    assert_equal 1, m1.cargo, 'Group accessor wrong'
    assert_equal 'COL', m1.cargo_type, 'Group accessor wrong'
    assert_equal 0.03, m1.qty, 'Group accessor wrong'
    assert_equal 0, m1.range, 'Group accessor wrong'
    assert_equal 39.34, m1.speed, 'Group accessor wrong'
    assert_equal 9.03, m1.mass, 'Group accessor wrong'
    assert_equal 'In_Orbit', m1.status, 'Group accessor wrong'
    assert_in_delta 0.0, m1.eta, 0.00001, 'ETA calculation wrong'
    assert_equal m1, @p1.groups.first, 'Group association wrong'
    assert_equal m1, @av.groups.first, 'Group association wrong'
    assert_equal m1, @mark.groups.first, 'Group association wrong'
  end
  
  def test_init_other
    m1 = Group.new %w[62  raz  2.22  0  0  0  -  0 N-A4 44.40  1], {:race=>@vd}
    m2 = Group.new %w[1 Def 8.05  6.04  6.04  4.27  COL 4.48 CYB 45.37   32.54], {:race=>@homo}
    
    assert_nil m1.key, 'Group key wrong'
    assert_equal @vd, m1.race, 'Group race wrong'
    assert_equal @raz, m1.product, 'Group product wrong'
    assert_equal @p1, m1.planet, 'Group planet wrong'
    assert_nil m1.from, 'Group planet wrong'
    assert_nil m1.fleet, 'Group fleet wrong'
    assert_nil m1.num, 'Group accessor wrong'
    assert_equal 10483.56, m1.x, 'Group accessor wrong'
    assert_equal 10512.20, m1.y, 'Group accessor wrong'
    assert_equal 62, m1.num_ships, 'Group accessor wrong'
    assert_nil m1.num_before, 'Group accessor wrong'
    assert_equal 2.22, m1.drive, 'Group accessor wrong'
    assert_equal 0, m1.weapons, 'Group accessor wrong'
    assert_equal 0, m1.shields, 'Group accessor wrong'
    assert_equal 0, m1.cargo, 'Group accessor wrong'
    assert_equal '-', m1.cargo_type, 'Group accessor wrong'
    assert_equal 0, m1.qty, 'Group accessor wrong'
    assert_nil m1.range, 'Group accessor wrong'
    assert_equal 44.40, m1.speed, 'Group accessor wrong'
    assert_equal 1, m1.mass, 'Group accessor wrong'
    assert_nil m1.status, 'Group accessor wrong'
    assert_in_delta 0, m1.eta, 0.00001, 'ETA calculation wrong'
    assert_equal m1, @p1.groups[0], 'Group association wrong'
    assert_equal m1, @vd.groups[0], 'Group association wrong'
    assert_equal m1, @raz.groups.first, 'Group association wrong'
    
    assert_nil m2.key, 'Group key wrong'
    assert_equal @homo, m2.race, 'Group race wrong'
    assert_equal @def, m2.product, 'Group product wrong'
    assert_equal @p2, m2.planet, 'Group planet wrong'
    assert_nil m2.from, 'Group planet wrong'
    assert_nil m2.fleet, 'Group fleet wrong'
    assert_nil m2.num, 'Group accessor wrong'
    assert_equal 13906.25, m2.x, 'Group accessor wrong'
    assert_equal 17458.86, m2.y, 'Group accessor wrong'
    assert_equal 1, m2.num_ships, 'Group accessor wrong'
    assert_nil m2.num_before, 'Group accessor wrong'
    assert_equal 8.05, m2.drive, 'Group accessor wrong'
    assert_equal 6.04, m2.weapons, 'Group accessor wrong'
    assert_equal 6.04, m2.shields, 'Group accessor wrong'
    assert_equal 4.27, m2.cargo, 'Group accessor wrong'
    assert_equal 'COL', m2.cargo_type, 'Group accessor wrong'
    assert_equal 4.48, m2.qty, 'Group accessor wrong'
    assert_nil m2.range, 'Group accessor wrong'
    assert_equal 45.37, m2.speed, 'Group accessor wrong'
    assert_equal 32.54, m2.mass, 'Group accessor wrong'
    assert_nil m2.status, 'Group accessor wrong'
    assert_in_delta 0, m2.eta, 0.00001, 'ETA calculation wrong'
    assert_equal m2, @p2.groups[0], 'Group association wrong'
    assert_equal m2, @homo.groups[0], 'Group association wrong'
    assert_equal m2, @def.groups.first, 'Group association wrong'
  end
end

