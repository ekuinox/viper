# viper
Gmailに飛ばされてくるIngress Damage Reportを適当に解析するよ．

## Usage

```ruby
require './analyzer.rb'
require 'pp'

reports = AnalyzeReport File.read('./samples/0.html', :encoding => Encoding::UTF_8)

pp reports

```

**Gmailから引っ張ってきたピュア（？）なReportしか通せません．**

整形などされると，死にます．