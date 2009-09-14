use inc::Module::Install;

# Define metadata
name           'Test-Time-HiRes';
all_from       'lib/Test/Time/HiRes.pm';

requires       'Math::BigFloat'  => '0';
test_requires  'Test::More'  => '0';

license 'perl';

WriteAll;
