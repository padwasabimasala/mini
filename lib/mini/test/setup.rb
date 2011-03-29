ENV['MINI_ENV'] = 'test'

require File.expand_path(File.join(File.dirname(__FILE__), '../../../config/env')) if !defined? MINI_ROOT
require 'test/unit'
