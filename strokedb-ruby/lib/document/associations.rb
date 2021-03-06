module StrokeDB

  module Associations

    module HasManyAssociation
      attr_reader :association_owner
    end

    def has_many(slotname,opts={},&block)
      opts = opts.stringify_keys

      reference_slotname = opts['foreign_reference']
      through = opts['through'] || []
      through = [through] unless through.is_a?(Array)
      meta = (through.shift || slotname).to_s.singularize.camelize
      query = opts['conditions'] || {}

      extend_with = opts['extend'] || block

      @meta_initialization_procs << Proc.new do
        case extend_with
        when Proc
          extend_with_proc = extend_with
          extend_with = "HasMany#{slotname.to_s.camelize}"
          const_set(extend_with,Module.new(&extend_with_proc))
          extend_with = "#{self.name}::HasMany#{slotname.to_s.camelize}"
        when Module
          extend_with = extend_with.name
        when NilClass
        else
          raise "has_many extension should be either Module or Proc"
        end
        @args.last.reverse_merge!("has_many_#{slotname}" => { :reference_slotname => reference_slotname || 
          name.tableize.singularize, 
          :through => through, :meta => meta, :query => query,
          :extend_with => extend_with })


        end

      end 
      
      private 
      
      def initialize_associations
        when_slot_not_found(:has_many) do |doc, missed_slotname|
          if slot_has_many = doc.meta["has_many_#{missed_slotname}"]
            reference_slotname = slot_has_many[:reference_slotname]
            through = slot_has_many[:through]
            meta = slot_has_many[:meta]
            query = slot_has_many[:query]
            effective_query = query.merge(:__meta__ => meta.constantize.document, reference_slotname => doc)
            result = doc.store.index_store.find(effective_query).map do |d| 
              begin
                through.each { |t| d = d.send(t) }
              rescue SlotNotFoundError
                d = nil
              end
              d
            end.compact

            if extend_with = slot_has_many[:extend_with] 
              result.extend(extend_with.constantize) 
            end
            result.extend(HasManyAssociation)
            result.instance_variable_set(:@association_owner,doc)

            result
          else
            SlotNotFoundError.new(missed_slotname)
          end
        end
      end
    end  
  end