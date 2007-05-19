package WebService::Reflexa;

use strict;
use warnings;

use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors(qw/rest parser/);

use Carp qw(croak);
use WWW::REST;
use XML::LibXML;

our $API_URI = "http://labs.preferred.jp/reflexa/api.php";

=head1 NAME

WebService::Reflexa - Perl wrapper for Japanese assoc word search engine. (http://labs.preferred.jp/reflexa/)

=head1 VERSION

version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    my $service = WebService::Reflexa->new;
    my @words = $service->search('Perl', 'CPAN');
    print join("\n", @words);

=head1 METHODS

=head2 new()

Create instance, No arguments.

=cut

sub new {
    my $class = shift;

    my $self = $class->SUPER::new({
        parser => XML::LibXML->new,
        rest => WWW::REST->new($API_URI)
    });

    return $self;
}

=head2 search(@words)

=head2 search($words_array_ref)

Search assoc words by keywords.
Keywords is permitted Array or Array reference.

=cut

sub search {
    my $self = shift;
    my @words = (ref $_[0] eq 'ARRAY') ? @{$_[0]} : @_;

    $self->rest->dispatch($self->dispatcher);
    return $self->rest->get( q => join(" ", @words), format => "xml");
}

=head2 dispatcher()

Return code reference for L<WWW::REST>.

=cut

sub dispatcher {
    my $self = shift;

    return sub {
        my $rest = shift;

        croak($rest->status_line) if $rest->is_error;

        my $doc = $self->parser->parse_string($rest->content);
        my $xc = XML::LibXML::XPathContext->new($doc);
        my @nodes = map { $_->data } $xc->findnodes("//word/text()");

        return \@nodes;
    };
}

=head1 AUTHOR

Toru Yamaguchi, C<< <zigorou@cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-webservice-reflexa@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically be
notified of progress on your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2007 Toru Yamaguchi, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of WebService::Reflexa
