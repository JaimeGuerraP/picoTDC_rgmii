`include "typedefs.sv"

class OpMode #(NGROUPS = 7, NCHAN = 4, NUM_USER_PACKETS = 16);

    // Member declarations
    rand prbsMode_t     prbsMode     [NGROUPS];
    rand speedMode_t    speedMode    [NGROUPS];
    rand dataMode_t     dataMode     [NGROUPS];
    rand prbsSeedMode_t prbsSeedMode [NGROUPS];
    rand bit [4:0] outputDelay [NGROUPS*NCHAN-1:0];

    rand bit [31:0]     prbsSeed     [NGROUPS];
    rand bit [NUM_USER_PACKETS*32-1:0] userData [NGROUPS];
    rand test_t testMode;

    // Prevent the test to run in IDLE mode, which is a pretty boring mode :)
    constraint NO_IDLE {
        foreach(dataMode[i]) {
            dataMode[i]  != NODATA;
        }

        foreach(speedMode[i]) {
            speedMode[i] != LSIDLE;
            speedMode[i] != HSIDLE;
        }
        
        /*
        foreach(dataMode[i]) {
            dataMode[i]  == PRBS;
        }

        foreach(prbsMode[i]) {
            prbsMode[i]  == PRBS7;
        }
        foreach(speedMode[i]) {
            speedMode[i] == LSX4;
        }

        foreach(prbsSeed[i]) {
            prbsSeed[i] == 32'd55555555;
        }

        foreach(prbsSeedMode[i]) {
            prbsSeedMode[i] == 1'b1;
        }

        foreach(outputDelay[i]) {
            outputDelay[i] == 5'd0;
        }
        */
    }

    // Guarantee that we don't feed a zero seed to the PRBS generator
    constraint VALID_PRBS_SEEDS {
        foreach(prbsSeed[i]) {
            (dataMode[i] == HSX32) ->
                prbsSeed[i][31:0] != 32'd0;
            (dataMode[i] == HSX16 || dataMode[i] == LSX16) -> {
                prbsSeed[i][31:16] != 16'd0;
                prbsSeed[i][15:0]  != 16'd0;
            }
            (dataMode[i] == HSX8 || dataMode[i] == LSX8) -> {
                prbsSeed[i][31:24] != 8'd0;
                prbsSeed[i][23:16] != 8'd0;
                prbsSeed[i][15:8]  != 8'd0;
                prbsSeed[i][7:0]   != 8'd0;
            }
            (dataMode[i] == LSX4) -> {
                prbsSeed[i][15:12] != 4'd0;
                prbsSeed[i][11:8]  != 4'd0;
                prbsSeed[i][7:4]   != 4'd0;
                prbsSeed[i][3:0]   != 4'd0;
            }
        }
    }

    // Guarantee that we don't feed all zeros to the user data/constant pattern 
    constraint VALID_USER_DATA {
        foreach(userData[i]) {
            (dataMode[i] == HSX32) -> {
                userData[i][0   +: 32] != 32'd0;
                userData[i][64  +: 32] != 32'd0;
                userData[i][96  +: 32] != 32'd0;
                userData[i][192 +: 32] != 32'd0;
                userData[i][0 +: 32] != 32'd0;
                userData[i][0 +: 32] != 32'd0;
                userData[i][0 +: 32] != 32'd0;
            }
            (dataMode[i] == HSX16 || dataMode[i] == LSX16) -> {
                userData[i][31:16] != 16'd0;
                userData[i][15:0]  != 16'd0;
            }
            (dataMode[i] == HSX8 || dataMode[i] == LSX8) -> {
                userData[i][31:24] != 8'd0;
                userData[i][23:16] != 8'd0;
                userData[i][15:8]  != 8'd0;
                userData[i][7:0]   != 8'd0;
            }
            (dataMode[i] == LSX4) -> {
                userData[i][15:12] != 4'd0;
                userData[i][11:8]  != 4'd0;
                userData[i][7:4]   != 4'd0;
                userData[i][3:0]   != 4'd0;
            }
        }
    }

    // If we are focused on testing the Delay features, the data we send must be the same seed must be the saame
    constraint DELAY_TEST_SAME_SEED {
       (testMode == DELAY_TEST) -> {
            foreach(dataMode[i]) {
                dataMode[i] == PRBS;
            }
            foreach(prbsMode[i]) {
                prbsMode[i] == PRBS7;
            }
            foreach(prbsSeedMode[i]) {
                prbsSeedMode[i] == EQAL;
            }
            foreach(prbsSeedMode[i]) {
                prbsSeed[i] == prbsSeed[0];
            }
            foreach(speedMode[i]) {
                speedMode[i] == HSX8;
            }
       }
    }

    // Balancing the numeber of each type of executed test
    constraint BALANCE_TEST_TYPE {
       testMode dist {NORMAL_TEST :/ 10, DELAY_TEST :/ 90};
    }

    // The coverage metrics for individual configuration modes, and correlated configuration modes
    covergroup ConfigMode;
        PRBSMODE_G0  : coverpoint OpMode.prbsMode[0];
        PRBSMODE_G1  : coverpoint OpMode.prbsMode[1];
        PRBSMODE_G2  : coverpoint OpMode.prbsMode[2];
        PRBSMODE_G3  : coverpoint OpMode.prbsMode[3];
        PRBSMODE_G4  : coverpoint OpMode.prbsMode[4];
        PRBSMODE_G5  : coverpoint OpMode.prbsMode[5];
        PRBSMODE_G6  : coverpoint OpMode.prbsMode[6];

        DATAMODE_G0  : coverpoint OpMode.dataMode[0];
        DATAMODE_G1  : coverpoint OpMode.dataMode[1];
        DATAMODE_G2  : coverpoint OpMode.dataMode[2];
        DATAMODE_G3  : coverpoint OpMode.dataMode[3];
        DATAMODE_G4  : coverpoint OpMode.dataMode[4];
        DATAMODE_G5  : coverpoint OpMode.dataMode[5];
        DATAMODE_G6  : coverpoint OpMode.dataMode[6];

        SPEEDMODE_G0 : coverpoint OpMode.speedMode[0];
        SPEEDMODE_G1 : coverpoint OpMode.speedMode[1];
        SPEEDMODE_G2 : coverpoint OpMode.speedMode[2];
        SPEEDMODE_G3 : coverpoint OpMode.speedMode[3];
        SPEEDMODE_G4 : coverpoint OpMode.speedMode[4];
        SPEEDMODE_G5 : coverpoint OpMode.speedMode[5];
        SPEEDMODE_G6 : coverpoint OpMode.speedMode[6];

        SEEDMODE_G0  : coverpoint OpMode.prbsSeedMode[0];
        SEEDMODE_G1  : coverpoint OpMode.prbsSeedMode[1];
        SEEDMODE_G2  : coverpoint OpMode.prbsSeedMode[2];
        SEEDMODE_G3  : coverpoint OpMode.prbsSeedMode[3];
        SEEDMODE_G4  : coverpoint OpMode.prbsSeedMode[4];
        SEEDMODE_G5  : coverpoint OpMode.prbsSeedMode[5];
        SEEDMODE_G6  : coverpoint OpMode.prbsSeedMode[6];

        // Cross coverage coverpoints
        cross PRBSMODE_G0, SPEEDMODE_G0;
        cross PRBSMODE_G1, SPEEDMODE_G1;
        cross PRBSMODE_G2, SPEEDMODE_G2;
        cross PRBSMODE_G3, SPEEDMODE_G3;
        cross PRBSMODE_G4, SPEEDMODE_G4;
        cross PRBSMODE_G5, SPEEDMODE_G5;
        cross PRBSMODE_G6, SPEEDMODE_G6;

        cross PRBSMODE_G0, DATAMODE_G0;
        cross PRBSMODE_G1, DATAMODE_G1;
        cross PRBSMODE_G2, DATAMODE_G2;
        cross PRBSMODE_G3, DATAMODE_G3;
        cross PRBSMODE_G4, DATAMODE_G4;
        cross PRBSMODE_G5, DATAMODE_G5;
        cross PRBSMODE_G6, DATAMODE_G6;

        cross PRBSMODE_G0, SEEDMODE_G0;
        cross PRBSMODE_G1, SEEDMODE_G1;
        cross PRBSMODE_G2, SEEDMODE_G2;
        cross PRBSMODE_G3, SEEDMODE_G3;
        cross PRBSMODE_G4, SEEDMODE_G4;
        cross PRBSMODE_G5, SEEDMODE_G5;
        cross PRBSMODE_G6, SEEDMODE_G6;

        cross SPEEDMODE_G0, DATAMODE_G0;
        cross SPEEDMODE_G1, DATAMODE_G1;
        cross SPEEDMODE_G2, DATAMODE_G2;
        cross SPEEDMODE_G3, DATAMODE_G3;
        cross SPEEDMODE_G4, DATAMODE_G4;
        cross SPEEDMODE_G5, DATAMODE_G5;
        cross SPEEDMODE_G6, DATAMODE_G6;
    endgroup

    // The coverage metrics for user data, non-related to operation modes 
    covergroup UserData;
        USERDATA_G0 : coverpoint OpMode.userData[0];
        USERDATA_G1 : coverpoint OpMode.userData[1];
        USERDATA_G2 : coverpoint OpMode.userData[2];
        USERDATA_G3 : coverpoint OpMode.userData[3];
        USERDATA_G4 : coverpoint OpMode.userData[4];
        USERDATA_G5 : coverpoint OpMode.userData[5];
        USERDATA_G6 : coverpoint OpMode.userData[6];
    endgroup
    
endclass
