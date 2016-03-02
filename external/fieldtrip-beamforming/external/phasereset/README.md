phasereset
==========

phasereset is a MATLAB package that allows the generation of simulated EEG data via the classical theory and phase reset. The aim of this project is to provide a more MATLAB friendly version of the original phasereset code in the form of a separate package to avoid name collisions.

The original work and a brief tutorial can be found at http://www.cs.bris.ac.uk/~rafal/phasereset/.

install
-------

Two options:

1. Use the setup script
    ```
    wget https://raw.githubusercontent.com/pchrapka/phasereset/master/setup.sh
    sh setup.sh
    ```
    which downloads and unzips the package into your MATLAB user folder.

2. Clone the repo
    ```
    git clone https://github.com/pchrapka/phasereset.git
    ```

setup
-----

Add the path to your MATLAB project or include it in a startup.m script.
```
addpath('/home/user/Documents/MATLAB/phasereset');
```

usage
-----

Use the functions within your script by referencing the package functions
```
phasereset.peak()
phasereset.noise()
etc.
```