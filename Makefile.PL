use inc::Module::Install;

name('WebService-Reflexa');
author('Toru Yamaguchi <zigorou@cpan.org>');
version_from('lib/WebService/Reflexa.pm');
abstract('Perl wrapper for Japanese assoc word search engine.');
license('perl');

requires('Carp', 1.03);
requires('Encode', 2.1);
requires('JSON::Any', 1.0);
requires('Class::Accessor::Fast', 0.30);
requires('WWW::REST', 0.01);
requires('XML::LibXML', 1.62);

use_test_base;

auto_include;
auto_install;

WriteAll;
