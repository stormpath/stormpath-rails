Dir[File.join(File.dirname(__FILE__), "stormpath/**/*.rb")].sort.each {|f| require f}
