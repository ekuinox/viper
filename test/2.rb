require '../analyzer.rb'
require 'pp'
require 'json'

FILE_PATH = '../samples/1.html'

reports = AnalyzeReport File.read(FILE_PATH, :encoding => Encoding::UTF_8)

json = JSON.generate reports

r = JSON.parse json

pp r["reports"]