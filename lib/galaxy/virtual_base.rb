module ActiveRecord
  module VirtualBase
    
    def self.included(base)
      # 'base' is assumed to be ActiveRecord::Base
      base.extend(TablelessClassMethods)
      base.extend(VirtualClassMethods)
    end
    
    module VirtualClassMethods
      # Model class that invokes this macro becomes "virtual" - uses dataset instead of DB connection
      def virtual
        include ActiveRecord::VirtualBase::VirtualInstanceMethods
        include ActiveRecord::VirtualBase::YourMethods
        include Comparable
        
        # Should be part of a separate macro, but let's leave them here for now
        attr_accessor :idx # To keep track of Model position in container HashArray       
        @@dataset ||= nil
        
        #self.extend(VirtualMetaMethods)
      end
      
      def has_many_linked( association_id, options = {}, &extension )
        #puts "#{self} has_many_linked #{association_id} with options: #{options}"
        #Standard has_many_linked, add standard before and after callback methods
        
        owner_reference = if options[:foreign_key] then options[:foreign_key].split('_')[0] else self.name.downcase end
        
        add_method = "add_linked_#{association_id}".to_sym      
        define_method(add_method) do |association|
          #p association_id, association, self, owner_reference
          owner = association.send(owner_reference.to_sym)
          if owner != self
            # If association already has another current_owner, delete it it from current_owner's collection
            owner.send(association_id.to_sym).delete association if owner
            association.send( (owner_reference+'=').to_sym, self)
          end
        end 
        
        remove_method = "remove_linked_#{association_id}".to_sym      
        define_method(remove_method) do |association|
          owner = association.send(owner_reference.to_sym)
          raise ActiveRecordError if owner and owner != self # Something wrong, association is not pointing back to us 
          association.send( (owner_reference+'=').to_sym, nil)
        end
        
        before = if options[:before_add] then [options[:before_add], add_method] else add_method end
        after = if options[:after_remove] then [options[:after_remove], remove_method] else remove_method end
        has_many association_id, options.merge(:before_add => before, :after_remove => after), &extension
      end
      
      #TODO Add methods for work with data set (save!, delete!, find, find_all, etc...)
      
      # Establish dataset to run add/lookup/kill (redefined save/find/delete?) operations against
      def establish_dataset( dataset )
        #print 'Dataset established: ', dataset.name if dataset.respond_to? :name and dataset.name
        @@dataset = dataset
      end
      
      # Return dataset proper for add/lookup/kill operations
      def dataset
        @@dataset
      end
      
      # Lookup objects of this Class in the dataset - analog of find()
      def lookup(*args)
        return nil unless dataset # Dataset is not established, unable to lookup
        # options = args.extract_options!
        case args.first
          when :first then dataset.send(table_name.to_sym).find{|m| m}
          when :last  then dataset.send(table_name.to_sym).compact[-1]
          when :all   then dataset.send(table_name.to_sym).compact
        else dataset.send(table_name.to_sym)[*args]
        end
      end
      
      # Delete objects from the dataset - analog of delete()
      def kill(*args)
        obj = self.lookup(*args)
        case obj 
          when nil then false
          when Array then obj.each {|o| o.kill}
        else obj.kill  
        end 
      end
      
      # Pass through method that calls new (called on each found Section record)
      # Model should redefine this method for meaningful result (like Planets.new_or_update)
      def new_or_update *args
        new *args
      end
    end
    
    module VirtualInstanceMethods
      def add key = nil
        return false unless self.class.dataset
        self.class.dataset.send(self.class.table_name.to_sym) << self
        self.class.dataset.send(self.class.table_name.to_sym)[key] = self if key
        true
      end
      
      def kill
        return false unless self.class.dataset
        
        self.class.dataset.send(self.class.table_name.to_sym) >> self rescue false
      end
      
    end
    
    module YourMethods
      def your? ; race and race.your? end
      alias yours? your?
      alias controlled? your?
      alias my? your?
      alias me? your?
      alias mine? your?
    end  
    
    module TablelessClassMethods
      def tableless( options = {} )
        include ActiveRecord::VirtualBase::TablelessInstanceMethods
        
        self.extend(TablelessMetaMethods)
        
        #raise "No columns defined" unless options.has_key?(:columns) && !options[:columns].empty?
        for column_args in options[:columns]
          column( *column_args )
        end
      end
    end
    
    module TablelessMetaMethods
      def columns()
        @columns ||= []
      end
      
      def column(name, sql_type = nil, default = nil, null = true)
        columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
        reset_column_information
      end
      
      # Do not reset @columns
      def reset_column_information
        generated_methods.each { |name| undef_method(name) }
        @column_names = @columns_hash = @content_columns = @dynamic_methods_hash = @read_methods = nil
      end
    end
    
    module TablelessInstanceMethods
      def create_or_update
        errors.empty?
      end
      
      def saved!(with_id = 1)
        self.id = with_id
        
        def self.new_record?
          false
        end
      end
      alias_method :exists!, :saved!
    end
  end 
end