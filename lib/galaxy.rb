# Used to auto-require all the source files located in lib/...
def self.require_libs( filename, filemask )
  file = ::File.expand_path(::File.join(::File.dirname(filename), filemask.gsub(/(?<!.rb)$/,'.rb')))
  require file if File.exist?(file) && !File.directory?(file)
  Dir.glob(file).sort.each {|rb| require rb}
end

%W[galaxy/virtual_base galaxy/models/models galaxy/*].each {|rb| require_libs(__FILE__, rb)}
