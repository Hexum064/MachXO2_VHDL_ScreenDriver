

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ColorRegPkg.all;
use work.VLineBuffPkg.all;
use work.ConstantsPkg.all;

entity DisplayDriverEnt is
	port (	Clk, Reset		:	in		std_logic;
			SPIClk, MOSI	:	in		std_logic;
			MemData			:	inout	std_logic_vector (15 downto 0);
			MemAddr			:	out		std_logic_vector (15 downto 0);
			MemWEn,	MemOEn	:	out		std_logic;
			Ready			:	out		std_logic;
			DisplayData		:	out		std_logic_vector (MAX_ROWS - 1 downto 0));
end DisplayDriverEnt;

architecture Behavioral of DisplayDriverEnt is
	signal	RedLUT, BlueLUT, GreenLUT		:	ColorLUT;
	signal	Rows							:	std_logic_vector (5 downto 0);
	signal	Cols							:	std_logic_vector (8 downto 0);
	signal	ColBuff							:	VLineBuff;
	
	signal SPIData							:	std_logic_vector (31 downto 0);
	
	signal	SPIReady, Draw, MemBank			:	std_logic;
	
	signal	MRReady, MWReady, WEn, REn		:	std_logic;
	signal	MRAddr, MWAddr, MRData, MWData	:	std_logic_vector (15 downto 0);
	signal	ResetAll						:	std_logic;
	
	signal	MatrixReady, VLineDraw			:	std_logic;
	signal	AddrStart						:	std_logic_vector (15 downto 0);
	
	signal	VLineReady, PReset, PClk		:	std_logic;
	
	signal	VEnabled						:	std_logic_vector (47 downto 0);
	

		
	function To_Std_Logic(L: BOOLEAN) return std_ulogic is
	begin
		if L then
			return('1');
		else
			return('0');
		end if;
	end function To_Std_Logic;
	
	
	
begin
	

	
	
	VEnabled(0) <= To_Std_Logic(to_integer(unsigned(Rows)) > 0);
	VEnabled(1) <= To_Std_Logic(to_integer(unsigned(Rows)) > 1);
	VEnabled(2) <= To_Std_Logic(to_integer(unsigned(Rows)) > 2);
	VEnabled(3) <= To_Std_Logic(to_integer(unsigned(Rows)) > 3);
	VEnabled(4) <= To_Std_Logic(to_integer(unsigned(Rows)) > 4);
	VEnabled(5) <= To_Std_Logic(to_integer(unsigned(Rows)) > 5);
	VEnabled(6) <= To_Std_Logic(to_integer(unsigned(Rows)) > 6);
	VEnabled(7) <= To_Std_Logic(to_integer(unsigned(Rows)) > 7);
	VEnabled(8) <= To_Std_Logic(to_integer(unsigned(Rows)) > 8);
	VEnabled(9) <= To_Std_Logic(to_integer(unsigned(Rows)) > 9); 
	
	VEnabled(10) <= To_Std_Logic(to_integer(unsigned(Rows)) > 10);
	VEnabled(11) <= To_Std_Logic(to_integer(unsigned(Rows)) > 11);
	VEnabled(12) <= To_Std_Logic(to_integer(unsigned(Rows)) > 12);
	VEnabled(13) <= To_Std_Logic(to_integer(unsigned(Rows)) > 13);
	VEnabled(14) <= To_Std_Logic(to_integer(unsigned(Rows)) > 14);
	VEnabled(15) <= To_Std_Logic(to_integer(unsigned(Rows)) > 15);
	VEnabled(16) <= To_Std_Logic(to_integer(unsigned(Rows)) > 16);
	VEnabled(17) <= To_Std_Logic(to_integer(unsigned(Rows)) > 17);
	VEnabled(18) <= To_Std_Logic(to_integer(unsigned(Rows)) > 18);
	VEnabled(19) <= To_Std_Logic(to_integer(unsigned(Rows)) > 19);
	
	VEnabled(20) <= To_Std_Logic(to_integer(unsigned(Rows)) > 20);
	VEnabled(21) <= To_Std_Logic(to_integer(unsigned(Rows)) > 21);
	VEnabled(22) <= To_Std_Logic(to_integer(unsigned(Rows)) > 22);
	VEnabled(23) <= To_Std_Logic(to_integer(unsigned(Rows)) > 23);
	VEnabled(24) <= To_Std_Logic(to_integer(unsigned(Rows)) > 24);
	VEnabled(25) <= To_Std_Logic(to_integer(unsigned(Rows)) > 25);
	VEnabled(26) <= To_Std_Logic(to_integer(unsigned(Rows)) > 26);
	VEnabled(27) <= To_Std_Logic(to_integer(unsigned(Rows)) > 27);
	VEnabled(28) <= To_Std_Logic(to_integer(unsigned(Rows)) > 28);
	VEnabled(29) <= To_Std_Logic(to_integer(unsigned(Rows)) > 29);
	
	VEnabled(30) <= To_Std_Logic(to_integer(unsigned(Rows)) > 30);
	VEnabled(31) <= To_Std_Logic(to_integer(unsigned(Rows)) > 31);
	VEnabled(32) <= To_Std_Logic(to_integer(unsigned(Rows)) > 32);
	VEnabled(33) <= To_Std_Logic(to_integer(unsigned(Rows)) > 33);
	VEnabled(34) <= To_Std_Logic(to_integer(unsigned(Rows)) > 34);
	VEnabled(35) <= To_Std_Logic(to_integer(unsigned(Rows)) > 35);
	VEnabled(36) <= To_Std_Logic(to_integer(unsigned(Rows)) > 36);
	VEnabled(37) <= To_Std_Logic(to_integer(unsigned(Rows)) > 37);
	VEnabled(38) <= To_Std_Logic(to_integer(unsigned(Rows)) > 38);
	VEnabled(39) <= To_Std_Logic(to_integer(unsigned(Rows)) > 39);
	
	VEnabled(40) <= To_Std_Logic(to_integer(unsigned(Rows)) > 40);
	VEnabled(41) <= To_Std_Logic(to_integer(unsigned(Rows)) > 41);
	VEnabled(42) <= To_Std_Logic(to_integer(unsigned(Rows)) > 42);
	VEnabled(43) <= To_Std_Logic(to_integer(unsigned(Rows)) > 43);
	VEnabled(44) <= To_Std_Logic(to_integer(unsigned(Rows)) > 44);
	VEnabled(45) <= To_Std_Logic(to_integer(unsigned(Rows)) > 45);
	VEnabled(46) <= To_Std_Logic(to_integer(unsigned(Rows)) > 46);
	VEnabled(47) <= To_Std_Logic(to_integer(unsigned(Rows)) > 47);

	
	
	SPIRvcr		:	entity work.SPIReceiverEnt(Behavioral)		port map 	(Clk => Clk, 
																			SPIClock => SPIClk, 
																			MOSIData => MOSI, 
																			Reset => Reset, 
																			SPIData => SPIData, 
																			Ready => SPIReady);
	
	CmdDecod	:	entity work.CommandDecoderEnt(Behavioral)	port map 	(Clk => Clk, 
																			SPIReady => SPIReady, 
																			MemReady => MWReady, 
																			Reset => Reset,
																			MatrixReady => MatrixReady,
																			SPIData => SPIData, 
																			MemWrite => WEn, 
																			Draw => Draw, 
																			MemBank => MemBank, 
																			ResetAll => ResetAll,
																			Ready => Ready,
																			MemAddr => MWAddr,
																			MemData => MWData, 
																			RedLUT => RedLUT, 
																			GreenLUT => GreenLUT, 
																			BlueLUT => BlueLUT, 
																			Rows => Rows, 
																			Columns => Cols);
	
	MemCtrl		:	entity work.MemoryControllerEnt(Behavioral)	port map 	(Clk => Clk, 
																			Reset => ResetAll, 
																			WData => MWData, 
																			RData => MRData, 
																			RReady => MRReady, 
																			WReady => MWReady, 
																			RAddr => MRAddr, 
																			WAddr => MWAddr, 
																			WEn => WEn, 
																			REn => REn,
																			MemDataQ => MemData,
																			MemAddr => MemAddr, 
																			MemWEn => MemWEn, 
																			MemOEn => MemOEn);
																			
	MatrixDvr	:	entity work.MatrixDriverEnt(Behavioral)		port map	(Clk => Clk,
																			Draw => Draw, 
																			MemBank => MemBank,
																			Reset => ResetAll,
																			VLineReady => VLineReady,
																			Rows => Rows,
																			Columns => Cols,
																			AddrStart => AddrStart,
																			DrawVLine => VLineDraw,
																			Ready => MatrixReady);
																			
	VLineDvr	:	entity	work.VLineDriverEnt(Behavioral)		port map	(Clk => Clk,
																			Draw => VLineDraw,
																			Reset => ResetAll,
																			MemReady => MRReady,
																			MemAddr => MRAddr,
																			MemData => MRData,
																			MemRead => REn,
																			RedLUT => RedLUT,
																			GreenLUT => GreenLUT,
																			BlueLUT => BlueLUT,
																			VBuff => ColBuff,
																			AddrStart => AddrStart,
																			Ready => VLineReady,
																			PClk => PClk,
																			PReset => PReset,
																			Rows => Rows);
																			
	PDriver0	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(0),
																			ScreenOut => DisplayData(0),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(0));
																			
	PDriver1	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(1),
																			ScreenOut => DisplayData(1),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(1));
																			
	PDriver2	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(2),
																			ScreenOut => DisplayData(2),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(2));
																			
	PDriver3	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(3),
																			ScreenOut => DisplayData(3),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(3));
																			
	PDriver4	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(4),
																			ScreenOut => DisplayData(4),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(4));
																			
	PDriver5	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(5),
																			ScreenOut => DisplayData(5),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(5));
																			
	PDriver6	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(6),
																			ScreenOut => DisplayData(6),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(6));
																			
	PDriver7	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(7),
																			ScreenOut => DisplayData(7),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(7));			
																			
	PDriver8	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(8),
																			ScreenOut => DisplayData(8),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(8));
																			
	PDriver9	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(9),
																			ScreenOut => DisplayData(9),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(9));	
																			
																			
																			

																			
	PDriver10	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(10),
																			ScreenOut => DisplayData(10),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(10));
																			
	PDriver11	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(11),
																			ScreenOut => DisplayData(11),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(11));
																			
	PDriver12	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(12),
																			ScreenOut => DisplayData(12),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(12));
																			
	PDriver13	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(13),
																			ScreenOut => DisplayData(13),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(13));
																			
	PDriver14	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(14),
																			ScreenOut => DisplayData(14),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(14));
																			
	PDriver15	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(15),
																			ScreenOut => DisplayData(15),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(15));
																			
	PDriver16	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(16),
																			ScreenOut => DisplayData(16),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(16));
																			
	PDriver17	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(17),
																			ScreenOut => DisplayData(17),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(17));			
																			
	PDriver18	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(18),
																			ScreenOut => DisplayData(18),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(18));
																			
	PDriver19	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(19),
																			ScreenOut => DisplayData(19),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(19));	
																			
																			
																			
	PDriver20	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(20),
																			ScreenOut => DisplayData(20),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(20));
																			
	PDriver21	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(21),
																			ScreenOut => DisplayData(21),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(21));
																			
	PDriver22	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(22),
																			ScreenOut => DisplayData(22),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(22));
																			
	PDriver23	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(23),
																			ScreenOut => DisplayData(23),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(23));
																			
	PDriver24	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(24),
																			ScreenOut => DisplayData(24),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(24));
																			
	PDriver25	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(25),
																			ScreenOut => DisplayData(25),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(25));
																			
	PDriver26	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(26),
																			ScreenOut => DisplayData(26),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(26));
																			
	PDriver27	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(27),
																			ScreenOut => DisplayData(27),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(27));			
																			
	PDriver28	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(28),
																			ScreenOut => DisplayData(28),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(28));
																			
	PDriver29	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(29),
																			ScreenOut => DisplayData(29),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(29));	
																																						


	PDriver30	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(30),
																			ScreenOut => DisplayData(30),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(30));
																			
	PDriver31	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(31),
																			ScreenOut => DisplayData(31),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(31));
																			
	PDriver32	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(32),
																			ScreenOut => DisplayData(32),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(32));
																			
	PDriver33	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(33),
																			ScreenOut => DisplayData(33),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(33));
																			
	PDriver34	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(34),
																			ScreenOut => DisplayData(34),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(34));
																			
	PDriver35	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(35),
																			ScreenOut => DisplayData(35),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(35));
																			
	PDriver36	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(36),
																			ScreenOut => DisplayData(36),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(36));
																			
	PDriver37	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(37),
																			ScreenOut => DisplayData(37),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(37));			
																			
	PDriver38	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(38),
																			ScreenOut => DisplayData(38),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(38));
																			
	PDriver39	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(39),
																			ScreenOut => DisplayData(39),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(39));	
																			
																			
	PDriver40	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(40),
																			ScreenOut => DisplayData(40),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(40));
																			
	PDriver41	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(41),
																			ScreenOut => DisplayData(41),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(41));
																			
	PDriver42	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(42),
																			ScreenOut => DisplayData(42),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(42));
																			
	PDriver43	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(43),
																			ScreenOut => DisplayData(43),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(43));
																			
	PDriver44	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(44),
																			ScreenOut => DisplayData(44),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(44));
																			
	PDriver45	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(45),
																			ScreenOut => DisplayData(45),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(45));
																			
	PDriver46	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(46),
																			ScreenOut => DisplayData(46),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(46));
																			
	PDriver47	:	entity	work.PixelDriverEnt(Behavioral)		port map	(Data => ColBuff(47),
																			ScreenOut => DisplayData(47),
																			Clk => PClk,
																			Reset => PReset,
																			Enabled => VEnabled(47));			
																			

																			
end Behavioral;
	


















