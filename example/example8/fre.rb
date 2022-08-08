exit unless ARGV.size >= 1

class WNode
  attr_reader :word, :count
  attr_accessor :nxt

  def initialize word, nxt=nil, count=1
    @word = word
    @nxt = nxt
    @count = count
  end

  def inc
    @count += 1
  end
end

class String
  def w_hash
    self.hash % HSIZE
  end
  def each_word
    self.split(/\s/).each do |w|
      yield(w) unless w == ""
    end
  end
end

HSIZE = 1001
@t = Array.new HSIZE
@t = @t.map {WNode.new(nil, nil, 0)}
@n = 0

ARGV.each do |file|
  s = File.read file
  s.each_word do |w|
    @n += 1
    n = w.w_hash
    wn = @t[n]
    while wn.nxt
      if wn.nxt.word == w
        wn.nxt.inc
        break
      end
      wn = wn.nxt
    end
    unless wn.nxt
      wn.nxt = WNode.new(w, nil, 1)
    end
  end
end

@a = []
@t.each do |wn|
  while wn.nxt
    @a << [wn.nxt.word, wn.nxt.count]
    wn = wn.nxt
  end
end

@a.sort!{|a,b| -(a[1] <=> b[1])} 

print "Number of words: #{@n}\n"
print "Top 10 words\n"
0.upto(9) do |i|
  printf "%-10s => % 3d\n", @a[i][0].inspect, @a[i][1]
end
