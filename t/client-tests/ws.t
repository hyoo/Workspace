use strict vars;
use Test::More;
use Test::Exception;
use Config::Simple;
use JSON;
use Data::Dumper;
use UUID;

my($cfg, $url, );

if (defined $ENV{KB_DEPLOYMENT_CONFIG} && -e $ENV{KB_DEPLOYMENT_CONFIG}) {
    $cfg = new Config::Simple($ENV{KB_DEPLOYMENT_CONFIG}) or
	die "can not create Config object";
    pass "using $ENV{KB_DEPLOYMENT_CONFIG} for configs";
}
else {
    $cfg = new Config::Simple(syntax=>'ini');
    $cfg->param('workspace.service-host', '127.0.0.1');
    $cfg->param('workspace.service-port', '7125');
    pass "using hardcoded Config values";
}

$url = "http://" . $cfg->param('workspace.service-host') . 
	  ":" . $cfg->param('workspace.service-port');

ok(system("curl -h > /dev/null 2>&1") == 0, "curl is installed");
ok(system("curl $url > /dev/null 2>&1") == 0, "$url is reachable");

BEGIN {
	use_ok( Bio::P3::Workspace::WorkspaceClient );
	use_ok( Bio::P3::Workspace::WorkspaceImpl );
}

can_ok("Bio::P3::Workspace::WorkspaceClient", qw(
		create_workspace
		save_objects
		create_upload_node
		get_objects
		get_objects_by_reference
		list_workspace_contents
		list_workspace_hierarchical_contents
		list_workspaces
		search_for_workspaces
		search_for_workspace_objects
		create_workspace_directory
		copy_objects
		move_objects
		delete_workspace
		delete_objects
		delete_workspace_directory
		reset_global_permission
		set_workspace_permissions
		list_workspace_permissions

   )
);

# create a client
my $obj;
isa_ok ($obj = Bio::P3::Workspace::WorkspaceClient->new(), Bio::P3::Workspace::WorkspaceClient);

# create a random workspace name
my($uuid, $string);
UUID::generate($uuid);
UUID::unparse($uuid, $string);
my $workspace = 'brettin-' . $string;

# create the create_workspace_params
my $create_workspace_params = {
	workspace => $workspace,
	permission => "a",
	metadata => {'owner' => 'brettin'}, 
};

# create a workspace
my $output;
ok($output = $obj->create_workspace($create_workspace_params), "auth user can call create workspace");

# list my workspaces
# funcdef list_workspaces(list_workspaces_params input)
#    returns (list<WorkspaceMeta> output)
#    authentication required;
my $list_workspaces_params = {};
my $output;
ok($output = $obj->list_workspaces($list_workspaces_params), "auth user can list workspaces");

print ref($output), "\n";
foreach my $mt (@{$output}) {
	print "WorkspaceID: $mt->[0]\n";
	print "WorkspaceName: $mt->[1]\n";
	print "Username: $mt->[2]\n";
	print "timestamp: $mt->[3]\n";
	print "num_objects: $mt->[4]\n";
	print "user_permission: ", ref($mt->[5]), "\n";
	print "global_permission: ", ref($mt->[6]), "\n";
	print "num_directories: $mt->[7]\n";
	print "UserMetadata: $mt->[8]\n";
}


# add an object to a workspace


# delete an object from a workspace


# delete a workspace




done_testing();
