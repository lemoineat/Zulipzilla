# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This Source Code Form is "Incompatible With Secondary Licenses", as
# defined by the Mozilla Public License, v. 2.0.

# Copyright © 2015 Andreas Misje
# Copyright @ 2020 Lemoine Automation Technologies (Nicolas Relange)

package Bugzilla::Extension::Zulipzilla;
use strict;
use utf8;
use base qw(Bugzilla::Extension);
use HTTP::Request::Common;
use JSON;
use LWP::UserAgent;

our $VERSION = '0.01';

# TODO: Inject a form in the admin panel where these can be set:
my %CONFIG = (
	uri => 'https://zulip.lemoine.tech/api/v1/',
	server => 'zulip.lemoine.tech:443',
	botemail => 'lemoineatbugs-bot@zulip.lemoine.tech',
	apikey => 'VvrkXIaOxwTtBoMPwfg99ncazkWRmjPS',
	bugzillaURI => 'http://bugs.lemoine.tech/',
);

my $userAgent = LWP::UserAgent->new();
$userAgent->credentials (
	$CONFIG{'server'},
	'zulip',
        $CONFIG{'botemail'},
	$CONFIG{'apikey'}
);

# Since bug_end_of_update is called also when bugs are created (and since I
# have found no good way to detect whether bug_end_of_update is called on a
# new bug object), keep the following message simple. All the details of the
# new bug will be posted in the following bug_end_of_update event.
sub bug_end_of_create {
	my (undef, ($args)) = @_;
	my $bug = $$args{'bug'};
	my $user = Bugzilla->user->name;
	my $id = $bug->id;
	my $product = $bug->product;
	my $component = $bug->component;

	my $text = "New Bug$id in $product/$component";

	sendData('messages', { type => 'stream', to => 'Bugs', topic => "Bug $id", content => "$text" });
}

sub bug_end_of_update {
	my (undef, $args) = @_;
	my $user = Bugzilla->user->name;
	my $useremail = Bugzilla->user->email;

	if($useremail =~ m/zulip-bot@/){
		return;
	}

	my ($bug, $oldBug, $changes) = @$args{qw(bug old_bug changes)};
	my $id = $bug->id;
	my $summary = $bug->short_desc;
	my $status = $bug->status->name;
	my $assignedTo = $bug->assigned_to->name;
	my $assignedToEMail = $bug->assigned_to->email;
	my $severity = $bug->bug_severity;
	my $product = $bug->product;
	my $component = $bug->component;
	# First comment is the bug description, and the remaining comments are in a
	# reverse order:
	my $description = ${$bug->comments}[0]->body;
	my $lastComment = ($#{$bug->comments} ? ${$bug->comments}[-1]->body : $description);

		# %$changes may be empty (when a comment is added, for instance). Not
		# sure what to write … so let's just be honest and write just that:
	my $text = "Bug$id: $user changed " . (%$changes ? join(', ', keys %$changes) : 
			'… something') . "\n\n$lastComment";

        sendData('messages', { type => 'stream', to => 'Bugs', topic => "Bug $id", content => "$text" });
}

sub sendData {
	my ($method, $jsonObj) = @_;

	$userAgent->post($CONFIG{'uri'} . $method, $jsonObj);
}

__PACKAGE__->NAME;
