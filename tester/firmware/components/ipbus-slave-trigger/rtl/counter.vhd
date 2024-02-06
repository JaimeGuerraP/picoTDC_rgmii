library ieee;
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 

-- DPo
-- HIT is driven by HIT_IN if external is 0 and EN is 1 or is 1 if external and reset are 1
 
entity counter is 
  port(C, CLR, EN, START, CIRC, EXTERNAL	: in  std_logic;  
	TRIGGER,HIT		              : out  std_logic;
	RESET                          : buffer std_logic;
	TRIGGER_IN,HIT_IN,CNT_IN  : in std_logic_vector(11 downto 0)
	);  
end counter; 


architecture archi of counter is  
  signal tmp: std_logic_vector(11 downto 0);
  signal EN2: std_logic := '0';
  signal Q:   std_logic_vector(11 downto 0);

-- if CIRCULAR is 0 it is single shot with no rearm
  
  begin  

  process (C,START, CLR, Q)

    begin 
        if rising_edge  (C) then 

                RESET <= '0';   

            if (CLR='1') then  
                EN2 <= '0';
                RESET <= '0';
            elsif (START= '1') then 
                RESET <= '1';
                EN2 <= '1';
                if EN2 = '1' then 
                    RESET <= '0';
                end if;
            elsif (Q = CNT_IN) then 
                RESET <= '1';
                EN2 <= '1';
            elsif Q = TRIGGER_IN and EN = '1'and CIRC = '0' then 
                EN2 <= '0';
                
            end if;
            
        end if;
  end process;
  
  -- HIT is generated after counter reaches HIT_IN value with External = 0 otherwise it is immediate  
  -- TRIGGER is generated when couter reaches TRIGGER_IN Value
  -- counter returns to 0 when overflow
  
      process (C) 
        begin  
          if rising_edge  (C) then 
            if (CLR='1') or RESET= '1' then  
                tmp <= "000000000000";  
              else   
                  if (EN = '1') then
                     if  (EN2 = '1') then 
                        tmp <= tmp + 1; 
                     end if;
                     if (tmp = CNT_IN) then 
                         tmp <= "000000000000";  
                     end if;
                  end if;
              end if; 
           end if; 
      end process; 
     
      HIT <= '1' when (Q = HIT_IN and EN = '1' and EXTERNAL = '0') or ( EXTERNAL = '1' and RESET ='1')  else '0';
      TRIGGER <= '1' when (Q = TRIGGER_IN and EN = '1' ) else '0';
      Q <= tmp;  

end archi; 
