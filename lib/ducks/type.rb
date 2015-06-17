module Ducks
    # Information about a type
    class Type
        # Known class objects of this type must be kind of
        attr_reader :kind_of_class
        # Known modules objects of this type must be kind of
        attr_reader :kind_of_modules
        # The set of messages this has to respond to
        #
        # @return [Array<Message>]
        attr_reader :messages

        def initialize(klass = BasicObject, modules = Set.new)
            @kind_of_class   = klass
            @kind_of_modules = modules.to_set.dup
            @messages = Array.new
        end

        def self.any
            new
        end

        def kind_of_duck_type?(other_type)
            self.kind_of_class <= other_type.kind_of_class
        end

        def ==(other)
            kind_of_class == other.kind_of_class &&
                kind_of_modules = other.kind_of_modules &&
                messages = other.messages
        end

        # Tests whether all objects described by the argument are also described
        # by self
        #
        # @param [Type] other_type
        def contains?(other_type)
            if !(kind_of_class <= other_type.kind_of_class)
                return false
            end

            modules_included = other_type.kind_of_modules.all? do |m|
                kind_of_class <= m ||
                    kind_of_modules.any? { |self_m| self_m <= m }
            end
            if !modules_included
                return false
            end

            other_type.messages.all? do |m|
                responds_to_duck_message?(m)
            end
        end

        # Tests whether instances of this type would respond to the given
        # duck-typed call
        #
        # @param [Message] c
        # @return [Boolean]
        def responds_to_duck_message?(c)
            kind_of_class.responds_to_duck_message?(c) ||
                kind_of_modules.any? { |m| m.responds_to_duck_message?(c) } ||
                messages.any? { |self_c| self_c.contains?(c) }
        end

        class InconsistentTypes < ArgumentError; end

        # Returns a type whose objects must be kind of type *and* match self
        #
        # Use this method when an instruction creates an object whose type is
        # inferred from self. If the instruction modifies the object in-place,
        # use, {#is_kind_of} instead.
        #
        # @param [Class,Module] type
        # @return [Type]
        def is_kind_of(type)
            ret = dup
            ret.is_kind_of!(type)
            ret
        end

        # Add a class/module constraint to this type, in-place
        #
        # Use this method when an instruction constraints the type of an object
        # further. If the instruction creates an object whose type is inferred
        # from self, use {#is_kind_of} instead.
        #
        # @param [Class,Module] type
        # @return [Type]
        def is_kind_of!(new)
            case new
            when Class
                @kind_of_modules = kind_of_modules.find_all { |m| !(new <= m) }
                class_order = (kind_of_class <=> new)
                if !class_order
                    raise InconsistentTypes, "#{kind_of_class} and #{new} are unrelated"
                elsif class_order > 0
                    @kind_of_class = new
                end
            when Module
                if kind_of_class <= new
                    # Already included in the class
                    return
                end
                @kind_of_modules = kind_of_modules.find_all do |m|
                    if m <= new
                        # Already included in m
                        return
                    elsif new <= m
                        # m is included in new, it is redundant
                        false
                    else true
                    end
                end
                kind_of_modules << new
            else
                raise ArgumentError, "types can only be kind of Module or Class"
            end
            self
        end

        # Returns a new type based on self which, in addition, responds to the
        # given message
        #
        # @param [Symbol] the message name
        # @param [Object] arguments the message arguments
        # @param [Hash] named_arguments the message named arguments
        # @return [Type] the new type
        def responds_to(message, *arguments, **named_arguments)
            result = dup
            result.responds_to!(message, *arguments, **named_arguments)
            result
        end

        # Declares that objects of this type must respond to the given message signature
        #
        # @param [Symbol] the message name
        # @param [Object] arguments the message arguments
        # @param [Hash] named_arguments the message named arguments
        # @return [Message] the call that has been added to {#calls}
        def responds_to!(message, *arguments, **named_arguments)
            callable = Message.new(message, self)
            callable.define_signature(*arguments, **named_arguments)
            messages << callable
            callable
        end

        # Tests whether self is {kind_of?} the first argument of the given sequence
        #
        # It is either (1..1) or nil for such a single type
        #
        # @return [Range,nil]
        def match_sequence(sequence)
            if !sequence.empty? && kind_of_duck_type?(sequence.first)
                (1..1)
            end
        end

        def pretty_print(pp)
            pp.text "Ducks::Type(#{kind_of_class})"
            if !kind_of_modules.empty?
                pp.nest(2) do
                    pp.breakable
                    pp.text ".include(#{kind_of_modules.map(&:name).join(",")})"
                end
            end
            pp.nest(2) do
                pp.seplist(calls) do |call|
                    pp.breakable
                    pp.text ".respond_to("
                    pp.nest(2) do
                        call.pretty_print(pp)
                    end
                    pp.breakable
                    pp.text ")"
                end
            end
        end
    end
end

