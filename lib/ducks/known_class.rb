module Ducks
    class KnownClass < Type
        class OverloadingKnownTypeError < ArgumentError; end

        def is_kind_of!(obj)
            case obj
            when Class
                if !(kind_of_class <= obj)
                    raise OverloadingKnownTypeError, "#{self} is known to be exactly of class #{kind_of_class}, cannot overload to #{obj}"
                end
            when Module
                if kind_of_class <= obj
                    return dup
                elsif kind_of_modules.any? { |m| m <= obj }
                    return dup
                end
                raise OverloadingKnownTypeError, "#{self} is known to exactly include the modules #{kind_of_modules.map(&:name).join(",")}, cannot add #{obj}"
            else
                raise ArgumentError, "expected Class or Module, got #{obj}"
            end
        end
    end
end
