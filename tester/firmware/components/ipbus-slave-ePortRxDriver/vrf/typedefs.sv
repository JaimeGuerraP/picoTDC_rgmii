typedef enum bit [1:0] {PRBS7, PRBS15, PRBS23, PRBS31}                          prbsMode_t;
typedef enum bit [2:0] {LSIDLE, LSX4, LSX8, LSX16, HSIDLE, HSX8, HSX16, HSX32}  speedMode_t;
typedef enum bit [1:0] {PRBS, CONSTPATT, USERDATA, NODATA}                      dataMode_t;
typedef enum bit       {DIFF, EQAL}                                             prbsSeedMode_t;
typedef enum bit       {NORMAL_TEST, DELAY_TEST}                                test_t;
