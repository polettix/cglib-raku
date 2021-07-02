use v6;
sub breadth-first-visit (
      :&discover-action,        # first time a node is found
      :action(:&visit-action),  # node is visited (happens once)
      :&skip-action,            # node skipped due previous visit
      :&leave-action,           # node visiting ends
      :identifier(:&id) = -> $item {~$item},
      :&successors!,
      :@start!,
) {
   my %m; # keep track of marked nodes
   my @q = @start.map: { &discover-action($_, Nil) if &discover-action;
                         %m{&id($_)} = 1; [$_, Nil] };
   while @q {
      my ($v, $pred) = @q.shift; # "dequeue"
      &visit-action($v, $pred) if &visit-action;
      for &successors($v) -> $w {
         if %m{&id($w)}++ {  # visit nodes only once 
            &skip-action($w, $v) if &skip-action;
         }
         else {
            &discover-action($w, $v) if &discover-action;
            @q.push: [$w, $v];
         }
      }
      &leave-action($v, $pred) if &leave-action;
   }
   return %m.keys;
}

sub MAIN {
   my %graph =
      1 => (2, 3, 4),
      2 => (3),
      3 => (5, 6),
      4 => (1, 6),
      5 => (1, 2),
      6 => (3, 4),
   ;
   my &printable = -> $name {
      -> $v, $p is copy {
         $p //= '(*)';
         put "$name $v (from $p)";
      }
   };
   .put for breadth-first-visit(
      successors => { %graph{$^node}.List },
      start      => [ 1 ],
      discover-action => &printable('found'),
      skip-action     => &printable('skip'),
      visit-action    => &printable('visit'),
      leave-action    => &printable('leave'),
   );
}
