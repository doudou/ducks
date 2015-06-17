module Ducks
    module Monkey
        module Module
            # Tests whether an object that includes this module can respond to
            # the given {Message}
            def responds_to_duck_message?(c)
                method_defined?(c.name)
            end
        end
    end
end

Module.include Ducks::Monkey::Module



