
use Test::More tests => 8;
use Test::Exception;

use_ok('Statim::Schema');

my $df_schema = {
    'collection' => {
        'fields' => {
            'jaz' => 'enum',
            'bar' => 'enum',
            'foo' => 'count'
        },
        'period' => '84600'
    }
};

my $schema = Statim::Schema->new;

{
    is_deeply( $schema->data($df_schema), $df_schema, 'schema::data return' );
    is_deeply( $schema->get,              $df_schema, 'schema::get return' );
}

{
    my $sc = $df_schema;
    delete( $sc->{collection}->{period} );
    $schema->data($sc);
    dies_ok { $schema->get } 'without period';
}

{
    my $sc = $df_schema;
    delete( $sc->{collection}->{fields} );
    $schema->data($sc);
    dies_ok { $schema->get } 'without fields';
}

{
    my $sc = $df_schema;
    $sc->{collection}->{fields}->{test} = 'other';
    $schema->data($sc);
    dies_ok { $schema->get } 'with wrong field type';
}

{
    my $sc = $df_schema;
    $sc->{collection}->{period} = 'other';
    $schema->data($sc);
    dies_ok { $schema->get } 'with string (other) period';
}

{
    my $sc = $df_schema;
    $sc->{collection}->{period} = -1;
    $schema->data($sc);
    dies_ok { $schema->get } 'with negative number';
}


