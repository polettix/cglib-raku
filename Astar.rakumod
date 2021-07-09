use v6;
class Astar {
   has (&!distance, &!successors, &!heuristic, &!identifier);

   method best-path ($start!, $goal!) {
      my ($id, $gid) = ($start, $goal).map: {&!identifier($^a)};
      my %node-for = $id => {pos => $start, g => 0};
      class PriorityQueue { ... }
      my $queue = PriorityQueue.new;
      $queue.enqueue($id, 0);
      while ! $queue.is-empty {
         my $cid = $queue.dequeue;
         my $cx = %node-for{$cid};
         next if $cx<visited>++;

         return self!unroll($cx, %node-for) if $cid eq $gid;

         my $cv = $cx<pos>;
         for &!successors($cv) -> $sv {
            my $sid = &!identifier($sv);
            my $sx = %node-for{$sid} ||= {pos => $sv};
            next if $sx<visited>;;
            my $g = $cx<g> + &!distance($cv, $sv);
            next if $sx<g>:exists && $g >= $sx<g>;
            $sx<p> = $cid; # p is the id of "best previous"
            $sx<g> = $g;   # with this cost
            $queue.enqueue($sid, $g + &!heuristic($sv, $goal));
         }
      }
      return ();
   }

   submethod BUILD (:&!distance!, :&!successors!,
      :&!heuristic = &!distance, :&!identifier = {~$^a}) {}

   method !unroll ($node is copy, %node-for) {
      my @path = $node<pos>;
      while $node<p>:exists {
         $node = %node-for{$node<p>};
         @path.unshift: $node<pos>;
      }
      return @path;
   }

   class PriorityQueue {
      has @!items  = ('-');
      method is-empty { @!items.end < 1 }
      method dequeue () { # includes "sink"
         return if @!items.end < 1;
         my $r = @!items.end > 1 ?? @!items.splice(1, 1, @!items.pop)[0] !! @!items.pop;
         my $k = 1;
         while (my $j = $k * 2) <= @!items.end {
            ++$j if $j < @!items.end && @!items[$j + 1]<w> < @!items[$j]<w>;
            last if @!items[$k]<w> < @!items[$j]<w>;
            (@!items[$j, $k], $k) = (|@!items[$k, $j], $j);
         }
         return $r<id>;
      }
      method enqueue ($id, $weight) { # includes "swim"
         @!items.push: {id => $id, w => $weight};
         my $k = @!items.end;
         (@!items[$k/2, $k], $k) = (|@!items[$k, $k/2], ($k/2).Int)
            while $k > 1 && @!items[$k]<w> < @!items[$k/2]<w>;
         return self;
      }
   }
}

sub MAIN {
   my $map = q:to/END/;
      ########
      #      #
      # #### #
      #    # #
      #      #
      ########
      END
   sub mapper ($map) {
      return sub ($node) {
         state @lines = $map.lines.reverse.map: *.comb;
         my ($x, $y) = $node;
         die 'invalid y' unless 0 <= $y < @lines.elems;
         die 'invalid x' unless 0 <= $x < @lines[$y].elems;
         return () if @lines[$y][$x] eq '#';
         return gather {
            for  $y - 1 .. $y + 1 -> $Y {
               next unless 0 <= $Y < @lines.elems;
               for $x - 1 .. $x + 1 -> $X {
                  next unless 0 <= $X < @lines[$Y].elems;
                  next if $X == $x && $Y == $y;
                  next if @lines[$Y][$X] eq '#';
                  take ($X, $Y);
               }
            }
         }
      }
   }
   sub map-path($map, @path is copy) {
      my @lines = $map.lines.reverse;
      sub put-item ($pos, $char = '.') {
         my ($x, $y) = $pos;
         @lines[$y].substr-rw($x, 1) = $char;
      }
      put-item(@path.shift, 'S');
      put-item(@path.pop, 'G');
      put-item($_, '.') for @path;
      return @lines.reverse.join("\n");
   }
   my $nav = Astar.new(
      distance  => {($^v «-» $^w).map(*.abs).sum},
      heuristic => {($^v «-» $^w).map(*²).sum.sqrt},
      identifier => {$^v.join(',')},
      successors => mapper($map),
   );
   my @path = $nav.best-path((1, 1), (4, 4));
   put map-path($map, @path);
   .say for @path;
}
