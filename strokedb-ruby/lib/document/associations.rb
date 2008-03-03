module StrokeDB

  module Associations
    def has_many(slotname,opts={},&block)
      opts = opts.stringify_keys

      reference_slotname = opts['foreign_reference']
      through = opts['through'] || []
      through = [through] unless through.is_a?(Array)
      meta = (through.shift || slotname).to_s.singularize.camelize
      query = opts['conditions'] || {}
      
      extend_with = opts['extend'] || block
      
      @meta_initialization_procs << Proc.new do |meta_module| 
        if extend_with.is_a?(Proc)
           extend_with_proc = extend_with
           extend_with = "HasMany#{slotname.to_s.camelize}"
           meta_module.const_set(extend_with,Module.new(&extend_with_proc))
           extend_with = "#{meta_module.name}::HasMany#{slotname.to_s.camelize}"
        end
        @args.last.reverse_merge!("has_many_#{slotname}" => { :reference_slotname => reference_slotname || 
                                                               meta_module.name.tableize.singularize, 
                                                               :through => through, :meta => meta, :query => query,
                                                               :extend_with => extend_with })
        
        when_slot_not_found(:has_many) do |doc, missed_slotname|
          if slot_has_many = doc.meta["has_many_#{missed_slotname}"]
            reference_slotname = slot_has_many[:reference_slotname]
            through = slot_has_many[:through]
            meta = slot_has_many[:meta]
            query = slot_has_many[:query]
            effective_query = query.merge(:__meta__ => meta.constantize.document)
            result = doc.store.index_store.find(effective_query).select do |d| 
              d.has_slot?(reference_slotname) && d.send(reference_slotname) == doc 
            end.map do |d| 
              skip = false
              through.each do |t| 
                unless d.has_slot?(t)
                  skip = true
                  break 
                end
                d = d.send(t)  
              end
              skip ? nil : d
            end.compact
            
            if extend_with = slot_has_many[:extend_with] 
              result.extend(extend_with.to_s.constantize) 
            end
            
            result
          else
            SlotNotFoundError.new(missed_slotname)
          end
        end
      end
      
    end 
  end  
end