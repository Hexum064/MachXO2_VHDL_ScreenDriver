library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MemoryControllerEnt is
	port ( 	Clk, Reset		:	in		std_logic;	
			WData			: 	in 		std_logic_vector(15 downto 0);
			RData			:	out		std_logic_vector(15 downto 0);
			RReady, WReady	:	out		std_logic;
			RAddr, WAddr	:	in		std_logic_vector(15 downto 0);
			Write, Read		:	in 		std_logic;
			MemDataQ		:	inout 	std_logic_vector(15 downto 0);
			MemAddr			:	out		std_logic_vector(15 downto 0);
			MemWEn, MemOEn	:	out		std_logic);
			
end MemoryControllerEnt;

architecture Behavioral of MemoryControllerEnt is
	type	StateType		is	(SSTRT, SWINIT, SWEND, SRINIT, SREND);
	signal	State			:	StateType := SSTRT;	 
	signal 	TRData			:	std_logic_vector(15 downto 0) := (others => 'Z');
	signal	TRReady			:	std_logic := '0';
begin
		
	ControllerProc	:	process(Clk, Reset)

		variable	WPend, RPend		:	std_logic;
		variable	ClkCount			:	integer range 0 to 133000000 := 0;
	begin
		
		if (Reset = '1') then
			RData <= (others => '0');
			State <= SSTRT;
		elsif (rising_edge(Clk)) then
			case State is
				when SSTRT =>
					MemWEn <= '1';
					MemOEn <= '1';
					MemDataQ <= (others => 'Z');
					MemAddr <= (others => '0');
					WPend := '0';
					RPend := '0';
					WReady <= '1';
					RReady <= '0'; 
					ClkCount := 0;
					if (Write = '1') then
						State <= SWINIT;
					end if;
					
					if (Read = '1') then
						State <= SRINIT;
					end if;
				when SWINIT =>	  

					
					ClkCount := ClkCount + 1;
					
					if (Read = '1') then
						RPend := '1';
					end if;
					
					
					if (ClkCount = 1) then
						MemDataQ <= WData;
						MemAddr <= WAddr;
						WReady <= '0';
						WPend := '0';						
					elsif (ClkCount = 3) then
						MemWEn<= '0';
					elsif (ClkCount = 11) then
						MemWEn<= '1';
					elsif (ClkCount = 13) then
						WReady <= '1';
						State <= SWEND;
						ClkCount := 0;
					end if;
						
				when SWEND => 
					
					MemDataQ <= (others => '0');
					
					if (RPend = '1') then
						State <= SRINIT;
					else
						State <= SSTRT;
					end if;
				when SRINIT => 
				
				
					ClkCount := ClkCount + 1;
					
					if (Write = '1') then
						WPend := '1';
					end if;
					
					
					if (ClkCount = 1) then
						MemDataQ <= (others => 'Z');
						MemAddr <= RAddr;
						RReady <= '0';
						RPend := '0';
					elsif (ClkCount = 3) then
						MemOEn <= '0';
					elsif (ClkCount = 11) then
						RData <= MemDataQ;
					elsif (ClkCount = 13) then
						RReady<= '1';
						MemOEn <= '1';
						State <= SREND;
						ClkCount := 0;
					end if;				

				when SREND =>  

					MemDataQ <= (others => 'Z');
					
					if (WPend = '1') then
						State <= SWINIT;
					else
						State <= SSTRT;
					end if;
			end case;
		
		end if;
			


	end process ControllerProc;


end Behavioral;