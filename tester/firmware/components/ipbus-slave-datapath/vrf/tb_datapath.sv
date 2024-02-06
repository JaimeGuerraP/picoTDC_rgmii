// TODO I still don't know why this step is necessary
`ifdef SDF
    `include "/opt/Xilinx/Vivado/2016.4/data/verilog/src/glbl.v"
`endif

//import eportrxdrv_pkg::*;

module tb_datapath();
    
    // Specifying the timeunits
    timeunit      1fs;
    timeprecision 1fs;

    // Instantiation parameters
    parameter NUM_GROUPS  = 7;
    parameter NUM_CHAN    = NUM_GROUPS*4;
    parameter NUM_TESTS   = 15;

    // Operation mode tags and other params
    parameter PER_40M     = 25ns;
    parameter PER_320M    = PER_40M/8;
    parameter PER_10G24   = 100ps;//97.656ps;
    parameter PER_5G12    = 195.313ps;
    parameter PER_2G56    = 390.625ps;
    parameter MAX_JITTER  = 0ps;

    // Connection signals
    bit clk40MHz_in, reset;
    bit clk320MHz_in;
    bit clk320MHz;
    bit clk40MHzTX;
    bit clk40MHzRX;
    bit clk80MHz;
    bit hsUpLink;
    reg hsDownLink_p, hsDownLink_n;
    reg  [31:0] statusBus;
    reg  [31:0] controlBus;
    reg  [31:0] controlBusDnLink;
    reg  [31:0] controlBusUpLink;
    reg  [31:0] userDataDnLink;
    reg   [1:0] icDataDnLink;
    reg   [1:0] ecDataDnLink;
    reg [229:0] userDataUpLink;
    reg  [1:0] icDataUpLink;
    reg  [1:0] ecDataUpLink;

    // Testbench signals and registers
    bit [2*NUM_TESTS*64-1:0] txBuffer;
    bit [NUM_TESTS*64-1:0]   txBufferReference;
    bit [2*NUM_TESTS*256-1:0] rxBuffer;
    bit [255:0]   rxBufferReference   [NUM_TESTS];

    bit [224*NUM_TESTS-1:0]   rxUserDataReference;
    bit [224*NUM_TESTS*2-1:0]   rxUserDataBuffer;
    
    bit [2*NUM_TESTS-1:0]     rxIcReference;
    bit [2*NUM_TESTS*2-1:0]   rxIcBuffer;
    bit [2*NUM_TESTS-1:0]     rxEcReference;
    bit [2*NUM_TESTS*2-1:0]   rxEcBuffer;

    bit [31:0] txStimuli_userData [NUM_TESTS];
    bit [1:0]  txStimuli_icData   [NUM_TESTS];
    bit [1:0]  txStimuli_ecData   [NUM_TESTS];

    bit [223:0] rxStimuli_userData;
    bit [1:0]   rxStimuli_icData   [NUM_TESTS];
    bit [1:0]   rxStimuli_ecData   [NUM_TESTS];

    bit [63:0] data_to_fpga_tx;
    bit [31:0] data_fr_fpga_rx;

    bit [255:0] test_rx = {32'hAAAAAAAA, 32'hBBBBBBBB, 32'hCCCCCCCC, 32'hDDDDDDDD, 32'h33333333, 32'h44444444};

    // Specifying which test we are going to run
    bit testType=0;

    // Instantiation of the DUV, the ePortRxDriver
    `ifdef SDF
        NETLIST_datapath DP (
            .refClkGTX_320M_n(~clk320MHz_in),
            .refClkGTX_320M_p(clk320MHz_in),        
            .clk40MHz_TX(clk40MHzTX),
            .clk40MHz_RX(clk40MHzRX),
            .hsUpLink_p_i(hsUpLink),
            .hsUpLink_n_i(~hsUpLink),
            .hsDnLink_p_o(hsDownLink_p),     
            .hsDnLink_n_o(hsDownLink_n),     
            
            .userDataDnLink(userDataDnLink),
            .icDataDnLink(icDataDnLink),
            .ecDataDnLink(ecDataDnLink),
            
            .statusBus(statusBus),
            .controlBus(controlBus),
            .controlBusDnLink(controlBusDnLink),
            .controlBusUpLink(controlBusUpLink),

            .userDataUpLink(userDataUpLink),
            .icDataUpLink(icDataUpLink),
            .ecDataUpLink(ecDataUpLink)
        );
    `else
        datapath DP (
            .refClkGTX_320M_n(~clk320MHz_in),
            .refClkGTX_320M_p(clk320MHz_in),        
            .clk40MHz_TX(clk40MHzTX),
            .clk40MHz_RX(clk40MHzRX),
            .hsUpLink_p_i(hsUpLink),
            .hsUpLink_n_i(~hsUpLink),
            .hsDnLink_p_o(hsDownLink_p),     
            .hsDnLink_n_o(hsDownLink_n),     
            
            .userDataDnLink(userDataDnLink),
            .icDataDnLink(icDataDnLink),
            .ecDataDnLink(ecDataDnLink),
            
            .statusBus(statusBus),
            .controlBus(controlBus),
            .controlBusDnLink(controlBusDnLink),
            .controlBusUpLink(controlBusUpLink),

            .userDataUpLink(userDataUpLink),
            .icDataUpLink(icDataUpLink),
            .ecDataUpLink(ecDataUpLink)
        );
    `endif

    // Clock generation
    always begin
        #(PER_40M*0.5  + MAX_JITTER*($random()/real'(32'hffffffff))) clk40MHz_in  = ~clk40MHz_in;
    end
    
    always begin
        #(PER_320M*0.5*1.024 + MAX_JITTER*($random()/real'(32'hffffffff))) clk320MHz_in = ~clk320MHz_in;
    end

    initial begin

        $timeformat(-6, 6, " us", 20);

        // Initialize signals
        clk40MHz_in      = 0;
        clk320MHz_in     = 0;
        controlBus       = 32'd0;
        controlBusDnLink = {27'd0, 3'b111, 1'b0, 1'b1};
        controlBusUpLink = {32'd0};

        // Generate stimuli
        for(int n=0; n < NUM_TESTS; n++) begin
            txStimuli_userData[n] = $random();
            txStimuli_icData[n]   = $random() % 4;
            txStimuli_ecData[n]   = $random() % 4;

            // TODO ASSUMES FIXED OPERATION AT 10G and FEC5
            //rxStimuli_userData[n] = {$random(), $random(), $random(), $random(), $random(), $random(), $random()};
            std::randomize(rxStimuli_userData) with {
                if(testType == 1)
                    $countones(rxStimuli_userData) == 112;
                else 
                    $countones(rxStimuli_userData[111:0]) == 56;
            };

            rxStimuli_icData[n]   = $random() % 4;
            rxStimuli_ecData[n]   = $random() % 4;
            // ____________________________________________

            txBufferReference[n*64 +: 64]   = {1'b1,  txStimuli_icData[n][1], 1'b0, txStimuli_icData[n][0], 1'b0, txStimuli_ecData[n][1], 1'b1, txStimuli_ecData[n][0], txStimuli_userData[n], 24'd0}; 
            if(testType == 1) begin
                rxBufferReference[n] = {2'b10, rxStimuli_icData[n], rxStimuli_ecData[n], 6'b111111, rxStimuli_userData, 20'd0};
                rxUserDataReference[n*224 +: 224] = rxStimuli_userData;
                rxIcReference[n*2 +: 2] = rxStimuli_icData[n];
                rxEcReference[n*2 +: 2] = rxStimuli_ecData[n];
            end
            else begin
                rxBufferReference[n] = {2'b10, rxStimuli_icData[n], rxStimuli_ecData[n], rxStimuli_userData[111:0], 10'd0};
                rxUserDataReference[n*112 +: 112] = rxStimuli_userData[111:0];
                rxIcReference[n*2 +: 2] = rxStimuli_icData[n];
                rxEcReference[n*2 +: 2] = rxStimuli_ecData[n];
            end
        end

        // Starts applying the bits with a random phase
        #(PER_10G24*($random()/real'(32'hffffffff)));

        fork
            // Driver for Tx Input (Parallel)
            forever begin
                for(int n=0; n < NUM_TESTS; n++) begin
                    @(negedge clk40MHzTX)
                    userDataDnLink <= txStimuli_userData[n];
                    icDataDnLink   <= txStimuli_icData[n];
                    ecDataDnLink   <= txStimuli_ecData[n];
                end
            end

            // Driver for Rx Input (Serial)
            forever begin
                for(int n=0; n < NUM_TESTS; n++) begin
                    if(testType == 1) begin
                        for(int b=0; b < 256; b++) begin
                            #(PER_10G24);
                            hsUpLink <= rxBufferReference[n][255-b];
                            //$display("Frame bit %d: %b", 255-b, rxBufferReference[n][255-b]);
                        end
                    end
                    else begin
                        for(int b=0; b < 128; b++) begin
                            #(PER_5G12);
                            hsUpLink <= rxBufferReference[n][127-b];
                            //$display("Frame bit %d: %b", 255-b, rxBufferReference[n][255-b]);
                        end
                    end
                end
            end
        join_none

        // Read outputs
        fork

            // Monitor for Rx Output (Serial)
            begin
                // Waits for the RX reset cycle to complete
                fork
                    begin
                        @(posedge statusBus[3]);
                        $display("@%t : Rx Deserializer Ready !", $time());
                    end
                    begin
                        @(posedge statusBus[12]);
                        $display("@%t : Rx Frame Aligner Ready !", $time());
                    end
                join
                
                // Synchronize with incoming stream
                #(1us)
                if(testType == 1) begin
                    for(int n=0; n <= 2*NUM_TESTS; n++) begin
                        @(negedge clk40MHzRX);
                        rxUserDataBuffer[n*224 +: 224] <= userDataUpLink[223:0];
                        rxIcBuffer[n*2 +: 2]       <= icDataUpLink;
                        rxEcBuffer[n*2 +: 2]       <= ecDataUpLink;
                        //$display("Sampled data # %d: %X", n, userDataUpLink[1:0]);
                        //$display("Sent data: %X", rxEcReference[n*2 +: 2]);
                    end
                    
                    for(int i=0; i < NUM_TESTS; i++) begin
                        if(rxUserDataBuffer[i*224 +: NUM_TESTS*224] == rxUserDataReference)
                            $display("@%t : [RX] Found match in User Data %d", $time(), i); //, rxUserDataBuffer[i*224 +: NUM_TESTS*224], rxUserDataReference);
                        else
                            $display("@%t : [RX] No match in Norm %d: \n%b\n%b", $time(), i, rxUserDataBuffer[i*224 +: NUM_TESTS*224], rxUserDataReference);
                    end
                end
                else begin
                    for(int n=0; n <= 2*NUM_TESTS; n++) begin
                        @(negedge clk40MHzRX);
                        rxUserDataBuffer[n*112 +: 112] <= userDataUpLink[111:0];
                        rxIcBuffer[n*2 +: 2]       <= icDataUpLink;
                        rxEcBuffer[n*2 +: 2]       <= ecDataUpLink;
                        //$display("Sampled data # %d: %X", n, ecDataUpLink[1:0]);
                        //$display("Sent data: %X", rxEcReference[n*2 +: 2]);
                    end
                    
                    for(int i=0; i < NUM_TESTS; i++) begin
                        if(rxUserDataBuffer[i*112 +: NUM_TESTS*112] == rxUserDataReference)
                            $display("@%t : [RX] Found match in User Data %d", $time(), i); //, rxUserDataBuffer[i*224 +: NUM_TESTS*224], rxUserDataReference);
                        //else
                        //    $display("@%t : [RX] No match in Norm %d: \n%b\n%b", $time(), i, rxUserDataBuffer[i*224 +: NUM_TESTS*224], rxUserDataReference);
                    end
                end

                for(int i=0; i < NUM_TESTS; i++) begin
                    if(rxIcBuffer[i*2 +: NUM_TESTS*2] == rxIcReference)
                        $display("@%t : [RX] Found match in IC Data %d", $time(), i); //, rxUserDataBuffer[i*224 +: NUM_TESTS*224], rxUserDataReference);
                    //else
                    //    $display("@%t : [RX] No match in Norm %d: \n%b\n%b", $time(), i, rxIcBuffer[i*2 +: NUM_TESTS*2], rxIcReference);
                end
                for(int i=0; i < NUM_TESTS; i++) begin
                    if(rxEcBuffer[i*2 +: NUM_TESTS*2] == rxEcReference)
                        $display("@%t : [RX] Found match in EC %d", $time(), i); //, rxUserDataBuffer[i*224 +: NUM_TESTS*224], rxUserDataReference);
                    //else
                    //    $display("@%t : [RX] No match in Norm %d: \n%b\n%b", $time(), i, rxEcBuffer[i*2 +: NUM_TESTS*2], rxEcReference);
                end

            end


            // Monitor for Tx Output (Serial)
            begin
                // Wait for the TX reset cycle to complete
                @(posedge statusBus[0]);
                $display("@%t : Tx Ready !", $time());

                // Synchronize with incoming stream
                #(100ns)
                @(posedge hsDownLink_p);
                #(PER_2G56*0.5);

                for(int i=0; i < 2*NUM_TESTS*64; i++) begin
                    txBuffer[i] = hsDownLink_p;     
                    #(PER_2G56);
                end
               
                for(int i=0; i < NUM_TESTS*64; i++) begin
                    if(txBuffer[i +: (NUM_TESTS*64)] == txBufferReference) 
                        $display("@%t : [TX] Found match in Frame: %d", $time(), i);
                    //else
                    //    $display("@%t : [TX] No match in Norm %d: \n%X\n%X", $time(), i, txBuffer[i +: NUM_TESTS*64], txBufferReference);
                end

                #(350us);
                
            end

            begin
            
                // Reset Driver
                /* REGISTER CHEATSHEET
                enableUpLink      <= controlBusUpLink(0);
                resetUpLink       <= controlBusUpLink(1);
                bypassIntlvUpLink <= controlBusUpLink(2);
                bypassFecCdUpLink <= controlBusUpLink(3);
                bypassScramUpLink <= controlBusUpLink(4);
                dataRateUpLink    <= controlBusUpLink(5);
                fecModeUpLink     <= controlBusUpLink(6);
                resetRxGearbox    <= controlBusUpLink(7);
                resetFrameAligner <= controlBusUpLink(8);

                tx_softReset  <= controlBus(0);
                gttxreset     <= controlBus(1);
                rx_softReset  <= controlBus(2);
                gtrxreset     <= controlBus(3);
                rxuserrdy     <= controlBus(4);
                rxpmareset    <= controlBus(5);
                rxdfelpmreset <= controlBus(6);
                eyescanreset  <= controlBus(7);   
                
                enableDnLink      <= controlBusDnLink(0);
                resetDnLink       <= controlBusDnLink(1);
                bypassIntlvDnLink <= controlBusDnLink(2);
                bypassFecCdDnLink <= controlBusDnLink(3);
                bypassScramDnLink <= controlBusDnLink(4);
                */

                controlBusUpLink[0] = 1;
                controlBusUpLink[2] = 1;
                controlBusUpLink[3] = 1;
                controlBusUpLink[4] = 1;
                controlBusUpLink[5] = testType;
                controlBusUpLink[6] = 0;

                wait ( (statusBus[2] == 1'b1) &&  (statusBus[5] == 1'b1) );
                $display("@%t : All MMCM blocks locked !", $time());
               
                // Initial reset and simulation timeout
                #(25ns);
                controlBus[3] = 1;
                controlBus[1] = 1;
                controlBusDnLink[1] = 1;
                controlBusUpLink[1] = 1;
                controlBusUpLink[7] = 1;
                controlBusUpLink[8] = 1;
                controlBusUpLink[9] = 1;
                #(150ns);
                controlBus[3] = 0;
                controlBusUpLink[1] = 0;
                controlBusUpLink[7] = 0;
                controlBusUpLink[8] = 0;
                controlBusUpLink[9] = 0;
                controlBusDnLink[1] = 0;
                #(250ns);
                controlBus[4] = 1;
                #(100ns);

                #(5us);
                reset = 0;

                #(2s);
                $error("Simulation Timeout");
            end
        join_any

        $stop();

    end

endmodule


