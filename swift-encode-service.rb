#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'daemons'

Daemons.run 'app.rb'