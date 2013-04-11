#!/usr/bin/env ruby -w

require 'rinda/ring'
require 'rinda/tuplespace'

DRb.start_service("druby://192.168.17.190:7647")

Rinda::RingServer.new(Rinda::TupleSpace.new)

DRb.thread.join
