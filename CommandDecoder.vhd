library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ColorRegPkg.all;
use work.ConstantsPkg.all;

entity CommandDecoderEnt is
	port	(	Clk, SPIReady, MemReady, Reset, MatrixReady	:	in		std_logic;                  
				SPIData										:	in		std_logic_vector(31 downto 0);
				MemWrite, Draw, MemBank, ResetAll, Ready	:	out		std_logic;
				MemAddr, MemData							:	out		std_logic_vector(15 downto 0);
				RedLUT, GreenLUT, BlueLUT					:	out		ColorLUT;
				Rows										:	inout	std_logic_vector(5 downto 0);
				Columns										:	inout	std_logic_vector(8 downto 0));
		

end CommandDecoderEnt;

architecture Behavioral of CommandDecoderEnt is
	type	StateType	is	(SRST, SSTRT, SCMDD, SCMDRST, SCMDROW, SCMDCOL, SCMDRLUT, SCMDGLUT, SCMDBLUT, SDWAIT, SDRAW0, SDRAW1, SMEMW00, SMEMW01, SMEMW10, SMEMW11, SWAIT);
	signal	State			:	StateType;
	signal	TData			:	std_logic_vector(31 downto 0);
	signal	TBank			:	std_logic := '0';
		            
begin

	DecoderSM	:	process	(Clk, Reset)
		variable	RowCount	:	integer	range 0 to MAX_ROWS - 1;
		variable	ColCount	:	integer	range 0 to MAX_COLS - 1;
		variable	Temp		:	integer	range 0	to 65535;
	begin
	
	if (Reset = '1') then
		State <= SRST;
		Rows <= (others => '0');
		Columns <= (others => '0');
		RedLUT <= ((others=> (others=>'0')));
		BlueLUT <= ((others=> (others=>'0')));
		GreenLUT <= ((others=> (others=>'0')));		
	elsif (rising_edge(Clk)) then
		case State is		  
			when SRST =>	   
				TBank <= '0';
				MemBank <= '0';
				State <= SSTRT;	
				Ready <= '1';			
			when SSTRT =>
				MemWrite <= '0';
				Draw <= '0';
				ResetAll <= '0';
				MemAddr <= (others => '0');
				MemData <= (others => '0'); 
				
				if (SPIReady = '0') then
					State <= SSTRT;
				else --SPIReady = '1'
					TData <= SPIData;
					State <= SCMDD;
				end if;
				
			when SCMDD =>
			

				
				if (TData(31) = '0') then  	
					Ready <= '0';
					State <= SMEMW00;
				else --TData(31) = '1' so it's a command;
					case to_integer(unsigned(TData(26 downto 24))) is
						when 0 =>
							State <= SCMDRST;
						when 1 =>
							State <= SCMDROW;
						when 2 =>
							State <= SCMDCOL;						
						when 3 =>
							State <= SCMDRLUT;						
						when 4 =>
							State <= SCMDGLUT;						
						when 5 =>
							State <= SCMDBLUT;						
						when 6 =>
							State <= SDWAIT;	
						when others =>
							State <= SSTRT;
					end case;
				end if;
			
			when SCMDRST =>
				RowCount := 0;
				ColCount := 0;	
				TBank <= '0';					
				ResetAll <= '1';
				TData <= (others => '0');
				MemBank <= '0';
				State <= SWAIT;
			when SCMDROW =>
				Rows <= TData(5 downto 0);
				State <= SWAIT;
			when SCMDCOL =>
				Columns <= TData(8 downto 0);
				State <= SWAIT;
			when SCMDRLUT =>
				RedLUT(to_integer(unsigned(TData(12 downto 8)))) <= TData(7 downto 0);
				State <= SWAIT;
			when SCMDGLUT =>	
				GreenLUT(to_integer(unsigned(TData(12 downto 8)))) <= TData(7 downto 0);
				State <= SWAIT;
			when SCMDBLUT =>
				BlueLUT(to_integer(unsigned(TData(12 downto 8)))) <= TData(7 downto 0);
				State <= SWAIT;			
			when SDRAW0 =>
				Draw <= '0'; 
				RowCount := 0;
				ColCount := 0;	
				
				MemBank <= TBank;
				State <= SWAIT;
			when SDRAW1 =>
				Draw <= '1';			
				Ready <= '1'; 
				TBank<= NOT(TBank);
			  	State <= SDRAW0; 
			when SDWAIT =>
				if (MatrixReady = '1') then
					State <= SDRAW1;
				end if;
			when SMEMW00 =>
				
				if (MemReady = '0') then
					State <= SMEMW00;
				else --MemReady = '1'
					Temp := (to_integer(unsigned(Rows)) * ColCount) + RowCount;
					
					if (TBank = '1') then
						Temp := Temp + IMG_BUF_SIZE;
					end if;
					
					MemAddr <= std_logic_vector(to_unsigned(Temp, 16));
					MemData <= TData(31 downto 16);
					MemWrite <= '0';
					State <= SMEMW01;
				end if;
			when SMEMW01 =>
				
				if (MemReady = '1') then
					MemWrite <= '1';
					State <= SMEMW01;
				else 
					MemWrite <= '0';
					RowCount := RowCount + 1;
					State <= SMEMW10;
				end if;
			when SMEMW10 =>
				if (MemReady = '0') then
					State <= SMEMW10;
				else --MemReady = '1'
					Temp := (to_integer(unsigned(Rows)) * ColCount) + RowCount;
					
					if (TBank = '1') then
						Temp := Temp + IMG_BUF_SIZE;
					end if;
					
					MemAddr <= std_logic_vector(to_unsigned(Temp, 16));
					MemData <= TData(15 downto 0);
					
					State <= SMEMW11;
				end if;				
			when SMEMW11 =>
				if (MemReady = '1') then
					MemWrite <= '1';
					State <= SMEMW11;
				else	 
					MemWrite <= '0';
					RowCount := RowCount + 1;
					
					if (RowCount >= to_integer(unsigned(Rows))) then
						RowCount := 0;
						ColCount := ColCount + 1;
					end if;
					
					if (ColCount >= to_integer(unsigned(Columns))) then
						ColCount := 0;
						State <= SDWAIT;
					else
						State <= SWAIT;
					end if;
									
				end if;			
			when SWAIT =>
				if (SPIReady = '1') then	
					State <= SWAIT;
				else
					State <= SSTRT;
				end if;
				
		end case;
	
	
	end if;
	
	
	end process DecoderSM;

end Behavioral;