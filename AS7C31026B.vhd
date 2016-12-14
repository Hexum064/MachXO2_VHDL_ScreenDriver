------------------------------------------------------------------------------------
--
--    File Name: AS7C31026B.vhd 
--      Version:  1.0
--         Date:  2 April 2005
--        Model:  BUS Functional
--
--
--      Company:  Alliance Semiconductor pvt ltd.
--  Part Number:  AS7C31026B (64K x 16)
--
--  Description:  Alliance 1Mb Fast Asynchronous SRAM
--
--  Note: The model is Done for 10ns cycle time . To work with other cycle time, 
--  we have to change the timing parameters according to Data sheet.
--   
------------------------------------------------------------------------------------

LIBRARY ieee;
    USE ieee.std_logic_1164.all;
    USE ieee.std_logic_unsigned.all;

ENTITY AS7C31026B IS
    GENERIC (
   
        Tsim   : TIME	:= 10000 ns;
   
   -- write timings 10ns address access time
        twc   : TIME	:= 10 ns;
	tcw   : TIME	:= 8  ns;
	taw   : TIME	:= 8  ns;
	tas   : TIME	:= 0  ns;
	twp   : TIME	:= 7  ns;
	twr   : TIME	:= 0  ns;
	tah   : TIME	:= 0  ns;
	tdw   : TIME	:= 5  ns;
	tdh   : TIME	:= 0  ns;
	twz   : TIME	:= 5  ns;
	tow   : TIME	:= 1  ns;
	tbw   : TIME	:= 7  ns;
   
   -- Read timings 10ns address access time
	trc   : TIME	:= 10 ns;
	taa   : TIME	:= 10 ns;
	tace  : TIME	:= 10 ns;
	toe   : TIME	:= 5  ns;
	toh   : TIME	:= 3  ns;
	tclz  : TIME	:= 3  ns;
	tchz  : TIME	:= 3  ns;
	tolz  : TIME	:= 0  ns;
	tohz  : TIME	:= 5  ns;
	tba   : TIME	:= 5  ns;
	tblz  : TIME	:= 0  ns;
	tbhz  : TIME	:= 5  ns;
	tpu   : TIME	:= 0  ns;
	tpd   : TIME	:= 10 ns;
	
	t0    : TIME	:= 0.1 ns;
	t1    : TIME	:= 1 ns;
	
  -- Bus Width and Data Bus
        addr_bits : INTEGER := 16;
        data_bits : INTEGER := 16
                );
	
	
    PORT (
	Address    : IN    STD_LOGIC_VECTOR (addr_bits - 1 DOWNTO 0);
	DataIO     : INOUT STD_LOGIC_VECTOR (data_bits - 1 DOWNTO 0) := (OTHERS => 'Z');
	OE_bar     : IN    STD_LOGIC; 
	CE_bar     : IN    STD_LOGIC;
	WE_bar     : IN    STD_LOGIC;
	LB_bar     : IN    STD_LOGIC;
	UB_bar     : IN    STD_LOGIC
          );
	
	
	END AS7C31026B;
	
	
ARCHITECTURE behave OF AS7C31026B IS
    TYPE   memory IS ARRAY (2 ** addr_bits - 1 DOWNTO 0) OF STD_LOGIC_VECTOR ((data_bits/2) - 1 DOWNTO 0);

    
    --For Timig Checks
    SIGNAL oe_n, ce_n, we_n, lb_n, ub_n                    : STD_LOGIC;
    SIGNAL add_reg 				           : STD_LOGIC_VECTOR (addr_bits - 1 DOWNTO 0);
    SIGNAL data_reg       			           : STD_LOGIC_VECTOR (data_bits - 1 DOWNTO 0);
    
    SIGNAL t2 : STD_LOGIC := '0' ;
    SIGNAL    Done    : BOOLEAN := FALSE;
    
    
    SIGNAL oe_n_dly, ce_n_dly, we_n_dly, lb_n_dly, ub_n_dly               : STD_LOGIC;
    SIGNAL add_reg_dly 				           : STD_LOGIC_VECTOR (addr_bits - 1 DOWNTO 0);
    SIGNAL data_reg_dly       			           : STD_LOGIC_VECTOR (data_bits - 1 DOWNTO 0);
    
    -- For Write access
    SIGNAL initiate_cebar,initiate_webar,initiate_wecebar  : STD_LOGIC;
    SIGNAL initiate_write1,initiate_write2                 : STD_LOGIC := '0';
    SIGNAL delayed_WE,delayed_OE			   : STD_LOGIC;
    SIGNAL Address_write1,Address_write2 		   : STD_LOGIC_VECTOR (addr_bits - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dataIO1 					   : STD_LOGIC_VECTOR (data_bits - 1 DOWNTO 0) := (OTHERS => 'Z');
    
    -- For Read Access
    SIGNAL data_temp 					   : STD_LOGIC_VECTOR (data_bits - 1 DOWNTO 0) := (OTHERS => 'Z');
    SIGNAL Address_read1,Address_read2 			   : STD_LOGIC_VECTOR (addr_bits - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL initiate_read1,initiate_read2 		   : STD_LOGIC := '0';
    
    
	
	
    --SIGNAL Tprev_address_event, Tprev_address_event1 : TIME ;
 
 BEGIN
       oe_n <= OE_bar;
       ce_n <= CE_bar;
       we_n <= WE_bar;
       lb_n <= LB_bar;
       ub_n <= UB_bar;

       add_reg <= Address(addr_bits - 1 DOWNTO 0);
       data_reg <= DataIO (15 DOWNTO 0); 
	
    main : PROCESS (oe_n, ce_n, we_n, lb_n, ub_n, add_reg, data_reg,t2,initiate_cebar,initiate_webar,initiate_wecebar,initiate_write1,initiate_write2,initiate_read1,initiate_read2)
	
	-- Memory Array
        VARIABLE dummy_array0, dummy_array1 : memory;
	VARIABLE mem_array0, mem_array1 : memory;
	
			
    BEGIN
	
       oe_n_dly <= oe_n after t0;
       ce_n_dly <= ce_n after t0 ;
       we_n_dly <= we_n after t0 ;
       lb_n_dly <= lb_n after t0 ;
       ub_n_dly <= ub_n after t0 ;

       add_reg_dly <= add_reg(addr_bits - 1 DOWNTO 0) after t0;
       data_reg_dly <= data_reg (15 DOWNTO 0) after t0; 
	
-- *******  Registering the Access ********    
   if(ce_n'event or we_n'event or oe_n'event or add_reg'event or data_reg'event) then
   
     if((ce_n='0') and (we_n = '0')) then
      
       Address_write1 <= add_reg;
       Address_write2 <= Address_write1;
       dataIO1  <= data_reg;
       dummy_array0(conv_integer(Address_write1)) :=  dataIO1(7 downto 0) ;
       dummy_array1(conv_integer(Address_write1)) :=  dataIO1(15 downto 8) ;
       
   
     end if;
   end if;	
   

	
-- ****  Write Access *************	
	
-- ****** CE_bar controlled ***********	
   
   if(ce_n'event and (ce_n = '0') ) then
      initiate_cebar <=  '0';
      initiate_wecebar<= '0';
   end if;
		
   if(ce_n'event and (ce_n = '1') ) then
	
	 if((ce_n_dly = '0') and (ce_n_dly'last_event >= (tcw-t0))) then
	   
	   if ((we_n_dly = '0') and (we_n_dly'last_event >= (twp-t0))) then
	      Address_write2 <= Address_write1;
      	      dummy_array0(conv_integer(Address_write1)) :=  dataIO1(7 downto 0) ;
              dummy_array1(conv_integer(Address_write1)) :=  dataIO1(15 downto 8) ;  
              initiate_cebar <= '1';
	  else
	      initiate_cebar <= '0';
	  end if; 

	else
	      initiate_cebar <= '0';
	end if; 
	
   end if;
 
   
-- ***** WE_bar controlled  **********
 
   
   
   if(we_n'event and (we_n = '0') ) then
     
      initiate_webar <= '0';
      initiate_wecebar <= '0';
      delayed_WE <= we_n AFTER twz;
   end if;
   
   
   if(we_n'event and (we_n = '1') ) then
	
	
	delayed_WE <= we_n;
	
	if ((we_n_dly = '0') and (we_n_dly'last_event >= (twp-t0))) then
	  
	  if((ce_n_dly = '0') and (ce_n_dly'last_event >= (tcw-t0))) then
	      Address_write2 <= Address_write1;
      	      dummy_array0(conv_integer(Address_write1)) :=  dataIO1(7 downto 0) ;
              dummy_array1(conv_integer(Address_write1)) :=  dataIO1(15 downto 8) ;  
              initiate_webar <= '1';
	  else
	      initiate_webar <= '0';
	  end if; 
	else
	      initiate_webar <= '0';
	end if;          
   end if;
   
-- ******* WE_bar & CE_bar controlled ( If both comes to high at the same time)**********
   
   if(we_n'event and ce_n'event ) then
   
      if ((ce_n = '1') and (we_n = '1')) then
         
         if (((we_n_dly = '0') and (we_n_dly'last_event >= (twp-t0))) and ((ce_n_dly = '0') and (ce_n_dly'last_event >= (tcw-t0))) )  then
              Address_write2 <= Address_write1;
      	      dummy_array0(conv_integer(Address_write1)) :=  dataIO1(7 downto 0) ;
              dummy_array1(conv_integer(Address_write1)) :=  dataIO1(15 downto 8) ;
	      initiate_wecebar <= '1';
           else
      	       initiate_wecebar <= '0' ;    
           end if; 
      else
           initiate_wecebar <= '0';
      end if;
   end if;      
   
-- ******* initiate_cebar or initiate_webar or ini_wecebar goes high - initiate write access **************

  if ( initiate_cebar'event or initiate_webar'event or initiate_wecebar'event) then
  
    if( (initiate_cebar = '1') or (initiate_webar = '1') or (initiate_wecebar = '1') ) then
      
      if (( add_reg_dly'last_event >= (twc-t0)) and ( data_reg_dly'last_event >= (tdw-t0))) then
         initiate_write1 <= '1';
      else
            initiate_write1 <= '0';
      end if;
    else
       initiate_write1 <= '0';
    end if;
  end if;

-- ******* Address/data changes before write completion, then New write(2) initation*************************   
   
   
   if (t2'event) then
            
     if (( add_reg_dly'last_event >= (twc-t0)) and ( data_reg_dly'last_event >= (tdw-t0))) then
        
	if ( (we_n_dly = '0') and  (ce_n_dly = '0')) then
	
	  if ( ( ce_n_dly'last_event >=(tcw-t0)) and ( we_n_dly'last_event >=(twp-t0)) ) then
	          Address_write2 <= Address_write1;
      	          dummy_array0(conv_integer(Address_write1)) :=  dataIO1(7 downto 0) ;
                  dummy_array1(conv_integer(Address_write1)) :=  dataIO1(15 downto 8) ;
                  initiate_write2 <= '1';
          else
                  initiate_write2 <= '0';
          end if;
        else
                  initiate_write2 <= '0';
        end if;
      else
                  initiate_write2 <= '0';
      end if;
   end if;

 
 -- ***** Write completion (Writing into mem_arrayx[][]) ***********
 
 
 if(initiate_write1'event and (initiate_write1= '1')) then
 
      
      if((ub_n_dly = '0') and ( ub_n_dly'last_event >=(tbw-t0))) then
		  mem_array1(conv_integer(Address_write2)) := dummy_array1(conv_integer(Address_write2));
      end if;
      if((lb_n_dly = '0') and ( lb_n_dly'last_event >=(tbw-t0))) then
 		  mem_array0(conv_integer(Address_write2)) := dummy_array0(conv_integer(Address_write2));
      end if; 
      initiate_write1 <= '0';
      
end if;

      
 if(initiate_write2'event and (initiate_write2= '1')) then
 
      
      if((ub_n_dly = '0') and ( ub_n_dly'last_event >=(tbw-t0))) then
		  mem_array1(conv_integer(Address_write2)) := dummy_array1(conv_integer(Address_write2));
      end if;
      if((lb_n_dly = '0') and ( lb_n_dly'last_event >=(tbw-t0))) then
 		  mem_array0(conv_integer(Address_write2)) := dummy_array0(conv_integer(Address_write2));
      end if; 
      initiate_write2 <= '0';
end if;

   
-- ****** Read Access  ********************

-- ******** Address transition initiates the Read access ********


if(add_reg'event) then     
     Address_read1 <=Address;
     Address_read2 <=Address_read1;
     if ( add_reg_dly'last_event >= (trc-t0)) then
         if ( (ce_n_dly = '0') and (we_n_dly = '1') ) then
		  initiate_read1 <= '1';
         else
      	    initiate_read1 <= '0';
         end if; 
     else
       initiate_read1 <= '0';
     end if;
end if;
   

if (t2'event) then
     if (( add_reg_dly'last_event >= (trc-t0))) then
     
        if ( (ce_n_dly = '0') and (we_n_dly = '1') ) then
             Address_read2 <=Address_read1;
	     initiate_read2 <= '1';
        else
             initiate_read2 <= '0';
        end if;
     else
       initiate_read2 <= '0';
    end if;
end if;


-- ***** Data drive to data_temp when $time >= taa & tace & trc (all are having same times) ******
 
if(initiate_read1'event or initiate_read2'event) then

     if ((initiate_read1 = '1') or (initiate_read2 = '1')) then
     
         if ((ce_n_dly = '0') and (we_n_dly = '1')) then
	 
             if ( ((we_n_dly = '1') and ( we_n_dly'last_event >=(trc-t0))) and  ((ce_n_dly = '0') and ( ce_n_dly'last_event >=(tace-t0))) and  ((oe_n_dly = '0') and ( oe_n_dly'last_event >=(toe-t0)))) then
			if((lb_n_dly = '0') and ( lb_n_dly'last_event >=(tba-t0))) then   
			        data_temp(7 downto 0) <= mem_array0(conv_integer(Address_read2));
			else
		  		data_temp(7 downto 0) <= (OTHERS => 'Z');
			end if;
			if((ub_n_dly = '0') and ( ub_n_dly'last_event >=(tba-t0))) then
      		                data_temp(15 downto 8) <= mem_array1(conv_integer(Address_read2));
		        else
          	  		data_temp(15 downto 8) <= (OTHERS => 'Z');
                        end if;
			
              else
	          data_temp <= TRANSPORT (OTHERS => 'Z') after toh;
	      end if;
	    else
	         data_temp <= TRANSPORT (OTHERS => 'Z') after toh;
         end if;
              initiate_read1 <= '0';
              initiate_read2 <= '0';
     else
	      data_temp <= TRANSPORT (OTHERS => 'Z') after toh;
     end if;
 end if;  

 
if(oe_n'event and (oe_n = '0') ) then
      delayed_OE <= NOT(oe_n);
   end if;
   
   
   if(oe_n'event and (oe_n = '1') ) then
	delayed_OE <= NOT(oe_n) AFTER tohz;
   end	if;
 		

 --WAIT FOR Tsim;
 --Done <= TRUE;

END PROCESS main;

-- Output buffer
      WITH (delayed_OE AND delayed_WE) SELECT
        DataIO <= TRANSPORT data_temp WHEN '1',
                      (OTHERS => 'Z')  WHEN '0',
                      (OTHERS => 'Z')  WHEN OTHERS;
   
  
    	
	
	Time : PROCESS BEGIN
        IF Done = FALSE THEN
            WAIT FOR t1;
	    t2 <= '1';
            WAIT FOR t1;
	    t2 <= '0';
        ELSE
            WAIT;
        END IF;
    END PROCESS;
	
	
END behave;
