use warnings;
use strict;

package Test::Statim::Config;
use base qw( Exporter );
our @EXPORT = qw( test_statim_gen_config );

use File::Temp qw/ tempfile /;

my $df_data = <<END;
{ 
    "collection" : {
        "period" : "84600",
        "aggregate" : "sum",
        "fields" : {
            "foo" : "count",
            "bar" : "enum",
            "jaz" : "enum"
        }
    }
}

END

sub test_statim_gen_config {
    my ($data) = shift || $df_data;
    
    my ( $fh, $filename ) = tempfile();
    close($fh);

    open( my $file, ">", $filename ) or die "$@";
    print {$file} $data;
    close($file);
    return $filename;
}

1;

