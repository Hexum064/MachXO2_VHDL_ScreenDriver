library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package ConstantsPkg is
	constant	IMG_BUF_SIZE	:	integer	:= 32768;
	constant	MAX_ROWS		:	integer	:= 48;
	constant	MAX_COLS		:	integer := 512;
	constant	PDRIVER_CLK_DIV	:	integer	:= 18;
end ConstantsPkg;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package ColorRegPkg is
	subtype ColorReg is std_logic_vector(7 downto 0);
	type ColorLUT is array (31 downto 0) of ColorReg;
end ColorRegPkg;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ConstantsPkg.all;

package VLineBuffPkg is
	subtype VLineReg 	is	std_logic_vector(23 downto 0);
	type	VLineBuff	is	array (MAX_ROWS downto 0)	of	VLineReg;
end VLineBuffPkg;

