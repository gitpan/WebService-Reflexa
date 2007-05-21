package WebService::Reflexa;

use strict;
use warnings;

use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors(qw/rest json xml result/);

use Carp qw(croak);
use Encode;
use JSON::Any qw/XS DWIW Syck JSON/;
use WWW::REST;
use XML::LibXML;

our $API_URI = "http://labs.preferred.jp/reflexa/api.php";

=head1 NAME

WebService::Reflexa - Perl wrapper for Japanese assoc word search engine. (http://labs.preferred.jp/reflexa/)

=head1 VERSION

version 0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

    my $service = WebService::Reflexa->new;
    my $words = $service->search(['Perl', 'CPAN']);
    print join("\n", @$words);

=head1 METHODS

=head2 new($args)

Create instance, $args is hash reference.
Key detail is below,

=over 4

=item use_xml (optional)

Default 1. Create L<XML::LibXML> and enable xml response.

=item use_json (optional)

Default 0. Create L<JSON::Any> and enable json response.

=back

=cut

sub new {
    my ($class, $args) = @_;

   $args = {
       use_xml => 1,
       use_json => 0,
       (ref $args) ? %$args : ()
   };

    my $self = $class->SUPER::new({
        xml => ($args->{use_xml}) ? XML::LibXML->new : undef,
        json => ($args->{use_json}) ? JSON::Any->new : undef,
        rest => WWW::REST->new($API_URI),
        result => ''
    });

    return $self;
}

=head2 search($word[, $format]);

=head2 search($words_array_ref[, $format])

Search assoc words by keywords.
Return as array reference.
Keywords is permitted Array reference or scalar.

If you want to specify format type which is "xml" or "json",
then you must specify last argument called $format.

=cut

sub search {
    my ($self, $words, $format) = @_;

    $format ||= ($self->xml) ? "xml" : ($self->json) ? "json" : "";
    $format = lc($format);

    if ($format eq 'xml') {
        $self->rest->dispatch($self->xml_dispatcher);
    }
    elsif ($format eq 'json') {
        $self->rest->dispatch($self->json_dispatcher);
    }
    else {
        croak("Unknown format $format or not instanciate $format. Please specify use_$format flag to on in new() arguments");
    }

    return $self->rest->get( q => join(" ", (ref $words eq 'ARRAY') ? @$words : $words), format => $format);
}

=head2 xml_dispatcher()

Return code reference for L<WWW::REST>.

=cut

sub xml_dispatcher {
    my $self = shift;

    return sub {
        my $rest = shift;

        croak($rest->status_line) if $rest->is_error;

        $self->result($rest->content);

        my $doc = $self->xml->parse_string($self->result);
        my $xc = XML::LibXML::XPathContext->new($doc);
        my @nodes = map { encode_utf8($_->data) } $xc->findnodes("//word/text()");

        return \@nodes;
    };
}

=head2 json_dispatcher()

Return code reference for L<WWW::REST>.

=cut

sub json_dispatcher {
    my $self = shift;

    return sub {
        my $rest = shift;

        croak($rest->status_line) if $rest->is_error;

        $self->result($rest->content);
        my $result = [map { encode_utf8($_) } @{$self->json->jsonToObj($self->result)}];

        return $result;
    };
}

=head2 rest()

L<WWW::REST> instance.

=head2 json()

L<JSON::Any> instance.

=head2 xml()

L<XML::LibXML> instance.

=head2 result()

Last response string.

=head1 SEE ALSO

=over 4

=item http://labs.preferred.jp/reflexa/

Reflexa search engine top.

=item http://labs.preferred.jp/reflexa/about_api.html

About reflexa API

=item L<WWW::REST>

=item L<XML::LibXML>

=item L<JSON::Any>

=back

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
