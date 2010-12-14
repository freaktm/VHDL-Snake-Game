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

entity tailread_logic is
  port(
    gamelogic_state    : in  gamelogic_state_t;
    clk25              : in  std_logic;
    ext_reset          : in  std_logic;
    address_a_tailread : out unsigned(12 downto 0);
    tail_read_data     : in  unsigned(15 downto 0);
    tailread_done      : out std_logic;
    next_tail_cell     : out unsigned(12 downto 0)
    );
end tailread_logic;

architecture Behavioral of tailread_logic is

  signal checking           : std_logic;
  signal current_cell       : unsigned(12 downto 0);
  signal next_tail_cell_int : unsigned(12 downto 0);
  signal next_direction     : unsigned(2 downto 0);

  
begin
  
  next_tail_cell <= next_tail_cell_int;

  --purpose: checks what the next_direction of the tail is before it  erases a cell
  --type   : sequential

  p_tail_checker : process (clk25, ext_reset)
  begin  -- process p_collision_checker
    if (ext_reset = '1') then           --  asynchronous reset (active high)
      tailread_done      <= '0';
      next_direction     <= "001";      -- reset to moving up
      current_cell       <= to_unsigned(2600, current_cell'length);
      next_tail_cell_int <= to_unsigned(2520, next_tail_cell'length);
    elsif clk25'event and clk25 = '1' then  --     rising clock edge
      if (gamelogic_state = READTAIL)then
        if (checking = '0') then
          checking     <= '1';
          current_cell <= next_tail_cell_int;
          if (next_direction = "001") then
            next_tail_cell_int <= to_unsigned(to_integer(current_cell) - 80, next_tail_cell_int'length);
          elsif (next_direction = "010") then
            next_tail_cell_int <= to_unsigned(to_integer(current_cell) + 1, next_tail_cell_int'length);
          elsif (next_direction = "011") then
            next_tail_cell_int <= to_unsigned(to_integer(current_cell) + 80, next_tail_cell_int'length);
          elsif (next_direction = "100") then
            next_tail_cell_int <= to_unsigned(to_integer(current_cell) - 1, next_tail_cell_int'length);
          end if;
          address_a_tailread <= next_tail_cell_int;
        elsif (checking = '1') then
          checking       <= '0';
          next_direction <= tail_read_data(11 downto 9);
          tailread_done  <= '1';
        end if;
      else
        tailread_done <= '0';
        checking      <= '0';
      end if;
    end if;
  end process p_tail_checker;



end Behavioral;
