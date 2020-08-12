#!/usr/bin/env python3
##############################################################################
## This file is part of 'ATLAS RD53 DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'ATLAS RD53 DEV', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

import pyrogue as pr

class EmuTimingLut(pr.Device):
    def __init__(   self,
        name        = "EmuTimingLut",
        description = "Container for EmuTiming LUT",
        ADDR_WIDTH_G = 10,
        **kwargs):

        super().__init__(name=name,description=description,**kwargs)

        self.addRemoteVariables(
            name        = 'MEM',
            offset      = 0x0,
            number      =  2**ADDR_WIDTH_G,
            bitSize     =  32,
            bitOffset   =  0,
            stride      =  4,
            mode        = "RW",
            hidden      = True,
        )

class EmuTimingFsm(pr.Device):
    def __init__(   self,
        name        = "EmuTimingFsm",
        description = "Container for EmuTiming FSM registers",
        ADDR_WIDTH_G = 10,
        **kwargs):

        super().__init__(name=name,description=description,**kwargs)

        self.add(pr.RemoteCommand(
            name        = "OneShot",
            description = "One-shot trigger the FSM",
            offset      = 0x00,
            bitSize     = 1,
            function    = lambda cmd: cmd.post(1),
        ))

        self.add(pr.RemoteVariable(
            name         = 'TimerSize',
            description  = 'Sets the timer\'s timeout configuration size between iterations',
            offset       = 0x04,
            bitSize      = 32,
            mode         = 'RW',
            units        = '1/160MHz',
        ))

        self.add(pr.RemoteVariable(
            name         = 'MaxAddr',
            description  = 'Max address used in the looping through the timing/trigger pattern LUTs',
            offset       = 0x08,
            bitSize      = ADDR_WIDTH_G,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'Iteration',
            description  = 'Number of time to loop through the timing/trigger pattern LUTs',
            offset       = 0x0C,
            bitSize      = 16,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'BackPreasureCnt',
            description  = 'Increments when back pressure detected during AXIS streaming',
            offset       = 0x10,
            bitSize      = 32,
            mode         = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name         = 'Busy',
            description  = '0x0 in IDLE state else 0x1',
            offset       = 0x14,
            bitSize      = 1,
            mode         = 'RO',
        ))
