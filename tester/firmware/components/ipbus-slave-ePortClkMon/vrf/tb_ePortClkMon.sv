// TODO if required, include glbl.v here without hardcoding a vivado version

package eportclkmon_pkg;
endpackage

import eportclkmon_pkg::*;

module tb_ePortClkMon();
    timeunit      1fs;
    timeprecision 1fs;

    parameter time PER_40M          = 25ns;
    
    parameter time PER_DUT          = 25ns/1;
    parameter time MAX_JITTER_DUT   = 100ps;
    
    // constants from clkmon_pkg that can not be imported :(
    parameter COUNTER_WIDTH         = 8;
    parameter DELAY_LINE_TAPS       = 16;
    parameter NUM_CHANNELS          = 28;
    
    bit clk;
    bit rst;
    bit [0:NUM_CHANNELS-1] clk_mon;
    bit unsigned [5:0] phase;
    bit phase_set;
    wire phase_ready;
    bit meas_start;
    wire meas_done;
    wire [NUM_CHANNELS*DELAY_LINE_TAPS*COUNTER_WIDTH-1:0] meas_results_slv;
    wire [COUNTER_WIDTH-1:0] meas_results [0:NUM_CHANNELS-1][0:DELAY_LINE_TAPS-1];
    
    // map the results vector back to a sane array type
    genvar i,j;
    generate
        for (i=0; i<NUM_CHANNELS; i++) begin
            for (j=0; j<DELAY_LINE_TAPS; j++) begin
                assign meas_results[i][j] = 
                    meas_results_slv[
                        COUNTER_WIDTH*DELAY_LINE_TAPS*i+COUNTER_WIDTH*(j+1)-1 :
                        COUNTER_WIDTH*DELAY_LINE_TAPS*i+COUNTER_WIDTH*j];
             end
         end
    endgenerate
    
    // generate 40 MHz system clock
    always begin
        #(PER_40M*0.5) clk = ~clk;
    end
    
    int seed = $random(1);
    
    genvar c;
    generate
        for (c = 0; c < NUM_CHANNELS; c = c + 1) begin: test
            always begin
                // jitter only the falling edge to avoid rounding error accumulation
                automatic int falling_edge;
                automatic int rising_edge; 
			    
				falling_edge = PER_DUT*0.5 + $dist_normal(seed, 0, MAX_JITTER_DUT);
				if (falling_edge < 1) begin
					falling_edge = 1;
				end
				if (falling_edge > PER_DUT-1) begin
					falling_edge = PER_DUT-1;
				end
                rising_edge = PER_DUT - falling_edge;
                #(falling_edge) clk_mon[c] = 0;
                #(rising_edge) clk_mon[c] = 1;
            end
        end
    endgenerate

    `ifdef SDF
    NETLIST_ePortClkMon #(NUM_CHANNELS) CLKMON (
        .clk(clk),
        .rst(rst),
        .clk_mon(clk_mon),
        .phase(phase),
        .phase_set(phase_set),
        .phase_ready(phase_ready),
        .meas_start(meas_start),
        .meas_done(meas_done),
        .meas_results(meas_results_slv)
    );
    `else
    ePortClkMon #(NUM_CHANNELS) CLKMON (
        .clk(clk),
        .rst(rst),
        .clk_mon(clk_mon),
        .phase(phase),
        .phase_set(phase_set),
        .phase_ready(phase_ready),
        .meas_start(meas_start),
        .meas_done(meas_done),
        .meas_results(meas_results_slv)   
    );
    `endif
    
    initial begin
        $timeformat(-12, 6, " ps", 20);
        clk = 0;
        rst = 1;
        clk_mon = 0;
        phase = 0;
        phase_set = 0;
        meas_start = 0;
        
        #(250ns);
        rst = 0;
        
        // wait for initial PLL phase lock
        @(posedge phase_ready);
              
        run_measurement();
  
    end

    task automatic run_measurement();

        parameter PHASE_STEPS = 56;
        int hist [0:NUM_CHANNELS-1][0:DELAY_LINE_TAPS-1][0:PHASE_STEPS-1];
        int channel_cnt, phase_cnt, tap_cnt;
        int f;
        
        for (phase_cnt=0; phase_cnt < PHASE_STEPS; phase_cnt++) begin
            // set new phase value  
            @(posedge clk);
            phase = phase_cnt;
            phase_set = 1;
            @(posedge clk);
            phase_set = 0;
            @(posedge phase_ready);
            
            // start measurement
            @(posedge clk);
            meas_start = 1;
            @(posedge clk);
            meas_start = 0;
            
            // wait for measurement completion and write results
            @(posedge meas_done)
            for (channel_cnt = 0; channel_cnt < NUM_CHANNELS; channel_cnt++) begin
                for (tap_cnt=0; tap_cnt < DELAY_LINE_TAPS; tap_cnt++) begin
                    hist[channel_cnt][tap_cnt][phase_cnt] = meas_results[channel_cnt][tap_cnt];
                end
            end
        end
        
        // write results
        f = $fopen("results.csv","w");
        for (channel_cnt = 0; channel_cnt < NUM_CHANNELS; channel_cnt++) begin
            for (tap_cnt=0; tap_cnt < DELAY_LINE_TAPS; tap_cnt++) begin
                for (phase_cnt=0; phase_cnt < PHASE_STEPS; phase_cnt++) begin
                    $fwrite(f, "%d", hist[channel_cnt][DELAY_LINE_TAPS-tap_cnt-1][PHASE_STEPS-phase_cnt-1]);
                    if (!(phase_cnt == PHASE_STEPS-1 && tap_cnt == DELAY_LINE_TAPS-1)) begin
                        $fwrite(f, ",");
                    end
                end
            end
            if (channel_cnt < NUM_CHANNELS-1) begin
                $fwrite(f, "\n");
            end
        end
        $fclose(f);
		#(10ns);
        $stop();
    endtask

endmodule
