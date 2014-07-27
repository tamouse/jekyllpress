require 'thor'
require "jekyllpress/version"

module Jekyllpress

  class App < Thor
    include Thor::Actions
    package_name 'Jekyllpress::App'
    map ["-V","--version"] => :version

    desc "version", "Display Jekyllpress::App version string"
    long_desc <<-EOT
    Display the version string for Jekyllpress::App on the output.

    In addition to the thor action, you can use -V or --version on the command line:

    jekyllpress -V

    jekyllpress --version

EOT
    def version
      say "Jekyllpress Version: #{Jekyllpress::VERSION}"
      Jekyllpress::VERSION
    end

    desc "new_post TITLE", "Create a new posts with title TITLE"
    def new_post(title="")
      
    end

    
  end


end
