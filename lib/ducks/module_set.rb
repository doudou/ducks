module Ducks
    class ModuleSet
        def ===(class_or_module)
            ancestry = class_or_module.ancestors.to_set
            ancestors[1..-1].all? { |o| ancestry.include?(o) }
        end
    end
end

