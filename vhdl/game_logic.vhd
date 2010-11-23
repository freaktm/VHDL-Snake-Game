----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:58:58 11/18/2010 
-- Design Name: 
-- Module Name:    game_logic - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity game_logic is
  port( 
		 clk50 : in std_logic;
       ext_reset   : in  std_logic;
       WEA_int     : out std_logic;
       EN_int      : out std_logic;
       address_a_int : out unsigned(12 downto 0);
	    input_a_int   : out std_logic_vector(5 downto 0);
       output_a_int   : in std_logic_vector(5 downto 0)
		 );
end game_logic;

architecture Behavioral of game_logic is


signal head_cell : unsigned(12 downto 0) := "0100110001000"; -- cell 2440
signal tail_cell : unsigned(12 downto 0) := "0100110001000"; -- cell 2440 (same start location as head)
signal next_cell : unsigned(12 downto 0) := "0100100111000";  -- cell 2360
signal birth_time : unsigned(4 downto 0) := "00101"; -- 5 seconds
signal seconds : unsigned(19 downto 0);
signal head_direction : unsigned(1 downto 0) := "00"; -- moving up
signal tail_direction : unsigned(1 downto 0) := "00"; -- moving up
signal speed : unsigned(4 downto 0) := "11111"; -- slowest speed
                                      
begin




EN_int <= '1';
 

 p_cell : process (clk50, ext_reset)
  begin  -- process p_cell
    if ext_reset = '1' then               -- asynchronous reset (active low)
      head_cell <= to_unsigned(2440, head_cell'length);
		tail_cell <= to_unsigned(2440, tail_cell'length);
		birth_time <= to_unsigned(5, birth_time'length);
		seconds <= to_unsigned(0, seconds'length);
		head_direction <= to_unsigned(0, head_direction'length); -- moving up
		tail_direction <= to_unsigned(0, tail_direction'length); -- moving up
		speed <= "11111";  -- slowest speed
    elsif clk50'event and clk50 = '1' then    -- rising clock edge
                                      

-----------------------GET CURRENT CELL  --------------------------------

-----------------------GET CELL STATE   -------------------------------------------


    end if;
  end process p_cell;




end Behavioral;

