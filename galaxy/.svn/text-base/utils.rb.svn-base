
# Array extension that supports both Integer index and Hash-like 'key'
# Objects put into HashArray might respond to key, key=, idx, idx= methods
# Class Interfaces:
# a = HashArray.new; b = HashArray[1,2,3,4,5]; c = HashArray.new(15, 'blah') - Initialize array
# a[idx] = obj. Insert object (by idx). If obj responds to 'key' method, key is automatically created
# a[key] = obj. Insert object(by key). If obj responds to 'idx' method, it is placed at a[idx]
# a[idx, key] = obj. Insert object by both idx and key. Both key and idx are created, object updated using 'key=','idx=' methods
# a << obj; a[] = obj. Add object. If obj responds to 'key' method, key is automatically created. If obj responds to 'idx' method, it is placed at a[idx]
# a >> obj. Remove object from array and kill all keys pointing to it
# Multiple keys can be assigned to obj by repeatedly adding it to HashArray with different keys.
# Deleting object from HashArray deletes all key references to it
# All other Array methods are not redefined and therefore return simple Arrays, not HashArrays
# (for example, if you add two HashArrays, @hashmap values will be all wrong)

class HashArray < Array
  attr_reader :hashmap
  
  def HashArray.[] *args
    new args
  end
  
  def initialize *args
    @hashmap = {} # Hash map that holds key=>idx pairs
    super *args
    temp = self.map{|x| x}
    clear
    temp.each {|x| self << x}
  end
  
  def >> (obj)
    # Remove object by idx
    idx = obj.idx if obj.respond_to? :idx  # Assign idx from obj.idx if it is not given
    key = obj.key if obj.respond_to? :key  # Assign key from obj.key if it is not given
    key = key.to_sym if key and String === key #Transparently convert String keys into Symbols
    if idx and self[idx] and self[idx].eql? obj
      self[idx,nil]=nil
    elsif key and self[key] and self[key].eql? obj
      self[nil,key]=nil
    elsif idx = self.index(obj)    
      self[idx,nil]=nil
    else
      raise ArgumentError, "Unable to delete #{obj}"
    end
    self
  end #[]
  
  def [](*args)
    case args.size
      when 2 then super *args # [3,3] slice access
      when 1 then 
      case args[0]
        when Range then super args[0]
        when Integer then super args[0]
        when String then self[args[0].to_sym]
      else
        return nil unless @hashmap[args[0]]
        super @hashmap[args[0]] 
      end #case  
    else
      raise ArgumentError 
    end #case
  end #[]
  
  # Also with 3 arguments (key, idx, obj) and without arguments 
  def []=(*args)
    case args.size
      when 1 then self[nil,nil] = *args # Assign obj given its idx and key
      when 2 then
      keyidx, obj = args
      case keyidx
        when Range then raise IndexError # TODO Implement Range access operation
        when Integer then self[keyidx, nil] = obj
      else self[nil, keyidx] = obj #keyidx is not Integer or Range, consider it a key
      end #case
      
      when 3 # Assign obj to HashArray using given key and idx (main logics here)
      idx, key, obj = args
      idx ||= obj.idx if obj.respond_to? :idx  # Assign idx from obj.idx if it is not given
      key ||= obj.key if obj.respond_to? :key  # Assign key from obj.key if it is not given
      key = key.to_sym if String === key #Transparently convert String keys into Symbols
      
      #return self if self.include? obj and  # Is this object already in HashArray?
      return self[self.size,key]=obj unless idx or obj.nil? # If no idx, add new element at the end of HashArray
      
      old_obj = idx ? self[idx] : self[key]
      if obj.nil?
        old_obj.idx = nil if old_obj.respond_to? :idx=
        old_obj.key = nil if old_obj.respond_to? :key=
        @hashmap.reject! {|k,v| v == idx} # Delete all key references to this object from hashmap
      else
        self >> old_obj if old_obj and not old_obj.eql? obj # Another object uses this idx, remove previous object 
        self >> self[key] if self[key] and not self[key].eql? obj # Another object uses this key, remove previous object 
        @hashmap[key] = idx if key
        obj.idx = idx if obj.respond_to? :idx=
        obj.key = key if obj.respond_to? :key=
      end
      super(idx, obj)
    else
      raise ArgumentError 
    end #case    
  end
  
  def <<(obj)
    self[]=obj
    self
  end
end

