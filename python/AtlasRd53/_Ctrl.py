#!/usr/bin/env python3
#-----------------------------------------------------------------------------
# This file is part of the 'ATLAS RD53 FMC DEV'. It is subject to 
# the license terms in the LICENSE.txt file found in the top-level directory 
# of this distribution and at: 
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
# No part of the 'ATLAS RD53 FMC DEV', including this file, may be 
# copied, modified, propagated, or distributed except according to the terms 
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import pyrogue as pr
        
class Ctrl(pr.Device):
    def __init__(   self,       
            name        = "Ctrl",
            description = "Ctrl Container",
            pollInterval = 1,
            **kwargs):
        super().__init__(name=name, description=description, **kwargs) 

        statusCntBitSize = 16

        self.addRemoteVariables(   
            name         = 'LinkUpCnt',
            description  = 'Status counter for link up',
            offset       = 0x000,
            bitSize      = statusCntBitSize,
            mode         = 'RO',
            number       = 4,
            stride       = 4,
            pollInterval = pollInterval,
        )        
        
        self.add(pr.RemoteVariable(
            name         = 'ChBondCnt',
            description  = 'Status counter for channel bonding',
            offset       = 0x010,
            bitSize      = statusCntBitSize,
            mode         = 'RO',
            pollInterval = pollInterval,
        ))        
                
        self.add(pr.RemoteVariable(
            name         = 'ConfigDropCnt',
            description  = 'Increments when config dropped due to back pressure',
            offset       = 0x014,
            bitSize      = statusCntBitSize,
            mode         = 'RO',
            pollInterval = pollInterval,
        ))   

        self.add(pr.RemoteVariable(
            name         = 'DataDropCnt',
            description  = 'Increments when data dropped due to back pressure',
            offset       = 0x018,
            bitSize      = statusCntBitSize,
            mode         = 'RO',
            pollInterval = pollInterval,
        ))  

        self.add(pr.RemoteVariable(
            name         = 'SingleHdrDetCnt',
            description  = 'Increments when 64-bit word sent to SW has only 1 event header detected',
            offset       = 0x020,
            bitSize      = statusCntBitSize,
            mode         = 'RO',
            disp         = '{:d}',
            pollInterval = pollInterval,
        ))

        self.add(pr.RemoteVariable(
            name         = 'DoubleHdrDetCnt',
            description  = 'Increments when 64-bit word sent to SW has only 2 event header detected',
            offset       = 0x024,
            bitSize      = statusCntBitSize,
            mode         = 'RO',
            disp         = '{:d}',
            pollInterval = pollInterval,
        )) 

        self.add(pr.RemoteVariable(
            name         = 'SingleHitDetCnt',
            description  = 'Increments when 64-bit word sent to SW has only 1 hit data detected',
            offset       = 0x028,
            bitSize      = statusCntBitSize,
            mode         = 'RO',
            disp         = '{:d}',
            pollInterval = pollInterval,
        ))

        self.add(pr.RemoteVariable(
            name         = 'DoubleHitDetCnt',
            description  = 'Increments when 64-bit word sent to SW has only 2 hit data detected',
            offset       = 0x02C,
            bitSize      = statusCntBitSize,
            mode         = 'RO',
            disp         = '{:d}',
            pollInterval = pollInterval,
        ))         
        
        self.add(pr.RemoteVariable(
            name         = 'WrdSentCnt',
            description  = 'Increments when 64-bit word sent to SW',
            offset       = 0x01C,
            bitSize      = statusCntBitSize,
            mode         = 'RO',
            disp         = '{:d}',
            pollInterval = pollInterval,
        ))  

        self.add(pr.LinkVariable(
            name         = 'TotalHdrDetCnt', 
            description  = 'Increments when 64-bit word sent to SW has event header detected',
            mode         = 'RO', 
            dependencies = [self.SingleHdrDetCnt,self.DoubleHdrDetCnt],
            linkedGet    = lambda: self.SingleHdrDetCnt.value() + 2*self.DoubleHdrDetCnt.value(),
            value        = 0,
        ))   

        self.add(pr.LinkVariable(
            name         = 'TotalHitDetCnt', 
            description  = 'Increments when 64-bit word sent to SW has hit data detected',
            mode         = 'RO', 
            dependencies = [self.SingleHitDetCnt,self.DoubleHitDetCnt],
            linkedGet    = lambda: self.SingleHitDetCnt.value() + 2*self.DoubleHitDetCnt.value(),
            value        = 0,
        ))           
        
        self.addRemoteVariables(   
            name         = 'AuroraHdrErrDet',
            description  = 'Increments when the Aurora 2-bit header is not 10 or 01',
            offset       = 0x030,
            bitSize      = statusCntBitSize,
            mode         = 'RO',
            number       = 4,
            stride       = 4,
            pollInterval = pollInterval,
        )   

        self.addRemoteVariables(   
            name         = 'GearBoxBitSlipCnt',
            description  = 'Increments whenever there is a gearbox bit slip executed',
            offset       = 0x040,
            bitSize      = statusCntBitSize,
            mode         = 'RO',
            number       = 4,
            stride       = 4,
            pollInterval = pollInterval,
        )           

        self.add(pr.RemoteVariable(
            name         = 'CmdBusyCnt',
            description  = 'Increments when CMD FIFO is not empty event',
            offset       = 0x050,
            bitSize      = statusCntBitSize,
            mode         = 'RO',
            disp         = '{:d}',
            pollInterval = pollInterval,
        ))
        
        self.add(pr.RemoteVariable(
            name         = 'DownlinkUpCnt',
            description  = 'Increments when lpGBT downlink is up event',
            offset       = 0x054,
            bitSize      = statusCntBitSize,
            mode         = 'RO',
            disp         = '{:d}',
            pollInterval = pollInterval,
        )) 

        self.add(pr.RemoteVariable(
            name         = 'UplinkUpCnt',
            description  = 'Increments when lpGBT uplink is up event',
            offset       = 0x058,
            bitSize      = statusCntBitSize,
            mode         = 'RO',
            disp         = '{:d}',
            pollInterval = pollInterval,
        ))         

        self.add(pr.RemoteVariable(
            name         = 'LinkUp',
            description  = 'link up',
            offset       = 0x400,
            bitSize      = 4, 
            bitOffset    = 0,
            mode         = 'RO',
            pollInterval = pollInterval,
        ))         
        
        self.add(pr.RemoteVariable(
            name         = 'ChBond',
            description  = 'channel bonding',
            offset       = 0x400,
            bitSize      = 1, 
            bitOffset    = 4,
            mode         = 'RO',
            pollInterval = pollInterval,
        ))        

        self.add(pr.RemoteVariable(
            name         = 'CmdBusy',
            description  = 'CMD FIFO is not empty',
            offset       = 0x400,
            bitSize      = 1,
            bitOffset    = 20,
            mode         = 'RO',
            pollInterval = pollInterval,
        ))
        
        self.add(pr.RemoteVariable(
            name         = 'DownlinkUp',
            description  = 'lpGBT Downlink Status',
            offset       = 0x400,
            bitSize      = 1,
            bitOffset    = 21,
            mode         = 'RO',
            pollInterval = pollInterval,
        ))

        self.add(pr.RemoteVariable(
            name         = 'UplinkUp',
            description  = 'lpGBT Uplink Status',
            offset       = 0x400,
            bitSize      = 1,
            bitOffset    = 22,
            mode         = 'RO',
            pollInterval = pollInterval,
        ))        
        
        self.addRemoteVariables(   
            name         = 'AutoRead',
            description  = 'RD53 auto-read register',
            offset       = 0x410,
            bitSize      = 32,
            mode         = 'RO',
            number       = 4,
            stride       = 4,
            pollInterval = pollInterval,
        )     

        self.addRemoteVariables(   
            name         = 'RxDelayTap',
            description  = 'RX IDELAY tap configuration (Note: For 7-series FPGAs the 5-bit config is mapped like dlyCfg(8 downto 4) to the most significant bits)',
            offset       = 0x420,
            bitSize      = 9,
            mode         = 'RO',
            number       = 4,
            stride       = 4,
            pollInterval = pollInterval,
        )             
        
        self.add(pr.RemoteVariable(
            name         = 'EnLane', 
            description  = 'Enable Lane Mask',
            offset       = 0x800,
            bitSize      = 4, 
            mode         = 'RW',
        )) 

        self.add(pr.RemoteVariable(
            name         = 'InvData', 
            description  = 'Invert the serial data bits',
            offset       = 0x804,
            bitSize      = 4, 
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'InvCmd', 
            description  = 'Invert the serial CMD bit',
            offset       = 0x808,
            bitSize      = 1, 
            bitOffset    = 0,
            mode         = 'RW',
        )) 

        self.add(pr.RemoteVariable(
            name         = 'DlyCmd', 
            description  = '0x1: add 3.125 ns delay on the CMD output (used to deskew the CMD from discrete re-timing flip-flop IC)',
            offset       = 0x808,
            bitSize      = 1, 
            bitOffset    = 1,
            mode         = 'RW',
            units        = '3.125 ns',
        ))         
        
        for i in range(4):
            self.add(pr.RemoteVariable(
                name         = ('RxPhyXbar[%d]'%i), 
                description  = 'RD53 Lane 4:4 lane crossbar configuration',
                offset       = 0x80C,
                bitOffset    = (2*i),
                bitSize      = 2, 
                mode         = 'RW',
            )) 

        self.add(pr.RemoteVariable(
            name         = 'SelectRate', 
            description  = 'SelectRate and RD53.SEL_SER_CLK[2:0] must be the same (default of 0x0 = 1.28Gbps)',
            offset       = 0x80C,
            bitSize      = 2, 
            bitOffset    = 8,
            mode         = 'RW',
        ))               
        
        self.add(pr.RemoteVariable(
            name         = 'DebugStream', 
            description  = 'Enables the interleaving of autoreg and read responses into the dataStream path',
            offset       = 0x810,
            bitSize      = 1, 
            mode         = 'RW',
        ))   

        self.add(pr.RemoteVariable(
            name         = 'EnUsrDlyCfg', 
            description  = 'Enables the User to override the automatic RX IDELAY tap configuration (Note: For 7-series FPGAs the 5-bit config is mapped like dlyCfg(8 downto 4) to the most significant bits)',
            offset       = 0x814,
            bitSize      = 1, 
            mode         = 'RW',
        ))  
        
        self.add(pr.RemoteVariable(
            name         = 'LockingCntCfg', 
            description  = 'Sets the number of good 2-bit headers required for locking per delay step sweep',
            offset       = 0x818,
            bitSize      = 24, 
            mode         = 'RW',
        ))          
        
        self.addRemoteVariables(   
            name         = 'UserRxDelayTap',
            description  = 'Sets the RX IDELAY tap configuration (A.K.A. RxDelayTap) when EnUsrDlyCfg = 0x1',
            offset       = 0x820,
            bitSize      = 9,
            mode         = 'RW',
            number       = 4,
            stride       = 4,
        )   
        
        self.addRemoteVariables(   
            name         = 'MinEyeWidth',
            description  = 'Sets the min. eye width in the RX IDELAY eye scan',
            offset       = 0x830,
            bitSize      = 8,
            mode         = 'RW',
            number       = 4,
            stride       = 4,
        )           
        
        self.add(pr.RemoteVariable(
            name         = 'BatchSize', 
            description  = 'Number of 64-bit (8 bytes) words to batch together into a AXIS frame',
            offset       = 0xFF0,
            bitSize      = 16, 
            bitOffset    = 0,
            mode         = 'RW',
            units        = '8Bytes',
            base         = pr.UInt,
        ))  

        self.add(pr.RemoteVariable(
            name         = 'TimerConfig', 
            description  = 'Batcher timer configuration',
            offset       = 0xFF0,
            bitSize      = 16, 
            bitOffset    = 16,
            mode         = 'RW',
            units        = '6.4ns',
            base         = pr.UInt,
        ))   
        
        self.add(pr.RemoteCommand(   
            name         = 'PllRst',
            description  = 'FPGA Internal PLL reset',
            offset       = 0xFF4,
            bitSize      = 1,
            bitOffset    = 0,
            function     = lambda cmd: cmd.toggle(),
            hidden       = False,
        ))

        self.add(pr.RemoteCommand(
            name         = 'LocalRst',
            description  = 'Local 160MHz Reset',
            offset       = 0xFF4,
            bitSize      = 1,
            bitOffset    = 1,
            function     = lambda cmd: cmd.toggle(),
            # hidden       = False,
        ))

        self.add(pr.RemoteVariable(
            name         = 'RollOverEn', 
            description  = 'Rollover enable for status counters',
            offset       = 0xFF8,
            bitSize      = 7, 
            mode         = 'RW',
        ))        
        
        self.add(pr.RemoteCommand(   
            name         = 'CntRst',
            description  = 'Status counter reset',
            offset       = 0xFFC,
            bitSize      = 1,
            function     = lambda cmd: cmd.post(1),
            hidden       = False,
        ))  

    def hardReset(self):
        self.CntRst()

    def softReset(self):
        self.CntRst()

    def countReset(self):
        self.CntRst()
     
