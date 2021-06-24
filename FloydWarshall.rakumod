use v6;
class FloydWarshall {
   has &!identifier;
   has %!d;  # output, distances
   has %!p;  # output, predecessors
   has %!nf; # output, node data for identifier

   method BUILD (:&distance!, :&successors!, :&!identifier = { ~$^a }, :@starts where *.elems > 0) {
      my @q = @starts;
      while (@q) {
         next if %!nf{my $vi = &!identifier(my $v = @q.shift)}:exists;
         for &successors(%!nf{$vi} = $v) -> $w {
            next if $vi eq (my $wi = &!identifier($w)); # avoid self-edges
            %!d{$vi}{$wi} = &distance($v, $w);
            %!p{$vi}{$wi} = $vi;
            @q.push($w) unless %!nf{$wi}:exists;
         }
      }
      my @vs = %!nf.keys;
      for @vs -> $vi {
         for @vs -> $vv {
            next unless %!p{$vv}{$vi}:exists;
            for @vs -> $vw {
               next unless %!d{$vi}{$vw}:exists;
               my $newd = %!d{$vv}{$vi} + %!d{$vi}{$vw};
               next if %!d{$vv}{$vw}:exists && %!d{$vv}{$vw} <= $newd;
               %!d{$vv}{$vw} = $newd;
               %!p{$vv}{$vw} = %!p{$vi}{$vw};
            }
            die 'negative cycle, bail out' if %!d{$vv}{$vv} < 0;
         }
      }
   }

   method has-path ($v, $w) {
      my ($vi, $wi) = ($v, $w).map({&!identifier($_)}).Slip;
      return (%!d{$vi}:exists) && (%!d{$vi}{$wi}:exists);
   }
   method distance ($v, $w) {
      my ($vi, $wi) = ($v, $w).map({&!identifier($_)}).Slip;
      return unless (%!d{$vi}:exists) && (%!d{$vi}{$wi}:exists);
      return %!d{$vi}{$wi};
   }
   method path ($v, $w) {
      my ($fi, $ti) = ($v, $w).map({&!identifier($_)}).Slip;
      return unless (%!d{$fi}:exists) && (%!d{$fi}{$ti}:exists);
      return reverse gather {
         while $ti ne $fi {
            take %!nf{$ti};
            $ti = %!p{$fi}{$ti};
         }
         take %!nf{$ti}; # take the last too
      }
   }
}
