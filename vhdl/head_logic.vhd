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
    address_a_head : out unsigned(12 downto 0);
    head_write_data   : out unsigned(15 downto 0);
    head_done     : out std_logic;
	 next_cell : in unsigned(12 downto 0);
	 current_direction : in unsigned(2 downto 0)
    );
end head_logic;

architecture Behavioral of head_logic is

  signal gamelogic_state : gamelogic_state_t;
  signal snake_character : unsigned (8 downto 0);
 
  
begin
  
  address_a_head <= next_cell;
  
p_update_character : process (gamelogic_state)
begin
   if (gamelogic_state = HEAD) then
	if (current_direction = "001") or (current_direction = "011") then
	 snake_character <= to_unsigned(2*8, snake_character'length);
	 elsif (current_direction = "010") or (current_direction = "100") then
	 snake_character <= to_unsigned(3*8, snake_character'length);
	 end if;
	 
	head_write_data <= "0000" & current_direction & snake_character;
	head_done <= '1';
 else
 head_done <= '0';	
 end if;
end process p_update_character;


-- p_reset_state : process (head_state)
-- begin
--if (head_state = RESET) then
--        input_a_int  <= (others => '0');
--        ramcnt_i     := ramcnt_i + 1;
--        if (ramcnt_i = 80) then
--          ramcnt_j := ramcnt_j + 1;
--          ramcnt_i := 0;
--          if (ramcnt_j = 55) then
--            reset_done <= '1';
--            ramcnt_i   := 0;
--            ramcnt_j   := 0;
--          end if;
--       elsif (ramcnt_i > 0) and (ramcnt_i < 79) and (ramcnt_j > 0) and (ramcnt_j < 55) then
--          address_a <= to_unsigned((ramcnt_j*80) + ramcnt_i, address_a'length);
--          input_a   <= (others => '0');
--        else
--          address_a <= to_unsigned((ramcnt_j*80) + ramcnt_i, address_a'length);
--          input_a   <= to_unsigned(8, input_a'length);
--        end if;
--end if;
--end process p_reset_state;





    end Behavioral;