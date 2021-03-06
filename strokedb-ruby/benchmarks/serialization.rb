require 'strokedb'
include StrokeDB

require 'benchmark'
include Benchmark 

N = 3_000

raw_doc = {"a"=>[2**63,{5=>"a"*100 },3],"ar"=>[1,2]*10,"b"=>Math::PI,"x"=>"a"*1024,"y"=>"b"*2048}

puts "Dumping #{N} times..."
bm(32) do |x| 
  x.report("ActiveSupport to_json") do
    (N/5).times do
      raw_doc.to_json
      raw_doc.to_json
      raw_doc.to_json
      raw_doc.to_json
      raw_doc.to_json
    end
  end
  x.report("Marshal.dump") do
    (N/5).times do
      Marshal.dump(raw_doc)
      Marshal.dump(raw_doc)
      Marshal.dump(raw_doc)
      Marshal.dump(raw_doc)
      Marshal.dump(raw_doc)
    end
  end
end

m_doc = Marshal.dump(raw_doc)
j_doc = raw_doc.to_json

puts " \n "
puts "Loading #{N} times..."
bm(32) do |x| 
  x.report("ActiveSupport::JSON.decode") do
    (N/5).times do
      ActiveSupport::JSON.decode(j_doc)
      ActiveSupport::JSON.decode(j_doc)
      ActiveSupport::JSON.decode(j_doc)
      ActiveSupport::JSON.decode(j_doc)
      ActiveSupport::JSON.decode(j_doc)
    end
  end
  x.report("Marshal.load") do
    (N/5).times do
      Marshal.load(m_doc)
      Marshal.load(m_doc)
      Marshal.load(m_doc)
      Marshal.load(m_doc)
      Marshal.load(m_doc)
    end
  end
end

