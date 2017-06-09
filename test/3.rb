require '../analyzer.rb'
require 'pp'

#
#   多分対応できました
#

FILE_PATH = '../samples/2.html'

result = AnalyzeReport File.read(FILE_PATH, :encoding => Encoding::UTF_8)

pp result[:reports]
pp result[:reports].length
pp result[:agent]
