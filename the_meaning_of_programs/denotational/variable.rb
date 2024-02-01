require 'execjs'
require_relative '../syntax/variable'

class Variable
  def to_ruby
    "-> e { e[#{name.inspect}] }"
  end

  def to_javascript
    "function (e) { return e[#{JSON.dump(name)}]; }"
  end
end
