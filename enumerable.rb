
class Array

  def rest
    self[1..-1]
  end

end

Pair = Struct.new(:left, :right)

def all?(fn, array)
  allfn = Proc.new { |x,accum| (fn.call(x) || (return false)) }
  reduce(allfn, array, true)
end

def any?(fn, array)
  anyfn = Proc.new { |x,accum| (fn.call(x) && (return true))}
  reduce(anyfn, array, false)
end

def collect(fn, array)
  cfn = lambda { |x,accum| accum << fn.call(x) }
  reduce(cfn, array, [])
end

def count(fn, array)
  reduce(lambda {|x,accum| accum + 1 }, array, 0)
end

def cycle(fn, array, upto=Infinity, cycles=0)
  if cycles == upto
    return
  else
    reduce(lambda {|x,accum| fn.call(x) }, array)
    cycle(fn, array, upto, cycles + 1)
  end
end

def drop(array, n)
  if n.zero?
    array
  else
    drop(array.rest, n - 1)
  end
end

def drop_while(fn, array)
  unless fn.call(array.first)
    array
  else
    drop_while(fn, array.rest)
  end
end

def each_cons(fn, array, n)
  # TODO
end

def each_slice(fn, array, n)
  raise ArgumentError, "invalid size" if n <= 0
  sfn = lambda do |x,accum|
    accum << x
    if accum.length % n == 0
      fn.call(accum)
      accum.clear
    end
    accum
  end
  last_slice = reduce(sfn, array, [])
  fn.call(last_slice) if last_slice.any?
  nil
end

def each_with_index(fn, array)
  efn = lambda { |x,accum| fn.call(x,accum); accum + 1 }
  reduce(efn, array, 0)
end

def entries
  # TODO
end

def find(fn, array, ifnone=nil)
  ffn = Proc.new do |x,accum|
    return x if fn.call(x)
    accum
  end
  reduce(ffn, array, ifnone)
end

def find_all(fn, array)
  fafn = lambda do |x,accum|
    accum << x if fn.call(x)
    accum
  end
  reduce(fafn, array, [])
end

def find_index(fn, array)
  fifn = Proc.new do |x,accum|
    return accum if fn.call(x)
    accum + 1
  end
  reduce(fifn, array, 0)
end

def first(array, n=1)
  ffn = Proc.new do |x,accum|
    if accum.left >= n
      return accum.right.first if n == 1
      return accum.right
    end
    accum.left  += 1
    accum.right << x
    accum
  end
  reduce(ffn, array, Pair.new(0, [])).right
end

def grep(fn, array, pattern)
  gfn = lambda do |x,accum|
    accum << fn.call(x) if pattern === x
    accum
  end
  reduce(gfn, array, [])
end

def group_by(fn, array)
  gbfn = lambda do |x,accum|
    key = fn.call(x)
    accum[key] ||= []
    accum[key] << x
    accum
  end
  reduce(gbfn, array, {})
end

def max(fn, array)
  mfn = lambda do |x,accum|
    fn.call(x,accum) == 1 ? x : accum
  end
  reduce(mfn, array)
end

def max_by(fn, array)
  mbfn = lambda { |x,accum| fn.call(x) > fn.call(accum) ? x : accum }
  reduce(mbfn, array)
end

def member?(array, obj)
  ifn = Proc.new do |x,accum|
    return true if x == obj
    accum
  end
  reduce(ifn, array, false)
end

def min(fn, array)
  mfn = lambda do |x,accum|
    fn.call(x,accum) == -1 ? x : accum
  end
  reduce(mfn, array)
end

def min_by(fn, array)
  mbfn = lambda { |x,accum| fn.call(x) < fn.call(accum) ? x : accum }
  reduce(mbfn, array)
end

def minmax(fn, array)
  mmfn = lambda do |x,accum|
    accum.left  = fn.call(x,accum.left)  == -1 ? x : accum.left
    accum.right = fn.call(x,accum.right) ==  1 ? x : accum.right
    accum
  end
  all = reduce(mmfn, array, Pair.new(array.first, array.first))
  [all.left, all.right]
end

def minmax_by(fn, array)
  mmfn = lambda do |x,accum|
    accum.left  = fn.call(x) < fn.call(accum.left)  ? x : accum.left
    accum.right = fn.call(x) > fn.call(accum.right) ? x : accum.right
    accum
  end
  all = reduce(mmfn, array, box.new(array.first, array.first))
  [all.left, all.right]
end

def none?(fn, array)
  nfn = Proc.new do |x,accum|
    return false if fn.call(x)
    accum
  end
  reduce(nfn, array, true)
end

def one?(fn, array)
  ofn = Proc.new do |x,accum|
    one = fn.call(x)
    return false if accum == true && one == true
    accum || one
  end
  reduce(ofn, array, false)
end

def partition(fn, array)
  pfn = lambda do |x,accum|
    fn.call(x)? accum.left << x : accum.right << x
    accum
  end
  all = reduce(pfn, array, Pair.new([],[]))
  [all.left, all.right]
end

def reduce(fn, array, accum=array.first)
  if array.empty?
    accum
  else
    reduce(fn, array.rest, fn.call(array.first, accum))
  end
end

def reject(fn, array)
  rfn = lambda do |x,accum|
    accum << x unless fn.call(x)
    accum
  end
  reduce(rfn, array, [])
end

def reverse_each(fn, array)
  rvfn = lambda { |x,accum| accum.unshift(x); accum }
  efn  = lambda { |x,_| fn.call(x) }
  reduce(efn, reduce(rvfn, array, []))
  nil
end

def sort(fn, array)
  # TODO
end

def sort_by(fn, array)
  # TODO
end

def take(n, array)
  tfn = Proc.new do |x,accum|
    return accum.left if n == accum.right
    accum.left  << x
    accum.right += 1
    accum
  end
  reduce(tfn, array, Pair.new([], 0))
end

def take_while(fn, array)
  # TODO
end

def to_a
  # TODO
end

def zip(fn, array)
  # TODO
end

# Aliases

alias :detect :find
alias :map :collect
alias :include? :member?
alias :inject :reduce
alias :select :find_all
