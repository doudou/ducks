module Ducks
    class Callee < Signature
        # The type of arguments before a possible splat argument
        #
        # @return [Array<Type>]
        attr_reader :arguments_before_splat

        # The type of the splat arguments, or nil if there is no splat argument
        #
        # @return [Type,nil]
        attr_reader :splat

        # The type of arguments after a possible splat argument
        #
        # @return [Array<Type>]
        attr_reader :arguments_after_splat

        def initialize(*arguments, **named_arguments)
            super

            if arguments.count { |arg| arg.kind_of?(Splat) } > 1
                raise ArgumentError, "callees can only have one splat"
            end

            splat_index = arguments.find_index { |el| el.kind_of?(Splat) }
            if splat_index
                @arguments_before_splat = arguments[0, splat_index]
                @splat = arguments[splat_index].type
                @arguments_after_splat  = arguments[(splat_index + 1)..-1]
            else
                @arguments_before_splat = arguments
                @splat = nil
                @arguments_after_splat  = Array.new
            end
        end

        # Alias for {#has_splats?} given that Callees can have only one splat
        def has_splat?
            has_splats?
        end

        def match_non_splat_callee_signature_against_arguments(args, sequence)
            sequences = args.map { |a| [a, sequence.dup] }
            has_remaining_sequence = !sequence.empty?
            while has_remaining_sequence
                has_remaining_sequence = false

                new_sequences = []
                sequences.each do |args, seq|
                    if seq.empty?
                        new_sequences << [args, seq]
                    elsif (t = args.shift) && (range = t.match_sequence(seq))
                        range.each do |i|
                            shortened_seq = seq[i..-1]
                            has_remaining_sequence ||= !shortened_seq.empty?
                            new_sequences << [args.dup, shortened_seq]
                        end
                    end
                end
                sequences = new_sequences
            end
            if !sequences.empty?
                sequences.map(&:first)
            end
        end

        def valid_positional_arguments_for?(args, before_splat, after_splat)
            remaining_args = match_non_splat_callee_signature_against_arguments([args], before_splat)
            return if !remaining_args
            remaining_args = match_non_splat_callee_signature_against_arguments(
                remaining_args.map(&:reverse), after_splat.reverse)
            return if !remaining_args

            # At this stage, we have in 'remaining_args' all the possible
            # combination of arguments that the rest of the call's splats could
            # leave to our own splat
            if has_splat?
                remaining_args.any? do |arg|
                    arg.all? { |a| a.match_sequence([splat.type]) }
                end
            else
                remaining_args.any?(&:empty?)
            end
        end

        def valid_callee_for?(signature)
            valid_positional_arguments_for?(
                signature.positional_arguments,
                arguments_before_splat,
                arguments_after_splat)
        end
    end
end

