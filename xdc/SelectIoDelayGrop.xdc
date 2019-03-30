##############################################################################
## This file is part of 'ATLAS RD53 FMC DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'ATLAS RD53 FMC DEV', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property IODELAY_GROUP xapp_idelay [get_cells U_IDELAYCTRL]
set_property IODELAY_GROUP xapp_idelay [get_cells U_App/GEN_DP[*].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/U_SerDes/loop0[0].idelay_m]
set_property IODELAY_GROUP xapp_idelay [get_cells U_App/GEN_DP[*].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/U_SerDes/loop0[0].idelay_s]
