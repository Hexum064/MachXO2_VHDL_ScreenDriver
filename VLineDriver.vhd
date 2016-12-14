library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ColorRegPkg.all;
use work.VLineBuffPkg.all;
use work.ConstantsPkg.all;

entity VLineDriverEnt is
	port	(	Clk, Draw, Reset, MemReady	:	in	std_logic;
				MemAddr						:	out	std_logic_vector(15 downto 0);
				MemData						:	in	std_logic_vector(15 downto 0);
				MemRead						:	out std_logic;
				RedLUT, GreenLUT, BlueLUT	:	in	ColorLUT;
				VBuff						:	out	VLineBuff;
				AddrStart					:	in std_logic_vector(15 downto 0);
				Ready, PClk, PReset			:	out std_logic;
				Rows						:	in std_logic_vector(5 downto 0)	;
				Count, Count2				:	out std_logic_vector(7 downto 0));
		

end VLineDriverEnt;

architecture Behavioral of VLineDriverEnt is
	type	StateType	is	(SSTRT, SDRAW, SMEM0, SMEM1, SMEMRD, SRSTP, SPCLK);
	signal	State			:	StateType;
	
	
begin

	VLineProc	:	process(Clk, Reset)
		variable	PClkCount	:	integer	range 0 to 160;		--143
		variable	PixelCount	:	integer	range 0 to MAX_ROWS;
		variable	ClkDivCount	:	integer range 0	to PDRIVER_CLK_DIV;
		variable	TPClk		:	std_logic;	
		variable	TAddr		:	integer range 0 to 65535	:= 0;
		variable	TCount		:	std_logic_vector (15 downto 0);
		variable	TMemData	:	std_logic_vector (15 downto 0);
	begin
	
		if (Reset = '1') then
			State <= SSTRT;
		elsif (rising_edge(Clk)) then
			case State is
				when SSTRT =>
					MemAddr <= (others => '0');
					MemRead <= '0';
					VBuff <= ((others=> (others=>'0')));
					Ready <= '1';
					PClk <= '0';
					PReset <= '1';
					TAddr := 0;
					PClkCount := 0;
					PixelCount := 0;
					State <= SDRAW;
				when SDRAW =>

					if (Draw = '1') then
						State <= SMEM0;
						TAddr := to_integer(unsigned(AddrStart));  
						MemAddr <= std_logic_vector(to_unsigned(TAddr, MemAddr'length));
						Ready <='0';
					else --Draw = '0'
						State <= SDRAW;
					end if;
				when SMEM0 =>	

						State <= SMEM1;
						
						MemRead <= '1';				
				
				when SMEM1 =>
					if (MemReady = '1') then
						State <= SMEMRD; 
						MemRead <= '0';
						TMemData := MemData;
					end if;
				when SMEMRD =>
					Count <= TMemData(15 downto 8);
					Count2 <= TMemData(7 downto 0);
					--State <= SRSTP;
					PixelCount := PixelCount + 1;
					VBuff(PixelCount - 1)(23 downto 16) <= GreenLUT(to_integer(unsigned(TMemData(14 downto 10))));
					VBuff(PixelCount - 1)(15 downto 8) <= RedLUT(to_integer(unsigned(TMemData(9 downto 5))));
					VBuff(PixelCount - 1)(7 downto 0) <= BlueLUT(to_integer(unsigned(TMemData(4 downto 0))));
					TAddr := TAddr + 1;
					

					
					if (PixelCount >= to_integer(unsigned(Rows))) then
						State <= SRSTP;
					else
						State <= SMEM0;	 
						MemAddr <= std_logic_vector(to_unsigned(TAddr, MemAddr'length));
					end if;

				when SRSTP =>
					PReset <= '1';
					PClk <= '1';
					TPClk := '1';
					ClkDivCount := 0;
					PClkCount := 0;
					State <= SPCLK;
				when SPCLK =>
					
					PReset <= '0';
					ClkDivCount := ClkDivCount + 1;
					
					if (ClkDivCount < PDRIVER_CLK_DIV) then
						
						State <= SPCLK;
					else	--ClkDivCount = PDRIVER_CLK_DIV

						

							if (PClkCount >= 143) then	 
								TPClk := '0';
								State <= SSTRT;
							else --PClkCount < 143	
								ClkDivCount := 0;
								TPClk := NOT(TPClk);
								PClk <= TPClk;								
								PClkCount := PClkCount + 1;
								State <= SPCLK;
							end if;

					end if;				
					
			end case;		
		end if;
	
	end process VLineProc;

end Behavioral;