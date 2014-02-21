require 'rubygems' unless defined? Gem
require 'irbtools'
require 'hirb'
require "awesome_print"

FancyIrb.start :colorize => {
  :rocket_prompt => [:blue],
  :result_prompt => [:blue],
  :input_prompt  => nil,
  :irb_errors    => [:red],
  :stderr        => [:red, :bright],
  :stdout        => [:white],
  :input         => nil,
  :output        => true,
}

Hirb.enable
AwesomePrint.irb!
