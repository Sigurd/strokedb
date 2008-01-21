module StrokeDB
  class Slot
    attr_reader :doc

    def initialize(doc)
      @doc = doc
    end

    def value=(v)
      case v
      when Document
        @value = "@##{v.uuid}"
        @cached_value = v # lets cache it locally
      else
        @value = v
      end
    end

    def value
      case @value
      when /@#(#{UUID_RE})/
        if doc.store.exists?($1)
          doc.store.find($1)
        else
          @cached_value || "@##{$1}" # return cache if available
        end
      else
        @value 
      end
    end

    def to_json(opts={})
      @value.to_json(opts)
    end
  end
end
