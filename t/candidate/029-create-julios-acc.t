use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my ( $response, $donation_url );
my $schema = VotoLegal->model('DB');
my $cpf    = '46223869762';

my $candidate_conf;
my $candidate_id;
my $id_donation_of_30reais;

my $pre_camp_start = DateTime->now( time_zone => 'America/Sao_Paulo' )->date;
my $pre_camp_end   = DateTime->now( time_zone => 'America/Sao_Paulo' )->add( days => 1 )->date;
my $camp_start     = DateTime->now( time_zone => 'America/Sao_Paulo' )->add( days => 2 )->date;
my $camp_end       = DateTime->now( time_zone => 'America/Sao_Paulo' )->add( days => 4 )->date;

db_transaction {
    create_candidate;
    $candidate_id = stash 'candidate.id';

    set_config( 'JULIOS_URL',     'http://mock');
    &activate_candidate;

    $ENV{SYNC_JULIOS_SECRET}='foo';

    # mock response de erro
    $VotoLegal::Test::Further::julios_information = { customer => { id => undef }};
    rest_get '/api2/julios_sync?secret=foo';
    $candidate_conf->discard_changes;
    ok $candidate_conf->pre_campaign_julios_customer_errmsg, 'error msg';

    # limpa o banco para voltar a ficar pendente a atualização
    $candidate_conf->update({ pre_campaign_julios_customer_errmsg => undef});

    # mock da response
    $VotoLegal::Test::Further::julios_information = { customer => { id => '123' }};
    rest_get '/api2/julios_sync?secret=foo';

    $candidate_conf->discard_changes;

    is $candidate_conf->pre_campaign_julios_customer_id, '123', 'db updated';

};

done_testing();

exit;


sub activate_candidate {

    set_config( 'USE_CANDIDATE_CONFIG_TABLE', '1' );

    set_config( 'CANDIDATE_CONFIG_PRE_CAMPAIGN_START_DATE', $pre_camp_start );
    set_config( 'CANDIDATE_CONFIG_PRE_CAMPAIGN_END_DATE',   $pre_camp_end );
    set_config( 'CANDIDATE_CONFIG_CAMPAIGN_START_DATE',     $camp_start );
    set_config( 'CANDIDATE_CONFIG_CAMPAIGN_END_DATE',       $camp_end );

    # ainda nao sao usados, mas deveriam ser usados para validar se o usuario editou certo
    set_config( 'CANDIDATE_CONFIG_PRE_CAMPAIGN_MIN_DATE', $pre_camp_start );
    set_config( 'CANDIDATE_CONFIG_PRE_CAMPAIGN_MAX_DATE', $pre_camp_end );
    set_config( 'CANDIDATE_CONFIG_CAMPAIGN_MIN_DATE',     $camp_start );
    set_config( 'CANDIDATE_CONFIG_CAMPAIGN_MAX_DATE',     $camp_end );


    # Aprovando o candidato
    ok(
        $schema->resultset('Candidate')->find($candidate_id)->update(
            {
                status         => "activated",
                payment_status => "paid",
                is_published   => 1,
            }
        ),
        'activate',
    );

    # automaticamente, a trigger deve inserir uma candidate config para ele, usando os valores acima
    $candidate_conf = $schema->resultset('Candidate')->find($candidate_id)->candidate_campaign_config;
    ok $candidate_conf, 'candidate_campaign_config found';

}

