
use Test::More tests => 9;
use Test::Exception;

use_ok('Statim::Schema');

sub get_schema {
    {
        'collection' => {
            'fields' => {
                'jaz' => 'enum',
                'bar' => 'enum',
                'foo' => 'count'
            },
            'period' => '84600',
            'aggregate' => 'sum'
        }
    };
}

my $schema = Statim::Schema->new;

{
    my $data = &get_schema;
    is_deeply( $schema->data($data), $data, 'schema::data return' );
    is_deeply( $schema->get,         $data, 'schema::get return' );
}

{
    my $sc = &get_schema;
    delete( $sc->{collection}->{period} );
    $schema->data($sc);
    throws_ok { $schema->get } qr/define period/, 'without period';
}

{
    my $sc = &get_schema;
    delete( $sc->{collection}->{fields} );
    $schema->data($sc);
    throws_ok { $schema->get } qr/define fields/, 'without fields';
}

{
    my $sc = &get_schema;
    $sc->{collection}->{fields}->{test} = 'other';
    $schema->data($sc);
    throws_ok { $schema->get } qr/enum or count/, 'with wrong field type';
}

{
    my $sc = &get_schema;
    $sc->{collection}->{period} = 'other';
    $schema->data($sc);
    throws_ok { $schema->get } qr/positive integer/,
      'with string (other) period';
}

{
    my $sc = &get_schema;
    $sc->{collection}->{period} = -1;
    $schema->data($sc);
    throws_ok { $schema->get } qr/positive integer/, 'with negative number';
}

{
    my $sc = &get_schema;
    $sc->{collection}->{fields}->{test} = 'count';
    $schema->data($sc);
    throws_ok { $schema->get } qr/one count/, 'with two counts';
}

