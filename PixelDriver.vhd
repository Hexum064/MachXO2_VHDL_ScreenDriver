library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PixelDriverEnt is
	port(	Data				:	in	std_logic_vector(23 downto 0);
			ScreenOut 			: 	out	std_logic;
			Clk, Reset, Enabled	:	in	std_logic);

end PixelDriverEnt;

architecture Behavioral of PixelDriverEnt is
	type	StageType	is 	(SSTRT, SMID, SFIN);
	signal	State		:	StageType;
begin
	
	DriverProc		:	process	(Clk, Reset)	 	
		variable BitCount	:	integer range 0 to 24			:= 0;
		variable TData		:	std_logic_vector(23 downto 0)	:= (others => '0');
	begin
		

	if (Enabled = '1') then
		if (Reset = '1') then
			ScreenOut <= '0';
			BitCount := 23;
			TData := (others => '0');
			State <= SSTRT;		

		elsif (rising_edge(Clk)) then
			case State is
				when SSTRT =>
					if (BitCount = 23) then
						TData := Data;
					end if;				
					
					ScreenOut <= '1';
					State <= SMID;			
				when SMID =>
					ScreenOut <= TData(BitCount);
					State <= SFIN;
				when SFIN =>
					ScreenOut <= '0';
					State <= SSTRT;  
					if (BitCount = 0) then
						BitCount := 23;
					else
						BitCount := BitCount - 1;
					end if;
			end case;
		end if;
	else
		ScreenOut <= '0';
	end if;
						
	end process DriverProc;
	
end Behavioral;