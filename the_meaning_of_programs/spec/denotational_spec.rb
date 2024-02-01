require_relative 'spec_helper'
require_relative '../denotational'

describe 'the denotational semantics of Simple' do
  describe 'expressions' do
    describe 'a variable' do
      subject { Variable.new(:x) }
      let(:value) { 42 }
      let(:environment) { { x: value } }

      it { should be_denoted_by_ruby '-> e { e[:x] }' }
      it { should mean_ruby(value).within(environment) }

      it { should be_denoted_by_javascript 'function (e) { return e["x"]; }' }
      it { should mean_javascript(value).within(environment) }
    end

    describe 'a number' do
      subject { Number.new(42) }

      it { should be_denoted_by_ruby '-> e { 42 }' }
      it { should mean_ruby 42 }

      it { should be_denoted_by_javascript 'function (e) { return 42; }' }
      it { should mean_javascript 42 }
    end

    describe 'booleans' do
      describe 'true' do
        subject { Boolean.new(true) }

        it { should be_denoted_by_ruby '-> e { true }' }
        it { should mean_ruby true }

        it { should be_denoted_by_javascript 'function (e) { return true; }' }
        it { should mean_javascript true }
      end

      describe 'false' do
        subject { Boolean.new(false) }

        it { should be_denoted_by_ruby '-> e { false }' }
        it { should mean_ruby false }

        it { should be_denoted_by_javascript 'function (e) { return false; }' }
        it { should mean_javascript false }
      end
    end

    describe 'addition' do
      context 'without reducible subexpressions' do
        subject { Add.new(Number.new(1), Number.new(2)) }

        it { should be_denoted_by_ruby '-> e { (-> e { 1 }).call(e) + (-> e { 2 }).call(e) }' }
        it { should mean_ruby 3 }

        it { should be_denoted_by_javascript 'function (e) { return (function (e) { return 1; }(e)) + (function (e) { return 2; }(e)); }' }
        it { should mean_javascript 3 }
      end

      context 'with a reducible subexpression' do
        context 'on the left' do
          subject { Add.new(Add.new(Number.new(1), Number.new(2)), Number.new(3)) }

          it { should be_denoted_by_ruby '-> e { (-> e { (-> e { 1 }).call(e) + (-> e { 2 }).call(e) }).call(e) + (-> e { 3 }).call(e) }' }
          it { should mean_ruby 6 }

          it { should be_denoted_by_javascript 'function (e) { return (function (e) { return (function (e) { return 1; }(e)) + (function (e) { return 2; }(e)); }(e)) + (function (e) { return 3; }(e)); }' }
          it { should mean_javascript 6 }
        end

        context 'on the right' do
          subject { Add.new(Number.new(1), Add.new(Number.new(2), Number.new(3))) }

          it { should be_denoted_by_ruby '-> e { (-> e { 1 }).call(e) + (-> e { (-> e { 2 }).call(e) + (-> e { 3 }).call(e) }).call(e) }' }
          it { should mean_ruby 6 }

          it { should be_denoted_by_javascript 'function (e) { return (function (e) { return 1; }(e)) + (function (e) { return (function (e) { return 2; }(e)) + (function (e) { return 3; }(e)); }(e)); }' }
          it { should mean_javascript 6 }
        end

        context 'on both sides' do
          subject { Add.new(Add.new(Number.new(1), Number.new(2)), Add.new(Number.new(3), Number.new(4))) }

          it { should be_denoted_by_ruby '-> e { (-> e { (-> e { 1 }).call(e) + (-> e { 2 }).call(e) }).call(e) + (-> e { (-> e { 3 }).call(e) + (-> e { 4 }).call(e) }).call(e) }' }
          it { should mean_ruby 10 }

          it { should be_denoted_by_javascript 'function (e) { return (function (e) { return (function (e) { return 1; }(e)) + (function (e) { return 2; }(e)); }(e)) + (function (e) { return (function (e) { return 3; }(e)) + (function (e) { return 4; }(e)); }(e)); }' }
          it { should mean_javascript 10 }
        end
      end
    end

    describe 'multiplication' do
      context 'without reducible subexpressions' do
        subject { Multiply.new(Number.new(2), Number.new(3)) }

        it { should be_denoted_by_ruby '-> e { (-> e { 2 }).call(e) * (-> e { 3 }).call(e) }' }
        it { should mean_ruby 6 }

        it { should be_denoted_by_javascript 'function (e) { return (function (e) { return 2; }(e)) * (function (e) { return 3; }(e)); }' }
        it { should mean_javascript 6 }
      end

      context 'with a reducible subexpression' do
        context 'on the left' do
          subject { Multiply.new(Multiply.new(Number.new(2), Number.new(3)), Number.new(4)) }

          it { should be_denoted_by_ruby '-> e { (-> e { (-> e { 2 }).call(e) * (-> e { 3 }).call(e) }).call(e) * (-> e { 4 }).call(e) }' }
          it { should mean_ruby 24 }

          it { should be_denoted_by_javascript 'function (e) { return (function (e) { return (function (e) { return 2; }(e)) * (function (e) { return 3; }(e)); }(e)) * (function (e) { return 4; }(e)); }' }
          it { should mean_javascript 24 }
        end

        context 'on the right' do
          subject { Multiply.new(Number.new(2), Multiply.new(Number.new(3), Number.new(4))) }

          it { should be_denoted_by_ruby '-> e { (-> e { 2 }).call(e) * (-> e { (-> e { 3 }).call(e) * (-> e { 4 }).call(e) }).call(e) }' }
          it { should mean_ruby 24 }

          it { should be_denoted_by_javascript 'function (e) { return (function (e) { return 2; }(e)) * (function (e) { return (function (e) { return 3; }(e)) * (function (e) { return 4; }(e)); }(e)); }' }
          it { should mean_javascript 24 }
        end

        context 'on both sides' do
          subject { Multiply.new(Multiply.new(Number.new(2), Number.new(3)), Multiply.new(Number.new(4), Number.new(5))) }

          it { should be_denoted_by_ruby '-> e { (-> e { (-> e { 2 }).call(e) * (-> e { 3 }).call(e) }).call(e) * (-> e { (-> e { 4 }).call(e) * (-> e { 5 }).call(e) }).call(e) }' }
          it { should mean_ruby 120 }

          it { should be_denoted_by_javascript 'function (e) { return (function (e) { return (function (e) { return 2; }(e)) * (function (e) { return 3; }(e)); }(e)) * (function (e) { return (function (e) { return 4; }(e)) * (function (e) { return 5; }(e)); }(e)); }' }
          it { should mean_javascript 120 }
        end
      end
    end

    describe 'less than' do
      context 'without reducible subexpressions' do
        subject { LessThan.new(Number.new(1), Number.new(2)) }

        it { should be_denoted_by_ruby '-> e { (-> e { 1 }).call(e) < (-> e { 2 }).call(e) }' }
        it { should mean_ruby true }

        it { should be_denoted_by_javascript 'function (e) { return (function (e) { return 1; }(e)) < (function (e) { return 2; }(e)); }' }
        it { should mean_javascript true }
      end

      context 'with a reducible subexpression' do
        context 'on the left' do
          subject { LessThan.new(Add.new(Number.new(2), Number.new(3)), Number.new(4)) }

          it { should be_denoted_by_ruby '-> e { (-> e { (-> e { 2 }).call(e) + (-> e { 3 }).call(e) }).call(e) < (-> e { 4 }).call(e) }' }
          it { should mean_ruby false }

          it { should be_denoted_by_javascript 'function (e) { return (function (e) { return (function (e) { return 2; }(e)) + (function (e) { return 3; }(e)); }(e)) < (function (e) { return 4; }(e)); }' }
          it { should mean_javascript false }
        end

        context 'on the right' do
          subject { LessThan.new(Number.new(1), Add.new(Number.new(2), Number.new(3))) }

          it { should be_denoted_by_ruby '-> e { (-> e { 1 }).call(e) < (-> e { (-> e { 2 }).call(e) + (-> e { 3 }).call(e) }).call(e) }' }
          it { should mean_ruby true }

          it { should be_denoted_by_javascript 'function (e) { return (function (e) { return 1; }(e)) < (function (e) { return (function (e) { return 2; }(e)) + (function (e) { return 3; }(e)); }(e)); }' }
          it { should mean_javascript true }
        end

        context 'on both sides' do
          subject { LessThan.new(Add.new(Number.new(1), Number.new(5)), Multiply.new(Number.new(2), Number.new(3))) }

          it { should be_denoted_by_ruby '-> e { (-> e { (-> e { 1 }).call(e) + (-> e { 5 }).call(e) }).call(e) < (-> e { (-> e { 2 }).call(e) * (-> e { 3 }).call(e) }).call(e) }' }
          it { should mean_ruby false }

          it { should be_denoted_by_javascript 'function (e) { return (function (e) { return (function (e) { return 1; }(e)) + (function (e) { return 5; }(e)); }(e)) < (function (e) { return (function (e) { return 2; }(e)) * (function (e) { return 3; }(e)); }(e)); }' }
          it { should mean_javascript false }
        end
      end
    end
  end

  describe 'statements' do
    describe 'do-nothing' do
      subject { DoNothing.new }
      let(:environment) { { x: 42 } }

      it { should be_denoted_by_ruby '-> e { e }' }
      it { should mean_ruby(environment).within(environment) }

      it { should be_denoted_by_javascript 'function (e) { return e; }' }
      it { should mean_javascript(environment).within(environment) }
    end

    describe 'assignment' do
      let(:environment) { { x: 1, y: 2 } }

      context 'without a reducible subexpression' do
        subject { Assign.new(:x, Number.new(5)) }

        it { should be_denoted_by_ruby '-> e { e.merge({ :x => (-> e { 5 }).call(e) }) }' }
        it { should mean_ruby(x: 5, y: 2).within(environment) }

        it { should be_denoted_by_javascript 'function (e) { e["x"] = (function (e) { return 5; }(e)); return e; }' }
        it { should mean_javascript(x: 5, y: 2).within(environment) }
      end

      context 'with a reducible subexpression' do
        subject { Assign.new(:x, Add.new(Number.new(2), Number.new(3))) }

        it { should be_denoted_by_ruby '-> e { e.merge({ :x => (-> e { (-> e { 2 }).call(e) + (-> e { 3 }).call(e) }).call(e) }) }' }
        it { should mean_ruby(x: 5, y: 2).within(environment) }

        it { should be_denoted_by_javascript 'function (e) { e["x"] = (function (e) { return (function (e) { return 2; }(e)) + (function (e) { return 3; }(e)); }(e)); return e; }' }
        it { should mean_javascript(x: 5, y: 2).within(environment) }
      end
    end

    describe 'sequence' do
      let(:environment) { { y: 3 } }

      context 'without reducible substatements' do
        subject { Sequence.new(DoNothing.new, DoNothing.new) }

        it { should be_denoted_by_ruby '-> e { (-> e { e }).call((-> e { e }).call(e)) }' }
        it { should mean_ruby(environment).within(environment) }

        it { should be_denoted_by_javascript 'function (e) { return (function (e) { return e; }(function (e) { return e; }(e))); }' }
        it { should mean_javascript(environment).within(environment) }
      end

      context 'with a reducible substatement' do
        context 'in first position' do
          subject { Sequence.new(Assign.new(:x, Number.new(1)), DoNothing.new) }

          it { should be_denoted_by_ruby '-> e { (-> e { e }).call((-> e { e.merge({ :x => (-> e { 1 }).call(e) }) }).call(e)) }' }
          it { should mean_ruby(x: 1, y: 3).within(environment) }

          it { should be_denoted_by_javascript 'function (e) { return (function (e) { return e; }(function (e) { e["x"] = (function (e) { return 1; }(e)); return e; }(e))); }' }
          it { should mean_javascript(x: 1, y: 3).within(environment) }
        end

        context 'in second position' do
          subject { Sequence.new(DoNothing.new, Assign.new(:x, Number.new(2))) }

          it { should be_denoted_by_ruby '-> e { (-> e { e.merge({ :x => (-> e { 2 }).call(e) }) }).call((-> e { e }).call(e)) }' }
          it { should mean_ruby(x: 2, y: 3).within(environment) }

          it { should be_denoted_by_javascript 'function (e) { return (function (e) { e["x"] = (function (e) { return 2; }(e)); return e; }(function (e) { return e; }(e))); }' }
          it { should mean_javascript(x: 2, y: 3).within(environment) }
        end

        context 'in both positions' do
          subject { Sequence.new(Assign.new(:x, Number.new(1)), Assign.new(:x, Number.new(2))) }

          it { should be_denoted_by_ruby '-> e { (-> e { e.merge({ :x => (-> e { 2 }).call(e) }) }).call((-> e { e.merge({ :x => (-> e { 1 }).call(e) }) }).call(e)) }' }
          it { should mean_ruby(x: 2, y: 3).within(environment) }

          it { should be_denoted_by_javascript 'function (e) { return (function (e) { e["x"] = (function (e) { return 2; }(e)); return e; }(function (e) { e["x"] = (function (e) { return 1; }(e)); return e; }(e))); }' }
          it { should mean_javascript(x: 2, y: 3).within(environment) }
        end
      end
    end

    describe 'if' do
      let(:environment) { { x: 1, y: 2 } }

      context 'without a reducible subexpression' do
        subject { If.new(Boolean.new(false), Assign.new(:x, Number.new(3)), Assign.new(:y, Number.new(3))) }

        it { should be_denoted_by_ruby '-> e { if (-> e { false }).call(e) then (-> e { e.merge({ :x => (-> e { 3 }).call(e) }) }).call(e) else (-> e { e.merge({ :y => (-> e { 3 }).call(e) }) }).call(e) end }' }
        it { should mean_ruby(x: 1, y: 3).within(environment) }

        it { should be_denoted_by_javascript 'function (e) { if (function (e) { return false; }(e)) { return (function (e) { e["x"] = (function (e) { return 3; }(e)); return e; }(e)); } else { return (function (e) { e["y"] = (function (e) { return 3; }(e)); return e; }(e)); } }' }
        it { should mean_javascript(x: 1, y: 3).within(environment) }
      end

      context 'with a reducible subexpression' do
        subject { If.new(LessThan.new(Number.new(3), Number.new(4)), Assign.new(:x, Number.new(3)), Assign.new(:y, Number.new(3))) }

        it { should be_denoted_by_ruby '-> e { if (-> e { (-> e { 3 }).call(e) < (-> e { 4 }).call(e) }).call(e) then (-> e { e.merge({ :x => (-> e { 3 }).call(e) }) }).call(e) else (-> e { e.merge({ :y => (-> e { 3 }).call(e) }) }).call(e) end }' }
        it { should mean_ruby(x: 3, y: 2).within(environment) }

        it { should be_denoted_by_javascript 'function (e) { if (function (e) { return (function (e) { return 3; }(e)) < (function (e) { return 4; }(e)); }(e)) { return (function (e) { e["x"] = (function (e) { return 3; }(e)); return e; }(e)); } else { return (function (e) { e["y"] = (function (e) { return 3; }(e)); return e; }(e)); } }' }
        it { should mean_javascript(x: 3, y: 2).within(environment) }
      end
    end

    describe 'while' do
      subject { While.new(LessThan.new(Variable.new(:x), Number.new(5)), Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3)))) }
      let(:environment) { { x: 1 } }

      it { should be_denoted_by_ruby '-> e { while (-> e { (-> e { e[:x] }).call(e) < (-> e { 5 }).call(e) }).call(e); e = (-> e { e.merge({ :x => (-> e { (-> e { e[:x] }).call(e) * (-> e { 3 }).call(e) }).call(e) }) }).call(e); end; e }' }
      it { should mean_ruby(x: 9).within(environment) }

      it { should be_denoted_by_javascript 'function (e) { while (function (e) { return (function (e) { return e["x"]; }(e)) < (function (e) { return 5; }(e)); }(e)) { e = (function (e) { e["x"] = (function (e) { return (function (e) { return e["x"]; }(e)) * (function (e) { return 3; }(e)); }(e)); return e; }(e)); } return e; }' }
      it { should mean_javascript(x: 9).within(environment) }
    end
  end
end
