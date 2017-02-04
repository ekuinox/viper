#!/usr/bin/ruby
require './AnalyzeReport.rb'
require 'pp'

r = AnalyzeReport.new(File.read('./samples/' + Readline.readline("sample number: ", true) + '.html'))

result = r.get_all

pp result