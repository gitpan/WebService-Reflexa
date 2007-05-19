use Test::More tests => 2;
use WebService::Reflexa;

my $service = WebService::Reflexa->new;
ok($service);
my @result = $service->search('ZIGOROu');
ok(@result >= 0);
