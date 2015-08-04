# --
# Kernel/Output/HTML/OutputFilterExportTicketOverview.pm
# Copyright (C) 2015 Perl-Services.de, http://www.perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::OutputFilterExportTicketOverview;

use strict;
use warnings;

our @ObjectDependencies = qw(
    Kernel::Output::HTML::Layout
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
            Name      => 'ExportResultForm',
            Size      => 1,
            HTMLQuote => 1,
        );

        my ($Link) = ${$Param{Data}} =~ m{
            <ul \s* class="OverviewZoom"> \s*
              <li> \s*
                <a .*? href="([^"]+)"
        }xms;

        return 1 if $Link !~ m{Agent\w*TicketSearch};

        $LayoutObject->AddJSOnDocumentComplete(
           Code => qq~
               \$('#ExportResultForm').unbind('change');
               \$('#ExportResultForm').bind('change', function() {
                   window.location.href = "$Link&ResultForm=" + \$(this).val();
               });
           ~, 
        );

        #scan html output and generate new html input
        ${ $Param{Data} } =~ s{(<ul \s+ class="Actions"> \s* <li .*? /li>)}{$1 $Select}xmgs;
    }

    return ${ $Param{Data} };
}

1;
