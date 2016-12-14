library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ColorRegPkg.all;

entity SPIReceiverEnt is
	port	(	Clk, SPIClock, MOSIData, Reset	:	in		std_logic;
				SPIData							:	out		std_logic_vector(31 downto 0);
				Ready							:	out		std_logic);
		

end SPIReceiverEnt;

architecture Behavioral of SPIReceiverEnt is
	signal 	TReady	:	std_logic	:= '0';
	signal	TData	:	std_logic_vector(31 downto 0);	 
begin


	process (SPIClock, Reset, Clk)
		variable	BitCount	:	integer	range 0 to 32 := 32;
		variable 	TData :  std_logic_vector( 31 downto 0); --integer range 0 to 127 := 127;
		variable	ClkCount	:	integer range 0 to 133000000 := 0;
	begin
	
		if (Reset = '1') then
			SPIData <= (others => '0');
			TData := (others => '0');
			BitCount := 32; 
			TReady <= '0';
		elsif (rising_edge(SPIClock)) then
			
			BitCount := BitCount - 1;
			TData(BitCount) := MOSIData;
			
			if (BitCount = 0) then
				BitCount := 32;		
				SPIData <= TData;	
				TReady <= '1';
			else
				TReady <= '0';
			end if;

		elsif (rising_edge(Clk)) then
		
			ClkCount := ClkCount + 1;
			if (ClkCount = 133000) then
				ClkCount := 0;
				--SPIData <= (others => '0');
				--TData := (others => '0');
				--BitCount := 32; 
				--TReady <= '0';
			end if;
		
		end if;

	
	end process;
   
	process (Clk)
	begin
		if (rising_edge(Clk)) then
			Ready <= TReady;
		end if;
	end process;

end Behavioral;