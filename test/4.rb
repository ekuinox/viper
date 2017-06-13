require '../analyzer.rb'
require 'pp'

FILE_PATH = '../samples/2.html'

reports = AnalyzeReport File.read(FILE_PATH, :encoding => Encoding::UTF_8)

pp reports

'''
8 Resonators remaining on this Portal.
No remaining Resonators detected on this Portal.
'''

