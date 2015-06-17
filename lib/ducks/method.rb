module Ducks
    class Method
        # The method name
        #
        # @return [Symbol]
        attr_reader :name
        # The set of signatures this method can respond to, asociated with the
        # corresponding return type
        #
        # @return [Array<(Signature,Type)>]
        attr_reader :signatures

        def initialize(name)
            @name = name
            @signatures = []
        end

        def add_callee(signature, return_type)
            signatures << [signature, return_type]
        end

        # Returns the set of possible return types this method can give for a
        # given message
        #
        # @param [Message] the message call
        # @return [Array<Type>]
        def infer_return_types(message)
            types = Array.new
            signatures.each do |s, t|
                if s.valid_callee_for?(message.signature)
                    types << t
                end
            end
            types
        end
    end
end

