require 'ducks/test'
module Ducks
    describe Type do
        describe "#contains?" do
            describe "type resolved to only a class" do
                it "returns false if its class is not contained in self" do
                    assert !Type.new(Class.new).contains?(Type.new(Class.new))
                end
                it "returns true if its class equals the one from self" do
                    k = Class.new
                    assert Type.new(k).contains?(Type.new(k))
                end
                it "returns true if its class is a superclass of the one from self" do
                    k0 = Class.new
                    k1 = Class.new(k0)
                    assert Type.new(k1).contains?(Type.new(k0))
                end
            end

            describe "type resolved to a class and a list of modules" do
                attr_reader :subject, :test

                before do
                    @subject = Type.new
                    @test    = Type.new
                end

                it "returns false if the modules are disjoint" do
                    subject.is_kind_of!(Module.new)
                    test.is_kind_of!(Module.new)
                    assert !subject.contains?(test)
                end
                it "returns true if all modules of the arguments are included in the class of the receiver" do
                    m = Module.new
                    k = Class.new { include m }
                    subject.is_kind_of!(k)
                    test.is_kind_of!(m)
                    assert subject.contains?(test)
                end
                it "returns true if all modules of the arguments are included in the module set of the receiver" do
                    subject.is_kind_of!(m = Module.new)
                    test.is_kind_of!(m)
                    assert subject.contains?(test)
                end
            end

            describe "type with call signatures" do
                attr_reader :subject, :test

                before do
                    @subject = Type.new
                    @test    = Type.new
                    test.responds_to!(:test)
                end

                it "returns false if some calls cannot be resolved in the receiver" do
                    flexmock(subject).should_receive(:responds_to_duck_message?).once.and_return(false)
                    assert !subject.contains?(test)
                end

                it "returns true if all calls can be resolved in the receiver" do
                    flexmock(subject).should_receive(:responds_to_duck_message?).once.and_return(true)
                    assert subject.contains?(test)
                end
            end
        end

        describe "#is_kind_of" do
            describe "when given a class" do
                it "replaces the current class by the new one" do
                    subject = Type.new(k0 = Class.new)
                    result = subject.is_kind_of(k1 = Class.new(k0))
                    assert_equal k1, result.kind_of_class
                    assert_equal Array.new, result.kind_of_modules
                end
                it "does nothing if the receiver's class is a superclass of the argument" do
                    k1 = Class.new
                    subject = Type.new(k0 = Class.new(k1))
                    result = subject.is_kind_of(k1)
                    assert_equal k0, result.kind_of_class
                    assert_equal Array.new, result.kind_of_modules
                end
                it "raises InconsistentTypes if the two classes are unrelated" do
                    subject = Type.new(k0 = Class.new)
                    assert_raises(Type::InconsistentTypes) { subject.is_kind_of(k1 = Class.new) }
                end
                it "does not modify the receiver" do
                    subject = Type.new(k0 = Class.new)
                    subject.is_kind_of(k1 = Class.new(k0))
                    assert_equal k0, subject.kind_of_class
                end
            end
            describe "when given a module" do
                it "adds the module to the module list" do
                    subject = Type.new
                    result = subject.is_kind_of(m = Module.new)
                    assert_equal [m], result.kind_of_modules
                end
                it "does nothing if the receiver's class includes the module" do
                    m = Module.new
                    subject = Type.new(k0 = Class.new { include m })
                    result = subject.is_kind_of(m)
                    assert_equal Set.new, result.kind_of_modules
                end
                it "does nothing if the module is already included in is_kind_of" do
                    m0 = Module.new
                    m1 = Module.new { include m0 }
                    subject = Type.new
                    subject = subject.is_kind_of(m1)
                    result = subject.is_kind_of(m0)
                    assert_equal [m1], subject.kind_of_modules
                end
            end
        end

        describe ".any" do
            it "creates a type that is contained by anything" do
                type = Type.new(Class.new)
                type.is_kind_of(Module.new)
                assert type.contains?(Type.any)
            end
        end
    end
end
