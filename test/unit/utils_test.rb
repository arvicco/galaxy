require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
#require 'utils.rb'

class A_ConstKeysHATest < Test::Unit::TestCase
  
  class TestObj
    attr_reader :key
    attr_accessor :idx, :data
    
    def initialize key = nil, idx = nil, data = "Empty"
      @key = key; @idx = idx; @data = data 
    end
  end
  
  def setup
    @o1 = TestObj.new('key1')
    @o2 = TestObj.new('key2', 2, 'Data 2')
    @o3 = TestObj.new('key3', 3, 'Data 3')
    @o7 = TestObj.new('key7', 7, 'Data 7')
    
    @o10 = TestObj.new('key10', nil, 'Data 10')
    @o11 = TestObj.new('key11', nil, 'Data 11')
    @o12 = TestObj.new('key12', 12, 'Data 12')
    @o13 = TestObj.new(nil, nil, 'Data 13')
    @o14 = TestObj.new('double_key', nil, 'Data 14')
    @o15 = TestObj.new('key15', 15, 'Data 15')
    
    @b = HashArray.new
    @a = HashArray[0, 1, 2, @o7, @o1, @o3, @o2]
    @hm = {:key2=>2, :key3=>3, :key7=>7, :key1=>8}
  end
  
  def test_create
    assert_equal [], HashArray.new, "Empty array creation failed"
    assert_equal [1,2,3,4,5], HashArray[1,2,3,4,5], "Literal array creation failed"
    assert_equal [1,1,1,1,1], HashArray.new(5,1), "Repeated array creation failed"
    assert_equal [0, 1, @o2, @o3, nil, nil, nil, @o7, @o1], @a, "Literal Object array creation failed"
  end
  
  def test_delete
    @a >> 1
    assert_nil @a[1], 'Deleted element not nil'
    @a >> @o1
    assert_nil @a[8], 'Deleted element not nil'
    assert_nil @a[:key1], 'Deleted element not nil'
    
    # Deleting element that is not in Array throws an exception
    assert_raise ArgumentError do @a >> @o11 end 

    assert_equal @a, @a << @o11 >> @o11, 'Round-trip adding and removing fails'
  end
  
  def test_access
    assert_equal @hm, @a.hashmap, "Hashmap matching failed"
    assert_nil @a[44], 'Out-of-range element not nil'
    assert_nil @a[nil], 'Nil index element not nil'
    assert_equal @o7, @a[7], 'Integer index access failed'
    assert_equal @o1, @a[-1], 'Negative integer index access failed'
    assert_equal @o3, @a['key3'], 'String index access failed'
    assert_equal [1, @o2, @o3, nil], @a[1..4], 'Range access failed'
    assert_equal [1, @o2, @o3], @a[1,3], 'Slice access failed'
  end
  
  def test_simple_assign
    @a[] = 'end'
    assert_equal 'end', @a[9], 'No-index assign failed'
    @a << 'more_end'
    assert_equal 'more_end', @a[10], 'Addition failed'
    
    @a[4] = 11
    assert_equal 11, @a[4], 'Index assign failed'
    @a[4] = 22
    assert_equal 22, @a[4], 'Index re-assign failed'
    
    @a['key'] = 33
    assert_equal 33, @a['key'], 'Key assign failed'
    
    @a[5,'double_key'] = 'double'
    assert_equal 'double', @a['double_key'], 'Index/key assign failed'
    assert_equal 'double', @a[5], 'Index/key assign failed'
    
    @a[11] = 'replace'
    assert_nil @a['key'], 'Keyed value replacement failed'
    assert_nil @a.hashmap['key'], 'Keyed value replacement failed'
    
    @a['double_key'] = 'trouble'
    assert_equal 'trouble', @a['double_key'], 'Key reuse failed'
    assert_nil @a[5], 'Key reuse failed'
    
    @a[25,'out_key'] = 'outlier'
    assert_equal 'outlier', @a['out_key'], 'Out-of-range index/key assign failed'
    assert_equal 'outlier', @a[25], 'Out-of-range index/key assign failed'
  end
  
  def test_object_assign
    @a[] = @o11
    assert_equal @o11, @a[9], 'No-index assign failed'
    assert_equal @o11, @a['key11'], 'No-index assign failed'
    assert_equal 9, @a[9].idx, 'No-index assign failed'
    
    @a << @o10
    assert_equal @o10, @a[10], 'Addition failed'
    assert_equal @o10, @a['key10'], 'Addition failed'
    assert_equal 10, @a[10].idx, 'Addition failed'
    
    # Add to Array object that is already there
    @a[] = @o3
    assert_equal @o3, @a[3], 'Object reassign failed'
    assert_equal @o3, @a['key3'], 'Object reassign failed'
    assert_equal 3, @a[3].idx, 'Object reassign failed'
    
    # Assign object by index and replace element later
    @a[4] = @o12
    assert_equal @o12, @a[4], 'Index assign failed'
    assert_equal @o12, @a['key12'], 'Index assign failed'
    assert_equal 4, @a[4].idx, 'Index assign failed'
    @a[4] = 22
    assert_equal 22, @a[4], 'Index re-assign failed'
    assert_nil @a['key12'], 'Index re-assign failed'
    assert_nil @o12.idx, 'Index re-assign failed'
    assert_equal 'key12', @o12.key, 'Index re-assign failed'
    
    # Assign object by key
    @a['key'] = @o12
    assert_equal @o12, @a['key'], 'Key assign failed'
    assert_equal 11, @o12.idx, 'Key assign failed'
    
    # Assign object by index and key
    @a[5,'double_key'] = @o13
    assert_equal @o13, @a['double_key'], 'Index/key assign failed'
    assert_equal @o13, @a[5], 'Index/key assign failed'
    assert_equal 5, @o13.idx, 'Index/key assign failed'
    
    # Replace object by index and key with another object (different key)
    @a[5,'new_key'] = @o2
    assert_equal @o2, @a['new_key'], 'Index/key replacement assign failed'
    assert_equal @o2, @a[5], 'Index/key replacement assign failed'
    assert_equal 5, @o2.idx, 'Index/key replacement assign failed'
    assert_nil @a['double_key'], 'Index/key replacement assign failed'
    assert_nil @o13.idx, 'Index/key replacement assign failed'
    
    # Replace object by index and key with another object (same key)
    @a[5,'new_key'] = @o1
    assert_equal @o1, @a['new_key'], 'Index/key replacement assign failed'
    assert_equal @o1, @a[5], 'Index/key replacement assign failed'
    assert_equal 5, @o1.idx, 'Index/key replacement assign failed'
    assert_nil @o2.idx, 'Index/key replacement assign failed'
    
    # Replace object by index (new object has different key)
    @a[5] = @o13
    assert_nil @a['new_key'], 'Keyed value replacement failed'
    assert_nil @a.hashmap['new_key'], 'Keyed value replacement failed'
    assert_nil @o1.idx, 'Keyed value replacement failed'
    
    # Replace object by index (new object has same key)
    @a[5] = @o14
    assert_equal 'double_key', @o14.key, 'Keyed value replacement failed'
    assert_nil @o13.key, 'Keyed value replacement failed' #old key value is deleted
    
    # Assign new key to element already in HashArray
    @a['double_key'] = @o2
    assert_equal @o2, @a['double_key'], 'Key reuse failed'
    assert_equal @o2, @a[2], 'Key reuse failed'
    assert_nil @a[5], 'Key reuse failed'
    
    # Assign to element beyond HashArray border
    @a[25,'out_key'] = @o15
    assert_equal @o15, @a['out_key'], 'Out-of-range index/key assign failed'
    assert_equal @o15, @a[25], 'Out-of-range index/key assign failed'
    assert_equal 25, @o15.idx, 'Index/key replacement assign failed'
  end
end

class A_MutableKeysHATest < Test::Unit::TestCase
  
  class TestObj
    attr_accessor :key, :idx, :data
    
    def initialize key = nil, idx = nil, data = "Empty"
      @key = key; @idx = idx; @data = data 
    end
  end
  
  def setup
    @o1 = TestObj.new('key1')
    @o2 = TestObj.new('key2', 2, 'Data 2')
    @o3 = TestObj.new('key3', 3, 'Data 3')
    @o7 = TestObj.new('key7', 7, 'Data 7')
    
    @o10 = TestObj.new('key10', nil, 'Data 10')
    @o11 = TestObj.new('key11', nil, 'Data 11')
    @o12 = TestObj.new('key12', 12, 'Data 12')
    @o13 = TestObj.new(nil, nil, 'Data 13')
    @o14 = TestObj.new('double_key', nil, 'Data 14')
    @o15 = TestObj.new('key15', 15, 'Data 15')
    @o16 = TestObj.new('key16', 16, 'Data 16')
    
    @b = HashArray.new
    @a = HashArray[0, 1, 2, @o7, @o1, @o3, @o2]
    @hm = {:key2=>2, :key3=>3, :key7=>7, :key1=>8}
  end
  
  def test_create
    assert_equal [], HashArray.new, "Empty array creation failed"
    assert_equal [1,2,3,4,5], HashArray[1,2,3,4,5], "Literal array creation failed"
    assert_equal [1,1,1,1,1], HashArray.new(5,1), "Repeated array creation failed"
    assert_equal [0, 1, @o2, @o3, nil, nil, nil, @o7, @o1], @a, "Literal Object array creation failed"
  end
  
  def test_delete
    @a >> 1
    assert_nil @a[1], 'Deleted element not nil'
    @a >> @o1
    assert_nil @a[8], 'Deleted element not nil'
    assert_nil @a[:key1], 'Deleted element not nil'

    # Deleting element that is not in Array throws an exception
    assert_raise ArgumentError do @a >> @o11 end 
    assert_equal @a, @a << @o11 >> @o11, 'Round-trip adding and removing fails'
  end
  
  def test_access
    assert_equal @hm, @a.hashmap, "Hashmap matching failed"
    assert_nil @a[44], 'Out-of-range element not nil'
    assert_nil @a[nil], 'Nil index element not nil'
    assert_equal @o7, @a[7], 'Integer index access failed'
    assert_equal @o1, @a[-1], 'Negative integer index access failed'
    assert_equal @o3, @a['key3'], 'String index access failed'
    assert_equal [1, @o2, @o3, nil], @a[1..4], 'Range access failed'
    assert_equal [1, @o2, @o3], @a[1,3], 'Slice access failed'
  end
  
  def test_simple_assign
    @a[] = 'end'
    assert_equal 'end', @a[9], 'No-index assign failed'
    @a << 'more_end'
    assert_equal 'more_end', @a[10], 'Addition failed'
    
    @a[4] = 11
    assert_equal 11, @a[4], 'Index assign failed'
    @a[4] = 22
    assert_equal 22, @a[4], 'Index re-assign failed'
    
    @a['key'] = 33
    assert_equal 33, @a['key'], 'Key assign failed'
    assert_equal 33, @a[:key], 'Key assign failed'
    
    @a[5,'double_key'] = 'double'
    assert_equal 'double', @a['double_key'], 'Index/key assign failed'
    assert_equal 'double', @a[5], 'Index/key assign failed'
    
    @a[11] = 'replace'
    assert_nil @a['key'], 'Keyed value replacement failed'
    assert_nil @a.hashmap['key'], 'Keyed value replacement failed'
    
    @a['double_key'] = 'trouble'
    assert_equal 'trouble', @a['double_key'], 'Key reuse failed'
    assert_nil @a[5], 'Key reuse failed'
    
    @a[25,'out_key'] = 'outlier'
    assert_equal 'outlier', @a['out_key'], 'Out-of-range index/key assign failed'
    assert_equal 'outlier', @a[25], 'Out-of-range index/key assign failed'
  end
  
  def test_object_assign
    @a[] = @o11
    assert_equal @o11, @a[9], 'No-index assign failed'
    assert_equal @o11, @a['key11'], 'No-index assign failed'
    assert_equal 9, @a[9].idx, 'No-index assign failed'
    
    @a << @o10
    assert_equal @o10, @a[10], 'Addition failed'
    assert_equal @o10, @a['key10'], 'Addition failed'
    assert_equal 10, @a[10].idx, 'Addition failed'
    
    # Add to Array object that is already there
    @a[] = @o3
    assert_equal @o3, @a[3], 'Object reassign failed'
    assert_equal @o3, @a['key3'], 'Object reassign failed'
    assert_equal 3, @a[3].idx, 'Object reassign failed'
    
    # Assign object by index and replace element later
    @a[4] = @o12
    assert_equal @o12, @a[4], 'Index assign failed'
    assert_equal @o12, @a['key12'], 'Index assign failed'
    assert_equal 4, @a[4].idx, 'Index assign failed'
    @a[4] = 22
    assert_equal 22, @a[4], 'Index re-assign failed'
    assert_nil @a['key12'], 'Index re-assign failed'
    assert_nil @o12.idx, 'Index re-assign failed'
    assert_nil @o12.key, 'Index re-assign failed'
    
    # Assign object by key
    @a['key'] = @o12
    assert_equal @o12, @a['key'], 'Key assign failed'
    assert_equal :key, @o12.key, 'Key assign failed'
    assert_equal 11, @o12.idx, 'Key assign failed'
    
    # Assign object by index and key
    @a[5,'double_key'] = @o13
    assert_equal @o13, @a['double_key'], 'Index/key assign failed'
    assert_equal @o13, @a[5], 'Index/key assign failed'
    assert_equal :double_key, @o13.key, 'Index/key assign failed'
    assert_equal 5, @o13.idx, 'Index/key assign failed'
    
    # Replace object by index and key with another object (different key)
    @a[5,'new_key'] = @o2
    assert_equal @o2, @a['new_key'], 'Index/key replacement assign failed'
    assert_equal @o2, @a[5], 'Index/key replacement assign failed'
    assert_equal :new_key, @o2.key, 'Index/key replacement assign failed'
    assert_equal 5, @o2.idx, 'Index/key replacement assign failed'
    assert_nil @a['double_key'], 'Index/key replacement assign failed'
    assert_nil @o13.key, 'Index/key replacement assign failed'
    assert_nil @o13.idx, 'Index/key replacement assign failed'
    
    # Replace object by index and key with another object (same key)
    @a[5,'new_key'] = @o1
    assert_equal @o1, @a['new_key'], 'Index/key replacement assign failed'
    assert_equal @o1, @a[5], 'Index/key replacement assign failed'
    assert_equal :new_key, @o1.key, 'Index/key replacement assign failed'
    assert_equal 5, @o1.idx, 'Index/key replacement assign failed'
    assert_nil @o2.idx, 'Index/key replacement assign failed'
    assert_nil @o2.key, 'Index/key replacement assign failed'
    
    # Replace object by index (new object has different key)
    @a[5] = @o16
    assert_nil @a['new_key'], 'Keyed value replacement failed'
    assert_equal @o16, @a[5], 'Keyed value replacement failed'
    assert_nil @a.hashmap['new_key'], 'Keyed value replacement failed'
    assert_nil @o1.idx, 'Keyed value replacement failed'
    assert_nil @o1.key, 'Keyed value replacement failed'
    assert_equal :key16, @o16.key, 'Keyed value replacement failed' #old key value remains
    
    # Replace object by index (new object has same key)
    @a[5] = @o14
    assert_equal :double_key, @o14.key, 'Keyed value replacement failed'
    assert_nil @o13.key, 'Keyed value replacement failed' #old key value is deleted
    
    # Assign new key to element already in HashArray
    @a['double_key'] = @o2
    assert_equal @o2, @a['double_key'], 'Key reuse failed'
    assert_equal @o2, @a[2], 'Key reuse failed'
    assert_equal :double_key, @o2.key, 'Key reuse failed'
    assert_nil @a[5], 'Key reuse failed'
    
    # Assign to element beyond HashArray border
    @a[25,'out_key'] = @o15
    assert_equal @o15, @a['out_key'], 'Out-of-range index/key assign failed'
    assert_equal @o15, @a[25], 'Out-of-range index/key assign failed'
    assert_equal 25, @o15.idx, 'Index/key replacement assign failed'
    assert_equal :out_key, @o15.key, 'Index/key replacement assign failed'
  end
  
  def test_double_keys
    # Add new key to existing element
    @a[:new_key] = @o7
    assert_equal @o7, @a[7], 'Adding second key to element failed'
    assert_equal @o7, @a[:key7], 'Adding second key to element failed'
    assert_equal @o7, @a['new_key'], 'Adding second key to element failed'
    
    # Add existing key to new element
    @a[:key2] = @o10
    assert_equal @o10, @a[:key2], 'Adding second key to element failed'
    assert_nil @a[2], 'Adding second key to element failed'
    assert_nil @o2.key, 'Adding second key to element failed'
    
    # Add existing key to existing element (existing key belongs to element with multiple keys)
    @a[:new_key] = @o10
    assert_equal @o10, @a[:key2], 'Adding second key to element failed'
    assert_equal @o10, @a['new_key'], 'Adding second key to element failed'
    assert_nil @a[7], 'Adding second key to element failed'
    assert_nil @a[:key7], 'Adding second key to element failed'
    assert_nil @o7.key, 'Adding second key to element failed'
    
    # Add 3rd key to existing element
    @a[:third_key] = @o10
    assert_equal @o10, @a[:key2], 'Adding second key to element failed'
    assert_equal @o10, @a[:third_key], 'Adding second key to element failed'
    assert_equal @o10, @a['new_key'], 'Adding second key to element failed'
  end
  
end

class A_ReportHATest < Test::Unit::TestCase
  
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
    @p1 = Planet.new %w[9802 10483.56 10512.20 N-A4 2500.00 2349.00 2200.00 0.03 QAK 49.75 5214.30  2005.14  2300.00], {:race=>@av, :product=>@q}
    @p2 = Planet.new %w[7346 13906.25 17458.86 CYB 2500.00   0.07  0.00   3819.89], {}
    @p3 = Planet.new %w[7261  15768.34  11160.36], {}
    @f1 = Fleet.new %w[1  fgtr5  6  N-A4 -  0.00  112.50  In_Orbit], {:owner=>'ArVitallian'}
    @g1 = Group.new %w[0  1  MAPKEP 2.22   0.00   0.00  1.00 COL 0.03  N-A4 - 0.00 39.34 9.03  -  In_Orbit], 
    {:planet=>@p1, :race=>@av, :product=>@mark}
    @g2 = Group.new %w[6830 1170 QAK 13.00 0.00 9.99 0.00 - 0.00 N-A4 - 0.00 78.08 3.33  fgtr5 In_Orbit], 
    {:planet=>@p1, :race=>@av, :product=>@q, :fleet=>@f1}
    @races = HashArray.new
  end
  
  def test_ha_on_races
    @races << @av
    @races << @vd
    assert_equal @av, @races.first
    assert_equal @av, @races['ArVitallian']
    assert_equal @vd, @races[1]
    assert_equal @vd, @races['Vildok']
    @races << @vd       # Adding Vildok race AGAIN... should end up in the same position
    assert_equal @vd, @races[1]
    assert_equal @vd, @races['Vildok']
    assert_equal 2, @races.size
  end
end
