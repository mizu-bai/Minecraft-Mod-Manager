#!/usr/bin/env perl

=pod

=head1 Minecraft Mod Manager

Author: Mizu-Bai

Date: Feb. 24 2022

=head2 Introduction

Here is a Minecraft Mod Manager supports some features. For details see Usage
section.

More features will be added in the future, including mod download, search, etc.


=head2 Usage

 ./mcmm.pl [option]

Avaliable Commands:

=over 4

=item

Install local mods (aka. .jar files)

 ./mcmm.pl --install local_mod.jar [ another_local_mod.jar ... ]
 ./mcmm.pl -i local_mod.jar [ another_local_mod.jar ... ]

=item

Uninstall installed mods

 ./mcmm.pl --uninstall some_mod [ another_mod ... ]
 ./mcmm.pl -ui some_mod [ another_mod ... ]

=item

List all installed mods

 ./mcmm.pl --list
 ./mcmm.pl -ls

=item

List locally cached mods

 ./mcmm.pl --cache
 ./mcmm.pl -cc

=item

Clean up local caches

 ./mcmm.pl --clean [ specified_mod [ another_specified_mod ... ] ]
 ./mcmm.pl -cl [ specified_mod [ another_specified_mod ... ] ]

=back

=cut

$USAGE_INFO = <<EOF;
Usage:

    ./mcmm.pl [option]

Avaliable Commands:

Install local mods (aka. .jar files)

    ./mcmm.pl --install local_mod.jar [ another_local_mod.jar ... ]
    ./mcmm.pl -i local_mod.jar [ another_local_mod.jar ... ]

Uninstall installed mods

    ./mcmm.pl --uninstall some_mod [ another_mod ... ]
    ./mcmm.pl -ui some_mod [ another_mod ... ]

List all installed mods

    ./mcmm.pl --list
    ./mcmm.pl -ls

Clean up local caches

    ./mcmm.pl --clean [ specified_mod [ another_specified_mod ... ] ]
    ./mcmm.pl -cl [ specified_mod [ another_specified_mod ... ] ]

Show help

    ./mcmm.pl --help
    ./mcmm.pl -help

EOF

use Switch;

%opt_hash = (
    install   => ["--install", "-i"],
    uninstall => ["--uninstall", "-ui"],
    list      => ["--list", "-ls"],
    cache     => ["--cache", "-cc"],
    clean     => ["--clean", "-cl"],
);

sub print_array {
    for (@_) {
        print $_ . "\n";
    }
}

sub mcmm_install {

}

sub mcmm_uninstall {

}

sub mcmm_list {

}

sub mcmm_cache {

}

sub mcmm_clean {

}

sub mcmm_exec {
    if ($#_ == -1) {
        die $USAGE_INFO;
    }
    $opt = shift;
    for (@_) {
        die "Too much options received!\n" if (m/^-{1,2}/);
    }
    switch ($opt) {
        case ($opt_hash{install}) {
            die "Error: No mod to install!\n" if ($#_ == -1);
            print "Installing the following mod(s):\n";
            print_array @_;
            mcmm_install @_;
        } case ($opt_hash{uninstall}) {
            die "Error: No mod to unnstall!\n" if ($#_ == -1);
            print "Unstalling the following mod(s):\n";
            print_array @_;
            #mcmm_uninstall @_;
        } case ($opt_hash{list}) {
            die "Error: --list (-l) option accecpts no argument!\n" if ($#_ > -1);
            print "# should list installed mods #\n";
            #mcmm_list;
        } case ($opt_hash{cache}) {
            die "Error: --cache (-cc) option accecpts no argument!\n" if ($#_ > -1);
            print "# should list cached mods #\n";
            #mcmm_cache;
        } case ($opt_hash{clean}) {
            if ($#_ == - 1) {
                print "Warning: No mod specified, cleaning all cached mod(s):\n";
                #mcmm_clean;
            } else {
                print "Cleaning specited mod(s):\n";
                print_array @_;
                #mcmm_clean @_;
            }
        } else {
            die "Error: Unknown option: $opt\n\n$USAGE_INFO";
        }
    }
}

mcmm_exec @ARGV;
