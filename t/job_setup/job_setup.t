#!/usr/bin/perl -w

# Test job submission and findjob

use strict;
use warnings;

use Test::More;

my $QCHASM = $ENV{QCHASM};
$QCHASM =~ s/(.*)\/?/$1/;
eval {
    use lib $ENV{'QCHASM'};
    use AaronTools::JobControl qw(get_job_template submit_job findJob killJob);
    pass("Loaded packages");
    1;
} or do {
    fail("Failed to import Aaron package(s)");
    die $@;
};

my $wall = 2;
my $n_procs = 2;
my $node = 1;

my $template_job;
eval {
    $template_job = get_job_template();
    ok("Read job template");
    1;
} or do {
    fail("Could not get job template");
    die $@;
};

my $submit_fail = submit_job( com_file     => 'test.com',
                              walltime     => $wall,
                              numprocs     => $n_procs,
                              template_job => $template_job,
                              node         => $node );
ok( !$submit_fail, "Testing job submission" );
if ($submit_fail) {
    die "Failed to submit test job to the queue.\n"
      . "Check $QCHASM/Aaron/t/job_setup/test.job for errors and revise "
      . "$QCHASM/AaronTools/template.job accordingly.\n";
} else {
    diag(   "Submitting test job requesting $n_procs cores "
          . "and walltime of $wall hours..." );
    sleep(10);
}

my $job_found = findJob("$ENV{PWD}");
ok( $job_found, "Find job" );
if ($job_found) {
	my $failed_to_kill;
    eval {
        killJob($job_found);
        pass("Killing job $job_found...");
        sleep(5);
		$failed_to_kill = findJob("$QCHASM/t/job_setup");
		$failed_to_kill ? 0 : 1;
    } or do {
        fail(   "Cound not kill job submitted to the queue. "
              . "Please find the job and kill it manually. "
              . "Contact catalysttrends\@uga.edu for assistance."
        );
		if ( $failed_to_kill ){
			die "Could not kill $failed_to_kill\n";
		}
        die $@;
    };
} else {
	fail(   "Cound not find job submitted to the queue. "
			. "Please find the job and kill it manually. "
			. "Contact catalysttrends\@uga.edu for assistance."
	);
}

done_testing();

