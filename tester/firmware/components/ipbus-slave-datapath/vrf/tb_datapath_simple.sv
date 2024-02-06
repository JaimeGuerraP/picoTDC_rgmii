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
    parameter NUM_TESTS   = 2500;

    // Operation mode tags and other params
    parameter PER_40M     = 25ns;
    parameter PER_320M    = PER_40M/8;
    parameter PER_10G24   = 97.656ps;
    parameter PER_5G12    = 195.313ps;
    parameter PER_2G56    = 390.625ps;
    parameter MAX_JITTER  = 0ps;

    // Connection signals
    bit clk40MHz_in, reset;
    bit clk320MHz_in;
    bit clk320MHz;
    bit clk40MHz;
    bit clk80MHz;
    bit hsUpLink;
    reg hsDownLink_p, hsDownLink_n;
    reg [31:0] statusBus;
    reg [31:0] controlBus;

    // Testbench signals and registers
    bit [2*NUM_TESTS*64-1:0] txBuffer;
    bit [NUM_TESTS*64-1:0]   txBufferReference;
    bit [2*NUM_TESTS*32-1:0] rxBuffer;
    bit [NUM_TESTS*32-1:0]   rxBufferReference;
    bit [63:0] txStimuli [NUM_TESTS];
    bit [31:0] rxStimuli [NUM_TESTS];
    bit [63:0] data_to_fpga_tx;
    bit [31:0] data_fr_fpga_rx;

    // Instantiation of the DUV, the ePortRxDriver
    `ifdef SDF
    `else
        datapath DP (
            .sysclk_i(clk40MHz_in),
            .refClkGTX_320M_n(~clk320MHz_in),
            .refClkGTX_320M_p(clk320MHz_in),        
            .clk320MHz(clk320MHz),
            .clk40MHz(clk40MHz),
            .hsUpLink_p_i(hsUpLink),
            .hsUpLink_n_i(~hsUpLink),
            .hsDnLink_p_o(hsDownLink_p),     
            .hsDnLink_n_o(hsDownLink_n),     
            .statusBus(statusBus),
            .controlBus(controlBus),
            .data_to_fpga_tx(data_to_fpga_tx),
            .data_fr_fpga_rx(data_fr_fpga_rx)
        );
    `endif

    // Clock generation
    always begin
        #(PER_40M*0.5  + MAX_JITTER*($random()/real'(32'hffffffff))) clk40MHz_in = ~clk40MHz_in;
    end
    
    always begin
        #(PER_320M*0.5 + MAX_JITTER*($random()/real'(32'hffffffff))) clk320MHz_in = ~clk320MHz_in;
    end

    initial begin

        $timeformat(-6, 6, " us", 20);

        // Initialize signals
        clk40MHz_in   = 0;
        clk320MHz_in  = 0;
        controlBus    = 32'd0;

        // Generate stimuli
        for(int n=0; n < NUM_TESTS; n++) begin
            txStimuli[n] = {$random(), $random()};
            rxStimuli[n] =  $random();
            txBufferReference[n*64 +: 64] = txStimuli[n];
            rxBufferReference[n*32 +: 32] = rxStimuli[n];
        end

        fork
            // Driver for Tx Input (Parallel)
            forever begin
                for(int n=0; n < NUM_TESTS; n++) begin
                    @(negedge clk40MHz)
                    data_to_fpga_tx <= txStimuli[n];
                end
            end

            // Driver for Rx Input (Serial)
            forever begin
                for(int n=0; n < NUM_TESTS; n++) begin
                    for(int b=0; b < 32; b++) begin
                        #(PER_10G24);
                        hsUpLink <= rxStimuli[n][b];
                    end
                end
            end
        join_none

        fork

            // Monitor for Rx Output (Serial)
            begin
                // Waits for the RX reset cycle to complete
                @(posedge statusBus[3]);
                $display("@%t : Rx Ready !", $time());

                // Synchronize with incoming stream
                #(100ns)
                for(int n=0; n <= 2*NUM_TESTS; n++) begin
                    @(negedge clk320MHz);
                    rxBuffer[n*32 +: 32] <= data_fr_fpga_rx;
                end

                for(int i=0; i < NUM_TESTS*32; i++) begin
                    if(rxBuffer[i +: NUM_TESTS*32] == rxBufferReference)
                        $display("@%t : [RX] Found match in Norm %d: \n%X\n%X", $time(), i, rxBuffer[i +: NUM_TESTS*32], rxBufferReference);
                    //else
                    //    $display("@%t : [RX] No match in Norm %d: \n%b\n%b", $time(), i, rxBuffer[i +: NUM_TESTS*32], rxBufferReference);
                end

                #(200us);

            end


            // Monitor for Tx Output (Parallel)
            begin

                // Wait for the TX reset cycle to complete
                @(posedge statusBus[0]);
                $display("@%t : Tx Ready !", $time());

                // Synchronize with incoming stream
                #(100ns)
                @(posedge hsDownLink_p);
                #(PER_2G56*0.5);

                for(int i=0; i < 2*NUM_TESTS*64; i++) begin
                    txBuffer[i]           = hsDownLink_p;     
                    #(PER_2G56);
                end
               
                for(int i=0; i < NUM_TESTS*64; i++) begin
                    if(txBuffer[i +: NUM_TESTS*64] == txBufferReference)
                        $display("@%t : [TX] Found match in Norm %d: \n%X\n%X", $time(), i, txBuffer[i +: NUM_TESTS*64], txBufferReference);
                    //else
                    //    $display("@%t : [TX] No match in Norm %d: \n%X\n%X", $time(), i, txBuffer[i +: NUM_TESTS*64], txBufferReference);
                end

                #(200us);
                
            end

            begin
            
                // Reset Driver

                wait ( (statusBus[2] == 1'b1) &&  (statusBus[5] == 1'b1) );
                $display("@%t : All MMCM blocks locked !", $time());
                
                // Initial reset and simulation timeout
                #(17us);
                controlBus[3] = 1;
                #(150ns);
                controlBus[3] = 0;
                #(250ns);
                controlBus[4] = 1;
                #(100ns);

                #(5us);
                controlBus[1] = 0;
                #(100ns);
                controlBus[1] = 1;
                #(100ns);
                controlBus[1] = 0;
                reset = 0;
                #(2s);
                $error("Simulation Timeout");
            end
        join_any

        $stop();

    end

endmodule


