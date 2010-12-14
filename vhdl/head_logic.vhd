--------------------------------------------------------------------------------
-- Module Name:    LOGIC - behavioral
--
-- Author: Aaron Storey
-- 
-- Description: This module controls the game logic for the snake physics etc.
--              
-- 
-- 
-- Dependencies: VRAM
-- 
-- 
-- Assisted by:
--
-- Anthonix
-- 
-----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.gamelogic_pkg.all;

entity head_logic is
  port(
  gamelogic_state   : in  gamelogic_state_t;
    address_a_head : out unsigned(12 downto 0);
    head_write_data   : out unsigned(11 downto 0);
    head_done     : out std_logic;
	 next_cell : in unsigned(12 downto 0);
	 current_direction_in : in unsigned(2 downto 0)
    );
end head_logic;

architecture Behavioral of head_logic is


  signal snake_character : unsigned(8 downto 0);
 
  
begin
  
  address_a_head <= next_cell;
  
p_update_character : process (gamelogic_state, current_direction_in, snake_character)
begin
   if (gamelogic_state = HEAD) then
	if (current_direction_in = "001") or (current_direction_in = "011") then
	 snake_character <= to_unsigned(3*8, snake_character'length);
	 elsif (current_direction_in = "010") or (current_direction_in = "100") then
	 snake_character <= to_unsigned(2*8, snake_character'length);
	 end if;
	 
	head_write_data <= "0000" & current_direction_in & snake_character;
	head_done <= '1';
 else
 head_done <= '0';	
 end if;
end process p_update_character;


    end Behavioral;