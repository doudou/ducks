module Ducks
    # Information about the program that is being processed
    class Program
        # A mapping from method names to the corresponding Transform objects
        attr_reader :method_names_to_modules
        # A mapping from method matchers to the corresponding Transform objects.
        # This is separated from {#method_names_to_transforms} for performance
        # reasons (the former can just do a Hash lookup)
        attr_reader :method_matchers_to_modules
    end
end
