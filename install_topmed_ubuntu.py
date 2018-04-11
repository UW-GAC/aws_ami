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
parser.add_argument("-s", "--script",help = "Name of the R script to create",
                    default = defScript )

args = parser.parse_args()
rscript = args.script

print(">>> Creating script to install topmed R packages")

# list of bioconductor and other r packages
bioc_pkgs=["SeqVarTools"  , "SNPRelate", "GENESIS", "argparser", "dplyr", "tidyr", "ggplot2", "GGally"]
r_pkgs=["devtools", "survey", "CompQuadForm", "rmarkdown"]

add_bp=False
fileHdr='#!/usr/local/bin/Rscript --no-save --slave\n'
# open the file; write the the first lines
sfile=open(rscript,'w')
sfile.write(fileHdr)
sfile.write('source("https://bioconductor.org/biocLite.R")\n')
for bp in bioc_pkgs:
    sfile.write('biocLite("%s")\n' % bp )

for rp in r_pkgs:
    # check directory
    sfile.write('install.packages("%s", rep="https://ftp.osuosl.org/pub/cran/")\n' % rp)

# install devel for some pkgs
sfile.write('devtools::install_git("git://github.com/zhengxwen/gdsfmt.git")\n')
sfile.write('devtools::install_git("git://github.com/zhengxwen/SeqArray.git")\n')
sfile.write('devtools::install_git("git://github.com/zhengxwen/SNPRelate.git")\n')
sfile.write('devtools::install_git("git://github.com/smgogarten/SeqVarTools.git")\n')
sfile.write('devtools::install_git("git://github.com/smgogarten/GENESIS.git")\n')
sfile.write('devtools::install_git("git://github.com/UW-GAC/genesis2_tests.git")\n')
sfile.write('devtools::install_git("git://github.com/UW-GAC/genesis2.git")\n')

sfile.close()

sys.exit(0)
