require 'json'
require_relative '../syntax/number'

class Number
  def to_ruby
    "-> e { #{value.inspect} }"
  end

  def to_javascript
    "function (e) { return #{JSON.dump(value)}; }"
  end
end
