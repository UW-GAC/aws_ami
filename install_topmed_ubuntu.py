#!/usr/bin/python
# install if necessary the topmed pipeline packages
from        argparse  import ArgumentParser
import      sys
import      os
import      os.path
import      subprocess


def pError(msg):
    print ">>> Error creating topmed pkg install script:\n\t" + msg

defScript = "installtopmed.R"
parser = ArgumentParser( description = "Create script to install topmed pipeline" )
parser.add_argument( "rlibpath",help = "Path to the topmed r-packages" )
parser.add_argument("-s", "--script",help = "Name of the R script to create",
                    default = defScript )

args = parser.parse_args()
rlibpath = args.rlibpath
rscript = args.script

# check if it exists

if not os.path.isdir( rlibpath ):
    pError( "R library path " + rlibpath + " does not exist" )
    sys.exit(2)

# list of bioconductor and other r packages
bioc_pkgs=["SeqVarTools"  , "SNPRelate", "GENESIS", "argparser", "dplyr", "tidyr", "ggplot2", "GGally"]
r_pkgs=["devtools", "survey", "CompQuadForm", "rmarkdown", "GENESIS"]

add_bp=False
for bp in bioc_pkgs:
    # check if the directory exist; if not
    if not os.path.isdir( rlibpath+"/"+bp ):
        if not add_bp:
            add_bp=True
            # open the file; write the the first lines
            sfile=open(rscript,'w')
            sfile.write('#!/usr/local/bin/Rscript --vanilla --no-save --slave\n')
            sfile.write('source("https://bioconductor.org/biocLite.R")\n')
        # write the PKG
        sfile.write('biocLite("%s")\n' % bp )

add_rp=False
for rp in r_pkgs:
    # check directory
    if not os.path.isdir( rlibpath+"/"+rp ):
        if add_rp or add_bp:
            if rp != "GENESIS":
                sfile.write('install.packages("%s", rep="https://ftp.osuosl.org/pub/cran/")\n' % rp)
            else:
                sfile.write('library(devtools)')
                sfile.write('devtools::install_git("git://github.com/smgogarten/GENESIS.git")\n')
        else:
            add_rp=True
            sfile=open(rscript,'w')
            sfile.write('#!/usr/local/bin/Rscript --vanilla --no-save --slave\n')
# close the file
if add_rp or add_bp:
    sfile.close()
    sys.exit(0)
else:
    sys.exit(1)
