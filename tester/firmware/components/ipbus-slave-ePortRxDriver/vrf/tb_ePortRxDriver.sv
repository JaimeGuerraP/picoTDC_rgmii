// TODO I still don't know why this step is necessary
//`ifdef SDF
//    `include "/opt/Xilinx/Vivado/2016.4/data/verilog/src/glbl.v"
//`endif

import eportrxdrv_pkg::*;

module tb_ePortRxDriver();
    
    // Specifying the timeunits
    timeunit      1fs;
    timeprecision 1fs;

    // Instantiation parameters
    parameter NUM_GROUPS  = 7;
    parameter NUM_CHAN    = NUM_GROUPS*4;
    parameter MAX_NUM_USER_PACKET = 16;
    parameter USER_DATA_BW        = MAX_NUM_USER_PACKET*32*7;
    parameter OUTDEL_REG_BW       = NUM_CHAN*5;
    parameter NUM_TESTS           = 1000;

    // Operation mode tags and other params
    parameter PER_40M     = 25ns;
    parameter MAX_JITTER  = 0ps;

    // Operation mode registers to be randomized
    OpMode opmode;

    // Connection signals
    bit clk40MHz, reset;
    reg clkSynthLock, delayLineLock;
    reg [NUM_CHAN-1:0] channelStream;
    bit [USER_DATA_BW-1:0]  userData = {(USER_DATA_BW){1'b0}};
    bit [NUM_GROUPS*3-1:0]  dataRateMode;
    bit [NUM_GROUPS*2-1:0]  dataSource;
    bit [NUM_GROUPS*2-1:0]  prbsTypeMode;
    bit [NUM_GROUPS-1:0]    prbsSeedMode = {(NUM_GROUPS){1'b0}};
    bit [NUM_GROUPS*32-1:0] prbsSeed = {(NUM_GROUPS*32){1'b0}};
    bit [OUTDEL_REG_BW-1:0] outputDelay = {(OUTDEL_REG_BW){1'b0}};

    // Instantiation of the DUV, the ePortRxDriver
    `ifdef SDF
        NETLIST_ePortRxDriver EPRX_DRV (
            .userData(userData),
            .dataRateMode(dataRateMode),
            .dataSource(dataSource),
            .prbsTypeMode(prbsTypeMode),
            .sameSeed(prbsSeedMode),
            .prbsSeed(prbsSeed),
            .clk40MHzIn(clk40MHz),
            .pllLock(clkSynthLock),
            .dllLock(delayLineLock),
            .channel(channelStream),
            .outputDelay(outputDelay)
        );
    `else
        ePortRxDriver EPRX_DRV (
            .userData(userData),
            .dataRateMode(dataRateMode),
            .dataSource(dataSource),
            .prbsTypeMode(prbsTypeMode),
            .sameSeed(prbsSeedMode),
            .prbsSeed(prbsSeed),
            .clk40MHzIn(clk40MHz),
            .pllLock(clkSynthLock),
            .dllLock(delayLineLock),
            .channel(channelStream),
            .outputDelay(outputDelay)
        );
    `endif

    // Clock generation
    always begin
        #(PER_40M*0.5 + MAX_JITTER*($random()/real'(32'hffffffff))) clk40MHz = ~clk40MHz;
    end

    covergroup ConfigMode;

        // It is mandatory to exercise all modes of operation
        option.goal = 100;

        PRBSMODE_G0  : coverpoint opmode.prbsMode[0];
        PRBSMODE_G1  : coverpoint opmode.prbsMode[1];
        PRBSMODE_G2  : coverpoint opmode.prbsMode[2];
        PRBSMODE_G3  : coverpoint opmode.prbsMode[3];
        PRBSMODE_G4  : coverpoint opmode.prbsMode[4];
        PRBSMODE_G5  : coverpoint opmode.prbsMode[5];
        PRBSMODE_G6  : coverpoint opmode.prbsMode[6];

        DATAMODE_G0  : coverpoint opmode.dataMode[0] {
            ignore_bins nodata = {NODATA};
        }
        DATAMODE_G1  : coverpoint opmode.dataMode[1] {
            ignore_bins nodata = {NODATA};
        }
        DATAMODE_G2  : coverpoint opmode.dataMode[2] {
            ignore_bins nodata = {NODATA};
        }
        DATAMODE_G3  : coverpoint opmode.dataMode[3] {
            ignore_bins nodata = {NODATA};
        }
        DATAMODE_G4  : coverpoint opmode.dataMode[4] {
            ignore_bins nodata = {NODATA};
        }
        DATAMODE_G5  : coverpoint opmode.dataMode[5] {
            ignore_bins nodata = {NODATA};
        }
        DATAMODE_G6  : coverpoint opmode.dataMode[6] {
            ignore_bins nodata = {NODATA};
        }

        SPEEDMODE_G0 : coverpoint opmode.speedMode[0] {
            ignore_bins nodata = {LSIDLE, HSIDLE};
        }
        SPEEDMODE_G1 : coverpoint opmode.speedMode[1] {
            ignore_bins nodata = {LSIDLE, HSIDLE};
        }
        SPEEDMODE_G2 : coverpoint opmode.speedMode[2] {
            ignore_bins nodata = {LSIDLE, HSIDLE};
        }
        SPEEDMODE_G3 : coverpoint opmode.speedMode[3] {
            ignore_bins nodata = {LSIDLE, HSIDLE};
        }
        SPEEDMODE_G4 : coverpoint opmode.speedMode[4] {
            ignore_bins nodata = {LSIDLE, HSIDLE};
        }
        SPEEDMODE_G5 : coverpoint opmode.speedMode[5] {
            ignore_bins nodata = {LSIDLE, HSIDLE};
        }
        SPEEDMODE_G6 : coverpoint opmode.speedMode[6] {
            ignore_bins nodata = {LSIDLE, HSIDLE};
        }

        SEEDMODE_G0  : coverpoint opmode.prbsSeedMode[0];
        SEEDMODE_G1  : coverpoint opmode.prbsSeedMode[1];
        SEEDMODE_G2  : coverpoint opmode.prbsSeedMode[2];
        SEEDMODE_G3  : coverpoint opmode.prbsSeedMode[3];
        SEEDMODE_G4  : coverpoint opmode.prbsSeedMode[4];
        SEEDMODE_G5  : coverpoint opmode.prbsSeedMode[5];
        SEEDMODE_G6  : coverpoint opmode.prbsSeedMode[6];

        // Cross coverage coverpoints
        CR_PRBS_SPEED_G0 : cross PRBSMODE_G0, SPEEDMODE_G0;
        CR_PRBS_SPEED_G1 : cross PRBSMODE_G1, SPEEDMODE_G1;
        CR_PRBS_SPEED_G2 : cross PRBSMODE_G2, SPEEDMODE_G2;
        CR_PRBS_SPEED_G3 : cross PRBSMODE_G3, SPEEDMODE_G3;
        CR_PRBS_SPEED_G4 : cross PRBSMODE_G4, SPEEDMODE_G4;
        CR_PRBS_SPEED_G5 : cross PRBSMODE_G5, SPEEDMODE_G5;
        CR_PRBS_SPEED_G6 : cross PRBSMODE_G6, SPEEDMODE_G6;

        CR_PRBS_SEED_G0 : cross PRBSMODE_G0, SEEDMODE_G0;
        CR_PRBS_SEED_G1 : cross PRBSMODE_G1, SEEDMODE_G1;
        CR_PRBS_SEED_G2 : cross PRBSMODE_G2, SEEDMODE_G2;
        CR_PRBS_SEED_G3 : cross PRBSMODE_G3, SEEDMODE_G3;
        CR_PRBS_SEED_G4 : cross PRBSMODE_G4, SEEDMODE_G4;
        CR_PRBS_SEED_G5 : cross PRBSMODE_G5, SEEDMODE_G5;
        CR_PRBS_SEED_G6 : cross PRBSMODE_G6, SEEDMODE_G6;

        CR_SPEED_DATA_G0 : cross SPEEDMODE_G0, DATAMODE_G0;
        CR_SPEED_DATA_G1 : cross SPEEDMODE_G1, DATAMODE_G1;
        CR_SPEED_DATA_G2 : cross SPEEDMODE_G2, DATAMODE_G2;
        CR_SPEED_DATA_G3 : cross SPEEDMODE_G3, DATAMODE_G3;
        CR_SPEED_DATA_G4 : cross SPEEDMODE_G4, DATAMODE_G4;
        CR_SPEED_DATA_G5 : cross SPEEDMODE_G5, DATAMODE_G5;
        CR_SPEED_DATA_G6 : cross SPEEDMODE_G6, DATAMODE_G6;
    endgroup

    covergroup DelayMode;
        DELAY_C00 : coverpoint opmode.outputDelay[0];
        DELAY_C01 : coverpoint opmode.outputDelay[1];
        DELAY_C02 : coverpoint opmode.outputDelay[2];
        DELAY_C03 : coverpoint opmode.outputDelay[3];
        DELAY_C04 : coverpoint opmode.outputDelay[4];
        DELAY_C05 : coverpoint opmode.outputDelay[5];
        DELAY_C06 : coverpoint opmode.outputDelay[6];
        DELAY_C07 : coverpoint opmode.outputDelay[7];
        DELAY_C08 : coverpoint opmode.outputDelay[8];
        DELAY_C09 : coverpoint opmode.outputDelay[9];
        DELAY_C10 : coverpoint opmode.outputDelay[10];
        DELAY_C11 : coverpoint opmode.outputDelay[11];
        DELAY_C12 : coverpoint opmode.outputDelay[12];
        DELAY_C13 : coverpoint opmode.outputDelay[13];
        DELAY_C14 : coverpoint opmode.outputDelay[14];
        DELAY_C15 : coverpoint opmode.outputDelay[15];
        DELAY_C16 : coverpoint opmode.outputDelay[16];
        DELAY_C17 : coverpoint opmode.outputDelay[17];
        DELAY_C18 : coverpoint opmode.outputDelay[18];
        DELAY_C19 : coverpoint opmode.outputDelay[19];
        DELAY_C20 : coverpoint opmode.outputDelay[20];
        DELAY_C21 : coverpoint opmode.outputDelay[21];
        DELAY_C22 : coverpoint opmode.outputDelay[22];
        DELAY_C23 : coverpoint opmode.outputDelay[23];
        DELAY_C24 : coverpoint opmode.outputDelay[24];
        DELAY_C25 : coverpoint opmode.outputDelay[25];
        DELAY_C26 : coverpoint opmode.outputDelay[26];
        DELAY_C27 : coverpoint opmode.outputDelay[27];
    endgroup

    // The coverage metrics for user data, non-related to operation modes 
    covergroup UserData;
        option.goal = 90;
        USERDATA_G0 : coverpoint opmode.userData[0];
        USERDATA_G1 : coverpoint opmode.userData[1];
        USERDATA_G2 : coverpoint opmode.userData[2];
        USERDATA_G3 : coverpoint opmode.userData[3];
        USERDATA_G4 : coverpoint opmode.userData[4];
        USERDATA_G5 : coverpoint opmode.userData[5];
        USERDATA_G6 : coverpoint opmode.userData[6];
    endgroup

    ConfigMode  cvg_cfg = new();
    UserData    cvg_dat = new();
    DelayMode   cvg_del = new();
    int testNum = 0;
    real vcvg_cfg, vcvg_dat , vcvg_del;

    initial begin

        $timeformat(-12, 6, " ps", 20);
        opmode = new();

        clk40MHz  = 0;
        reset     = 0;
        outputDelay    = {(OUTDEL_REG_BW){1'b0}}; 

        // Waits for internal PLL to lock
        @(posedge clkSynthLock);

        // Randomize new test
        while( (cvg_cfg.get_coverage() < cvg_cfg.option.goal) && (cvg_dat.get_coverage() < cvg_dat.option.goal) ) begin

            testNum++;
        
            assert(opmode.randomize()); 
            
            cvg_cfg.sample();
            cvg_dat.sample();
            
            $display("TEST # %03d %p", testNum, opmode);
            $display("Current coverage: %.2f -- %.2f -- %.2f", cvg_cfg.get_coverage(), cvg_dat.get_coverage(), cvg_del.get_coverage());
            vcvg_cfg = cvg_cfg.get_coverage();
            vcvg_dat = cvg_dat.get_coverage();
            vcvg_del = cvg_del.get_coverage();

            dataRateMode   = {opmode.speedMode[6], opmode.speedMode[5], opmode.speedMode[4], opmode.speedMode[3], opmode.speedMode[2], opmode.speedMode[1], opmode.speedMode[0]}; 
            dataSource     = {opmode.dataMode[6], opmode.dataMode[5], opmode.dataMode[4], opmode.dataMode[3], opmode.dataMode[2], opmode.dataMode[1], opmode.dataMode[0]};
            prbsTypeMode   = {opmode.prbsMode[6], opmode.prbsMode[5], opmode.prbsMode[4], opmode.prbsMode[3], opmode.prbsMode[2], opmode.prbsMode[1], opmode.prbsMode[0]};
            prbsSeedMode   = {opmode.prbsSeedMode[6], opmode.prbsSeedMode[5], opmode.prbsSeedMode[4], opmode.prbsSeedMode[3], opmode.prbsSeedMode[2], opmode.prbsSeedMode[1], opmode.prbsSeedMode[0]};
            prbsSeed       = {opmode.prbsSeed[6], opmode.prbsSeed[5], opmode.prbsSeed[4], opmode.prbsSeed[3], opmode.prbsSeed[2], opmode.prbsSeed[1], opmode.prbsSeed[0]};
            userData       = {opmode.userData[6], opmode.userData[5], opmode.userData[4], opmode.userData[3], opmode.userData[2], opmode.userData[1], opmode.userData[0]};
            outputDelay    = {opmode.outputDelay[27], opmode.outputDelay[26], opmode.outputDelay[25], opmode.outputDelay[24],
            opmode.outputDelay[23], opmode.outputDelay[22], opmode.outputDelay[21],opmode.outputDelay[20], opmode.outputDelay[19],
            opmode.outputDelay[18], opmode.outputDelay[17], opmode.outputDelay[16],opmode.outputDelay[15], opmode.outputDelay[14],
            opmode.outputDelay[13], opmode.outputDelay[12], opmode.outputDelay[11],opmode.outputDelay[10], opmode.outputDelay[9],
            opmode.outputDelay[8], opmode.outputDelay[7], opmode.outputDelay[6],opmode.outputDelay[5], opmode.outputDelay[4],
            opmode.outputDelay[3], opmode.outputDelay[2], opmode.outputDelay[1], opmode.outputDelay[0]};

            #(250ns);
            if(opmode.testMode == DELAY_TEST) begin
                cvg_del.sample();
                delay_check(outputDelay);
            end
            else fork
                    begin
                        for(int c=0; c < 28; c+=1) begin
                            fork
                                automatic int k=c;
                                begin    
                                    stream_check(k, 25, dataRateMode[3*(k/4) +: 3], dataSource[2*(k/4) +: 2], prbsTypeMode[2*(k/4) +: 2]);  
                                end
                            join_none
                        end
                    wait fork;
                    end
            join
        end
        $stop();

    end

task automatic delay_check(input bit [OUTDEL_REG_BW-1:0] outputDel);
    
    int numCorrChecks = 0;
    int numErrors = 0;
    parameter MAX_NUM_CHECKS = 10;
    int chanToCheckA = 0;
    int chanToCheckB = 0;
    time expectedDelay, firstEdge, measDelay, error;

    begin
        for(int n=0; n < MAX_NUM_CHECKS; n++) begin

            chanToCheckA = $random() % 32'd28;
            chanToCheckB = $random() % 32'd28;
            if(chanToCheckA == chanToCheckB) chanToCheckB++;

            //$display("Measuring delay between %d and %d", chanToCheckA, chanToCheckB);

            if(outputDel[5*chanToCheckA +: 5] < outputDel[5*chanToCheckB +: 5]) begin
                expectedDelay = 52ps * (outputDel[5*chanToCheckB +: 5] - outputDel[5*chanToCheckA +: 5]);
                @(posedge channelStream[chanToCheckA]);
                //$display("Posedge A: %t", $time());
                firstEdge = $time();
                @(posedge channelStream[chanToCheckB]);
                //$display("Posedge B: %t", $time());
                measDelay = $time() - firstEdge;
            end
            else begin
                expectedDelay = 52ps * (outputDel[5*chanToCheckA +: 5] - outputDel[5*chanToCheckB +: 5]);
                @(posedge channelStream[chanToCheckB]);
                //$display("Posedge B: %t", $time());
                firstEdge = $time();
                @(posedge channelStream[chanToCheckA]);
                //$display("Posedge A: %t", $time());
                measDelay = $time() - firstEdge;
            end

            error = measDelay - expectedDelay;
            if(error > 20ps || error < -20ps)
                if(expectedDelay != 0.0ps)
                    $display("ERROR: Delay between %d and %d: %t vs. expect %t", chanToCheckA, chanToCheckB, measDelay, expectedDelay);
        end
    end
endtask

task automatic stream_check(input int chanNum, input int numBits2Test, input reg [2:0] streamSpeed, input reg [1:0] streamType, input reg [1:0] prbsType);

    time bitTime;
    int  stateLen;
    int  constPattBW;
    int  constPattBS;
    bit [30:0] state;
    bit [31:0] constPatt;
    time TIMEOUT = 10us;

    begin
        case(streamSpeed)
            HSX32:        bitTime = 781.25ps;
            HSX16, LSX16: bitTime = 1.5625ns;
            HSX8,  LSX8:  bitTime = 3.125ns;
            LSX4:         bitTime = 6.25ns;
            default:      bitTime = 0ns;
        endcase

        case(streamSpeed)
            HSX32:        
            begin
                constPattBS = 31; 
                constPattBW = 32;
            end
            HSX16: 
            begin
                if(chanNum%4 == 2)
                    constPattBS = 31;
                else if(chanNum%4 == 0)
                    constPattBS = 15;
                constPattBW = 16;
            end
            HSX8:  
            begin
                if(chanNum%4 == 3)
                    constPattBS = 31;
                else if(chanNum%4 == 2)
                    constPattBS = 23;
                else if(chanNum%4 == 1)
                    constPattBS = 15;
                else if(chanNum%4 == 0)
                    constPattBS = 7; 
                constPattBW = 8;
            end
            LSX16: 
            begin
                constPattBS = 15;
                constPattBW = 16;
            end
            LSX8: 
            begin
                if(chanNum%4 == 2)
                    constPattBS = 15;
                else if(chanNum%4 == 0)
                    constPattBS = 7;
                constPattBW = 8;
            end
            LSX4:  
            begin
                if(chanNum%4 == 3)
                    constPattBS = 15;
                else if(chanNum%4 == 2)
                    constPattBS = 11;
                else if(chanNum%4 == 1)
                    constPattBS = 7;
                else if(chanNum%4 == 0)
                    constPattBS = 3; 
                constPattBW = 4;
            end
            default:      
            begin
                constPattBS = 0;
                constPattBW = 0;
            end
        endcase

        case(prbsType)
            PRBS7 : stateLen = 7;
            PRBS15: stateLen = 15;
            PRBS23: stateLen = 23;
            PRBS31: stateLen = 31;
        endcase
        //$display("Thread Launched %02d. BitTime: %t and PRBS: %d", chanNum, bitTime, stateLen);

        // Sync with incoming stream
        if (streamType == PRBS) begin
            if( ((chanNum%4 == 1) && (streamSpeed == LSX8  || streamSpeed == HSX16 || streamSpeed == LSX16 || streamSpeed == HSX32)) || 
                ((chanNum%4 == 2) && (streamSpeed == LSX16 || streamSpeed == HSX32)) ||
                ((chanNum%4 == 3) && (streamSpeed == LSX8  || streamSpeed == HSX16 || streamSpeed == LSX16 || streamSpeed == HSX32)) )begin
                #(1);
            end
            else begin
                
                // Wait for a given posedge, but timeout if channel is idle
                fork : timeout
                    @(posedge channelStream[chanNum]);
                    begin
                        #(TIMEOUT);
                        $error("ERROR: Timeout on Channel %d, DataSource: %b. No activity", chanNum, streamType);
                    end
                join_any
                disable fork;

                //$display("Posedge [%02d]", chanNum);
                #(bitTime*0.5);

                for(int i=stateLen-1; i >= 0; i--) begin 
                    state[i] = channelStream[chanNum];
                    #(bitTime);
                end 

                // Fetch samples
                for(int n=0; n < numBits2Test; n++) begin
                    if(prbsType == PRBS7) 
                        state = {state[29:0], state[6]^state[5]};
                    else if(prbsType == PRBS15) 
                        state = {state[29:0], state[14]^state[13]};
                    else if(prbsType == PRBS23) 
                        state = {state[29:0], state[17]^state[22]};
                    else if(prbsType == PRBS31)
                        state = {state[29:0], state[30]^state[27]};
                    
                    if( state[0] != channelStream[chanNum])
                        $error("Error in Chan[%02d]! Mismatch in Bitstreams %b != %b", chanNum, state[0], channelStream[chanNum]);
                    //else  
                    //    $display("Good Chan[%02d]!     Correct Bitstreams %b == %b", chanNum, state[0], channelStream[chanNum]);

                    #(bitTime); 
                end
            end
        end
        else if (streamType == CONSTPATT) begin
            if( ((chanNum%4 == 1) && (streamSpeed == LSX8  || streamSpeed == HSX16   || streamSpeed == LSX16 || streamSpeed == HSX32)) || 
                ((chanNum%4 == 2) && (streamSpeed == LSX16 || streamSpeed == HSX32)) ||
                ((chanNum%4 == 3) && (streamSpeed == LSX8  || streamSpeed == HSX16   || streamSpeed == LSX16 || streamSpeed == HSX32)) )begin
                #(1);
            end
            else begin
                int sampleAlign = 0;
                int alignSteps    = 0;
                constPatt = userData[(chanNum/4)*32*MAX_NUM_USER_PACKET +: 32];

                // Wait for a given posedge, but timeout if channel is idle
                fork : timeout
                    @(posedge channelStream[chanNum]);
                    begin
                        #(TIMEOUT);
                        $error("ERROR: Timeout on Channel %d, DataSource: %b. No activity", chanNum, streamType);
                    end
                join_any
                disable fork;

                //$display("Posedge [%02d]", chanNum);
                #(bitTime*0.5);
               

                // Synchronizing internal state with incoming stream
                while(1) begin
                    //$display("Channel %d -- %b:%b -- Align: %d", chanNum, channelStream[chanNum], constPatt[constPattBS-sampleAlign], sampleAlign);
                    alignSteps++;
                    if(alignSteps == 5000) begin
                        $error("ERROR: Couldn't find lock on Channel %d, DataSource: %b, Speed: %b", chanNum, streamType, streamSpeed);
                        break;
                    end
                    if (channelStream[chanNum] == constPatt[constPattBS-sampleAlign]) begin
                        sampleAlign++; 
                        if(sampleAlign == constPattBW) begin
                            for(int n=0; n < numBits2Test; n++) begin
                                #(bitTime);
                                if(channelStream[chanNum] != constPatt[constPattBS - (n%constPattBW)])
                                    $error("Error in Chan[%02d]! Mismatch in Bitstreams %b != %b", chanNum, constPatt[constPattBS - (n%constPattBW)], channelStream[chanNum]);
                                //else  
                                //    $display("Good Chan[%02d]!     Correct Bitstreams %b == %b", chanNum, constPatt[constPattBS - (n%constPattBW)], channelStream[chanNum]);
                            end
                            break;
                        end
                    end
                    else begin
                        if (channelStream[chanNum] == constPatt[constPattBS])
                            sampleAlign = 1;
                        else
                            sampleAlign = 0;
                    end
                    #(bitTime); 
                end

            end
        end
        else if (streamType == USERDATA) begin
            if( ((chanNum%4 == 1) && (streamSpeed == LSX8  || streamSpeed == HSX16   || streamSpeed == LSX16 || streamSpeed == HSX32)) || 
                ((chanNum%4 == 2) && (streamSpeed == LSX16 || streamSpeed == HSX32)) ||
                ((chanNum%4 == 3) && (streamSpeed == LSX8  || streamSpeed == HSX16   || streamSpeed == LSX16 || streamSpeed == HSX32)) )begin
                #(1);
            end
            else begin
                int sampleAlign   = 0;
                int numBitsTotal  = MAX_NUM_USER_PACKET*constPattBW;
                int alignSteps    = 0;
                bit [MAX_NUM_USER_PACKET*NUM_GROUPS*32-1:0] userDataChan;
                
                for(int p=0; p < MAX_NUM_USER_PACKET; p++) begin
                    if(chanNum%4 == 0) begin
                        if(streamSpeed == HSX32)
                            userDataChan[(MAX_NUM_USER_PACKET-p)*32-1 -: 32] = userData[p*32 +: 32];
                        else if (streamSpeed == HSX16)
                            userDataChan[(MAX_NUM_USER_PACKET-p)*16-1 -: 16] = userData[p*32 +: 16];
                        else if (streamSpeed == HSX8)
                            userDataChan[(MAX_NUM_USER_PACKET-p)*8-1 -: 8] = userData[p*32 +: 8];
                        else if (streamSpeed == LSX16)
                            userDataChan[(MAX_NUM_USER_PACKET-p)*16-1 -: 16] = userData[p*32 +: 16];
                        else if (streamSpeed == LSX8)
                            userDataChan[(MAX_NUM_USER_PACKET-p)*8-1 -: 8] = userData[p*32 +: 8];
                        else if (streamSpeed == LSX4)
                            userDataChan[(MAX_NUM_USER_PACKET-p)*4-1 -: 4] = userData[p*32 +: 4];
                    end
                    else if(chanNum%4 == 2) begin
                        if(streamSpeed == HSX16)
                            userDataChan[(MAX_NUM_USER_PACKET-p)*16-1 -: 16] = userData[16+p*32 +: 16];
                        else if(streamSpeed == HSX8)
                            userDataChan[(MAX_NUM_USER_PACKET-p)*8-1  -: 8] = userData[16+p*32 +: 8];
                        else if(streamSpeed == LSX8)
                            userDataChan[(MAX_NUM_USER_PACKET-p)*8-1  -: 8] = userData[8+p*32 +: 8];
                        else if(streamSpeed == LSX4)
                            userDataChan[(MAX_NUM_USER_PACKET-p)*4-1  -: 4] = userData[8+p*32 +: 4];
                    end
                    else if(chanNum%4 == 1) begin
                        if(streamSpeed[2] == 1)
                            userDataChan[(MAX_NUM_USER_PACKET-p)*8-1 -: 8] = userData[8+p*32 +: 8];
                        else
                            userDataChan[(MAX_NUM_USER_PACKET-p)*4-1 -: 4] = userData[4+p*32 +: 4];
                    end
                    else if(chanNum%4 == 3) begin
                        if(streamSpeed[2] == 1)
                            userDataChan[(MAX_NUM_USER_PACKET-p)*8-1 -: 8] = userData[24+p*32 +: 8];
                        else
                            userDataChan[(MAX_NUM_USER_PACKET-p)*4-1 -: 4] = userData[12+p*32 +: 4];
                    end
                end

                // Wait for a given posedge, but timeout if channel is idle
                fork : timeout
                    @(posedge channelStream[chanNum]);
                    begin
                        #(TIMEOUT);
                        $error("ERROR: Timeout on Channel %d, DataSource: %b. No activity", chanNum, streamType);
                    end
                join_any
                disable fork;

                //$display("Posedge [%02d]", chanNum);
                #(bitTime*0.5); 

                // Synchronizing internal state with incoming stream
                while(1) begin
                    alignSteps++;
                    if(alignSteps == 5000) begin
                        $display("UserData: %X", userDataChan);
                        $error("ERROR: Couldn't find lock on Channel %d, DataSource: %b, Speed: %b", chanNum, streamType, streamSpeed);
                        break;
                    end
                    //$display("Channel %d -- %b:%b -- Align: %d", chanNum, channelStream[chanNum], userDataChan[numBitsTotal-1-sampleAlign], sampleAlign);
                    if (channelStream[chanNum] == userDataChan[numBitsTotal-1-sampleAlign]) begin
                        sampleAlign++; 
                        if(sampleAlign == numBitsTotal) begin
                            for(int n=0; n < numBits2Test; n++) begin
                                #(bitTime);
                                if(channelStream[chanNum] != userDataChan[numBitsTotal -1 - (n%numBitsTotal)])
                                    $error("Error in Chan[%02d]! Mismatch in Bitstreams %b != %b", chanNum, userDataChan[numBitsTotal -1 -(n%numBitsTotal)], channelStream[chanNum]);
                                //else  
                                //    $display("Good Chan[%02d]!     Correct Bitstreams %b == %b", chanNum, userDataChan[numBitsTotal -1 -(n%numBitsTotal)], channelStream[chanNum]);
                            end
                            break;
                        end
                    end
                    else begin
                        if (channelStream[chanNum] == userDataChan[numBitsTotal-1])
                            sampleAlign = 1;
                        else
                            sampleAlign = 0;
                    end
                    #(bitTime); 
                end

            end
        end
        else begin
            #(1);
        end
        //$display("Thread Finished: Datatype: %d  -- Chan: %d -- Speed: %03b", streamType, chanNum, streamSpeed);
    end
endtask


endmodule


