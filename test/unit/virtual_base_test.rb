require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
#require 'active_record'
#require 'virtual_base.rb'

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ":memory:", :timeout => 500
ActiveRecord::Base.send(:include, ActiveRecord::VirtualBase)

class VirtualBaseModel < ActiveRecord::Base
  tableless :columns => [
  [:email, :string],
  [:password, :string],
  [:password_confirmation] ]
  
  validates_presence_of :email, :password, :password_confirmation
  validates_confirmation_of :password
end

class B_TablelessTest < Test::Unit::TestCase
  
  def setup
    super
    @valid_attributes = {
      :email => "robin@bogus.com",
      :password => "password",
      :password_confirmation => "password"
    }
  end
  
  def test_create
    assert VirtualBaseModel.create(@valid_attributes).valid?
  end
  
  def test_validations
    # Just check a few validations to make sure we didn't break ActiveRecord::Validations::ClassMethods
    assert_not_nil VirtualBaseModel.create(@valid_attributes.merge(:email => "")).errors[:email]
    assert_not_nil VirtualBaseModel.create(@valid_attributes.merge(:password => "")).errors[:password]
    assert_not_nil VirtualBaseModel.create(@valid_attributes.merge(:password_confirmation => "")).errors[:password]
  end
  
  def test_save
    assert VirtualBaseModel.new(@valid_attributes).save
    assert !VirtualBaseModel.new(@valid_attributes.merge(:password => "no_match")).save
  end
  
  def test_valid?
    assert VirtualBaseModel.new(@valid_attributes).valid?
    assert !VirtualBaseModel.new(@valid_attributes.merge(:password => "no_match")).valid?
  end
  
  def test_exists!
    m = VirtualBaseModel.new(@valid_attributes)
    
    assert_nil m.id
    assert m.new_record?
    
    m.exists!
    assert_equal 1, m.id
    assert !m.new_record?
    
    m.exists!(250)
    assert_equal 250, m.id
    assert !m.new_record?
  end
end

class B_ReportWithVBTest < Test::Unit::TestCase
  
  def setup
    require 'report.rb'
    
    rep = Report.new 'rep/ArVit187.rep'
    @data = ActiveRecord::Base.establish_dataset(rep)
    @data.owner='ArVitallian'
    
    @av = Race.new %w[ArVitallian 13.00  11.61  11.08  5.48  2276614.82  2028341.13  2515 - 2276.61],{}
    @vd = Race.new %w[Vildok 10.33 1.00 1.00 6.07 2035.74 0.00 1 War 0.00], {}
    @raz = Product.new %w[raz 1.00 0 0.00 0.00 0.00 1.00],{:race=>@vd}
    @q = Product.new %w[QAK 1.00 0 0.00 2.33 0.00 3.33],{:race=>@av}
    @s1 = Product.new %w[MoveTo_6300_12504 6299.55   12503.99  0  0],{:race=>@av}
    @mark = Product.new %w[MAPKEP 8.00 0 0.00 0.00 1.00 9.00],{:race=>@av}
    @p1 = Planet.new %w[9802 10483.56 10512.20 N-A4 2500.00 2349.00 2200.00 0.03 QAK 49.75 5214.30  2005.14  2300.00], {:race=>@av}
    @p2 = Planet.new %w[7346 13906.25 17458.86 CYB 2500.00   0.07  0.00   3819.89], {}
    @p3 = Planet.new %w[7261  15768.34  11160.36], {}
    @p4 = Planet.new %w[7810  8-14R], {}
    @f1 = Fleet.new %w[1  fgtr5  6  N-A4 -  0.00  112.50  In_Orbit], {:owner=>'ArVitallian'}
    @g1 = Group.new %w[0  1  MAPKEP 2.22   0.00   0.00  1.00 COL 0.03  N-A4 - 0.00 39.34 9.03  -  In_Orbit], 
    {:planet=>@p1, :race=>@av, :product=>@mark}
    @g2 = Group.new %w[6830 1170 QAK 13.00 0.00 9.99 0.00 - 0.00 N-A4 - 0.00 78.08 3.33  fgtr5 In_Orbit], 
    {:planet=>@p1, :race=>@av, :product=>@q, :fleet=>@f1}
    @r = Route.new %w[N-A4 -  #7346  - -], {:owner=>'ArVitallian'}
  end
  
  def test_add
    # Models are automatically added to dataset upon creation
    assert @vd.add # Multiple add leaves object in the same place of dataset
    assert @vd.add
    assert_equal @vd, @data.races[1]
    assert_equal @av, @data.races.first
    assert_equal 2, @data.races.size
    assert_equal @raz, @data.products[6] #first products (drive, cap, etc...) defined in Report
    assert_equal @mark, @data.ships.last
    assert_equal @mark, @data.products[-1]
    assert_equal @s1, @data.sciences[0]
    assert_equal @p1, @data.planets['N-A4']
    assert_equal @p1, @data.your_planets[0]
    assert_equal @p2, @data.planets['#7346']
    assert_equal @p2, @data.uninhabited_planets[0]
    assert_equal @p3, @data.planets['#7261']
    assert_equal @p3, @data.unknown_planets[0]
    assert_equal @f1, @data.fleets.first
    assert_equal @g1, @data.groups.first
    assert_equal @r, @data.routes.first
    
    #Update a Planet and make sure no duplicates added to dataset
    @p4.update_planet %w[7810 10483.56 10512.20 NEW 2500.00 2349.00 2200.00 0.03 QAK 49.75 5214.30  2005.14  2300.00], {:race=>@av}
    assert_equal 4, @data.planets.size
    assert_equal @p4, @data.planets['#7810']
    assert_equal @p4, @data.planets['8-14R']
    assert_equal @p4, @data.planets['NEW']
  end
  
  def test_lookup
    assert_equal @av, Race.lookup(:first)
    assert_equal @av, Race.lookup(0)
    assert_equal @av, Race.lookup(@av.key)
    assert_equal @av, Race.lookup(@av.idx)
    assert_equal @vd, Race.lookup(:last)
    assert_equal @vd, Race.lookup('Vildok')
    assert_equal [@av,@vd], Race.lookup(:all)
    assert_equal 'Drive', Product.lookup(:first).name # Auto-created by Report
    assert_equal @mark, Product.lookup(:last)
    assert_equal @s1, Product.lookup(8)
    assert_equal @raz, Product.lookup(@raz.key)
    assert_equal 10, Product.lookup(:all).size
    assert_equal @p1, Planet.lookup(:first)
    assert_equal @p4, Planet.lookup(:last)
    assert_equal @p1, Planet.lookup('N-A4')
    assert_equal @p1, Planet.lookup(@p1.key)
    assert_equal @p1, Planet.lookup(@p1.idx)
    assert_equal @p2, Planet.lookup('#7346')
    assert_equal 4, Planet.lookup(:all).size
    assert_equal @f1, Fleet.lookup(:first)
    assert_equal @f1, Fleet.lookup(:last)
    assert_equal @f1, Fleet.lookup('ArVitallian.fgtr5')
    assert_equal @f1, Fleet.lookup(@f1.key)
    assert_equal @f1, Fleet.lookup(@f1.idx)
    assert_equal @f1, Fleet.lookup(0)
    assert_equal @g1, Group.lookup(:first)
    assert_equal @g2, Group.lookup(:last)
    assert_equal @g1, Group.lookup('ArVitallian.0')
    assert_equal @g1, Group.lookup(@g1.key)
    assert_equal @g1, Group.lookup(@g1.idx)
    assert_equal @g1, Group.lookup(0)
    assert_equal @r, Route.lookup(:first)
    assert_equal @r, Route.lookup(:last)
    assert_equal @r, Route.lookup('9802.7346.mat')
    assert_equal @r, Route.lookup(@r.key)
    assert_equal @r, Route.lookup(@r.idx)
    assert_equal @r, Route.lookup(0)
  end
  
  def test_kill
    assert @raz.kill
    assert_nil @data.products[@raz.key]
    assert @mark.kill
    assert_nil @data.products[@mark.key]
    assert @q.kill
    assert @data.ships.empty?
    assert @s1.kill
    assert_nil @data.sciences[0]
    assert_nil @data.products[-1]
    assert @p1.kill
    assert_nil @data.planets['N-A4']
    assert_nil @data.your_planets[0]
    assert @p2.kill
    assert_nil @data.planets['#7346']
    assert_nil @data.uninhabited_planets[0]
    assert @p3.kill
    assert_nil @data.planets['#7261']
    assert_nil @data.unknown_planets[1]
    assert @f1.kill
    assert_nil @data.fleets.first
    assert @g1.kill
    assert_nil @data.groups.first
    assert @r.kill
    assert_nil @data.routes.first
    assert @av.kill
    assert_nil @data.races.first
    assert_nil @data.races['ArVitallian']
    assert @vd.kill
    assert_nil @data.races.last
    assert_nil @vd.idx
  end
  
  def test_class_kill
    Product.kill 'Vildok.raz'
    assert_nil @data.products[@raz.key]
    Product.kill :all
    assert_nil @data.ships.last
    assert_nil @data.products[@mark.key]
    assert_nil @data.sciences[0]
    assert_nil @data.products[-1]
    Planet.kill 'N-A4'
    assert_nil @data.your_planets[0]
    assert_nil @data.planets['N-A4']
    Planet.kill '#7346'
    assert_nil @data.planets['#7346']
    assert_nil @data.uninhabited_planets[0]
    Planet.kill :last
    assert_nil @data.planets['#7810']
    assert_nil @data.unknown_planets[1]
    Fleet.kill @f1.idx
    assert_nil @data.fleets.first
    Group.kill :first
    assert_nil @data.groups.first
    Route.kill :first
    assert_nil @data.routes.first
    Race.kill 'ArVitallian'
    assert_nil @data.races['ArVitallian']
    Race.kill :last
    assert_nil @data.races.last
    assert_nil @vd.idx
  end
end