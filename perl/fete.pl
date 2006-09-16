# =============================================================================
#  Copyright (c) 2003-2005 by FlashCode <flashcode@flashtux.org>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
#  fete.pl (c) D�cembre 2003 par FlashCode <flashcode@flashtux.org>
#  Mis � jour le 04/06/2005, FlashCode <flashcode@flashtux.org>
#
#  Gestion des f�tes du calendrier fran�ais avec la commande "/fete"
#  Syntaxe: /fete          - affiche la f�te du jour et du lendemain
#           /fete prenom   - cherche un pr�nom dans le calendrier
# =============================================================================

use locale;

my $version = "0.4";
weechat::register ("Fete", $version, "", "Gestion des f�tes du calendrier fran�ais");
weechat::print ("Script 'Fete' $version charg�");
weechat::add_command_handler ("fete", fete);

@noms_jours = qw(Dimanche Lundi Mardi Mercredi Jeudi Vendredi Samedi);
@noms_mois = qw(Janvier F�vrier Mars Avril Mai Juin Juillet Ao�t Septembre Octobre Novembre D�cembre);
@fetes = (
    # janvier
    [ '!Marie - JOUR de l\'AN', '&Basile', '!Genevi�ve', '&Odilon', '&Edouard',
      '&M�laine', '&Raymond', '&Lucien', '!Alix', '&Guillaume', '&Paulin',
      '!Tatiana', '!Yvette', '!Nina', '&R�mi', '&Marcel', '!Roseline',
      '!Prisca', '&Marius', '&S�bastien', '!Agn�s', '&Vincent', '&Barnard',
      '&Fran�ois de Sales', '-Conversion de St Paul', '!Paule', '!Ang�le',
      '&Thomas d\'Aquin', '&Gildas', '!Martine', '!Marcelle' ],
    # f�vrier
    [ '!Ella', '-Pr�sentation', '&Blaise', '!V�ronique', '!Agathe',
      '&Gaston', '!Eug�nie', '!Jacqueline', '!Apolline', '&Arnaud',
      '-Notre-Dame de Lourdes', '&F�lix', '!B�atrice', '&Valentin', '&Claude',
      '!Julienne', '&Alexis', '!Bernadette', '&Gabin', '!Aim�e',
      '&Pierre Damien', '!Isabelle', '&Lazare', '&Modeste', '&Rom�o', '&Nestor',
      '!Honorine', '&Romain', '&Auguste' ],
    # mars
    [ '&Aubin', '&Charles le Bon', '&Gu�nol�', '&Casimir', '&Olive', '&Colette',
      '!F�licit�', '&Jean de Dieu', '!Fran�oise', '&Vivien', '!Rosine',
      '!Justine', '&Rodrigue', '!Mathilde', '!Louise de Marillac', '!B�n�dicte',
      '&Patrice', '&Cyrille', '&Joseph', '&Herbert', '!Cl�mence', '!L�a',
      '&Victorien', '!Catherine de Su�de', '-Annonciation', '!Larissa',
      '&Habib', '&Gontran', '!Gwladys', '&Am�d�e', '&Benjamin' ],
    # avril
    [ '&Hugues', '!Sandrine', '&Richard', '&Isodore', '!Ir�ne', '&Marcellin',
      '&Jean-Baptiste de la Salle', '!Julie', '&Gautier', '&Fulbert',
      '&Stanislas', '&Jules', '!Ida', '&Maxime', '&Paterne',
      '&Beno�t-Joseph Labre', '&Anicet', '&Parfait', '!Emma', '!Odette',
      '&Anselme', '&Alexandre', '&Georges', '&Fid�le', '&Marc', '!Alida',
      '!Zita', '!Val�rie', '!Catherine de Sienne', '&Robert' ],
    # mai
    [ '&J�r�mie - FETE du TRAVAIL', '&Boris', '&Philippe / Jacques', '&Sylvain',
      '!Judith', '!Prudence', '!Gis�le', '&D�sir� - ANNIVERSAIRE 1945',
      '&Pac�me', '!Solange', '!Estelle', '&Achille', '!Rolande', '&Mathias',
      '!Denise', '&Honor�', '&Pascal', '&Eric', '&Yves', '&Bernardin',
      '&Constantin', '&Emile', '&Didier', '&Donatien', '!Sophie', '&B�renger',
      '&Augustin', '&Germain', '&Aymar', '&Ferdinand', '-Visitation' ],
    # juin
    [ '&Justin', '!Blandine', '&K�vin', '!Clotilde', '&Igor', '&Norbert',
      '&Gilbert', '&M�dard', '!Diane', '&Landry', '&Barnab�', '&Guy',
      '&Antoine de Padoue', '&Elis�e', '!Germaine', '&Jean-Fran�ois R�gis',
      '&Herv�', '&L�once', '&Romuald', '&Silv�re', '&Rodolphe', '&Alban',
      '!Audrey', '&Jean-Baptiste', '&Salomon', '&Anthelme', '&Fernand',
      '&Ir�n�e', '&Pierre / Paul', '&Martial' ],
    # juillet
    [ '&Thierry', '&Martinien', '&Thomas', '&Florent', '&Antoine', '!Mariette',
      '&Raoul', '&Thibaut', '!Amandine', '&Ulrich', '&Beno�t', '&Olivier',
      '&Henri / Jo�l', '!Camille - FETE NATIONALE', '&Donald',
      '-N.D. du Mont Carmel', '!Charlotte', '&Fr�d�ric', '&Ars�ne', '!Marina',
      '&Victor', '!Marie-Madeleine', '!Brigitte', '!Christine', '&Jacques',
      '&Anne', '!Nathalie', '&Samson', '!Marthe', '!Juliette',
      '&Ignace de Loyola' ],
    # ao�t
    [ '&Alphonse', '&Julien', '!Lydie', '&Jean-Marie Vianney', '&Abel',
      '-Transfiguration', '&Ga�tan', '&Dominique', '&Amour', '&Laurent',
      '!Claire', '!Clarisse', '&Hippolyte', '&Evrard',
      '!Marie - ASSOMPTION', '&Armel', '&Hyacinthe', '!H�l�ne', '&Jean Eudes',
      '&Bernard', '&Christophe', '&Fabrice', '!Rose de Lima', '&Barth�l�my',
      '&Louis', '!Natacha', '!Monique', '&Augustin', '!Sabine', '&Fiacre',
      '&Aristide' ],
    # septembre
    [ '&Gilles', '!Ingrid', '&Gr�goire', '!Rosalie', '!Ra�ssa', '&Bertrand',
      '!Reine', '-Nativit� de Marie', '&Alain', '!In�s', '&Adelphe',
      '&Apollinaire', '&Aim�', '-La Ste Croix', '&Roland', '!Edith', '&Renaud',
      '!Nad�ge', '!Emilie', '&Davy', '&Matthieu', '&Maurice', '&Constant',
      '!Th�cle', '&Hermann', '&C�me / Damien', '&Vincent de Paul', '&Venceslas',
      '&Michel / Gabriel', '&J�r�me' ],
    # octobre
    [ '!Th�r�se de l\'Enfant J�sus', '&L�ger', '&G�rard', '&Fran�ois d\'Assise',
      '!Fleur', '&Bruno', '&Serge', '!P�lagie', '&Denis', '&Ghislain', '&Firmin',
      '&Wilfried', '&G�raud', '&Juste', '!Th�r�se d\'Avila', '!Edwige',
      '&Baudouin', '&Luc', '&Ren�', '!Adeline', '!C�line', '!Elodie',
      '&Jean de Capistran', '&Florentin', '&Cr�pin', '&Dimitri', '!Emeline',
      '&Simon / Jude', '&Narcisse', '!Bienvenue', '&Quentin' ],
    # novembre
    [ '&Harold - TOUSSAINT', '-D�funts', '&Hubert', '&Charles', '!Sylvie',
      '!Bertille', '!Carine', '&Geoffroy', '&Th�odore', '&L�on',
      '&Martin - ARMISTICE 1918', '&Christian', '&Brice', '&Sidoine', '&Albert',
      '!Marguerite', '!Elisabeth', '!Aude', '&Tanguy', '&Edmond',
      '-Pr�sentation de Marie', '!C�cile', '&Cl�ment', '!Flora', '!Catherine',
      '!Delphine', '&S�verin', '&Jacques de la Marche', '&Saturnin', '&Andr�' ],
    # d�cembre
    [ '!Florence', '!Viviane', '&Xavier', '!Barbara', '&G�rald', '&Nicolas',
      '&Ambroise', '-Immacul�e Conception', '&Pierre Fourier', '&Romaric',
      '&Daniel', '!Jeanne de Chantal', '!Lucie', '!Odile', '!Ninon', '!Alice',
      '&Ga�l', '&Gatien', '&Urbain', '&Abraham', '&Pierre Canisius',
      '!Fran�oise-Xavier', '&Armand', '!Ad�le', '&Emmanuel - NOEL', '&Etienne',
      '&Jean', '-Sts Innocents', '&David', '&Roger', '&Sylvestre' ],
);

sub fete_jour
{
    my ($sec, $min, $heure, $mjour, $mois, $annee, $sjour, $ajour, $est_dst) = localtime ($_[0]);
    my $fete = $fetes[$mois][$mjour-1];
    $fete =~ s/^!/Ste /;
    $fete =~ s/^&/St /;
    $fete =~ s/^-//;
    $fete;
}

sub fete
{
    if ($#_ == 1)
    {
        my @params = split " ", @_[1];
        for $arg (@params)
        {
            for (my $mois = 0; $mois <= $#fetes; $mois++)
            {
                for (my $jour = 0; $jour < 31; $jour++)
                {
                    if (uc ($fetes[$mois][$jour]) =~ /\U$arg/)
                    {
                        weechat::print (($jour + 1)." ".$noms_mois[$mois].": ".substr ($fetes[$mois][$jour], 1));
                    }
                }
            }
        }
    }
    else
    {
        my $time_now = time;
        my ($fete1, $fete2) = (fete_jour ($time_now), fete_jour ($time_now + (3600 * 24)));
        my ($mjour, $mois, $sjour) = (localtime ($time_now))[3, 4, 6];
        weechat::print_infobar (0, "$fete1 (demain: $fete2)");
    }
    return weechat::PLUGIN_RC_OK;
}

fete ();
