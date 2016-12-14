library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ConstantsPkg.all;

entity MatrixDriverEnt is
	port	(	Clk, Draw, MemBank, Reset, VLineReady	:	in	std_logic;
				Rows									:	in	std_logic_vector(5 downto 0);
				Columns									:	in	std_logic_vector(8 downto 0);
				AddrStart								:	out	std_logic_vector(15 downto 0);
				DrawVLine, Ready						:	out std_logic);
		

end MatrixDriverEnt;

architecture Behavioral of MatrixDriverEnt is
	type	StateType	is	(SSTRT, SDINIT, SADDRSET, SVRDY1, SVRDY0);
	signal	State		:	StateType;
	signal	TRows		:	integer	range 0 to 48;
	signal	TCols		:	integer	range 0 to 300;
	
begin

	DriverProc	:	process(Clk, Reset)
		variable	ColCount	:	integer	range 0 to 300;
		variable	TAddrStart	:	integer range 0 to 65535;
	begin
	
		if (Reset = '1') then
			State <= SSTRT;
		elsif (rising_edge(Clk)) then
			case State is
				when SSTRT =>
					Ready <= '1';
					DrawVLine <= '0';
					TAddrStart := 0;
					TRows <= 0;
					TCols <= 0;
					AddrStart <= (others => '0');
					ColCount := 0;
					
					if (Draw = '1') then
						State <= SDINIT;
					else	--Draw = '0'
						State <= SSTRT;
					end if;				
					
				when SDINIT =>
					TRows <= to_integer(unsigned(Rows));
					TCols <= to_integer(unsigned(Columns));
					Ready <= '0';
					
					if (MemBank = '1') then
						TAddrStart := 0;
					else
						TAddrStart := IMG_BUF_SIZE;
					end if;
					
					State <= SADDRSET;
				when SADDRSET =>
					if (VLineReady = '0') then
						State <= SADDRSET;
					else	--VLineReady = '1'
						
						AddrStart <= std_logic_vector(to_unsigned(TAddrStart, AddrStart'length));
						DrawVLine <= '1';
						State <= SVRDY1;
					end if;
				when SVRDY1 =>
					if (VLineReady = '1') then
						State <= SVRDY1;
					else	--VLineReady = '0' 
						TAddrStart := TAddrStart + TRows;
						DrawVLine <= '0';
						State <= SVRDY0;
					end if;
				when SVRDY0 =>				
					if (VLineReady = '0') then
						State <= SVRDY0;
					else	--VLineReady = '1'
						ColCount := ColCount + 1;
						
						if (ColCount >= TCols) then
							State <= SSTRT;
						else	--ColCount < TCols
							State <= SADDRSET;
						end if;
					end if;					
			end case;
		end if;
			
	
	end process DriverProc;

end Behavioral;
