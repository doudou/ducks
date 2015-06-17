module Ducks
    class TypeUnion
        attr_reader :types

        def initialize
            @types = Array.new
        end

        def <<(t)
            types << t
        end
    end
end
