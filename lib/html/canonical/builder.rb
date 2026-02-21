require 'dry-monads'
include Dry::Monads[:result]

module Html
  module Canonical
    class BuilderResult
      attr_accessor :result, :next_state
      def initialize(result:, next_state:)
        raise TypeError, "`result` must be an instance of Result monad" unless result.kind_of?(Dry::Monads::Result)
        raise TypeError, "`next_state` must be an instance of Integer" unless next_state.kind_of?(Integer)

        @result = result
        @next_state = next_state
      end

      def ==(other)
        other.is_a?(BuilderResult) && result == other.result && next_state == other.next_state
      end

      def eql?(other)
        self == other
      end
    end

    class Builder
      def initialize(&block)
        @block = block
      end

      def run(config:, state:) # -> BuilderResult
        @block.call(config, state)
      end

      #  // Functor: Transform the value inside //endo-functor
      def map(&f) # map( T->U ) -> Builder<U>
        Builder.new do |cfg, s| # return
          builder_result = self.run(config: cfg, state: s) # -> BuilderResult
          case builder_result.result
          in Success(value)
            BuilderResult.new(result: Success(f.call(value)), next_state: builder_result.next_state)
          in Failure
            builder_result
          end
        end
      end

      #  // Monad: Chain dependent computations
      def chain(&f) # chain( T->Builder<U> ) -> Builder<U>
        Builder.new do |cfg, s|
          builder_result = self.run(config: cfg, state: s) # -> BuilderResult
          case builder_result.result
          in Success
            f.call(builder_result.result.value!).run(config: cfg, state: builder_result.next_state)
          in Failure
            builder_result
          end
        end
      end

      #  // Applicative/Semigroup: Combine independent builders
      def self.apply(b1, b2, &f) # apply( (Builder<A> -> Builder<B> -> (A->B)->C) ) -> Builder<C>
        Builder.new do |cfg, s0|
          r1 = b1.run(config: cfg, state: s0) # -> BuilderResult
          r2 = b2.run(config: cfg, state: r1.next_state)
          errors =  []

          # // Error Accumulation Logic
          if r1.result.failure?
            errors.push(*r1.result.failure)
          end

          if r2.result.failure?
            errors.push(*r2.result.failure)
          end

          if errors.any?
            BuilderResult.new(result: Failure(errors), next_state: r2.next_state)
          else
            BuilderResult.new(result: f.call(r1.result.value!, r2.result.value!), next_state: r2.next_state)
          end
        end
      end

      # Helper: Convert array of Builders to Builder of Array
      def self.sequence(builders:)  # sequence( [ Builder ] ) -> Builder<T[]>
        builders.reduce(Builder.of([])) do |acc, curr|
          Builder.apply(acc, curr) { |list, val|  Success([ *list, val ]) }
        end
      end

      # Factory: Lift a raw value into the context
      def self.of(val) # of(T)->Builder<T>
        Builder.new { |_, s| BuilderResult.new(result: Success(val), next_state: s) }
      end

      # Factory: Create a failure immediately
      def self.fail(err) # fail(string) -> Builder<String>
        Builder.new { |_, s| BuilderResult.new(result: Failure(err), next_state: s) }
      end
    end
  end
end
