use v6;

=begin pod
=begin SYNOPSIS
   my $queue = BasicPriorityQueue.new(
      before => -> $x, $y {}, # Opt, tells if $x is before $y
      items  => [],           # Opt, initial items to enqueueu
   );
   $queue.enqueue($_) for 10, 4, 7;            # add elements
   $queue.top.put;                             # 4, peek and keep
   $queue.size.put;                            # 3
   $queue.dequeue.put while ! $queue.is-empty; # 4, 7, 10
   $queue.elems.put;                           # 0, same as size
=end SYNOPSIS
=end pod

class BasicPriorityQueue {
   has @!items;
   has &!before;

   submethod BUILD (:&!before = {$^a < $^b}, :@items) {
      @!items = '-';
      self.enqueue($_) for @items;
   }

   #method dequeue ($obj) <-- see below
   method elems { @!items.end }
   # method enqueue ($obj) <-- see below
   method is-empty { @!items.elems == 1 }
   method size  { @!items.end }
   method top { @!items.end ?? @!items[1] !! Any }

   method dequeue () { # includes "sink"
      return unless @!items.end;
      my $r = @!items.end > 1 ?? @!items.splice(1, 1, @!items.pop)[0] !! @!items.pop;
      my $k = 1;
      while (my $j = $k * 2) <= @!items.end {
         ++$j if $j < @!items.end && &!before(@!items[$j + 1], @!items[$j]);
         last if &!before(@!items[$k], @!items[$j]);
         (@!items[$j, $k], $k) = (|@!items[$k, $j], $j);
      }
      return $r;
   }

   method enqueue ($obj) { # includes "swim"
      @!items.push: $obj;
      my $k = @!items.end;
      (@!items[$k/2, $k], $k) = (|@!items[$k, $k/2], ($k/2).Int)
         while $k > 1 && &!before(@!items[$k], @!items[$k/2]);
      return self;
   }
}

sub MAIN {
   sub printall (BasicPriorityQueue $pq) {
      $pq.dequeue.say while ! $pq.is-empty;
      put '-' x 10;
   }
   printall(BasicPriorityQueue.new(items => 1 .. 5));
   printall(BasicPriorityQueue.new(items => 1 .. 5, before => {$^b < $^a}));
   my $pq = BasicPriorityQueue.new;
   $pq.enqueue(10);
   put 'top is ', $pq.top;
   $pq.enqueue(3);
   put 'top is ', $pq.top;
   $pq.enqueue(1);
   put 'top is ', $pq.top;
   $pq.enqueue(5);
   put 'top is ', $pq.top;
   put 'queue has ', $pq.size, ' elements';
   put 'queue has ', $pq.elems, ' elements';
   printall($pq);
}
