module Rufus
  module Tokyo

    #
    # errors used in Tyrant are decendents of TyrantError
    #
    class TyrantError < RuntimeError

      attr_reader :message

      def initialize(err=nil)
        @message = err
      end

      def message
        "An error occurred within Tyrant #{@message}"
      end
      
      def to_s
        message
      end

      class BadArgument < self

        def message
          "incorrect arguments #{@message}"
        end

      end

    end

    require 'rufus/tokyo/tyrant/lib'
    require 'rufus/tokyo/tyrant/abstract'
    require 'rufus/tokyo/tyrant/table'

  end
end

