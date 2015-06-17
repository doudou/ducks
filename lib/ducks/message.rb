module Ducks
    # Representation of a callable structure (labmdas, methods, ...)
    class Message
        # The message name
        #
        # @return [Symbol]
        attr_reader :name

        # The receiver known type
        #
        # @return [Type]
        attr_reader :receiver

        # Description of the argument call
        #
        # @return [Signature]
        attr_reader :signature

        # Description of the return value
        attr_reader :return

        def self.empty
            new(nil, nil)
        end

        def initialize(name, receiver)
            @name = name
            @receiver = receiver
            @signature = Signature.new
            @return = Type.new
        end

        # The message's arity as returned by {Signature#arity}
        def minimal_positional_argument_count
            signature.minimal_positional_argument_count
        end

        # Whether this message has splats
        def has_splats?
            signature.has_splats?
        end

        def define_signature(*arguments, **named_arguments)
            @signature = Signature.new(*arguments, **named_arguments)
        end

        def pretty_print(pp)
            pp.text "#{name}("
            pp.nest(2) do
                pp.breakable
                sig.pretty_print(pp)
            end
            pp.breakable
            pp.text(")")
        end
    end
end

