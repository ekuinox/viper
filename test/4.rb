require '../analyzer.rb'
require 'pp'

FILE_PATH = '../../http-receive-test/Trauminator <lm0xlemon@gmail.com>_1496763121853.html'

reports = AnalyzeReport File.read(FILE_PATH, :encoding => Encoding::UTF_8)

pp reports
