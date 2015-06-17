require 'ducks/test'

module Ducks
    describe KnownClass do
        describe "#is_kind_of!" do
            it "refuses to overload the class" do
                assert_raises(KnownClass::OverloadingKnownTypeError) { KnownClass.new.is_kind_of!(Object) }
            end
            it "refuses to overload the modules" do
                assert_raises(KnownClass::OverloadingKnownTypeError) { KnownClass.new.is_kind_of!(Module.new) }
            end
            it "is a no-op when passing a superclass" do
                result = KnownClass.new(Object)
                result.is_kind_of!(BasicObject)
                assert_equal Object, result.kind_of_class
            end
            it "is a no-op when passing a module already included in #kind_of_class" do
                m0 = Module.new
                k  = Class.new { include m0 }
                result = KnownClass.new(k)
                result.is_kind_of!(m0)
                assert_equal k, result.kind_of_class
                assert_equal Set.new, result.kind_of_modules
            end
            it "is a no-op when passing a module already included in #kind_of_modules" do
                m0 = Module.new
                m1 = Module.new { include m0 }
                result = KnownClass.new(BasicObject, [m1])
                result.is_kind_of!(m0)
                assert_equal [m1].to_set, result.kind_of_modules
            end
        end
    end
end
