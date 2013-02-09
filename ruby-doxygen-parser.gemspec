Gem::Specification.new do |s|
  s.name        = 'ruby-doxygen-parser'
  s.version     = '0.9'
  s.date        = '2013-02-06'
  s.summary     = "Ruby library that uses Doxygen XML output to parse and query C++ header files"
  s.description = "Ruby library that uses Doxygen XML output to parse and query C++ header files"
  s.authors     = ["David Fuenmayor"]
  s.email       = 'melodiac_mind@hotmail.com'
  
  patterns = [
    'README.md',
    'lib/**/*.rb',
  ]
  s.files = patterns.map {|p| Dir.glob(p) }.flatten
  s.homepage    =
    'https://github.com/davfuenmayor/ruby-doxygen-parser'
    
  s.test_files = Dir.glob('spec/**/*.rb')

  s.require_paths = ['lib']
end
