
package Statim;

use strict;
use warnings;

our $VERSION = '0.0001';

1;
=head1 NAME

Statim - Time series database server.

=head1 ABSTRACT

Statim Server allows user to create, update and destroy varios times series and
organize the in the statim fashion. Theses series may organized by a fact or 
just by time.

The server often supports a number of basic calculations that works on 
a series as a whole, such as multiplying, adding, or otherwise combining
various time series into a new time series.

They can also filter on arbitraty patterns defined by the period time of
series and apply filter to get high, low and avegare value.

=head1 SEE ALSO

=over 4

=item * L<Statim::Doc::Spec>

=back

=head1 AUTHOR

Thiago Rondon, <tbr@cpan.org>, 

http://www.aware.com.br

=head1 COPYRIGHT AND LICENSE

This library is free software under the same terms as perl itself

=cut

