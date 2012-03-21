#!/usr/bin/env ruby -w
require 'drb'

DRb.start_service

# attach to the DRb server via a URI given on the command line
remote_thing = DRbObject.new nil, ARGV.shift

remote_thing.restart