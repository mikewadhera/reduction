
module Enumerable

  Pair = Struct.new(:left, :right)

  def all?(&block)
    fn = Proc.new { |x,accum| (block.call(x) || (return false)) }
    reduce(true, &fn)
  end

  def any?(&block)
    fn = Proc.new { |x,accum| (block.call(x) && (return true))}
    reduce(false, &fn)
  end

  def collect(&block)
    fn = lambda { |x,accum| accum << block.call(x) }
    reduce([], &fn)
  end

  def count(*args, &block)
    raise ArgumentError, "wrong # of arguments(#{args.size} for 1)" if args.size > 1
    
    if respond_to?(:size) && args.empty?
      self.size
    else
      fn = if block
        block
      elsif args.any?
        item = args.first
        lambda { |x,accum| x == item ? accum + 1 : accum }
      else
        lambda { |x,accum| accum + 1 }
      end
      reduce(0, &fn)
    end
  end

  def cycle(n=Infinity, &block)
    fn = lambda { |x,accum| block.call(x) }
    0.upto(n) { reduce(&fn) }
  end

  def drop(n)
    # TODO
  end

  def drop_while(&block)
    # TODO
  end

  def each_cons(n, &block)
    # TODO
  end

  def each_slice(n, &block)
    raise ArgumentError, "invalid size" if n <= 0

    fn = lambda do |x,accum|
      accum << x
      if accum.length % n == 0
        block.call(accum)
        accum.clear
      end
      accum
    end
    last_slice = reduce([], &fn)
    block.call(last_slice) if last_slice.any?
  end

  def each_with_index(&block)
    fn = lambda { |x,accum| block.call(x,accum); accum + 1 }
    reduce(0, &fn)
  end

  def entries
    # TODO
  end

  def find(ifnone=nil, &block)
    fn = Proc.new do |x,accum|
      return x if block.call(x)
      accum
    end
    reduce(ifnone, &fn)
  end

  def find_all(&block)
    fn = lambda do |x,accum|
      accum << x if block.call(x)
      accum
    end
    reduce([], &fn)
  end

  def find_index(&block)
    fn = Proc.new do |x,accum|
      return accum if block.call(x)
      accum + 1
    end
    reduce(0, &fn)
  end

  def first(n=1)
    fn = Proc.new do |x,accum|
      if accum.left >= n
        return accum.right.first if n == 1
        return accum.right
      end
      accum.left  += 1
      accum.right << x
      accum
    end
    reduce(Pair.new(0, []), &fn).right
  end

  def grep(pattern, &block)
    fn = lambda do |x,accum|
      accum << block.call(x) if pattern === x
      accum
    end
    reduce([], &fn)
  end

  def group_by(&block)
    fn = lambda do |x,accum|
      key = block.call(x)
      accum[key] ||= []
      accum[key] << x
      accum
    end
    reduce({}, &fn)
  end

  def max(&block)
    fn = lambda do |x,accum|
      block.call(x,accum) == 1 ? x : accum
    end
    reduce(&fn)
  end

  def max_by(&block)
    fn = lambda { |x,accum| block.call(x) > block.call(accum) ? x : accum }
    reduce(&fn)
  end

  def member?(obj, &block)
    fn = Proc.new do |x,accum|
      return true if x == obj
      accum
    end
    reduce(false, &fn)
  end

  def min(&block)
    fn = lambda do |x,accum|
      block.call(x,accum) == -1 ? x : accum
    end
    reduce(&fn)
  end

  def min_by(&block)
    fn = lambda { |x,accum| fn.call(x) < fn.call(accum) ? x : accum }
    reduce(&fn)
  end

  def minmax(&block)
    fn = lambda do |x,accum|
      accum = Pair.new(x, x) if accum.nil?

      accum.left  = block.call(x, accum.left)  == -1 ? x : accum.left
      accum.right = block.call(x, accum.right) ==  1 ? x : accum.right
      accum
    end
    all = reduce(nil, &fn)
    [all.left, all.right]
  end

  def minmax_by(&block)
    fn = lambda do |x,accum|
      accum = Pair.new(x, x) if accum.nil?

      accum.left  = block.call(x) < block.call(accum.left)  ? x : accum.left
      accum.right = block.call(x) > block.call(accum.right) ? x : accum.right
      accum
    end
    all = reduce(nil, &fn)
    [all.left, all.right]
  end

  def none?(&block)
    fn = Proc.new do |x,accum|
      return false if block.call(x)
      accum
    end
    reduce(true, &fn)
  end

  def one?(&block)
    fn = Proc.new do |x,accum|
      one = block.call(x)
      return false if accum == true && one == true
      accum || one
    end
    reduce(false, &fn)
  end

  def partition(&block)
    fn  = lambda { |x,accum| block.call(x) ? accum.left << x : accum.right << x }
    all = reduce(Pair.new([],[]), &fn)
    [all.left, all.right]
  end

  def reduce(*args, &block)
    @init = args.first if args.any?

    each do |x|
      @accum = block.call(x, @init || @accum || x)
      @init  = nil
    end

    @accum || @init
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

end