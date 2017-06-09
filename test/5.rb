require '../analyzer.rb'
require 'pp'

reports = AnalyzeReport File.read(ARGV[0], :encoding => Encoding::UTF_8)

pp reports
