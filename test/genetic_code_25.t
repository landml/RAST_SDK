use Test::Most;
use RASTTestUtils;
use Data::Dumper::Concise;

use Config::Simple;
use Time::HiRes qw(time);
use JSON;
use File::Copy;
use installed_clients::WorkspaceClient;
use installed_clients::GenomeAnnotationAPIClient;
use Storable qw(dclone);
use File::Slurp;

print "PURPOSE:\n";
print "    1.  Test annotation of genetic code 25 for Mircea Podar. \n";
print "    2.  Test the Prodigal is using the -meta when the domain is 'Unknown'\n\n";

my $ws_client     = RASTTestUtils::get_ws_client();
my $ws_name       = RASTTestUtils::get_ws_name();

my $assembly_obj_name = "GCA_000350285.1_OR1_genomic.fna";
my $assembly_ref      = RASTTestUtils::prepare_assembly( $assembly_obj_name );
my $genome_obj_name   = 'SR1_bacterium_MGEHA';
my $genome_set_name   = "New_GenomeSet";

my $params = {
    "input_contigset"            => $assembly_obj_name,
    "scientific_name"            => 'candidate division SR1 bacterium MGEHA',
    "domain"                     => 'U',
    "genetic_code"               => '25',
    "call_features_CDS_prodigal" => '1',
};

$params = RASTTestUtils::set_params( $genome_obj_name, $params );

subtest 'Running RAST annotation' => sub {

    RASTTestUtils::make_impl_call( "RAST_SDK.annotate_genome", $params );
    my $genome_ref = RASTTestUtils::get_ws_name() . "/" . $genome_obj_name;
    my $genome_obj = $ws_client->get_objects( [ { ref => $genome_ref } ] )->[ 0 ]->{ data };

    print "\n\nOUTPUT OBJECT DOMAIN = $genome_obj->{domain}\n";
    print "OUTPUT OBJECT G_CODE = $genome_obj->{genetic_code}\n";
    print "OUTPUT SCIENTIFIC NAME = $genome_obj->{scientific_name}\n";

    ok defined $genome_obj->{ features }, "Features array is present";
    ok @{ $genome_obj->{ features } }, "More than 0 features present";
};

RASTTestUtils::clean_up();

done_testing;


