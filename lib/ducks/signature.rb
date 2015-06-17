module Ducks
    # Instance of a single message call
    class Signature
        Splat = Struct.new :type do
            def match_sequence(seq)
                seq.each_with_index do |t, i|
                    if !type.kind_of_duck_type?(t)
                        return (0..i)
                    end
                end
                (0..seq.size)
            end
        end

        # The list of positional arguments
        #
        # Splats are represented by a {Splat} object
        #
        # @return [Array<Type,Splat>]
        attr_reader :positional_arguments

        # The type of named arguments
        #
        # @return [Hash<TypeSet>]
        attr_reader :named_arguments

        # The type of a catch-all named argument
        #
        # @return [Hash<Type>]
        attr_reader :catchall_named_arguments

        # The minimal number of arguments this signature represents
        attr_reader :minimal_positional_argument_count

        # Whether the signature has positional splats
        attr_predicate :has_splats?

        def initialize(*arguments, **named_arguments)
            @positional_arguments = arguments
            splats = arguments.find_all { |arg| arg.kind_of?(Splat) }
            @minimal_positional_argument_count = arguments.size - splats.size
            @has_splats = !splats.empty?

            @named_arguments = named_arguments
            @catchall_named_arguments = Type.new(Hash)
        end

        def pretty_print(pp)
            pp.seplist(arguments) do |arg|
                pp.breakable
                arg.pretty_print(pp)
            end
            pp.seplist(catchall_arguments) do |arg|
                pp.breakable
                pp.text "["
                arg.pretty_print(pp)
                pp.text "]"
            end
            if catchall_remaining_arguments
                if catchall_size.min > catchall_arguments.size
                    pp.breakable
                    catchall_remaining_arguments.pretty_print(pp)
                end
            end
            pp.seplist(named_arguments) do |arg|
                pp.breakable
                name, arg = *arg
                pp.text "#{name}: "
                arg.pretty_print(pp)
            end
            pp.seplist(catchall_named_arguments) do |arg|
                pp.breakable
                name, arg = *arg
                pp.text "[#{name}: "
                arg.pretty_print(pp)
                pp.text "]"
            end
            if catchall_remaining_arguments
                if catchall_named_size.min > catchall_named_arguments.size
                    pp.breakable
                    catchall_remaining_named_arguments.pretty_print(pp)
                end
            end
        end
    end
end
