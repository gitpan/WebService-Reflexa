use Test::More tests => 6;
use WebService::Reflexa;

SKIP: { ### for xml
    my $service = WebService::Reflexa->new;
    ok($service, 'Create instance with xml option');

    ok($service->xml, 'XML::LibXML instance');

    eval {
	my $result = $service->search(['ZIGOROu']);
	ok(@$result >= 0, 'XML search');
    };
    skip($@, 1) if ($@);
}

SKIP: { ### for json
    my $service = WebService::Reflexa->new({ use_json => 1 });
    ok($service, 'Create instance with json option');

    ok($service->json, 'JSON::Any instance');

    eval {
	my $result = $service->search(['ZIGOROu'], 'json');
	ok(@$result >= 0, 'JSON search');
    };
    skip($@, 1) if ($@);
}
