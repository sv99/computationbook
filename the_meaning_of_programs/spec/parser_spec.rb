require_relative 'spec_helper'
require_relative '../parser'
require_relative '../syntax'

describe 'the Simple parser' do
  describe 'expressions' do
    describe 'numbers' do
      specify { expect('0').to parse_as Number.new(0) }
      specify { expect('42').to parse_as Number.new(42) }
    end

    describe 'booleans' do
      specify { expect('true').to parse_as Boolean.new(true) }
      specify { expect('false').to parse_as Boolean.new(false) }
    end

    describe 'variables' do
      specify { expect('x').to parse_as Variable.new(:x) }
      specify { expect('y').to parse_as Variable.new(:y) }
      specify { expect('trueness').to parse_as Variable.new(:trueness) }
      specify { expect('falsehood').to parse_as Variable.new(:falsehood) }
    end

    describe 'brackets' do
      specify { expect('(((42)))').to parse_as Number.new(42) }
    end

    describe 'less than' do
      specify { expect('x < 5').to parse_as LessThan.new(Variable.new(:x), Number.new(5)) }
    end

    describe 'multiplication' do
      specify { expect('1 * 2').to parse_as Multiply.new(Number.new(1), Number.new(2)) }
      specify { expect('1 * 2 * 3').to parse_as Multiply.new(Number.new(1), Multiply.new(Number.new(2), Number.new(3))) }
      specify { expect('(1 * 2) * 3').to parse_as Multiply.new(Multiply.new(Number.new(1), Number.new(2)), Number.new(3)) }
    end

    describe 'addition' do
      specify { expect('1 + 2').to parse_as Add.new(Number.new(1), Number.new(2)) }
      specify { expect('1 + 2 + 3').to parse_as Add.new(Number.new(1), Add.new(Number.new(2), Number.new(3))) }
      specify { expect('(1 + 2) + 3').to parse_as Add.new(Add.new(Number.new(1), Number.new(2)), Number.new(3)) }
    end

    describe 'operator precedence' do
      specify { expect('1 + 2 < 3').to parse_as LessThan.new(Add.new(Number.new(1), Number.new(2)), Number.new(3)) }
      specify { expect('1 + (2 < 3)').to parse_as Add.new(Number.new(1), LessThan.new(Number.new(2), Number.new(3))) }
      specify { expect('1 < 2 + 3').to parse_as LessThan.new(Number.new(1), Add.new(Number.new(2), Number.new(3))) }
      specify { expect('(1 < 2) + 3').to parse_as Add.new(LessThan.new(Number.new(1), Number.new(2)), Number.new(3)) }
      specify { expect('1 + 2 * 3').to parse_as Add.new(Number.new(1), Multiply.new(Number.new(2), Number.new(3))) }
      specify { expect('1 + 2 < 3 * 4').to parse_as LessThan.new(Add.new(Number.new(1), Number.new(2)), Multiply.new(Number.new(3), Number.new(4))) }
      specify { expect('(1 + 2) * 3').to parse_as Multiply.new(Add.new(Number.new(1), Number.new(2)), Number.new(3)) }
      specify { expect('1 * 2 + 3').to parse_as Add.new(Multiply.new(Number.new(1), Number.new(2)), Number.new(3)) }
      specify { expect('1 * (2 + 3)').to parse_as Multiply.new(Number.new(1), Add.new(Number.new(2), Number.new(3))) }
    end
  end

  describe 'statements' do
    describe 'assignment' do
      specify { expect('x = 42').to parse_as Assign.new(:x, Number.new(42)) }
      specify { expect('y = 6 * 7').to parse_as Assign.new(:y, Multiply.new(Number.new(6), Number.new(7))) }
    end

    describe 'conditional' do
      specify { expect('if (x < 42) { x = 6 } else { x = 7 }').to parse_as If.new(LessThan.new(Variable.new(:x), Number.new(42)), Assign.new(:x, Number.new(6)), Assign.new(:x, Number.new(7))) }
      specify { expect('if (true) { x = 6 } else { x = 7 }').to parse_as If.new(Boolean.new(true), Assign.new(:x, Number.new(6)), Assign.new(:x, Number.new(7))) }
    end

    describe 'while' do
      specify { expect('while (x < 5) { x = x * 3 }').to parse_as While.new(LessThan.new(Variable.new(:x), Number.new(5)), Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3)))) }
    end

    describe 'doing nothing' do
      specify { expect('do-nothing').to parse_as DoNothing.new }
    end

    describe 'sequence' do
      specify { expect('do-nothing; do-nothing').to parse_as Sequence.new(DoNothing.new(), DoNothing.new()) }
      specify { expect('x = 6; y = 7; z = x * y').to parse_as Sequence.new(Assign.new(:x, Number.new(6)), Sequence.new(Assign.new(:y, Number.new(7)), Assign.new(:z, Multiply.new(Variable.new(:x), Variable.new(:y))))) }
    end
  end
end
