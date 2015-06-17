require 'ducks/test'

module Ducks
    module Parsers
        describe YARVBytecode do
            attr_reader :parser
            before do
                @parser = YARVBytecode.new
            end

            def parse_method(name, &block)
                klass = Class.new { define_method(name, &block) }
                parser.parse_method(klass.instance_method(name))
            end

            it "handles an empty method" do
                result = parse_method(:empty) {}
                assert_equal [Ducks::Builtins.Nil], result.infer_return_types(Message.empty)
            end
        end
    end
end

