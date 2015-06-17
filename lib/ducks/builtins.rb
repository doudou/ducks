module Ducks
    module Builtins
        def self.False
            KnownClass.new(FalseClass)
        end
        def self.True
            KnownClass.new(TrueClass)
        end
        def self.Nil
            KnownClass.new(NilClass)
        end
    end
end

