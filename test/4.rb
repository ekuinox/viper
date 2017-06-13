require '../analyzer.rb'
require 'pp'

FILE_PATH = '../samples/2.html'

reports = AnalyzeReport File.read(FILE_PATH, :encoding => Encoding::UTF_8)

pp reports
