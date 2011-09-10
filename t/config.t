
use Test::More tests => 5;
use_ok('Statim::Config');
use File::Temp qw/ tempfile /;

my ( $fh, $filename ) = tempfile();
close($fh);

# set up test data
if ( open( my $file, ">", $filename ) ) {
    my $testData = <<END;
{ 
	"collection1" : {
		"fields" : {
			"ts" : { "epoch" : "day" },
			"foo" : "count",
			"bar" : "enum"
		},
	}
}
END
    print {$file} $testData;
    close($file);
    ok( 1, "set up test data" );
}
my $config = Statim::Config->new;

is_deeply(
    $config->get($filename),
    {
        'collection1' => {
            'fields' => {
                'bar' => 'enum',
                'ts'  => { 'epoch' => 'day' },
                'foo' => 'count'
            }
        }
    }
);

isnt($config->file, $filename);
$ENV{'STATIM_CONFIG'} = $filename;
is($config->file, $filename);

