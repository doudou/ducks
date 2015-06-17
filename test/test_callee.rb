require 'ducks/test'

module Ducks
    describe Callee do
        attr_reader :t0, :t1, :t2
        before do
            k0, k1, k2 = Class.new, Class.new, Class.new
            @t0, @t1, @t2 = Type.new(k0), Type.new(k1), Type.new(k2)
        end

        describe "#initialize" do
            it "separates the arguments in before-splat, after-splat and splat" do
                c = Callee.new(t0, Callee::Splat.new(t1), t2)
                assert_equal [t0], c.arguments_before_splat
                assert_equal t1, c.splat
                assert_equal [t2], c.arguments_after_splat
            end
            it "handles the absence of a splat argument" do
                c = Callee.new(t0, t1)
                assert_equal [t0, t1], c.arguments_before_splat
                assert !c.splat
                assert_equal [], c.arguments_after_splat
            end
            it "handles a leading splat argument" do
                c = Callee.new(Callee::Splat.new(t0), t1)
                assert_equal [], c.arguments_before_splat
                assert_equal t0, c.splat
                assert_equal [t1], c.arguments_after_splat
            end
            it "handles a trailing splat argument" do
                c = Callee.new(t0, Callee::Splat.new(t1))
                assert_equal [t0], c.arguments_before_splat
                assert_equal t1, c.splat
                assert_equal [], c.arguments_after_splat
            end
        end

        describe "#match_non_splat_callee_signature_against_arguments" do
            it "returns empty matching arguments for two identical signatures" do
                args = [t0, t1, t2]
                seq  = [t0, t1, t2]
                callee = Callee.new(seq)
                assert_equal [[]], callee.match_non_splat_callee_signature_against_arguments(
                    [args], seq)
            end
            it "returns empty matching arguments for two identical signatures with a non-matching splat in-between" do
                args = [t0, Signature::Splat.new(t1), t2]
                seq  = [t0, t2]
                callee = Callee.new(seq)
                assert_equal [[]], callee.match_non_splat_callee_signature_against_arguments(
                    [args], seq)
            end
            it "returns empty matching arguments for two identical signatures with a matching splat in-between" do
                args = [t0, Signature::Splat.new(t1), t2]
                seq  = [t0, t1, t1, t2]
                callee = Callee.new(seq)
                assert_equal [[]], callee.match_non_splat_callee_signature_against_arguments(
                    [args], seq)
            end
            it "returns nil if the sequence has remaining non-matched arguments" do
                args = [t0, Signature::Splat.new(t1)]
                seq  = [t0, t1, t1, t2]
                callee = Callee.new(seq)
                assert !callee.match_non_splat_callee_signature_against_arguments([args], seq)
            end
            it "returns nil if the sequence and the arguments are incompatible" do
                args = [t0, t2]
                seq  = [t0, t1]
                callee = Callee.new(seq)
                assert !callee.match_non_splat_callee_signature_against_arguments([args], seq)
            end
            it "returns the possible remaining signatures if the sequence does not eat all arguments" do
                args = [t0, Signature::Splat.new(t1), t2]
                seq  = [t0, t1, t1]
                callee = Callee.new(seq)
                ret = callee.match_non_splat_callee_signature_against_arguments([args], seq)
                assert_equal [[t2]], ret
            end
            it "returns the possible remaining signatures if the sequence does not eat all arguments" do
                args = [t0, t2, Signature::Splat.new(t1)]
                seq  = [t0, t2]
                callee = Callee.new(seq)
                ret = callee.match_non_splat_callee_signature_against_arguments([args], seq)
                assert_equal [[Signature::Splat.new(t1)]], ret
            end
        end
    end
end

