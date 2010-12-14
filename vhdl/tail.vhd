--------------------------------------------------------------------------------
-- Module Name:    LOGIC - behavioral
--
-- Author: Aaron Storey
-- 
-- Description: This module controls the game logic for the snake physics etc.
--              
-- Assisted by:
--
-- Anthonix
-- 
-----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.gamelogic_pkg.all;

entity tail_logic is
  port(
    gamelogic_state : in  gamelogic_state_t;
    address_a_tail  : out unsigned(12 downto 0);
    tail_write_data : out unsigned(11 downto 0);
    tail_done       : out std_logic;
    next_cell       : in  unsigned(12 downto 0)
    );
end tail_logic;

architecture Behavioral of tail_logic is

begin
  
  address_a_tail <= next_cell;

  p_update_tail : process (gamelogic_state, next_cell)
  begin
    if (gamelogic_state = TAIL) then
      tail_write_data <= (others => '0');
      tail_done       <= '1';
    else
      tail_done <= '0';
    end if;
  end process p_update_tail;


end Behavioral;
