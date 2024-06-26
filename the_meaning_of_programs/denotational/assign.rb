require 'json'
require_relative '../syntax/assign'

class Assign
  def to_ruby
    "-> e { e.merge({ #{name.inspect} => (#{expression.to_ruby}).call(e) }) }"
  end

  def to_javascript
    "function (e) { e[#{JSON.dump(name)}] = (#{expression.to_javascript}(e)); return e; }"
  end
end
