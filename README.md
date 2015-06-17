= Ducks: a type-inference library in duck-typed languages

The goal of this library is to do as much type inference in the constraints of a
duck-typed language.

The underlying assumption here is that one would not dynamically add/remove
methods during the *runtime* of the program, only do metaprogramming at loading
time. This means that one can infer class/module-to-method once the program is
loaded. The type inference engine then tries to infer a possible list of
class/modules that form the class of an object based on which messages this
object should respond to.

This fails for very small programs, but as soon as we're dealing with
decent-sized programs I hope it will become a completely different story.
