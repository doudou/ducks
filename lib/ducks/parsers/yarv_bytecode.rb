module Ducks
    module Parsers
        class YARVBytecode
            class UnhandledOpFound < RuntimeError; end

            def parse_method(m)
                magic, major_version, minor_version, format_type,
                    misc, label, path, absolute_path, first_lineno,
                    type, locals, args, catch_table, bytecode = RubyVM::InstructionSequence.of(m).to_a

                local_variables = Hash.new

                all_args =
                    if args.respond_to?(:to_ary)
                        required_argc, *named_arguments, splat_index,
                            post_splat_argc, post_splat_index,
                            block_index, simple = *args

                        (1..required_argc).map { Type.new } +
                            [Type.new(Array)] +
                            (1..post_splat_argc).map { Type.new }
                    else
                        (1..args).map { Type.new }
                    end


                stack = Array.new
                bytecode.each do |op, *op_args|
                    case op
                    when Integer # Line number
                    when :putnil
                        stack.push Ducks::Builtins.Nil
                    when :trace
                    when :leave
                        break
                    when /^label_/
                    else
                        raise UnhandledOpFound, "#{self.class} does not know how to handle the #{op} RubyVM opcode (yet)"
                    end
                end

                m = Method.new(m.name)
                m.add_callee(Callee.new, stack.last)
                m
            end
        end
    end
end
