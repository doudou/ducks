require 'utilrb/module/attr_predicate'
require 'ducks/version'

require 'ducks/monkey'

require 'ducks/type'
require 'ducks/known_class'

require 'ducks/method'
require 'ducks/signature'
require 'ducks/callee'
require 'ducks/message'

require 'ducks/builtins'

require 'ducks/parsers/yarv_bytecode'

# The toplevel namespace for ducks
#
# You should describe the basic idea about ducks here
require 'utilrb/logger'
module Ducks
    extend Logger::Root('Ducks', Logger::WARN)
end

