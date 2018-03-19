# --
# Copyright (C) 2015 - 2018 Perl-Services.de, http://www.perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::FilterElementPost::ExportTicketOverview;

use strict;
use warnings;

our @ObjectDependencies = qw(
    Kernel::Output::HTML::Layout
    Kernel::System::Web::Request
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # get template name
    my $Templatename = $Param{TemplateFile} || '';
    return 1 if !$Templatename;

    if ( $Templatename  =~ m{AgentTicketOverview(?:Small|Medium|Preview)\z} ) {
        my $Select = $LayoutObject->BuildSelection(
            Data => {
                ""     => '- Export -',
                Normal => 'Normal',
                Print  => 'Print',
                CSV    => 'CSV',
                Excel  => 'Excel',
            },
            Name         => 'ExportResultForm',
            Size         => 1,
            HTMLQuote    => 1,
            AutoComplete => 'off',
            Class        => 'Modernize',
        );

        my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');
        my @ParamNames  = $ParamObject->GetParamNames();

        my $Link = '';

        NAME:
        for my $Name ( @ParamNames ) {

            next NAME if $Name eq 'ResultForm';

            my @Values = $ParamObject->GetArray( Param => $Name );
            $Link .= join '&', map{ sprintf "%s=%s", $Name, $LayoutObject->LinkEncode( $_ ) }@Values;
            $Link .= '&';
        }

        return 1 if !$Link || $Link !~ m{Agent\w*TicketSearch};

        $LayoutObject->AddJSOnDocumentComplete(
           Code => qq~
               \$('#ExportResultForm').unbind('change');
               \$('#ExportResultForm').bind('change', function() {
                   var BaseURL          = Core.Config.Get('Baselink');
                   window.location.href = BaseURL + "$Link&ResultForm=" + \$(this).val();
               });
           ~, 
        );

        #scan html output and generate new html input
        ${ $Param{Data} } =~ s{(<ul \s+ class="Actions"> \s* <li .*? /li>)}{$Select $1}xmgs;
    }

    return 1;
}

1;
