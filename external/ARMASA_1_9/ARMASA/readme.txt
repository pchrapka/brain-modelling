
ARMASA Toolbox for use with Matlab
==================================

This ARMASA Toolbox is developed on a Windows OS platform using 
Matlab R11.1 and tested, optimizing performance, using Matlab R12. 
Care has been taken to develop program code that should also run well 
on platforms with other operating systems and on Octave.

Required Matlab version (any OS): R11 or later

Title to ownership
------------------

Any part of the ARMASA software package may freely be used for 
scientific or educational purposes. For commercial applications, 
permission is required from P.M.T. Broersen (address stated below).

How to Install in Matlab
------------------------

1. Unzip the file ARMASA_1_X.ZIP (X = number) to a directory where
   you want the main ARMASA directory to reside. An obvious choice is
   to locate it where other Matlab toolboxes are installed. To do this
   choose '...\Matlab\Toolbox' as the directory to extract the files.
   Be sure the 'Use folder names option' is checked.

2. Start Matlab.

3. Select the ARMASA directory as the current working directory in
   Matlab. From the command prompt, using the command 'cd' and typing
   the full path to the ARMASA directory, will do so. Type 'help cd'
   for more information. Alternatively, you can use the graphical
   user interface, like the path browser in R11.

4. Type 'ASAaddpath'. Search paths, needed to access the various
   functions of the ARMASA toolbox, will then be added to the default
   search paths. You must decide whether the paths will be 
   "prepended" to the existing paths, resulting in the highest
   priority compared to other functions on search, or "appended",
   resulting in the lowest search priority.

How to Uninstall
----------------

1. Start Matlab.

2. Type 'ASArmpath' to remove the previously added ARMASA toolbox 
   paths.

3. Remove the directory ARMASA and its entire contents.

To Get Started with ARMASA
--------------------------

Once installed, type 'help ARMASA'.
Look for simple applications in the three demo programs

User support
------------
Book:
   Piet M.T. Broersen
   Automatic Autocorrelation and Spectral Analysis
   Springer-Verlag,London, 2006.
   ISBN 1-84628-328.

Journal paper:
   P. M. T. Broersen, Automatic Spectral Analysis with Time Series Models, 
   IEEE Trans. Instrum. Meas., Vol. 51, No. 2, April 2002, pp. 211-216.

   and many other papers listed in ARMASA info.txt 


Any questions on the theoretical foundations and the applicability of 
the functions can be submitted to: 
p.m.t.broersen@tudelft.nl or to
p.broersen@xs4all.nl  

P.M.T. Broersen
Delft University of Technology
Faculty of Multi-Scale Physics
Prins Bernhardlaan 6
2628 BW Delft
the Netherlands
email: p.m.t.broersen@tudelft.nl
       p.broersen@xs4all.nl  

