#!/usr/bin/env perl

# packages and features
use Switch;
use File::Path qw(make_path);
use File::Copy qw(copy);
use File::Basename;
use File::Spec;

## Constants
# usage information
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


## Output Format (no indentation here)
# list installed mod top
format INSTALLED_MODS_TOP =
======================================================================
 Index                              Mod Name
======================================================================
.

# list installed mod content
format INSTALLED_MODS = 
@||||| @|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
"[$order]", $name
.

# list cached mod top
format CACHED_MODS_TOP =
======================================================================
  Index                     Mod Name                       Installed
======================================================================
.

# list cached mod content
format CACHED_MODS =  
@||||| @||||||||||||||||||||||||||||||||||||||||||||||||||| @||||||||
"[$order]", $name, "[$install_flag]"
.


# options
%opt_hash = (
    install   => ["--install", "-i"],
    uninstall => ["--uninstall", "-ui"],
    list      => ["--list", "-ls"],
    cache     => ["--cache", "-cc"],
    clean     => ["--clean", "-cl"],
);

# mods dir
$MODS_DIR = "./serverfile/mods";
# cache dir
$CACHE_DIR = "./serverfile/.cache";

## Subroutines
# auxiliary subroutines
sub print_array {
    print $_ . "\n" for (@_);
}

# create directory
sub create_dir {
    $dir = shift;
    print "Creating `$dir`...\n";
    make_path $dir or die "Cannot create `$dir`, $!";
}

# check mod dir
sub check_mod_dir {
    if (not -e $MODS_DIR) {
        print "No directory for mod installation.\n";
        create_dir $MODS_DIR;
    }
}

# check cache dir
sub check_cache_dir {
    if (not -e $CACHE_DIR) {
        print "No directory for mod cache.\n";
        create_dir $CACHE_DIR;
    }
}

# install mods
sub mcmm_install {
    check_mod_dir;
    check_cache_dir;
    for (@_) {
        if (-e) {
            ($mod_name, $directory, $suffix) = fileparse $_;
            $mod_install_dest = File::Spec->catfile($MODS_DIR, $mod_name);
            $mod_cache_dest = File::Spec->catfile($CACHE_DIR, $mod_name);
            print "Copying $mod_name to $CACHE_DIR\n";
            copy $_, $CACHE_DIR or die "Cannot install mod $mod_name, $!";
            print "Linking $mod_cache_dest -> $mod_cache_dest\n";
            symlink $mod_cache_dest, $mod_install_dest or die "Cannot link mod $_, $!";
        } else {
            warn "No such file `$_`.\n";
        }
    }
    print "Done.\n";
}

# uninstall mods
sub mcmm_uninstall {

}

# list installed mods
sub mcmm_list {
    check_mod_dir;
    opendir (DIR, $MODS_DIR);
    @mods = sort grep(/^.*\.jar$/, readdir DIR);
    if ($#mods == -1) {
        closedir DIR;
        die "There is no mod installed in `$MODS_DIR`! Please add some!\n";
    }

    # set format
    select STDOUT;
    $^ = INSTALLED_MODS_TOP;
    $~ = INSTALLED_MODS;

    # output
    for ($i = 0; $i <= $#mods; $i++) {
        $order = $i + 1;
        $name = $mods[$i];
        write;
    }
    closedir DIR;
}

# list cached mods
sub mcmm_cache {
    check_mod_dir;
    check_cache_dir;
    opendir (CACHE_DIR, $CACHE_DIR);
    @cached_mods = sort grep(/^.*\.jar/, readdir CACHE_DIR);
    if ($#cached_mods == -1) {
        closedir CACHE_DIR;
        die "No local cache found.\n";
    }

    opendir (INSTALL_DIR, $MODS_DIR);
    @installed_mods = sort grep(/^.*\.jar/, readdir INSTALL_DIR);

    # set format
    $^ = CACHED_MODS_TOP;
    $~ = CACHED_MODS;

    # output
    for ($i = 0; $i <= $#cached_mods; $i++) {
        $order = $i + 1;
        $name = $cached_mods[$i];
        $install_flag = grep(/^$name/, @installed_mods) ? "x" : " ";
        write;
    }
    closedir CACHE_DIR;
    closedir INSTALL_DIR;
}

# clean local cache
sub mcmm_clean {

}

# execute option
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
            mcmm_uninstall @_;
        } case ($opt_hash{list}) {
            die "Error: --list (-l) option accecpts no argument!\n" if ($#_ > -1);
            mcmm_list;
        } case ($opt_hash{cache}) {
            die "Error: --cache (-cc) option accecpts no argument!\n" if ($#_ > -1);
            mcmm_cache;
        } case ($opt_hash{clean}) {
            if ($#_ == - 1) {
                print "Warning: No mod specified, cleaning all cached mod(s):\n";
                mcmm_clean;
            } else {
                print "Cleaning specited mod(s):\n";
                print_array @_;
                mcmm_clean @_;
            }
        } else {
            die "Error: Unknown option: $opt\n\n$USAGE_INFO";
        }
    }
}

## Entry
# run
mcmm_exec @ARGV;

__DATA__

## Document
=pod

=head1 Minecraft Mod Manager

Author: Mizu-Bai

Date: Feb. 24 2022

=head2 Introduction

Here is a Minecraft Mod Manager supports some features. For details see Usage section.

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

=head2 License

BSD 2-Clause License

Copyright (c) 2022, mizu-bai
All rights reserved.

=cut
