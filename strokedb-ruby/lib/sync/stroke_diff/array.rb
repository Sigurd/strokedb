module StrokeDB
  class ::Array
    SDATPTAGS = {
      '-' => PATCH_MINUS,
      '+' => PATCH_PLUS,
      '!' => PATCH_DIFF
    }.freeze
    def stroke_diff(to)
      return super(to) unless Array === to
      return nil if self == to
      
      # sdiff:  +   -   !   = 
      lcs_sdiff = ::Diff::LCS.sdiff(self, to)
      patchset = []
      last_part = lcs_sdiff.inject(nil) do |part, change|
        a = SDATPTAGS[change.action]
        if part && part[0] == a && a != PATCH_DIFF
          if a == '+'
            part[2] << change.new_element
          else
            part[2] += 1
          end
          part
        else
          patchset << part if part
          # emit
          if a == '!' 
            [a, change.old_position, change.new_position, 
                change.old_element.stroke_diff(change.new_element)]
          elsif a == '-'
            [a, change.old_position, 1]
          elsif a == '+'
            [a, change.new_position, [change.new_element]]
          else 
            nil
          end
        end
      end
      patchset << last_part if last_part
      patchset.empty? ? nil : patchset
    end
    
    def stroke_patch(patch)
      return self unless patch
      return patch[1] if patch[0] == PATCH_REPLACE
      #puts "#{self.inspect}.stroke_patch(#{patch.inspect}) "
      res = []
      ai = bj = 0
      patch.each do |change|
        action, position, element = change
        case action
        when PATCH_MINUS
          d = position - ai
          if d > 0
            res += self[ai, d]
            ai += d
            bj += d
          end
          ai += element # element == length
        when PATCH_PLUS
          d = position - bj
          if d > 0
            res += self[ai, d]
            ai += d
            bj += d
          end
          bj += element.size
          res += element
        when PATCH_DIFF
          action, pa, pb, diff = change
          da = pa - ai
          db = pb - bj
          raise "Distances do not match!" if da != db
          if da > 0
            res += self[ai, da]
            ai += da
            bj += db
          end
          res << self[ai].stroke_patch(diff)
          ai += 1
          bj += 1
        end
      end
      d = self.size - ai
      res += self[ai, d] if d > 0
      res
    end
  end
end
