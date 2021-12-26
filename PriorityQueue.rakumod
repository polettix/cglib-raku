use v6;
class PriorityQueue {
   has @!items;
   has %!pos-of;
   has %!item-of;
   has &!before;
   has &!id-of;

   submethod BUILD (
      :&!before = {$^a < $^b},
      :&!id-of  = {~$^a},
      :@items
   ) {
      @!items = '-';
      self.enqueue($_) for @items;
   }

   method contains ($obj --> Bool) { self.contains-id(&!id-of($obj)) }
   method contains-id ($id --> Bool) { %!item-of{$id}:exists }
   method dequeue { self!remove-kth(1) }
   method elems { @!items.end }
   # method enqueue ($obj) <-- see below
   method is-empty { @!items.elems == 1 }
   method item-of ($id) { %!item-of{$id}:exists ?? %!item-of{$id} !! Any }
   method remove ($obj) { self.remove-id(&!id-of($obj)) }
   method remove-id ($id) { self!remove-kth(%!pos-of{$id}) }
   method size  { @!items.end }
   method top { @!items.end ?? @!items[1] !! Any }
   method top-id { @!items.end ?? &!id-of(@!items[1]) !! Any }

   method enqueue ($obj) {
      my $id = &!id-of($obj);
      %!item-of{$id} = $obj; # keep track of this item
      @!items[my $k = %!pos-of{$id} ||= @!items.end + 1] = $obj;
      self!adjust($k);
      return $id;
   }
   method !adjust ($k is copy) { # assumption: $k <= @!items.end
      $k = self!swap(($k / 2).Int, $k)
         while ($k > 1) && &!before(@!items[$k], @!items[$k / 2]);
      while (my $j = $k * 2) <= @!items.end {
         ++$j if ($j < @!items.end) && &!before(@!items[$j+1], @!items[$j]);
         last if &!before(@!items[$k], @!items[$j]); # parent is OK
         $k = self!swap($j, $k);
      }
      return self;
   }
   method !remove-kth (Int:D $k where 0 < $k <= @!items.end) {
      self!swap($k, @!items.end);
      my $r = @!items.pop;
      self!adjust($k) if $k <= @!items.end; # no adjust for last element
      my $id = &!id-of($r);
      %!item-of{$id}:delete;
      %!pos-of{$id}:delete;
      return $r;
   }
   method !swap ($i, $j) {
      my ($I, $J) = @!items[$i, $j] = @!items[$j, $i];
      %!pos-of{&!id-of($I)} = $i;
      %!pos-of{&!id-of($J)} = $j;
      return $i;
   }
}

sub MAIN {
   sub printall (PriorityQueue $pq) {
      $pq.dequeue.say while ! $pq.is-empty;
      put '-' x 10;
   }
   printall(PriorityQueue.new(items => 1 .. 5));
   printall(PriorityQueue.new(
      items => 'a' .. 'e',
      before => { $^a lt $^b },
   ));
   printall(PriorityQueue.new(
      items => 'a' .. 'e',
      before => { $^b lt $^a },
   ));
   my $pq = PriorityQueue.new;
   $pq.enqueue(10);
   put 'top is ', $pq.top;
   $pq.enqueue(3);
   put 'top is ', $pq.top;
   $pq.enqueue(1);
   put 'top is ', $pq.top;
   $pq.enqueue(5);
   put 'top is ', $pq.top;
   put 'queue has ', $pq.size, ' elements';
   for (4 .. 7) { $pq.remove($_) if $pq.contains($_) }
   put 'queue has ', $pq.elems, ' elements';
   printall($pq);
}
