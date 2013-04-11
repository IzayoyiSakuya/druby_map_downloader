#!/usr/bin/env ruby -w

require 'rinda/ring'
require 'rinda/tuplespace'
require_relative 'netUtil'

DRb.start_service("druby://#{local_ip}:7647")

Rinda::RingServer.new(Rinda::TupleSpace.new)

DRb.thread.join
